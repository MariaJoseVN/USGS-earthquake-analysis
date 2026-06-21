#Analisis descriptivo----
#Este script utiliza la base preparada en Codigo.R.
#Su proposito es explorar descriptivamente el catalogo y construir la variable zona.
#No guarda graficos; las salidas se revisan directamente en consola y panel grafico.


#Reiniciar dispositivo grafico----
#Evita que los graficos se envien a un dispositivo externo abierto previamente.
graphics.off()


#Conteo y tasas de ocurrencia----
##Periodo definido para el estudio----

año_inicio <- 2000
año_fin <- 2025

cantidad_años <- año_fin - año_inicio + 1
cantidad_meses <- cantidad_años * 12
numero_total_eventos <- nrow(sismos)

resumen_periodo <- tibble::tibble(
  indicador = c(
    "Año de inicio",
    "Año de termino",
    "Años analizados",
    "Meses analizados",
    "Eventos con M >= 6.5"
  ),
  valor = c(
    año_inicio,
    año_fin,
    cantidad_años,
    cantidad_meses,
    numero_total_eventos
  )
)

print(resumen_periodo)


#Magnitud----
##Resumen descriptivo de mag----

resumen_magnitud <- sismos %>%
  summarise(
    magnitud_media = mean(mag, na.rm = TRUE),
    magnitud_mediana = median(mag, na.rm = TRUE),
    magnitud_desviacion = sd(mag, na.rm = TRUE),
    magnitud_maxima = max(mag, na.rm = TRUE),
    cuantil_25 = quantile(mag, 0.25, na.rm = TRUE),
    cuantil_50 = quantile(mag, 0.50, na.rm = TRUE),
    cuantil_75 = quantile(mag, 0.75, na.rm = TRUE),
    cuantil_90 = quantile(mag, 0.90, na.rm = TRUE),
    cuantil_95 = quantile(mag, 0.95, na.rm = TRUE)
  )

print(resumen_magnitud)


##Magnitud maxima anual----

magnitud_maxima_anual <- sismos %>%
  group_by(año) %>%
  summarise(
    magnitud_maxima = max(mag, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    fill = list(magnitud_maxima = 0)
  ) %>%
  arrange(año)

print(magnitud_maxima_anual, n = Inf)


##Eventos segun magnitud_cat----

eventos_categoria_magnitud <- sismos %>%
  count(
    magnitud_cat,
    name = "numero_eventos",
    .drop = FALSE
  ) %>%
  mutate(
    proporcion = numero_eventos / if_else(
      sum(numero_eventos) == 0,
      1,
      sum(numero_eventos)
    ),
    porcentaje = proporcion * 100
  )

print(eventos_categoria_magnitud, n = Inf)


##Distribucion general de mag----

histograma_magnitud <- hist(
  sismos$mag,
  breaks = "Sturges",
  plot = FALSE
)

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

plot(
  histograma_magnitud,
  freq = TRUE,
  main = "Distribucion de eventos segun magnitud",
  xlab = "Magnitud",
  ylab = "Numero de eventos",
  col = "gray80",
  border = "gray30",
  ylim = c(0, max(histograma_magnitud$counts) * 1.10)
)

abline(
  v = mean(sismos$mag, na.rm = TRUE),
  col = "black",
  lty = 2,
  lwd = 1.5
)

abline(
  v = median(sismos$mag, na.rm = TRUE),
  col = "red",
  lty = 3,
  lwd = 1.5
)

legend(
  "topright",
  legend = c("Media", "Mediana"),
  col = c("black", "red"),
  lty = c(2, 3),
  lwd = c(1.5, 1.5),
  bty = "n",
  cex = 0.8
)

box()


#Profundidad----
##Resumen descriptivo de depth----

resumen_profundidad <- sismos %>%
  summarise(
    profundidad_media = mean(depth, na.rm = TRUE),
    profundidad_mediana = median(depth, na.rm = TRUE),
    profundidad_desviacion = sd(depth, na.rm = TRUE),
    profundidad_maxima = max(depth, na.rm = TRUE),
    cuantil_25 = quantile(depth, 0.25, na.rm = TRUE),
    cuantil_50 = quantile(depth, 0.50, na.rm = TRUE),
    cuantil_75 = quantile(depth, 0.75, na.rm = TRUE),
    cuantil_90 = quantile(depth, 0.90, na.rm = TRUE),
    cuantil_95 = quantile(depth, 0.95, na.rm = TRUE)
  )

print(resumen_profundidad)


##Eventos segun profundidad_cat----

eventos_categoria_profundidad <- sismos %>%
  count(
    profundidad_cat,
    name = "numero_eventos",
    .drop = FALSE
  ) %>%
  mutate(
    proporcion = numero_eventos / if_else(
      sum(numero_eventos) == 0,
      1,
      sum(numero_eventos)
    ),
    porcentaje = proporcion * 100
  )

print(eventos_categoria_profundidad, n = Inf)


##Distribucion general de depth----

histograma_profundidad <- hist(
  sismos$depth,
  breaks = "Sturges",
  plot = FALSE
)

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

plot(
  histograma_profundidad,
  freq = TRUE,
  main = "Distribucion de eventos segun profundidad",
  xlab = "Profundidad (km)",
  ylab = "Numero de eventos",
  col = "gray80",
  border = "gray30",
  ylim = c(0, max(histograma_profundidad$counts) * 1.10)
)

abline(
  v = mean(sismos$depth, na.rm = TRUE),
  col = "black",
  lty = 2,
  lwd = 1.5
)

abline(
  v = median(sismos$depth, na.rm = TRUE),
  col = "red",
  lty = 3,
  lwd = 1.5
)

legend(
  "topright",
  legend = c("Media", "Mediana"),
  col = c("black", "red"),
  lty = c(2, 3),
  lwd = c(1.5, 1.5),
  bty = "n",
  cex = 0.8
)

box()


#Zonificacion espacial----
##Leer poligonos de zonas sismicas----

library(sf)

area_regiones <- st_read(
  "SIG/area_regiones.geojson",
  quiet = TRUE
)


##Convertir eventos en puntos y asignar zona----

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

print(count(sismos, zona, name = "numero_eventos"), n = Inf)


#Caracterizacion espacial----
##Total de eventos por zona----

zonas_estudio <- unique(c(
  as.character(area_regiones$Region),
  "Resto del mundo"
))

total_eventos_zona <- sismos %>%
  count(zona, name = "total_eventos") %>%
  tidyr::complete(
    zona = zonas_estudio,
    fill = list(total_eventos = 0)
  ) %>%
  mutate(
    proporcion = total_eventos / if_else(
      sum(total_eventos) == 0,
      1,
      sum(total_eventos)
    ),
    porcentaje = proporcion * 100,
    tasa_anual = total_eventos / cantidad_años
  ) %>%
  arrange(desc(total_eventos))

print(total_eventos_zona, n = Inf)


##Grafico de eventos por zona----

colores_zona <- c(
  "Cinturon de Fuego" = "#E06B70",
  "Dorsal Meso-Atlantica" = "#C7B17A",
  "Cinturon Alpino-Himalayo" = "#5AC8AE",
  "Resto del mundo" = "#BDBDBD"
)

par(mfrow = c(1, 1), bg = "white", mar = c(10, 5, 4, 2) + 0.1)

barras_zona <- barplot(
  total_eventos_zona$total_eventos,
  names.arg = total_eventos_zona$zona,
  col = colores_zona[total_eventos_zona$zona],
  border = "gray30",
  las = 2,
  ylim = c(0, max(total_eventos_zona$total_eventos) * 1.18),
  ylab = "Numero de eventos",
  main = "Eventos por zona sismica"
)

text(
  x = barras_zona,
  y = total_eventos_zona$total_eventos,
  labels = paste0(
    total_eventos_zona$total_eventos,
    " (",
    format(total_eventos_zona$porcentaje, decimal.mark = ",", nsmall = 1),
    "%)"
  ),
  pos = 3,
  cex = 0.85
)

box()


##Eventos por zona y año----

eventos_zona_anio <- sismos %>%
  count(zona, año, name = "numero_eventos") %>%
  tidyr::complete(
    zona = zonas_estudio,
    año = año_inicio:año_fin,
    fill = list(numero_eventos = 0)
  ) %>%
  arrange(año, zona)

print(eventos_zona_anio, n = Inf)


##Estadisticos descriptivos por zona----

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
  mutate(
    across(
      where(is.numeric),
      ~ replace(.x, is.na(.x) | is.infinite(.x), 0)
    )
  ) %>%
  arrange(desc(numero_eventos))

print(estadisticos_zona, n = Inf)


##Distribucion de profundidad por zona----

profundidad_zona <- sismos %>%
  count(zona, profundidad_cat, name = "numero_eventos") %>%
  tidyr::complete(
    zona = zonas_estudio,
    profundidad_cat = c("Superficial", "Intermedio", "Profundo"),
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

print(profundidad_zona, n = Inf)


##Boxplot de mag por zona----

par(mfrow = c(1, 1), bg = "white", mar = c(10, 4, 4, 2) + 0.1)

boxplot(
  mag ~ zona,
  data = sismos,
  main = "Distribucion de magnitud por zona",
  xlab = "",
  ylab = "Magnitud",
  col = unname(colores_zona[sort(unique(sismos$zona))]),
  border = "gray30",
  las = 2,
  outline = TRUE
)

points(
  x = seq_along(sort(unique(sismos$zona))),
  y = tapply(sismos$mag, sismos$zona, mean, na.rm = TRUE)[sort(unique(sismos$zona))],
  pch = 19,
  col = "black"
)

legend(
  "topright",
  legend = "Media",
  pch = 19,
  col = "black",
  bty = "n",
  cex = 0.8
)

box()


##Boxplot de depth por zona----

par(mfrow = c(1, 1), bg = "white", mar = c(10, 4, 4, 2) + 0.1)

boxplot(
  depth ~ zona,
  data = sismos,
  main = "Distribucion de profundidad por zona",
  xlab = "",
  ylab = "Profundidad (km)",
  col = unname(colores_zona[sort(unique(sismos$zona))]),
  border = "gray30",
  las = 2,
  outline = TRUE
)

points(
  x = seq_along(sort(unique(sismos$zona))),
  y = tapply(sismos$depth, sismos$zona, mean, na.rm = TRUE)[sort(unique(sismos$zona))],
  pch = 19,
  col = "black"
)

legend(
  "topright",
  legend = "Media",
  pch = 19,
  col = "black",
  bty = "n",
  cex = 0.8
)

box()


#Restablecer parametros graficos----

par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)

