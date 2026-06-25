#Analisis de la variable magType----
#magType indica el metodo/escala con que se estimo la magnitud y depende del magSource.



#Reiniciar dispositivo grafico----
#Evita que los graficos se envien a un dispositivo externo abierto previamente.
graphics.off()


#Distribucion de eventos segun magType----

eventos_magtype <- sismos %>%
  count(
    magType,
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
  ) %>%
  arrange(desc(numero_eventos))

print(eventos_magtype, n = Inf)


#Resumen de magnitud por magType----

magnitud_por_magtype <- sismos %>%
  group_by(magType) %>%
  summarise(
    numero_eventos = n(),
    magnitud_media = mean(mag, na.rm = TRUE),
    magnitud_mediana = median(mag, na.rm = TRUE),
    magnitud_desviacion = sd(mag, na.rm = TRUE),
    magnitud_minima = min(mag, na.rm = TRUE),
    magnitud_maxima = max(mag, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(numero_eventos))

print(magnitud_por_magtype, n = Inf)


#Evolucion temporal de magType----
#Permite ver el cambio metodologico del catalogo a lo largo del periodo.

magtype_anio <- sismos %>%
  count(año, magType, name = "numero_eventos") %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    magType,
    fill = list(numero_eventos = 0)
  ) %>%
  arrange(año, magType)

print(magtype_anio, n = Inf)


#Relacion entre magType y magSource----
#Revisa que agencia (magSource) reporta cada tipo de magnitud.

magtype_magsource <- sismos %>%
  count(magType, magSource, name = "numero_eventos") %>%
  arrange(magType, desc(numero_eventos))

print(magtype_magsource, n = Inf)


#Grafico de eventos por magType----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 5, 4, 2) + 0.1)

barras_magtype <- barplot(
  eventos_magtype$numero_eventos,
  names.arg = eventos_magtype$magType,
  col = "gray80",
  border = "gray30",
  las = 1,
  cex.names = 0.9,
  ylim = c(0, max(eventos_magtype$numero_eventos) * 1.18),
  ylab = "Numero de eventos",
  main = "Eventos segun tipo de magnitud"
)

text(
  x = barras_magtype,
  y = eventos_magtype$numero_eventos,
  labels = paste0(
    eventos_magtype$numero_eventos,
    " (",
    format(eventos_magtype$porcentaje, decimal.mark = ",", nsmall = 1),
    "%)"
  ),
  pos = 3,
  cex = 0.8
)

box()

#Restablecer parametros graficos----
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)




#Analisis descriptivo de la variable sig----
#sig: significancia del evento segun USGS. Indice numerico que resume la importancia
#del sismo a partir de magnitud, intensidad maxima, reportes sentidos e impacto estimado.
#A mayor valor, mas significativo el evento. Se incorporo a sismos mediante union por id.


##Resumen descriptivo de sig----

resumen_significancia <- sismos %>%
  summarise(
    significancia_media = mean(sig, na.rm = TRUE),
    significancia_mediana = median(sig, na.rm = TRUE),
    significancia_desviacion = sd(sig, na.rm = TRUE),
    significancia_minima = min(sig, na.rm = TRUE),
    significancia_maxima = max(sig, na.rm = TRUE),
    cuantil_25 = quantile(sig, 0.25, na.rm = TRUE),
    cuantil_50 = quantile(sig, 0.50, na.rm = TRUE),
    cuantil_75 = quantile(sig, 0.75, na.rm = TRUE),
    cuantil_90 = quantile(sig, 0.90, na.rm = TRUE),
    cuantil_95 = quantile(sig, 0.95, na.rm = TRUE)
  )

print(resumen_significancia)


##Datos faltantes en sig----

significancia_faltantes <- sismos %>%
  summarise(
    eventos_total = n(),
    eventos_sin_sig = sum(is.na(sig)),
    porcentaje_sin_sig = mean(is.na(sig)) * 100
  )

print(significancia_faltantes)


##Distribucion general de sig----

histograma_significancia <- hist(
  sismos$sig,
  breaks = "Sturges",
  plot = FALSE
)

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

plot(
  histograma_significancia,
  freq = TRUE,
  main = "Distribucion de eventos segun significancia",
  xlab = "Significancia (sig)",
  ylab = "Numero de eventos",
  col = "gray80",
  border = "gray30",
  ylim = c(0, max(histograma_significancia$counts) * 1.10)
)

abline(
  v = mean(sismos$sig, na.rm = TRUE),
  col = "black",
  lty = 2,
  lwd = 1.5
)

abline(
  v = median(sismos$sig, na.rm = TRUE),
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


##Eventos mas significativos----

eventos_mas_significativos <- sismos %>%
  arrange(desc(sig)) %>%
  select(id, fecha, año, place, zona, mag, depth, sig) %>%
  slice_head(n = 10)

print(eventos_mas_significativos, n = Inf)


##Significancia por zona----

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

par(mfrow = c(1, 1), bg = "white", mar = c(10, 4, 4, 2) + 0.1)

boxplot(
  sig ~ zona,
  data = sismos,
  main = "Distribucion de significancia por zona",
  xlab = "",
  ylab = "Significancia (sig)",
  col = unname(colores_zona[sort(unique(sismos$zona))]),
  border = "gray30",
  las = 2,
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


##Significancia segun magnitud_cat----

significancia_magnitud_cat <- sismos %>%
  group_by(magnitud_cat) %>%
  summarise(
    numero_eventos = n(),
    significancia_media = mean(sig, na.rm = TRUE),
    significancia_mediana = median(sig, na.rm = TRUE),
    significancia_desviacion = sd(sig, na.rm = TRUE),
    significancia_maxima = max(sig, na.rm = TRUE),
    .groups = "drop"
  )

print(significancia_magnitud_cat, n = Inf)


##Boxplot de sig segun magnitud_cat----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  sig ~ magnitud_cat,
  data = sismos,
  main = "Distribucion de significancia por categoria de magnitud",
  xlab = "Categoria de magnitud",
  ylab = "Significancia (sig)",
  col = "gray80",
  border = "gray30",
  las = 1,
  outline = TRUE
)

box()


##Significancia segun profundidad_cat----

significancia_profundidad_cat <- sismos %>%
  group_by(profundidad_cat) %>%
  summarise(
    numero_eventos = n(),
    significancia_media = mean(sig, na.rm = TRUE),
    significancia_mediana = median(sig, na.rm = TRUE),
    significancia_desviacion = sd(sig, na.rm = TRUE),
    significancia_maxima = max(sig, na.rm = TRUE),
    .groups = "drop"
  )

print(significancia_profundidad_cat, n = Inf)


##Relacion entre sig y mag----
#sig se construye en parte a partir de la magnitud, por lo que se espera correlacion alta.

correlacion_sig_mag <- cor(
  sismos$sig,
  sismos$mag,
  use = "complete.obs"
)

print(correlacion_sig_mag)

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

plot(
  sismos$mag,
  sismos$sig,
  main = "Relacion entre magnitud y significancia",
  xlab = "Magnitud",
  ylab = "Significancia (sig)",
  pch = 19,
  col = "gray50",
  cex = 0.6
)

abline(
  lm(sig ~ mag, data = sismos),
  col = "red",
  lwd = 1.5
)

box()


##Correlaciones robustas de sig con otras variables numericas----
#sig esta sesgada a la derecha, por lo que se usa Spearman (basada en rangos) como
#medida principal, con Pearson como referencia. Cada par usa sus casos completos,
#usando las versiones imputadas nst_imp y rms_imp. Se suprime la advertencia por empates.

variables_sig <- c("mag", "depth", "nst_imp", "rms_imp")

correlaciones_sig <- tibble::tibble(
  variable = variables_sig,
  observaciones = sapply(
    variables_sig,
    function(v) sum(complete.cases(sismos$sig, sismos[[v]]))
  ),
  correlacion_pearson = sapply(
    variables_sig,
    function(v) cor(sismos$sig, sismos[[v]], method = "pearson", use = "complete.obs")
  ),
  correlacion_spearman = sapply(
    variables_sig,
    function(v) cor(sismos$sig, sismos[[v]], method = "spearman", use = "complete.obs")
  ),
  valor_p_spearman = sapply(
    variables_sig,
    function(v) suppressWarnings(
      cor.test(sismos$sig, sismos[[v]], method = "spearman", use = "complete.obs")
    )$p.value
  )
) %>%
  arrange(desc(abs(correlacion_spearman)))

print(correlaciones_sig)


##Significancia maxima anual----

significancia_maxima_anual <- sismos %>%
  group_by(año) %>%
  summarise(
    significancia_media = mean(sig, na.rm = TRUE),
    significancia_maxima = max(sig, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    fill = list(significancia_media = 0, significancia_maxima = 0)
  ) %>%
  arrange(año)

print(significancia_maxima_anual, n = Inf)


#Restablecer parametros graficos----
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)

# La variable sig corresponde al puntaje de significancia asignado por USGS 
# a cada evento sísmico. Este indicador no representa una propiedad física única, 
# sino una medida compuesta de relevancia del evento, asociada a factores como magnitud, 
# intensidad, reportes de percepción e impacto estimado. En la base analizada, sig varía 
# entre 650 y 2910, por lo que todos los eventos corresponden a terremotos de alta significancia 
# dentro del catálogo USGS. Valores mayores indican eventos más relevantes o con mayor impacto relativo.