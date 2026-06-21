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
    magnitud_mediana = median(mag, na.rm = TRUE),
    magnitud_desviacion = sd(mag, na.rm = TRUE),
    magnitud_maxima = max(mag, na.rm = TRUE),
    cuantil_25 = quantile(mag, 0.25, na.rm = TRUE),
    cuantil_50 = quantile(mag, 0.50, na.rm = TRUE),
    cuantil_75 = quantile(mag, 0.75, na.rm = TRUE),
    cuantil_90 = quantile(mag, 0.90, na.rm = TRUE),
    cuantil_95 = quantile(mag, 0.95, na.rm = TRUE)
  )

#Magnitud máxima anual----
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
View(magnitud_maxima_anual)

#Número y proporción de eventos según magnitud----
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
View(eventos_categoria_magnitud)


#Profundidad media----
sismos %>%
  summarise(
    profundidad_media = mean(depth, na.rm = TRUE)
  )
#Profundidad media, máxima y cuantiles----
sismos %>%
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

#Gráfico de eventos por zona para el informe----
if (dir.exists("Informes Quarto/Imágenes y Recursos")) {
  eventos_por_zona_grafico <- total_eventos_zona %>%
    mutate(
      porcentaje = total_eventos / sum(total_eventos) * 100
    )

  colores_zona_informe <- c(
    "Cinturon de Fuego" = "#E06B70",
    "Dorsal Meso-Atlantica" = "#C7B17A",
    "Cinturon Alpino-Himalayo" = "#5AC8AE",
    "Resto del mundo" = "#BDBDBD"
  )

  png(
    filename = "Informes Quarto/Imágenes y Recursos/eventos-por-zona.png",
    width = 1800,
    height = 1200,
    res = 180
  )

  par_anterior <- par(no.readonly = TRUE)
  par(
    bg = "white",
    mar = c(10.5, 5, 4, 2) + 0.1
  )

  barras_zona <- barplot(
    eventos_por_zona_grafico$total_eventos,
    names.arg = eventos_por_zona_grafico$zona,
    col = colores_zona_informe[eventos_por_zona_grafico$zona],
    border = "gray30",
    las = 2,
    ylim = c(
      0,
      max(eventos_por_zona_grafico$total_eventos) * 1.18
    ),
    ylab = "Numero de eventos",
    main = "Eventos por zona sismica"
  )

  text(
    x = barras_zona,
    y = eventos_por_zona_grafico$total_eventos,
    labels = paste0(
      eventos_por_zona_grafico$total_eventos,
      " (",
      format(
        eventos_por_zona_grafico$porcentaje,
        decimal.mark = ",",
        nsmall = 1
      ),
      "%)"
    ),
    pos = 3,
    cex = 0.85
  )

  box()
  par(par_anterior)
  dev.off()
}

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


#Estadísticos descriptivos iniciales por zona---- 
### corresponde al 4.3 del informe final
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
  tidyr::complete(
    zona = unique(c(
      as.character(area_regiones$Region),
      "Resto del mundo"
    ))
  ) %>%
  mutate(
    across(
      where(is.numeric),
      ~ replace(
        .x,
        is.na(.x) | is.infinite(.x),
        0
      )
    )
  )
View(estadisticos_zona)







#Instalar solamente una vez si es necesario
#install.packages("vioplot")

library(vioplot)

#Distribución general de magnitud----
histograma_magnitud <- hist(
  sismos$mag,
  breaks = "Sturges",
  plot = FALSE
)

graficar_distribucion_magnitud <- function() {
  par(
    bg = "white",
    mar = c(5, 4, 4, 2) + 0.1
  )
  
  plot(
    histograma_magnitud,
    freq = TRUE,
    main = "Distribución de eventos según magnitud",
    xlab = "Magnitud",
    ylab = "Número de eventos",
    col = "gray80",
    border = "gray30",
    ylim = c(
      0,
      max(histograma_magnitud$counts) * 1.10
    )
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
}

dir.create(
  "Informes Quarto/Imágenes y Recursos",
  recursive = TRUE,
  showWarnings = FALSE
)

png(
  filename = "Informes Quarto/Imágenes y Recursos/distribucion-eventos-magnitud.png",
  width = 1600,
  height = 1000,
  res = 180
)
graficar_distribucion_magnitud()
dev.off()

graficar_distribucion_magnitud()

#Distribución general de profundidad----
histograma_profundidad <- hist(
  sismos$depth,
  breaks = "Sturges",
  plot = FALSE
)

plot(
  histograma_profundidad,
  freq = TRUE,
  main = "Distribución de eventos según profundidad",
  xlab = "Profundidad (km)",
  ylab = "Número de eventos",
  col = "gray80",
  border = "gray30",
  ylim = c(
    0,
    max(histograma_profundidad$counts) * 1.10
  )
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

#Colores según el mapa----
colores_zona <- c(
  "Cinturon de Fuego" = "#E06B70",
  "Dorsal Meso-Atlantica" = "#C7B17A",
  "Cinturon Alpino-Himalayo" = "#5AC8AE",
  "Resto del mundo" = "#BDBDBD"
)

#Preparar magnitud por zona----
magnitud_por_zona <- split(
  sismos$mag[!is.na(sismos$mag)],
  sismos$zona[!is.na(sismos$mag)],
  drop = TRUE
)

#Distribución de magnitud por zona----
par(
  bg = "white",
  mar = c(9, 4, 4, 2) + 0.1
)

plot(
  NA,
  xlim = c(
    0.5,
    length(magnitud_por_zona) + 0.5
  ),
  ylim = extendrange(
    sismos$mag,
    f = 0.05
  ),
  main = "Distribución de magnitud por zona",
  xlab = "",
  ylab = "Magnitud",
  axes = FALSE,
  bty = "n"
)

do.call(
  vioplot::vioplot,
  c(
    unname(magnitud_por_zona),
    list(
      at = seq_along(magnitud_por_zona),
      add = TRUE,
      drawRect = FALSE,
      col = unname(
        colores_zona[names(magnitud_por_zona)]
      ),
      border = "gray30",
      lwd = 1,
      wex = 0.9
    )
  )
)

boxplot(
  magnitud_por_zona,
  add = TRUE,
  at = seq_along(magnitud_por_zona),
  boxwex = 0.14,
  col = "white",
  border = "black",
  outline = FALSE,
  axes = FALSE
)

points(
  seq_along(magnitud_por_zona),
  sapply(
    magnitud_por_zona,
    mean,
    na.rm = TRUE
  ),
  pch = 19,
  col = "black"
)

axis(
  side = 1,
  at = seq_along(magnitud_por_zona),
  labels = names(magnitud_por_zona),
  las = 2,
  cex.axis = 0.75
)

axis(
  side = 2,
  at = pretty(range(sismos$mag, na.rm = TRUE)),
  las = 1
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

#Preparar profundidad por zona----
profundidad_por_zona <- split(
  sismos$depth[!is.na(sismos$depth)],
  sismos$zona[!is.na(sismos$depth)],
  drop = TRUE
)

#Distribución de profundidad por zona----
plot(
  NA,
  xlim = c(
    0.5,
    length(profundidad_por_zona) + 0.5
  ),
  ylim = c(
    0,
    max(sismos$depth, na.rm = TRUE) * 1.08
  ),
  main = "Distribución de profundidad por zona",
  xlab = "",
  ylab = "Profundidad (km)",
  axes = FALSE,
  bty = "n"
)

do.call(
  vioplot::vioplot,
  c(
    unname(profundidad_por_zona),
    list(
      at = seq_along(profundidad_por_zona),
      add = TRUE,
      drawRect = FALSE,
      col = unname(
        colores_zona[names(profundidad_por_zona)]
      ),
      border = "gray30",
      lwd = 1,
      wex = 0.9
    )
  )
)

boxplot(
  profundidad_por_zona,
  add = TRUE,
  at = seq_along(profundidad_por_zona),
  boxwex = 0.14,
  col = "white",
  border = "black",
  outline = FALSE,
  axes = FALSE
)

points(
  seq_along(profundidad_por_zona),
  sapply(
    profundidad_por_zona,
    mean,
    na.rm = TRUE
  ),
  pch = 19,
  col = "black"
)

axis(
  side = 1,
  at = seq_along(profundidad_por_zona),
  labels = names(profundidad_por_zona),
  las = 2,
  cex.axis = 0.75
)

axis(
  side = 2,
  at = pretty(c(
    0,
    max(sismos$depth, na.rm = TRUE)
  )),
  las = 1
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

#Restablecer márgenes----
par(
  mar = c(5, 4, 4, 2) + 0.1
)

