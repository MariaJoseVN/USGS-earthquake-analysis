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

# library(dplyr)
# library(tidyr)
# library(sf)
# library(AER)
# library(MASS)

# Pasos previstos:
# 0.3 Tabla zona-anio con tidyr::complete() -> 26 x 4 = 104 filas, ceros incluidos.
# 0.2 Superficie por zona (km2) desde SIG/area_regiones.geojson en proyeccion de
#     igual area o st_area() con s2. "Resto del mundo" = total de referencia - suma zonas.
# 2.1 GLM Poisson: glm(n ~ zona, family = poisson) como principal (tasa anual).
# 2.2 Sobredispersion por tres vias: dispersion de Pearson, AER::dispersiontest,
#     razon de verosimilitud vs MASS::glm.nb (dividir el p-valor por dos).
# 2.3 Decidir Poisson vs binomial negativa y documentarlo.
# 2.4 Razones de tasa exp(coef) con IC 95 % (confint) por zona vs Cinturon de Fuego.
# 2.5 Tabla puente con el Informe 1: tasa anual bruta (34,3/7,8/2,4/1,1) junto a
#     la tasa por km2 (offset) como sensibilidad.

message("07_inf_frecuencia.R: stub pendiente de implementacion (Fase 2 / C2).")
