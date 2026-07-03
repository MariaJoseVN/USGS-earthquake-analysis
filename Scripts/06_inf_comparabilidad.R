# 06 - Comparabilidad del registro (Informe Asesoria 2)----
#
# Fase 1 del checklist | Seccion 7.1 del informe | Checkpoint C1
# Objetivo: verificar si las comparaciones inferenciales podrian estar
# condicionadas por la estructura de reporte (magType, magSource, rms), antes
# de interpretar las secciones confirmatorias. Bloque exploratorio con FDR.
#
# Paquetes: dplyr, rcompanion (cramerV). chisq/kruskal/p.adjust son base.


# Cargar la base si no esta disponible (ruta rapida de desarrollo).
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# library(dplyr)
# library(rcompanion)

# Pasos previstos:
# 1.1 Tabla zona x magType_grupo + chi-cuadrado (simulate.p.value = TRUE, B = 10000
#     si hay esperados < 5).
# 1.2 Tabla zona x magSource (agrupar fuentes minoritarias) + mismo contraste.
# 1.3 Kruskal-Wallis de rms_imp entre zonas y entre periodos.
# 1.4 magType_grupo por periodo (formaliza la transicion hacia mww).
# 1.5 Reunir p-valores y ajustar con p.adjust(p, method = "BH"). Reportar crudos y ajustados.
# 1.6 Veredicto: las comparaciones siguientes estan o no condicionadas por el reporte.

message("06_inf_comparabilidad.R: stub pendiente de implementacion (Fase 1 / C1).")
