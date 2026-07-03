# 08 - Magnitud y profundidad entre zonas (Informe Asesoria 2)----
#
# Fase 3 del checklist | Seccion 7.3 del informe | Checkpoints C3 (COMPUERTA DURA) y C4
# Objetivo: contrastar las distribuciones de magnitud y profundidad entre zonas.
# Primero los supuestos multivariantes (propuesta rescatada del Informe 1); su
# resultado define la ruta parametrica o no parametrica.
#
# Paquetes: MVN, heplots (boxM), psych (cortest.bartlett), FSA (dunnTest),
#           rcompanion (epsilonSquared), effsize (cliff.delta), boot o base para IC.


# Cargar la base si no esta disponible (ruta rapida de desarrollo).
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# library(MVN)
# library(heplots)
# library(psych)
# library(FSA)
# library(rcompanion)
# library(effsize)

# Bloque A - Supuestos (alfa = 0,10 + graficos). ANTES de correr el bloque B (C3):
# 3.1 Mardia por zona: MVN::mvn(datos[,c("mag","depth")], subset="zona", mvnTest="mardia").
# 3.2 QQ chi-cuadrado de distancias de Mahalanobis por zona y QQ univariados.
# 3.3 M-Box: heplots::boxM(cbind(mag,depth) ~ zona). Interpretar junto a Mardia.
# 3.4 Bartlett: psych::cortest.bartlett() sobre la matriz de correlaciones.
# 3.5 Declarar la ruta (se espera rechazo de normalidad -> ruta no parametrica).
#
# Bloque B - Contrastes (C4):
# 3.6 kruskal.test(mag ~ zona) y kruskal.test(depth ~ zona) + epsilon cuadrado.
# 3.7 FSA::dunnTest(..., method = "holm") -> 6 pares por variable, Z, p crudo y ajustado.
# 3.8 effsize::cliff.delta() para Fuego-Dorsal y Fuego-Alpino en ambas variables.
# 3.9 IC bootstrap (R = 10.000) para la mediana de mag y depth por zona.

message("08_inf_magnitud_profundidad.R: stub pendiente de implementacion (Fase 3 / C3-C4).")
