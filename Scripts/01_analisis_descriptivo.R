#Analisis descriptivo----

# Este script utiliza la base preparada en Codigo.R.
# Base disponible: sismos

#Resumen general de eventos----

#Magnitud----

#Profundidad----

#Frecuencia temporal----

#Distribucion espacial----



#Conteo y tasas de ocurrencia----
#Período definido para el estudio
año_inicio <- 2000
año_fin <- 2025

#Cantidad de años y meses analizados
cantidad_años <- año_fin - año_inicio + 1  # 26 años
cantidad_meses <- cantidad_años * 12       # 312 meses

#Número total de terremotos con magnitud mayor o igual a 6.5
numero_total_eventos <- nrow(sismos)       # 1186

#Magnitud media, máxima y cuantiles----
sismos %>%
  summarise(
    magnitud_media = mean(mag, na.rm = TRUE),
    magnitud_maxima = max(mag, na.rm = TRUE),
    cuantil_25 = quantile(mag, 0.25, na.rm = TRUE),
    cuantil_50 = quantile(mag, 0.50, na.rm = TRUE),
    cuantil_75 = quantile(mag, 0.75, na.rm = TRUE),
    cuantil_90 = quantile(mag, 0.90, na.rm = TRUE),
    cuantil_95 = quantile(mag, 0.95, na.rm = TRUE)
  )

#Profundidad media----
sismos %>%
  summarise(
    profundidad_media = mean(depth, na.rm = TRUE)
  )

#Proporción de eventos según profundidad----
sismos %>%
  janitor::tabyl(profundidad_cat)




#Zonas----
library(sf)

#Leer las regiones
area_regiones <- st_read(
  "SIG/area_regiones.geojson",
  quiet = TRUE
)

#Convertir los terremotos en puntos
puntos_sismos <- st_as_sf(
  sismos %>% select(-any_of("zona")),
  coords = c("longitude", "latitude"),
  crs = 4326,
  remove = FALSE
) %>%
  st_transform(st_crs(area_regiones))

#Manejar el antimeridiano
sf_use_s2(FALSE)

#Asignar cada terremoto a su región
puntos_sismos <- puntos_sismos %>%
  st_join(
    area_regiones %>% select(Region),
    join = st_intersects,
    left = TRUE
  )

#Crear la variable zona
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

#Reactivar el procesamiento esférico
sf_use_s2(TRUE)

#Total de eventos por zona----
total_eventos_zona <- sismos %>%
  count(zona, name = "total_eventos") %>%
  tidyr::complete(
    zona = unique(c(
      as.character(area_regiones$Region),
      "Resto del mundo"
    )),
    fill = list(total_eventos = 0)
  ) %>%
  arrange(desc(total_eventos))

View(total_eventos_zona)

#Eventos por zona y año----
eventos_zona_anio <- sismos %>%
  count(zona, año, name = "numero_eventos") %>%
  tidyr::complete(
    zona = unique(c(
      as.character(area_regiones$Region),
      "Resto del mundo"
    )),
    año = año_inicio:año_fin,
    fill = list(numero_eventos = 0)
  ) %>%
  arrange(año, zona)

View(eventos_zona_anio)   # cinturonFuego - mesoAtlantico - alpinoHimalayo - RestoMundo

#Mostrar todas las columnas
options(tibble.width = Inf)

#Estadísticos descriptivos por zona----
sismos %>%
  group_by(zona) %>%
  summarise(
    numero_eventos = n(),
    tasa_anual = n() / cantidad_años,
    magnitud_media = mean(mag, na.rm = TRUE),
    magnitud_mediana = median(mag, na.rm = TRUE),
    magnitud_desviacion = sd(mag, na.rm = TRUE),
    magnitud_maxima = max(mag, na.rm = TRUE),
    magnitud_cuantil_25 = quantile(mag, 0.25, na.rm = TRUE),
    magnitud_cuantil_75 = quantile(mag, 0.75, na.rm = TRUE),
    magnitud_cuantil_90 = quantile(mag, 0.90, na.rm = TRUE),
    magnitud_cuantil_95 = quantile(mag, 0.95, na.rm = TRUE),
    profundidad_media = mean(depth, na.rm = TRUE),
    profundidad_mediana = median(depth, na.rm = TRUE),
    profundidad_desviacion = sd(depth, na.rm = TRUE),
    profundidad_maxima = max(depth, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    zona = unique(c(
      as.character(area_regiones$Region),
      "Resto del mundo"
    ))
  ) %>%
  mutate(
    across(
      where(is.numeric),
      ~ replace(.x, is.na(.x) | is.infinite(.x), 0)
    )
  )

#Categorías de profundidad por zona----
sismos %>%
  count(zona, profundidad_cat, name = "numero_eventos") %>%
  tidyr::complete(
    zona = unique(c(
      as.character(area_regiones$Region),
      "Resto del mundo"
    )),
    profundidad_cat = c(
      "Superficial",
      "Intermedio",
      "Profundo"
    ),
    fill = list(numero_eventos = 0)
  ) %>%
  group_by(zona) %>%
  mutate(
    proporcion = numero_eventos / if_else(
      sum(numero_eventos) == 0,
      1,
      sum(numero_eventos)
    ),
    porcentaje = proporcion * 100
  ) %>%
  ungroup()







