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
  select(zona = Region, area_km2 = Area)

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
