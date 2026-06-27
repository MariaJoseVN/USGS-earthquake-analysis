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

print(data.frame(resumen_magnitud))


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

print(data.frame(resumen_profundidad))


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

par(mfrow = c(1, 2), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

# Panel 1: profundidad continua
histograma_profundidad <- hist(
  sismos$depth,
  breaks = "Sturges",
  plot = FALSE
)

plot(
  histograma_profundidad,
  freq = TRUE,
  main = "Distribución según profundidad",
  xlab = "Profundidad (km)",
  ylab = "Número de eventos",
  col = "gray80",
  border = "gray30",
  ylim = c(0, max(histograma_profundidad$counts) * 1.10)
)

abline(v = mean(sismos$depth, na.rm = TRUE), col = "black", lty = 2, lwd = 1.5)
abline(v = median(sismos$depth, na.rm = TRUE), col = "red", lty = 3, lwd = 1.5)

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

# Panel 2: profundidad categórica
profundidad_plot <- eventos_categoria_profundidad %>%
  mutate(
    profundidad_cat = factor(
      profundidad_cat,
      levels = c("Superficial", "Intermedio", "Profundo")
    )
  ) %>%
  arrange(profundidad_cat)

barras <- barplot(
  profundidad_plot$porcentaje,
  names.arg = profundidad_plot$profundidad_cat,
  col = "gray80",
  border = "gray30",
  ylim = c(0, max(profundidad_plot$porcentaje) * 1.18),
  main = "Distribución por categoría",
  xlab = "Categoría de profundidad",
  ylab = "Porcentaje de eventos"
)

text(
  x = barras,
  y = profundidad_plot$porcentaje,
  labels = paste0(round(profundidad_plot$porcentaje, 1), "%"),
  pos = 3,
  cex = 0.85
)

box()

par(mfrow = c(1, 1))


#Ajuste RMS de localizacion----
##Disponibilidad e imputacion----

disponibilidad_rms <- sismos %>%
  summarise(
    total_eventos = n(),
    rms_observado = sum(!is.na(rms)),
    rms_imputado = sum(is.na(rms)),
    porcentaje_observado = mean(!is.na(rms)) * 100,
    porcentaje_imputado = mean(is.na(rms)) * 100
  )

print(disponibilidad_rms)


##Resumen descriptivo observado e imputado----

resumen_rms <- dplyr::bind_rows(
  sismos %>%
    summarise(
      serie = "RMS observado",
      observaciones = sum(!is.na(rms)),
      media = mean(rms, na.rm = TRUE),
      mediana = median(rms, na.rm = TRUE),
      desviacion = sd(rms, na.rm = TRUE),
      minimo = min(rms, na.rm = TRUE),
      cuantil_25 = quantile(rms, 0.25, na.rm = TRUE),
      cuantil_75 = quantile(rms, 0.75, na.rm = TRUE),
      cuantil_90 = quantile(rms, 0.90, na.rm = TRUE),
      cuantil_95 = quantile(rms, 0.95, na.rm = TRUE),
      maximo = max(rms, na.rm = TRUE)
    ),
  sismos %>%
    summarise(
      serie = "RMS imputado",
      observaciones = sum(!is.na(rms_imp)),
      media = mean(rms_imp, na.rm = TRUE),
      mediana = median(rms_imp, na.rm = TRUE),
      desviacion = sd(rms_imp, na.rm = TRUE),
      minimo = min(rms_imp, na.rm = TRUE),
      cuantil_25 = quantile(rms_imp, 0.25, na.rm = TRUE),
      cuantil_75 = quantile(rms_imp, 0.75, na.rm = TRUE),
      cuantil_90 = quantile(rms_imp, 0.90, na.rm = TRUE),
      cuantil_95 = quantile(rms_imp, 0.95, na.rm = TRUE),
      maximo = max(rms_imp, na.rm = TRUE)
    )
)

print(data.frame(resumen_rms))


##Distribucion del RMS observado----

rms_observado <- sismos$rms[!is.na(sismos$rms)]

par(mfrow = c(1, 2), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

hist(
  rms_observado,
  breaks = "Sturges",
  main = "Distribucion del RMS observado",
  xlab = "RMS (segundos)",
  ylab = "Numero de eventos",
  col = "gray80",
  border = "gray30"
)

abline(
  v = median(rms_observado),
  col = "red",
  lty = 3,
  lwd = 1.5
)

boxplot(
  rms_observado,
  horizontal = TRUE,
  main = "Dispersion del RMS observado",
  xlab = "RMS (segundos)",
  col = "gray80",
  border = "gray30",
  outline = TRUE
)

par(mfrow = c(1, 1))


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

etiquetas_zona <- c(
  "Cinturon de Fuego" = "C. Fuego",
  "Resto del mundo" = "Resto",
  "Cinturon Alpino-Himalayo" = "C. Alpino-H.",
  "Dorsal Meso-Atlantica" = "Dorsal M.-Atl."
)

par(mfrow = c(1, 1), bg = "white", mar = c(5, 5, 4, 2) + 0.1)

barras_zona <- barplot(
  total_eventos_zona$total_eventos,
  names.arg = etiquetas_zona[total_eventos_zona$zona],
  col = colores_zona[total_eventos_zona$zona],
  border = "gray30",
  las = 1,
  cex.names = 0.9,
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


#Comparabilidad del registro por zona----
##Indicadores de monitoreo, ajuste y tipo de magnitud----
#Estos indicadores permiten interpretar las comparaciones espaciales considerando
#diferencias en cobertura instrumental, criterios de reporte y tipo de magnitud.

moda_texto <- function(x) {
  tabla <- table(x, useNA = "no")

  if (length(tabla) == 0) {
    return(NA_character_)
  }

  names(tabla)[which.max(tabla)]
}

porcentaje_moda <- function(x) {
  tabla <- table(x, useNA = "no")

  if (length(tabla) == 0 || sum(tabla) == 0) {
    return(NA_real_)
  }

  max(tabla) / sum(tabla) * 100
}

comparabilidad_zona <- sismos %>%
  group_by(zona) %>%
  summarise(
    numero_eventos = n(),
    nst_mediana = median(nst_imp, na.rm = TRUE),
    nst_media = mean(nst_imp, na.rm = TRUE),
    rms_mediana = median(rms_imp, na.rm = TRUE),
    rms_media = mean(rms_imp, na.rm = TRUE),
    magType_dominante = moda_texto(magType_grupo),
    porcentaje_magType_dominante = porcentaje_moda(magType_grupo),
    magSource_dominante = moda_texto(magSource),
    porcentaje_magSource_dominante = porcentaje_moda(magSource),
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

print(comparabilidad_zona, n = Inf)


##Distribucion de nst_imp por zona----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  nst_imp ~ zona,
  data = sismos,
  main = "Numero de estaciones por zona",
  xlab = "",
  ylab = "nst imputado",
  col = unname(colores_zona[sort(unique(sismos$zona))]),
  border = "gray30",
  names = etiquetas_zona[sort(unique(sismos$zona))],
  las = 1,
  outline = TRUE
)

legend(
  "topright",
  legend = etiquetas_zona[names(etiquetas_zona) %in% sort(unique(sismos$zona))],
  fill = colores_zona[names(etiquetas_zona) %in% sort(unique(sismos$zona))],
  border = "gray30",
  bty = "n",
  cex = 0.75
)

box()


##Distribucion de rms_imp por zona----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  rms_imp ~ zona,
  data = sismos,
  main = "Ajuste RMS por zona",
  xlab = "",
  ylab = "rms imputado",
  col = unname(colores_zona[sort(unique(sismos$zona))]),
  border = "gray30",
  names = etiquetas_zona[sort(unique(sismos$zona))],
  las = 1,
  outline = TRUE
)

legend(
  "topright",
  legend = etiquetas_zona[names(etiquetas_zona) %in% sort(unique(sismos$zona))],
  fill = colores_zona[names(etiquetas_zona) %in% sort(unique(sismos$zona))],
  border = "gray30",
  bty = "n",
  cex = 0.75
)

box()


##Composicion de magType_grupo por zona----

tabla_zona_magtype <- table(
  sismos$zona,
  sismos$magType_grupo
)

matriz_zona_magtype_porcentaje <- prop.table(
  t(tabla_zona_magtype),
  margin = 2
) * 100

colores_magtype <- grDevices::hcl.colors(
  n = nrow(matriz_zona_magtype_porcentaje),
  palette = "Dark 3"
)

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 8) + 0.1)

barplot(
  matriz_zona_magtype_porcentaje,
  beside = FALSE,
  main = "Composicion de magType por zona",
  names.arg = etiquetas_zona[colnames(matriz_zona_magtype_porcentaje)],
  xlab = "",
  ylab = "Porcentaje de eventos",
  col = colores_magtype,
  border = "gray30",
  las = 1,
  ylim = c(0, 100),
  axes = FALSE
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

legend(
  "topright",
  inset = c(-0.22, 0),
  legend = rownames(matriz_zona_magtype_porcentaje),
  fill = colores_magtype,
  border = "gray30",
  bty = "n",
  cex = 0.8,
  xpd = TRUE
)

box()


##Boxplot de mag por zona----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  mag ~ zona,
  data = sismos,
  main = "Distribucion de magnitud por zona",
  xlab = "",
  ylab = "Magnitud",
  col = unname(colores_zona[sort(unique(sismos$zona))]),
  border = "gray30",
  names = etiquetas_zona[sort(unique(sismos$zona))],
  las = 1,
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

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  depth ~ zona,
  data = sismos,
  main = "Distribucion de profundidad por zona",
  xlab = "",
  ylab = "Profundidad (km)",
  col = unname(colores_zona[sort(unique(sismos$zona))]),
  border = "gray30",
  names = etiquetas_zona[sort(unique(sismos$zona))],
  las = 1,
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

