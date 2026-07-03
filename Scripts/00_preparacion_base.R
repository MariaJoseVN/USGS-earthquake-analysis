# Preparacion de la base analitica (ruta rapida para la etapa inferencial)----
#
# Este script deja disponible el objeto `sismos` completo y listo para el
# Informe Asesoria 2, en segundos y sin ejecutar los analisis ni los graficos
# del Informe Asesoria 1.
#
# Reproduce, de forma consolidada y silenciosa, las tres piezas que la etapa
# inferencial necesita y que en el flujo del Informe 1 estan repartidas:
#   1. Base `sismos` con variables derivadas   -> definido en Codigo.R
#   2. Imputacion `nst_imp` y `rms_imp`         -> definido en 01_tratamiento_NAs.R
#   3. Variable `zona` por cruce espacial       -> definido en 04_analisis_espacial.R
#
# La fuente de verdad para el Informe 1 sigue siendo Codigo.R + 01 + 04. Si en
# algun momento cambia una definicion de variable en aquellos scripts, hay que
# reflejarla tambien aqui.
#
# Uso (ruta rapida de desarrollo):
#   source(file.path("Scripts", "00_preparacion_base.R"))
# y a trabajar sobre `sismos` en el script 06-12 correspondiente.


#Paquetes minimos para la base----
library(readr)     # Lectura de archivos CSV.
library(dplyr)     # Union, mutate, select y resumen.
library(tidyr)     # Reestructuracion auxiliar.
library(lubridate) # Manejo de fechas y periodos.
library(sf)        # Lectura de zonas sismicas y cruce espacial.

options(
  scipen = 999,
  tibble.width = Inf,
  tibble.print_max = Inf
)


#1. Carga y variables derivadas (equivalente a Codigo.R)----

sismos_raw <- read_csv("BBDD/query.csv", show_col_types = FALSE)
sig_raw <- read_csv("BBDD/sig.csv", show_col_types = FALSE)

sismos <- sismos_raw %>%
  left_join(sig_raw, by = "id") %>%
  mutate(
    fecha_hora_utc = ymd_hms(time, tz = "UTC"),
    fecha = as.Date(fecha_hora_utc),
    año = year(fecha_hora_utc),
    mes = month(fecha_hora_utc),
    decada = floor(año / 10) * 10,
    profundidad_cat = case_when(
      depth >= 0 & depth <= 70 ~ "Superficial",
      depth > 70 & depth <= 300 ~ "Intermedio",
      depth > 300 ~ "Profundo"
    ),
    magnitud_cat = factor(
      case_when(
        mag >= 6.5 & mag < 7.0 ~ "Fuerte",
        mag >= 7.0 & mag < 7.8 ~ "Mayor",
        mag >= 7.8 ~ "Grande o extremo",
        TRUE ~ NA_character_
      ),
      levels = c("Fuerte", "Mayor", "Grande o extremo")
    ),
    magType_grupo = factor(
      case_when(
        magType %in% c("mww", "mwc", "mwb") ~ magType,
        TRUE ~ "otros"
      ),
      levels = c("mww", "mwc", "mwb", "otros")
    )
  ) %>%
  select(
    id, fecha_hora_utc, fecha, año, mes, decada,
    latitude, longitude, depth, profundidad_cat,
    mag, sig, magnitud_cat, magType, magType_grupo,
    place, type, status, net, locationSource, magSource,
    nst, rms
  )


#2. Imputacion por mediana decadal (equivalente a 01_tratamiento_NAs.R)----

sismos <- sismos %>%
  group_by(decada) %>%
  mutate(
    nst_imp = if_else(is.na(nst), median(nst, na.rm = TRUE), nst),
    rms_imp = if_else(is.na(rms), median(rms, na.rm = TRUE), rms)
  ) %>%
  ungroup()


#3. Zonificacion espacial (equivalente a 04_analisis_espacial.R)----

area_regiones <- st_read("SIG/area_regiones.geojson", quiet = TRUE)

puntos_sismos <- st_as_sf(
  sismos %>% select(-any_of("zona")),
  coords = c("longitude", "latitude"),
  crs = 4326,
  remove = FALSE
) %>%
  st_transform(st_crs(area_regiones))

sf_use_s2(FALSE)

puntos_sismos <- puntos_sismos %>%
  st_join(
    area_regiones %>% select(Region),
    join = st_intersects,
    left = TRUE
  )

sismos <- puntos_sismos %>%
  mutate(
    zona = if_else(
      is.na(Region),
      "Resto del mundo",
      as.character(Region)
    )
  ) %>%
  st_drop_geometry() %>%
  select(-Region)

sf_use_s2(TRUE)


#Verificacion de la base (equivale al paso 0.1 del checklist)----

cat("Base `sismos` lista:", nrow(sismos), "eventos.\n")
cat("Conteo por zona (control: 892 / 203 / 63 / 28):\n")
print(count(sismos, zona, name = "numero_eventos"))
