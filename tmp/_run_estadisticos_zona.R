suppressMessages({
  library(readr); library(dplyr); library(lubridate); library(sf)
})

setwd("D:/danie/Escritorio/asesoria 1/USGS-earthquake-analysis")

sismos_raw <- read_csv("BBDD/query.csv", show_col_types = FALSE)
sig_raw    <- read_csv("BBDD/sig.csv",  show_col_types = FALSE)

sismos <- sismos_raw %>%
  left_join(sig_raw, by = "id") %>%
  mutate(
    fecha_hora_utc = ymd_hms(time, tz = "UTC"),
    fecha = as.Date(fecha_hora_utc),
    año = year(fecha_hora_utc)
  )

# periodo
año_inicio <- 2000; año_fin <- 2025
cantidad_años  <- año_fin - año_inicio + 1
cantidad_meses <- cantidad_años * 12
numero_total_eventos <- nrow(sismos)

# zona via spatial join
area_regiones <- st_read("SIG/area_regiones.geojson", quiet = TRUE)
puntos_sismos <- st_as_sf(
  sismos %>% select(-any_of("zona")),
  coords = c("longitude", "latitude"), crs = 4326, remove = FALSE
) %>% st_transform(st_crs(area_regiones))
sf_use_s2(FALSE)
puntos_sismos <- puntos_sismos %>%
  st_join(area_regiones %>% select(Region), join = st_intersects, left = TRUE)
sismos <- puntos_sismos %>%
  mutate(zona = if_else(is.na(Region), "Resto del mundo", as.character(Region))) %>%
  st_drop_geometry() %>% select(-Region)
sf_use_s2(TRUE)

zonas_estudio <- unique(c(as.character(area_regiones$Region), "Resto del mundo"))

estadisticos_zona <- sismos %>%
  group_by(zona) %>%
  summarise(
    numero_eventos = n(),
    proporcion_eventos = n() / numero_total_eventos,
    porcentaje_eventos = proporcion_eventos * 100,
    tasa_anual = n() / cantidad_años,
    tasa_mensual = n() / cantidad_meses,
    magnitud_media = mean(mag, na.rm = TRUE),
    magnitud_mediana = median(mag, na.rm = TRUE),
    magnitud_desviacion = sd(mag, na.rm = TRUE),
    magnitud_maxima = max(mag, na.rm = TRUE),
    magnitud_cuantil_25 = quantile(mag, 0.25, na.rm = TRUE),
    magnitud_cuantil_50 = quantile(mag, 0.50, na.rm = TRUE),
    magnitud_cuantil_75 = quantile(mag, 0.75, na.rm = TRUE),
    magnitud_cuantil_90 = quantile(mag, 0.90, na.rm = TRUE),
    magnitud_cuantil_95 = quantile(mag, 0.95, na.rm = TRUE),
    profundidad_media = mean(depth, na.rm = TRUE),
    profundidad_mediana = median(depth, na.rm = TRUE),
    profundidad_desviacion = sd(depth, na.rm = TRUE),
    profundidad_maxima = max(depth, na.rm = TRUE),
    profundidad_cuantil_25 = quantile(depth, 0.25, na.rm = TRUE),
    profundidad_cuantil_50 = quantile(depth, 0.50, na.rm = TRUE),
    profundidad_cuantil_75 = quantile(depth, 0.75, na.rm = TRUE),
    profundidad_cuantil_90 = quantile(depth, 0.90, na.rm = TRUE),
    profundidad_cuantil_95 = quantile(depth, 0.95, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::complete(zona = zonas_estudio) %>%
  mutate(across(where(is.numeric), ~ replace(.x, is.na(.x) | is.infinite(.x), 0))) %>%
  arrange(desc(numero_eventos))

write.csv(estadisticos_zona, "tmp/estadisticos_zona.csv", row.names = FALSE, fileEncoding = "UTF-8")
print(as.data.frame(estadisticos_zona))
