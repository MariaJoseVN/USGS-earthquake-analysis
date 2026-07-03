# 07 - Frecuencia de eventos entre zonas (Informe Asesoria 2)----
#
# Fase 2 del checklist | Seccion 7.2 del informe | Checkpoint C2 (COMPUERTA DURA)
# Objetivo: comparar formalmente la frecuencia entre zonas mediante un modelo de
# conteo. La normalizacion por superficie (offset) entra como sensibilidad, no
# como prerrequisito: el modelo de tasa anual (sin offset) es el analisis principal.
#
# Paquetes: dplyr, tidyr, sf (superficies), AER (dispersiontest), MASS (glm.nb).


# Cargar la base si no esta disponible (ruta rapida de desarrollo).
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

library(sf)
library(dplyr)
# library(tidyr)
# library(AER)
# library(MASS)

# Superficie por zona (paso 0.2)----
# Se lee directo de MAPA_HTML/zonas_inf2.geojson, donde el campo `Area` ya viene
# en km2. Las cuatro zonas tilean el planeta (suma ~510,1 millones km2 = superficie
# terrestre total), por lo que "Resto del mundo" (429 M km2) es el complemento real
# de los tres cinturones y su area SI corresponde a los eventos etiquetados asi.
# Los nombres de Region coinciden con sismos$zona, por lo que el join es directo.

superficie_zona <- st_read(file.path("MAPA_HTML", "zonas_inf2.geojson"), quiet = TRUE) %>%
  st_drop_geometry() %>%
  dplyr::select(zona = Region, area_km2 = Area)

superficie_zona

# Pasos previstos:
# 0.3 Tabla zona-anio con tidyr::complete() -> 26 x 4 = 104 filas, ceros incluidos.
#     Unir superficie_zona por `zona` para disponer de area_km2 en cada fila.
# 2.1 GLM Poisson: glm(n ~ zona, family = poisson) como principal (tasa anual).
# 2.2 Sobredispersion por tres vias: dispersion de Pearson, AER::dispersiontest,
#     razon de verosimilitud vs MASS::glm.nb (dividir el p-valor por dos).
# 2.3 Decidir Poisson vs binomial negativa y documentarlo.
# 2.4 Razones de tasa exp(coef) con IC 95 % (confint) por zona vs Cinturon de Fuego.
# 2.5 Tabla puente con el Informe 1: tasa anual bruta (34,3/7,8/2,4/1,1) junto a
#     la tasa por km2 (offset). Con las cuatro zonas consistentes, "Resto del mundo"
#     ya puede entrar en el modelo de densidad, no solo en el de tasa bruta.

message("07_inf_frecuencia.R: stub pendiente de implementacion (Fase 2 / C2).")

library(tidyr)
library(AER)
library(MASS)

# 0.3 Tabla de conteos zona-año (rellena con 0 los años sin eventos)----
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
nrow(tabla_zona_anio)                    # debe dar 104 (4 zonas x 26 años)
sum(tabla_zona_anio$n)                   # debe dar 1186
any(is.na(tabla_zona_anio$area_km2))     # debe dar FALSE (join completo)

# 2.1 Modelos de conteo----
# Principal: tasa anual (comparable con el Informe 1)
m_tasa <- glm(n ~ zona, family = poisson, data = tabla_zona_anio)

# Densidad: controla el tamaño de cada zona (offset de superficie)
m_dens <- glm(n ~ zona, family = poisson, offset = log(area_km2),
              data = tabla_zona_anio)

# 2.2 Diagnóstico de sobredispersión (sobre el modelo de tasa)----
# (a) Dispersión de Pearson: cerca de 1 = sin sobredispersión
disp_pearson <- sum(residuals(m_tasa, "pearson")^2) / df.residual(m_tasa)
disp_pearson

# (b) Test de Cameron-Trivedi
dispersiontest(m_tasa)

# (c) Binomial negativa + razón de verosimilitud (p se divide por dos)
m_nb <- glm.nb(n ~ zona, data = tabla_zona_anio)
lrt   <- 2 * (as.numeric(logLik(m_nb)) - as.numeric(logLik(m_tasa)))
p_lrt <- pchisq(lrt, df = 1, lower.tail = FALSE) / 2
c(estadistico_LR = lrt, valor_p = p_lrt)

summary(m_tasa)
