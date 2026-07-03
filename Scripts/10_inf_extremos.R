# 10 - Eventos fuertes y extremos (Informe Asesoria 2)----
#
# Fase 5 del checklist | Seccion 7.5 del informe | Checkpoint C6
# Objetivo: analizar los eventos fuertes usando las categorias del Informe 1
# ("Mayor" M >= 7,0; "Grande o extremo" M >= 7,8), mediante tabla de contingencia
# y regresion logistica.
#
# Paquetes: dplyr, rcompanion (cramerV). chisq y glm binomial son base.


# Cargar la base si no esta disponible (ruta rapida de desarrollo).
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# library(dplyr)
# library(rcompanion)

# Pasos previstos:
# 5.1 Tabla zona x magnitud_cat con observados y esperados. chisq.test con
#     simulate.p.value = TRUE, B = 10000. V de Cramer con correccion de sesgo.
# 5.2 evento_mayor = (mag >= 7.0). glm(evento_mayor ~ zona + depth, family = binomial).
#     LR por variable (drop1, test = "Chisq"), odds ratios con IC 95 % (exp(confint)).
# 5.3 Comparar depth continua vs profundidad_cat por AIC; elegir y justificar.
# 5.4 M >= 7,8: solo conteos por zona y tasa anual, sin modelo (muestra insuficiente
#     en zonas menores).

message("10_inf_extremos.R: stub pendiente de implementacion (Fase 5 / C6).")
