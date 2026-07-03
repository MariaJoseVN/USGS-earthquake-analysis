# 11 - Sintesis: clasificacion de zonas (Informe Asesoria 2)----
#
# Fase 6 del checklist | Seccion 7.6 del informe | Checkpoint C7 (COMPUERTA DURA, el clave)
# Objetivo: responder la segunda componente de la pregunta estadistica. Integrar
# magnitud y profundidad para clasificar la zona del evento. Es la culminacion
# del informe y donde vive el riesgo de separacion por la Dorsal (n = 28):
# conviene prototipar la multinomial temprano para detectarlo antes de C7.
#
# Paquetes: ppcor (pcor), FactoMineR o ca (correspondencia), nnet (multinom),
#           brglm2 (brmultinom, correccion de Firth), car (Anova por LR).


# Cargar la base si no esta disponible (ruta rapida de desarrollo).
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# library(ppcor)
# library(FactoMineR)
# library(nnet)
# library(brglm2)
# library(car)

# Pasos previstos:
# 6.1 Correlaciones parciales de Spearman entre mag, depth y sig (ppcor::pcor).
#     Lectura clave: depth con sig controlando mag (sig deriva de mag).
# 6.2 Analisis de correspondencia sobre zona x magnitud_cat y zona x profundidad_cat.
#     Reportar inercia total, % por dimension y biplot.
# 6.3 Multinomial: nnet::multinom(zona ~ mag + depth), referencia Cinturon de Fuego.
#     Significacion por variable con car::Anova (razon de verosimilitud, no Wald).
# 6.4 Revisar separacion (|coef| > 10 o EE gigantes); si aparece, brglm2::brmultinom
#     (Firth) y declararlo. Se espera en la Dorsal: hallazgo, no fracaso.
# 6.5 Matriz de confusion + exactitud global, exactitud balanceada y sensibilidad
#     por clase. Comparar SIEMPRE contra la base trivial del 75,21 %.
# 6.6 Opcional: validacion cruzada de 10 pliegues para las metricas.
# 6.7 Comparar zona ~ mag + depth vs zona ~ mag y zona ~ depth (AIC y LR):
#     cuantifica el aporte conjunto de las variables.

message("11_inf_clasificacion.R: stub pendiente de implementacion (Fase 6 / C7).")
