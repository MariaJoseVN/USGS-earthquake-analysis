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

resumen_periodo
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

data.frame(resumen_magnitud)
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

magnitud_maxima_anual
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

eventos_categoria_magnitud
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

data.frame(resumen_profundidad)
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

eventos_categoria_profundidad
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

disponibilidad_rms
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

data.frame(resumen_rms)
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


#Restablecer parametros graficos----

par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)

