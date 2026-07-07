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
# Se lee de MAPA_HTML/zonas_inf2.geojson, capa derivada de los tres cinturones de
# SIG/area_regiones.geojson y de su complemento espacial. El campo `Area` ya viene
# expresado en km2. Las cuatro categorias cubren en conjunto la superficie global
# representada por la capa (~510,1 millones de km2); "Resto del mundo" (429 M km2)
# es el complemento de los tres cinturones. Los nombres de Region coinciden con
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

# Validacion con R base (sin paquetes extra): el "dispersion parameter" que summary()
# reporta al ajustar el MISMO modelo como quasi-Poisson es este mismo indice
# (suma de residuos de Pearson al cuadrado / gl residuales). Entrega 1,409584 contra
# 1,409579 del calculo manual: la misma cifra (difieren recien en el 6to decimal por
# la ruta interna de summary). performance::check_overdispersion daria lo mismo, pero
# no se agrega esa dependencia para una division de una linea.
m_qp <- glm(n ~ zona, family = quasipoisson, data = tabla_zona_anio)
summary(m_qp)$dispersion                       # 1,4096 (valida el indice manual)

# (b) Test de Cameron-Trivedi: docima formal, H0 = no hay sobredispersion (unilateral).
dispersiontest(m_tasa)                         # z = 2,149 ; p = 0,0158

# Robustez: la version por defecto contrasta la alternativa LINEAL de varianza
# (varianza = c x media, la forma del quasi-Poisson) y estima c = 1,36. Con trafo = 2
# contrasta la alternativa CUADRATICA (varianza = media + alfa x media^2), que es la
# forma de varianza de la binomial negativa que se adopta al final. Tambien rechaza:
# el veredicto de sobredispersion no depende de la forma supuesta para la alternativa.
dispersiontest(m_tasa, trafo = 2)              # z = 2,349 ; p = 0,0094 ; alfa = 0,022

# (c) Razon de verosimilitud Poisson vs binomial negativa. El parametro de dispersion
# esta en el borde del espacio parametrico (no puede ser negativo), por lo que la
# distribucion nula es una mezcla 50:50 y el p-valor se divide por dos.
m_nb  <- glm.nb(n ~ zona, data = tabla_zona_anio)
lrt   <- 2 * (as.numeric(logLik(m_nb)) - as.numeric(logLik(m_tasa)))
p_lrt <- pchisq(lrt, df = 1, lower.tail = FALSE) / 2
c(estadistico_LR = lrt, valor_p = p_lrt)       # LR = 5,63 ; p = 0,0088

# Validacion con libreria estandar (lmtest ya viene cargado por AER): lrtest()
# reproduce las log-verosimilitudes (-246,23 y -243,42) y el estadistico (5,6276),
# lo que confirma la aritmetica del calculo manual. OJO: su p = 0,0177 NO se reporta,
# porque es una funcion generica que usa la chi-cuadrado estandar y no sabe que el
# parametro de dispersion esta en la frontera; el p valido es el corregido de arriba
# (0,0088). pscl::odTest hace exactamente el mismo calculo que las lineas manuales
# (mismo estadistico y division por dos), pero no se agrega esa dependencia por esto.
lmtest::lrtest(m_tasa, m_nb)                   # valida LR = 5,6276 ; su p (0,0177) sin corregir

# Lectura del summary del modelo Poisson inicial (queda como registro del diagnostico):
# - Estimates (escala log): exp() los traduce a tasas/razones -> 34,31 ; 0,228 ; 0,071 ;
#   0,031. La binomial negativa casi no los mueve; lo que corrige es la incertidumbre.
# - Std. Error refleja el desbalance de zonas: Dorsal 0,192 (28 eventos) vs intercepto
#   0,033 (Fuego, 892 eventos). Menos datos, mas incertidumbre; se vera en los IC.
# - "Dispersion parameter taken to be 1": ASUMIDO, no estimado. Como el valor real
#   ronda 1,41, los SE de esta tabla quedan ~19 % angostos (raiz de 1,41) y sus p NO
#   se reportan; la inferencia valida sale del modelo binomial negativo.
# - Residual deviance / gl = 156,75 / 100 = 1,57: tercer indice informal de
#   sobredispersion, coherente con 1,41 (Pearson) y 1,36 (Cameron-Trivedi).
# - Caida de deviance 1.640,55 -> 156,75 con 3 gl: contraste global "la zona importa"
#   en version Poisson (inflado por la sobredispersion). El paso 2.4 lo rehace sobre
#   la binomial negativa (LR = 220): mismo veredicto, evidencia a tamanio honesto.
# - AIC 500,46 vs 496,83 de la binomial negativa: la NB gana aun pagando la multa
#   del parametro extra de varianza.
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
m_nb_dens <- glm.nb(n ~ zona + offset(log(area_km2)), data = tabla_zona_anio) # es el modelo de densidad /  n ~ zona + offset(log(area_km2)): la fórmula de siempre más el término de compensación. La función offset() dentro de la fórmula es la manera de decirle a R "incluye esta variable con coeficiente clavado en 1, no lo estimes". 


#Contrastes globales de zona (paso 2.4)----
# a los dos modelos finales la pregunta más básica de todas, la que formalmente debe venir antes de mirar cualquier comparación individual: ¿aporta algo la zona, en conjunto? 
# Un modelo nulo es el modelo rival que representa "la zona no importa". El contraste global compara qué tan bien explican los datos el modelo con zonas y el modelo sin zonas.
# Cada modelo final se compara con su modelo nulo. En el modelo de densidad se
# conserva el offset en ambos ajustes, de modo que la docima evalua exclusivamente
# si la zona aporta informacion adicional. El estadistico es una razon de
# verosimilitudes con 3 grados de libertad.
m_nb_nulo <- glm.nb(n ~ 1, data = tabla_zona_anio)  #m_nb_nulo <- glm.nb(n ~ 1, ...): la fórmula ~ 1 significa "solo intercepto": una única tasa común para las 104 celdas zona-año, como si el planeta fuera homogéneo. Su exp(intercepto) sería simplemente el conteo promedio por celda (1.186 / 104 = 11,4 eventos). Es el rival del modelo de tasa anual.
m_nb_dens_nulo <- glm.nb(n ~ offset(log(area_km2)), data = tabla_zona_anio)   #el rival del modelo de densidad. Este nulo dice "una única densidad común para todo el planeta" (cada zona espera eventos en proporción a su superficie, nada más). 

prueba_global <- tibble(
  modelo = c("Tasa anual bruta", "Densidad por superficie"),
  estadistico_LR = c(
    2 * (as.numeric(logLik(m_nb)) - as.numeric(logLik(m_nb_nulo))),
    2 * (as.numeric(logLik(m_nb_dens)) - as.numeric(logLik(m_nb_dens_nulo)))
  ),
  gl = 3L
) %>%
  mutate(valor_p = pchisq(estadistico_LR, df = gl, lower.tail = FALSE))

prueba_global

# Validacion con librerias estandar: lmtest::lrtest y anova() de MASS reproducen
# ambos estadisticos (220,374 y 225,851). Aqui NO corresponde dividir el p por dos:
# los coeficientes de zona son parametros interiores (no estan en frontera), asi que
# la chi-cuadrado con 3 gl es la distribucion correcta y el p de lrtest vale.
# El anova() de MASS ademas muestra los theta: 0,577 en el nulo vs 42,35 con zona.
# Theta chico = MAS sobredispersion (Var = mu + mu^2/theta, theta divide): el nulo
# absorbe como varianza extra las diferencias entre zonas que no puede explicar.
# OJO: car::Anova(m_nb) y drop1(m_nb, test = "Chisq") reportan 1.156,9 en vez de
# 220,4 porque reajustan el nulo con theta FIJO en el del modelo completo (42,35);
# contrastan otra pregunta y NO se usan para esta docima.
lmtest::lrtest(m_nb_nulo, m_nb)                # valida LR = 220,374 (tasa anual)
lmtest::lrtest(m_nb_dens_nulo, m_nb_dens)      # valida LR = 225,851 (densidad)

# Los dos modelos "completos" tienen la misma log-verosimilitud. las dos dicen -243,42. No es coincidencia ni redondeo: el modelo de tasa (n ~ zona) y el de densidad (n ~ zona + offset) ajustan exactamente igual a los datos.
# ¿Por qué? Porque cada zona tiene una única superficie: sabiendo la zona, el área ya está determinada. Entonces, cuando el modelo ya incluye la zona, el offset no aporta información nueva para predecir; lo único que hace es reacomodar la contabilidad interna. (tasas → densidades) sin cambiar las predicciones ni el ajuste.

# CONCLUSION (paso 2.4): el contraste global responde formalmente la pregunta central
# de la seccion: las cuatro zonas no comparten una misma tasa de ocurrencia
# (LR = 220,4) ni una misma densidad por superficie (LR = 225,9), ambos con 3 gl y
# p < 0,001. Convierte la diferencia descrita en el Informe 1 en una afirmacion
# inferencial y habilita los analisis siguientes: las razones de tasa contra el
# Cinturon de Fuego (2.5) y los seis pares con ajuste de Holm (2.6) detallan una
# diferencia cuya existencia ya quedo establecida con una sola docima.


#Razones de tasa con IC 95 % (paso 2.5)----
# exp() lleva los coeficientes a la escala de razones de tasa. Cada fila compara una
# zona con el Cinturon de Fuego (referencia). El intercepto es la tasa base de Fuego.
rr_tasa <- exp(cbind(RR = coef(m_nb), confint(m_nb)))
rr_tasa

rr_dens <- exp(cbind(RR = coef(m_nb_dens), confint(m_nb_dens)))
rr_dens

# Nota metodologica: el mensaje "Waiting for profiling to be done..." indica que
# confint() sobre glm.nb usa verosimilitud PERFILADA (metodo de MASS), no la formula
# rapida de Wald (estimacion +/- 1,96 SE). El perfil no asume simetria y es mejor
# con zonas de pocos eventos (Dorsal, 28). Comparados aqui, Wald y perfil difieren
# recien en la 3ra cifra (Dorsal: [0,0214; 0,0462] vs [0,0209; 0,0452]): ninguna
# conclusion depende del metodo de intervalo, robustez que puede citarse en el anexo.
# Validacion con libreria: broom::tidy(m_nb, exponentiate = TRUE, conf.int = TRUE)
# reproduce exactamente RR e IC de perfil, y sus p de Wald (3,4e-83; 2,2e-69;
# 1,5e-62) son los tres primeros p crudos de pares_tasa del paso 2.6 (los
# coeficientes SON las comparaciones contra la referencia). OJO: en esa salida
# std.error queda en escala log aunque estimate este exponenciado.
broom::tidy(m_nb, exponentiate = TRUE, conf.int = TRUE)   # valida RR e IC de perfil
broom::tidy(m_nb_dens, exponentiate = TRUE, conf.int = TRUE)

# CONCLUSION (paso 2.5): si el 2.4 dijo "las zonas difieren", el 2.5 midio cuanto y
# con que precision. Tamanios de efecto con IC 95 % de perfil (modelo binomial
# negativo): Resto opera al 22,8 % de la tasa de Fuego [0,191; 0,270], Alpino al
# 7,1 % [0,053; 0,092] y Dorsal al 3,1 % [0,021; 0,045]; leido al reves, Fuego las
# multiplica por 4,4 / 14,2 / 31,9. En densidad el orden se invierte y Resto cae al
# ultimo lugar: 2,5 % de Fuego por km2 [0,021; 0,030]. Los seis intervalos excluyen
# el 1: las cifras descriptivas del Informe 1 (34,3/7,8/2,4/1,1) pasan a afirmacion
# inferencial con magnitud e incertidumbre. El IC mas ancho en terminos relativos es
# el de la Dorsal (28 eventos): el desbalance del catalogo queda documentado.


#Comparaciones por pares con ajuste de Holm (paso 2.6)----
# Se comparan las seis parejas posibles. La razon de tasa es el tamanio de efecto:
# 1 indica igualdad; valores mayores que 1 favorecen a la primera zona del rotulo y
# valores menores que 1, a la segunda. Los valores p de Wald se ajustan por separado
# dentro de cada familia de seis contrastes mediante Holm, con error familiar 0,05.
contrastes_pares_nb <- function(modelo, datos) {
  zonas <- levels(datos$zona)
  diseno <- model.matrix(
    ~ zona,
    data = data.frame(zona = factor(zonas, levels = zonas))
  )
  rownames(diseno) <- zonas

  pares <- combn(zonas, 2, simplify = FALSE)

  resultados <- lapply(pares, function(par) {
    contraste <- diseno[par[1], ] - diseno[par[2], ]
    estimacion <- sum(contraste * coef(modelo))
    error_estandar <- sqrt(
      drop(t(contraste) %*% vcov(modelo) %*% contraste)
    )
    estadistico_z <- estimacion / error_estandar

    tibble(
      zona_1 = par[1],
      zona_2 = par[2],
      razon_tasa = exp(estimacion),
      ic_95_inferior = exp(estimacion - qnorm(0.975) * error_estandar),
      ic_95_superior = exp(estimacion + qnorm(0.975) * error_estandar),
      estadistico_z = estadistico_z,
      valor_p = 2 * pnorm(-abs(estadistico_z))
    )
  })

  bind_rows(resultados) %>%
    mutate(valor_p_ajustado_holm = p.adjust(valor_p, method = "holm"))
}

pares_tasa <- contrastes_pares_nb(m_nb, tabla_zona_anio)
pares_dens <- contrastes_pares_nb(m_nb_dens, tabla_zona_anio)

pares_tasa
pares_dens

# Validacion con las librerias canonicas de post-hoc (ambas ya instaladas):
# multcomp::glht con contrastes de Tukey reproduce estimaciones en log, SE, z y p
# de Holm identicos (Dorsal-Alpino: p ajustado 0,00045, igual que la funcion manual);
# sus rotulos van al reves ("Alpino - Fuego"), asi que los signos se invierten.
# emmeans entrega lo mismo con las razones ya exponenciadas (type = "response").
# Lo unico que las librerias agregan: intervalos SIMULTANEOS (ajustados por la
# familia de 6); los IC de la tabla manual son individuales al 95 % y solo los p
# llevan ajuste. Con estas magnitudes no cambia ninguna conclusion, pero la
# redaccion debe decir "intervalos individuales".
summary(multcomp::glht(m_nb, linfct = multcomp::mcp(zona = "Tukey")),
        test = multcomp::adjusted("holm"))     # valida z y p de Holm (tasa anual)

summary(multcomp::glht(m_nb_dens, linfct = multcomp::mcp(zona = "Tukey")),
        test = multcomp::adjusted("holm")) 

# CONCLUSION (paso 2.6): las 6 comparaciones por pares son significativas tras Holm
# en AMBAS metricas (p ajustado maximo: 0,00045, Alpino-Dorsal en tasa). Eso
# establece inferencialmente los rankings completos, escalon por escalon:
# tasa anual  Fuego > Resto > Alpino > Dorsal ; densidad  Fuego > Alpino > Dorsal >
# Resto. El reordenamiento de "Resto del mundo" (2do por conteo, ultimo por km2) es
# por tanto un resultado inferencial, no solo descriptivo. El par mas apretado
# (Alpino duplica a la Dorsal en tasa: 2,25 [1,43; 3,54]) resiste el ajuste: hasta
# el eslabon mas debil del ranking esta respaldado.


#Tabla puente con el Informe 1 (paso 2.7)----
# Muestra lado a lado la tasa anual bruta (reproduce 34,3/7,8/2,4/1,1) y la densidad
# por millon de km2. El contraste es el hallazgo de la seccion: por conteo bruto el
# orden es Fuego > Resto > Alpino > Dorsal, pero por densidad "Resto del mundo" cae al
# ultimo lugar. La normalizacion evita interpretar el segundo lugar de esta categoria
# residual como una actividad alta por unidad de superficie. Responde de frente la
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
# Por conteo bruto "Resto del mundo" ocupa el segundo lugar, pero por densidad cae
# al ultimo. La interpretacion queda condicionada a la delimitacion adoptada.


#Figura de la seccion: tasa anual vs densidad por zona----
# Misma paleta y etiquetas del Informe 1 para mantener la identidad visual. Cada panel
# se ordena por su propia metrica y el color se mantiene por zona, de modo que el
# reordenamiento sea visible: "Resto del mundo" pasa del 2do lugar (tasa) al ultimo
# (densidad). Se exporta a la carpeta de imagenes que consume el .qmd del Informe 2.

colores_zona <- c(
  "Cinturon de Fuego"        = "#e31a1c",
  "Cinturon Alpino-Himalayo" = "#47cea8",
  "Dorsal Meso-Atlantica"    = "#dfbf8a",
  "Resto del mundo"          = "#9e9e9e"
)
etiquetas_zona <- c(
  "Cinturon de Fuego"        = "C. Fuego",
  "Cinturon Alpino-Himalayo" = "C. Alpino-H.",
  "Dorsal Meso-Atlantica"    = "Dorsal M.-Atl.",
  "Resto del mundo"          = "Resto"
)

ruta_fig <- file.path("Informes Quarto", "Imágenes y Recursos",
                      "inf2-frecuencia-tasa-densidad.png")

# La figura se abre directamente en un dispositivo PNG para que la ejecucion por
# Rscript sea reproducible y no cree archivos graficos auxiliares.
png(filename = ruta_fig, width = 2200, height = 1000, res = 200, bg = "white")  # saltarse png()/dev.off() cuando quiera ver el gráfico en PLOTS
par(mfrow = c(1, 2), bg = "white", oma = c(0, 0, 3, 0),
    mar = c(6.2, 4.5, 3, 1.5) + 0.1)

# Panel izquierdo: tasa anual bruta
d1 <- puente[order(-puente$tasa_anual), ]
rotulos_d1 <- unname(etiquetas_zona[match(as.character(d1$zona), names(etiquetas_zona))])
stopifnot(!anyNA(rotulos_d1))
b1 <- barplot(d1$tasa_anual,
              names.arg = rotulos_d1,
              col = colores_zona[as.character(d1$zona)], border = "gray30",
              las = 1, ylim = c(0, max(d1$tasa_anual) * 1.15),
              cex.names = 0.78,
              main = "Tasa anual", ylab = "Eventos por año")
text(b1, d1$tasa_anual, labels = format(round(d1$tasa_anual, 1), decimal.mark = ","),
     pos = 3, cex = 0.85)
box()

# Panel derecho: densidad por millon de km2
d2 <- puente[order(-puente$densidad_Mkm2_anual), ]
rotulos_d2 <- unname(etiquetas_zona[match(as.character(d2$zona), names(etiquetas_zona))])
stopifnot(!anyNA(rotulos_d2))
b2 <- barplot(d2$densidad_Mkm2_anual,
              names.arg = rotulos_d2,
              col = colores_zona[as.character(d2$zona)], border = "gray30",
              las = 1, ylim = c(0, max(d2$densidad_Mkm2_anual) * 1.15),
              cex.names = 0.78,
              main = "Densidad por superficie",
              ylab = "Eventos por millón de km2 y año")
text(b2, d2$densidad_Mkm2_anual, labels = format(round(d2$densidad_Mkm2_anual, 3), decimal.mark = ","),
     pos = 3, cex = 0.85)
box()

mtext("Frecuencia por zona: el orden cambia al controlar la superficie",
      side = 3, outer = TRUE, line = 0.5, font = 2, cex = 1.05)

dev.off()             # saltarse png()/dev.off() cuando quiera ver el gráfico en PLOTS


#Figura de bosque: razones con IC 95 % en escala logaritmica----
# Complementa a la figura de barras. Las barras muestran la MAGNITUD (tasa/densidad);
# el bosque muestra el TAMANIO DE EFECTO y su INCERTIDUMBRE: cada punto es la razon
# frente al Cinturon de Fuego (referencia = linea vertical en 1) y el segmento su IC 95 %
# de perfil. En escala log, un IC alejado de 1 y angosto indica un efecto grande y preciso;
# el IC mas ancho es el de la Dorsal (28 eventos), que documenta el desbalance del catalogo.
# Reutiliza rr_tasa y rr_dens ya calculados en el paso 2.5 (matrices con RR, 2.5 %, 97.5 %).

prep_bosque <- function(rr) {
  rr <- rr[rownames(rr) != "(Intercept)", , drop = FALSE]  # se excluye Fuego (referencia)
  data.frame(term = rownames(rr), rr = rr[, 1], lo = rr[, 2], hi = rr[, 3],
             stringsAsFactors = FALSE)
}

etiquetas_bosque <- c(
  "zonaCinturon Alpino-Himalayo" = "C. Alpino-H.",
  "zonaDorsal Meso-Atlantica"    = "Dorsal M.-Atl.",
  "zonaResto del mundo"          = "Resto"
)
colores_bosque <- c(
  "zonaCinturon Alpino-Himalayo" = "#47cea8",
  "zonaDorsal Meso-Atlantica"    = "#dfbf8a",
  "zonaResto del mundo"          = "#9e9e9e"
)

ruta_forest <- file.path("Informes Quarto", "Imágenes y Recursos",
                         "inf2-frecuencia-forest.png")

png(filename = ruta_forest, width = 2200, height = 1000, res = 200, bg = "white")
par(mfrow = c(1, 2), bg = "white", oma = c(0, 0, 3, 0),
    mar = c(4.5, 7.2, 3, 1.5) + 0.1)

panel_bosque <- function(d, titulo) {
  d <- d[order(d$rr), ]                       # menor razon abajo, mayor arriba
  n <- nrow(d)
  xlim <- range(c(d$lo, d$hi, 1))
  plot(NA, xlim = xlim, ylim = c(0.5, n + 0.5), log = "x", yaxt = "n",
       xlab = "Razón (IC 95 %, escala log)", ylab = "", main = titulo, las = 1)
  abline(v = 1, col = "gray50", lty = 2)
  segments(d$lo, seq_len(n), d$hi, seq_len(n),
           col = colores_bosque[d$term], lwd = 2.5)
  points(d$rr, seq_len(n), pch = 19, col = colores_bosque[d$term], cex = 1.4)
  axis(2, at = seq_len(n), labels = etiquetas_bosque[d$term], las = 1, cex.axis = 0.9)
}

panel_bosque(prep_bosque(rr_tasa), "Tasa anual")
panel_bosque(prep_bosque(rr_dens), "Densidad por superficie")
mtext("Razones frente al Cinturón de Fuego (referencia = 1). El orden de Resto se invierte",
      side = 3, outer = TRUE, line = 0.5, font = 2, cex = 1.05)

dev.off()
