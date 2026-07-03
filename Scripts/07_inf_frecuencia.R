# 07 - Frecuencia de eventos entre zonas (Informe Asesoria 2)----
#
# Fase 2 del checklist | Seccion 7.2 del informe | Checkpoint C2
#
# Pregunta: la frecuencia de terremotos difiere entre zonas? La frecuencia es un
# CONTEO (eventos por zona y anio), por lo que el modelo natural es un GLM de
# conteo (Poisson y su extension binomial negativa), no una comparacion de medias.
#
# Se estiman dos miradas complementarias:
#   - Tasa anual  : eventos por anio  -> comparable con el Informe 1 (34,3/7,8/2,4/1,1).
#   - Densidad    : eventos por km2   -> controla el tamanio de cada zona (offset de area).
#
# Paquetes: sf (superficies), dplyr, tidyr, AER (dispersiontest), MASS (glm.nb).


#Paquetes----
# dplyr::select se califica de forma explicita porque MASS tambien exporta select()
# y, segun el orden de carga, puede enmascarar la de dplyr.
library(sf)
library(dplyr)
library(tidyr)
library(AER)
library(MASS)


#Cargar la base si no esta disponible (ruta rapida de desarrollo)----
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}


#Superficie por zona (paso 0.2)----
# Se lee de MAPA_HTML/zonas_inf2.geojson, donde el campo `Area` ya viene en km2.
# Las cuatro zonas tilean el planeta (suma ~510,1 millones km2 = superficie terrestre
# total), por lo que "Resto del mundo" (429 M km2) es el complemento real de los tres
# cinturones: su area SI corresponde a los eventos etiquetados asi, y por eso puede
# entrar tambien en el modelo de densidad. Los nombres de Region coinciden con
# sismos$zona, de modo que el join posterior es directo.

superficie_zona <- st_read(file.path("MAPA_HTML", "zonas_inf2.geojson"), quiet = TRUE) %>%
  st_drop_geometry() %>%
  dplyr::select(zona = Region, area_km2 = Area)

superficie_zona


#Tabla de conteos zona-anio (paso 0.3)----
# Unidad de observacion: una zona en un anio. Cada fila es un conteo `n`.
# complete() crea las 104 combinaciones (4 zonas x 26 anios) y rellena con 0 los
# anios sin eventos: un anio sin sismos es un cero observado, no un dato faltante.
# Omitir esos ceros sobreestimaria la tasa de las zonas de baja actividad (Dorsal).
# relevel() fija al Cinturon de Fuego como categoria de referencia: asi cada
# coeficiente del modelo se lee como "esta zona respecto al Cinturon de Fuego".

tabla_zona_anio <- sismos %>%
  count(zona, año, name = "n") %>%
  complete(
    zona = superficie_zona$zona,   # las 4 zonas, garantizado
    año = 2000:2025,
    fill = list(n = 0)
  ) %>%
  left_join(superficie_zona, by = "zona") %>%
  mutate(zona = relevel(factor(zona), ref = "Cinturon de Fuego"))

# Verificaciones antes de modelar
nrow(tabla_zona_anio)                    # 104 (4 zonas x 26 anios)
sum(tabla_zona_anio$n)                   # 1186 (total del catalogo)
any(is.na(tabla_zona_anio$area_km2))     # FALSE (join completo, sin zonas sin area)


#Modelo Poisson inicial (paso 2.1)----
# GLM Poisson con enlace log (el que trae por defecto). Con enlace log, exp() de un
# coeficiente es una razon de tasas: exp(intercepto) = tasa anual del Cinturon de
# Fuego (~34,3), y exp(coef de otra zona) = su tasa relativa a Fuego. Este modelo es
# el punto de partida y la referencia para diagnosticar el supuesto de la Poisson.

m_tasa <- glm(n ~ zona, family = poisson, data = tabla_zona_anio)


#Diagnostico de sobredispersion (paso 2.2)----
# La Poisson supone varianza = media. Si la varianza es mayor (sobredispersion),
# los errores estandar quedan subestimados y la significancia se infla. Se evalua
# por tres vias convergentes; nivel alfa = 0,05.

# (a) Dispersion de Pearson: descriptivo. Cerca de 1 = sin sobredispersion.
disp_pearson <- sum(residuals(m_tasa, "pearson")^2) / df.residual(m_tasa)
disp_pearson                                   # 1,41

# (b) Test de Cameron-Trivedi: docima formal, H0 = no hay sobredispersion (unilateral).
dispersiontest(m_tasa)                         # z = 2,149 ; p = 0,0158

# (c) Razon de verosimilitud Poisson vs binomial negativa. El parametro de dispersion
# esta en el borde del espacio parametrico (no puede ser negativo), por lo que la
# distribucion nula es una mezcla 50:50 y el p-valor se divide por dos.
m_nb  <- glm.nb(n ~ zona, data = tabla_zona_anio)
lrt   <- 2 * (as.numeric(logLik(m_nb)) - as.numeric(logLik(m_tasa)))
p_lrt <- pchisq(lrt, df = 1, lower.tail = FALSE) / 2
c(estadistico_LR = lrt, valor_p = p_lrt)       # LR = 5,63 ; p = 0,0088

summary(m_tasa)


#Decision de modelo (paso 2.3)----
# Las tres vias coinciden: hay sobredispersion, leve pero consistente
# (Pearson 1,41 ; dispersion 1,36 ; deviance/gl = 1,57). El modelo FINAL es binomial
# negativa, que agrega un parametro de varianza extra y devuelve intervalos de
# confianza a su tamanio honesto. Los puntos estimados casi no cambian respecto a la
# Poisson; lo que se corrige es la amplitud de los intervalos.

# Modelo de tasa anual (final): m_nb, ya ajustado arriba.
# Modelo de densidad (final): binomial negativa con offset de superficie.
# El offset = log(area_km2) fija un termino con coeficiente 1, equivalente a modelar
# eventos por km2 en lugar de eventos a secas: controla el tamanio de cada zona.
m_nb_dens <- glm.nb(n ~ zona + offset(log(area_km2)), data = tabla_zona_anio)


#Razones de tasa con IC 95 % (paso 2.4)----
# exp() lleva los coeficientes a la escala de razones de tasa. Cada fila compara una
# zona con el Cinturon de Fuego (referencia). El intercepto es la tasa base de Fuego.
rr_tasa <- exp(cbind(RR = coef(m_nb), confint(m_nb)))
rr_tasa

rr_dens <- exp(cbind(RR = coef(m_nb_dens), confint(m_nb_dens)))
rr_dens


#Tabla puente con el Informe 1 (paso 2.5)----
# Muestra lado a lado la tasa anual bruta (reproduce 34,3/7,8/2,4/1,1) y la densidad
# por millon de km2. El contraste es el hallazgo de la seccion: por conteo bruto el
# orden es Fuego > Resto > Alpino > Dorsal, pero por densidad "Resto del mundo" cae al
# ultimo lugar (parece activo solo por su enorme superficie). Responde de frente la
# heterogeneidad de tamanios de zona senalada en la revision docente.
puente <- tabla_zona_anio %>%
  group_by(zona) %>%
  summarise(
    eventos  = sum(n),
    area_km2 = dplyr::first(area_km2),
    .groups  = "drop"
  ) %>%
  mutate(
    area_Mkm2           = area_km2 / 1e6,          # superficie en millones de km2 (legible)
    tasa_anual          = eventos / 26,            # 26 anios observados (2000-2025)
    densidad_Mkm2_anual = eventos / area_Mkm2 / 26
  ) %>%
  arrange(desc(tasa_anual)) %>%
  dplyr::select(zona, eventos, area_Mkm2, tasa_anual, densidad_Mkm2_anual)
puente
#Se confirmó el hallazgo: por conteo bruto "Resto del mundo" va 2º, pero por densidad cae al último lugar. 
# Es activo solo porque es enorme; por km² es el menos activo de todos.