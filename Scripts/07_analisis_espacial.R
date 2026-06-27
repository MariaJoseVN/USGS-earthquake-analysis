#Analisis espacial----
#Este script reune toda la caracterizacion espacial del catalogo, antes dispersa en
#01_analisis_descriptivo.R, 05_analisis_descriptivo.R,
#05_analisis_descritivo_V.CATEGORICAS.R y 06_analisis_asociatividad.R.
#Requiere que Codigo.R ya haya preparado sismos (con magnitud_cat, profundidad_cat,
#magType_grupo, magSource y sig) y que 02_tratamiento_NAs.R haya creado nst_imp y rms_imp.
#Construye la variable zona y debe ejecutarse antes de los scripts que la utilizan.
#No guarda graficos; las salidas se revisan directamente en consola y panel grafico.


#Preparacion general----

graphics.off()

library(sf)

año_inicio <- 2000
año_fin <- 2025

cantidad_años <- año_fin - año_inicio + 1
cantidad_meses <- cantidad_años * 12
numero_total_eventos <- nrow(sismos)


#Zonificacion espacial----
##Leer poligonos de zonas sismicas----

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


##Universo de zonas, paleta y etiquetas----

zonas_estudio <- unique(c(
  as.character(area_regiones$Region),
  "Resto del mundo"
))

#Paleta de zonas con leve transparencia (alpha ~0.85, sufijo D9) para un acabado profesional.
colores_zona <- c(
  "Cinturon de Fuego" = "#e31a1cD9",
  "Cinturon Alpino-Himalayo" = "#47cea8D9",
  "Dorsal Meso-Atlantica" = "#dfbf8aD9",
  "Resto del mundo" = "#9e9e9eD9"
)

etiquetas_zona <- c(
  "Cinturon de Fuego" = "C. Fuego",
  "Resto del mundo" = "Resto",
  "Cinturon Alpino-Himalayo" = "C. Alpino-H.",
  "Dorsal Meso-Atlantica" = "Dorsal M.-Atl."
)


#Frecuencia de ocurrencia por zona----
##Total de eventos, porcentaje y tasa anual----

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


#Magnitud y profundidad por zona----
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


#Profundidad categorica por zona----
##Distribucion de profundidad_cat por zona----

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


##Asociacion entre zona y profundidad_cat----
#Chi-cuadrado para evaluar independencia y V de Cramer para medir la fuerza de asociacion.

tabla_zona_profundidad <- sismos %>%
  filter(!is.na(zona), !is.na(profundidad_cat)) %>%
  with(table(zona, profundidad_cat))

prueba_chi_zona_profundidad <- suppressWarnings(chisq.test(tabla_zona_profundidad))

v_cramer_zona_profundidad <- sqrt(
  as.numeric(prueba_chi_zona_profundidad$statistic) /
    (sum(tabla_zona_profundidad) * (min(dim(tabla_zona_profundidad)) - 1))
)

asociacion_zona_profundidad <- tibble::tibble(
  estadistico_chi = as.numeric(prueba_chi_zona_profundidad$statistic),
  grados_libertad = as.numeric(prueba_chi_zona_profundidad$parameter),
  valor_p = prueba_chi_zona_profundidad$p.value,
  v_cramer = v_cramer_zona_profundidad
)

print(asociacion_zona_profundidad)


#Significancia por zona----
##Resumen de sig por zona----

significancia_zona <- sismos %>%
  group_by(zona) %>%
  summarise(
    numero_eventos = n(),
    significancia_media = mean(sig, na.rm = TRUE),
    significancia_mediana = median(sig, na.rm = TRUE),
    significancia_desviacion = sd(sig, na.rm = TRUE),
    significancia_maxima = max(sig, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::complete(zona = zonas_estudio) %>%
  mutate(
    across(
      where(is.numeric),
      ~ replace(.x, is.na(.x) | is.infinite(.x), 0)
    )
  ) %>%
  arrange(desc(significancia_media))

print(significancia_zona, n = Inf)


##Boxplot de sig por zona----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  sig ~ zona,
  data = sismos,
  main = "Distribucion de significancia por zona",
  xlab = "",
  ylab = "Significancia (sig)",
  col = unname(colores_zona[sort(unique(sismos$zona))]),
  border = "gray30",
  names = etiquetas_zona[sort(unique(sismos$zona))],
  las = 1,
  outline = TRUE
)

points(
  x = seq_along(sort(unique(sismos$zona))),
  y = tapply(sismos$sig, sismos$zona, mean, na.rm = TRUE)[sort(unique(sismos$zona))],
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


#Composicion de tipo de magnitud por zona----
##Tabla de magType_grupo por zona----

magtype_grupo_zona <- sismos %>%
  count(zona, magType_grupo, name = "numero_eventos") %>%
  group_by(zona) %>%
  mutate(
    total_fila = sum(numero_eventos),
    proporcion = if_else(
      total_fila == 0,
      0,
      numero_eventos / total_fila
    ),
    porcentaje = proporcion * 100
  ) %>%
  ungroup() %>%
  select(-total_fila) %>%
  arrange(zona, desc(numero_eventos))

print(magtype_grupo_zona, n = Inf)


##Grafico de composicion de magType por zona----

tabla_zona_magtype <- table(
  sismos$zona,
  sismos$magType_grupo
)

matriz_zona_magtype_porcentaje <- prop.table(
  t(tabla_zona_magtype),
  margin = 2
) * 100

#Paleta de grises del proyecto para composiciones (mismo estilo que las figuras de magType_grupo).
colores_magtype <- c("gray30", "gray55", "gray75", "gray90")

par(mfrow = c(1, 1), bg = "white", mar = c(7, 4, 4, 2) + 0.1)

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
  "bottom",
  inset = c(0, -0.28),
  legend = rev(rownames(matriz_zona_magtype_porcentaje)),
  fill = rev(colores_magtype),
  border = "gray30",
  bty = "n",
  cex = 0.85,
  horiz = TRUE,
  xpd = TRUE
)

box()


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

box()


#Restablecer parametros graficos----

par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)

