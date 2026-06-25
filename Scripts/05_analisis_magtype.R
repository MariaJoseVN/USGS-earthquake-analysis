#Analisis de las variables magType y magSource----
#Este script utiliza la base preparada en Codigo.R.
#magType indica el metodo/escala con que se estimo la magnitud y magSource la agencia que la reporto.
#Ambas son categoricas: las descriptivas son frecuencias, modas, tablas de contingencia y asociacion.
#No guarda graficos; las salidas se revisan directamente en consola y panel grafico.


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
  arrange(desc(numero_eventos)) %>%
  mutate(
    proporcion = numero_eventos / if_else(
      sum(numero_eventos) == 0,
      1,
      sum(numero_eventos)
    ),
    porcentaje = proporcion * 100,
  )

print(eventos_magtype, n = Inf)


#Distribucion de eventos segun magSource----

eventos_magsource <- sismos %>%
  count(
    magSource,
    name = "numero_eventos",
    .drop = FALSE
  ) %>%
  arrange(desc(numero_eventos)) %>%
  mutate(
    proporcion = numero_eventos / if_else(
      sum(numero_eventos) == 0,
      1,
      sum(numero_eventos)
    ),
    porcentaje = proporcion * 100,
  )

print(eventos_magsource, n = Inf)


#Resumen de categorias: numero de niveles, moda y concentracion----

resumen_categorias <- tibble::tibble(
  variable = c("magType", "magSource"),
  categorias_distintas = c(
    n_distinct(sismos$magType),
    n_distinct(sismos$magSource)
  ),
  categoria_dominante = c(
    eventos_magtype$magType[1],
    eventos_magsource$magSource[1]
  ),
  porcentaje_dominante = c(
    eventos_magtype$porcentaje[1],
    eventos_magsource$porcentaje[1]
  )
)

print(resumen_categorias)


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


#Distribucion de mag por magType----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  mag ~ magType,
  data = sismos,
  main = "Distribucion de magnitud por tipo de magnitud",
  xlab = "Tipo de magnitud",
  ylab = "Magnitud",
  col = "gray80",
  border = "gray30",
  las = 1,
  outline = TRUE
)

points(
  x = seq_along(sort(unique(sismos$magType))),
  y = tapply(sismos$mag, sismos$magType, mean, na.rm = TRUE)[sort(unique(sismos$magType))],
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


#Relacion entre magType y magSource----
#Revisa que agencia (magSource) reporta cada tipo de magnitud, con proporciones por fila.

magtype_magsource <- sismos %>%
  count(magType, magSource, name = "numero_eventos") %>%
  group_by(magType) %>%
  mutate(
    proporcion_fila = numero_eventos / sum(numero_eventos),
    porcentaje_fila = proporcion_fila * 100
  ) %>%
  ungroup() %>%
  arrange(magType, desc(numero_eventos))

print(magtype_magsource, n = Inf)


##Medida de asociacion: chi-cuadrado y V de Cramer----
#La V de Cramer (0 a 1) cuantifica la fuerza de la relacion magType - magSource.
#Se calcula en R base a partir de chisq.test, sin paquetes adicionales.
#Se suprime la advertencia de aproximacion por celdas con frecuencia esperada baja.

tabla_contingencia <- table(sismos$magType, sismos$magSource)

prueba_chi <- suppressWarnings(chisq.test(tabla_contingencia))

v_cramer <- sqrt(
  as.numeric(prueba_chi$statistic) /
    (sum(tabla_contingencia) * (min(dim(tabla_contingencia)) - 1))
)

asociacion_magtype_magsource <- tibble::tibble(
  estadistico_chi = as.numeric(prueba_chi$statistic),
  grados_libertad = as.numeric(prueba_chi$parameter),
  valor_p = prueba_chi$p.value,
  v_cramer = v_cramer
)

print(asociacion_magtype_magsource)


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


##Vigencia de cada magType y magSource----
#Primer y ultimo año en que aparece cada categoria.

vigencia_magtype <- sismos %>%
  group_by(magType) %>%
  summarise(
    numero_eventos = n(),
    primer_año = min(año, na.rm = TRUE),
    ultimo_año = max(año, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(primer_año, magType)

print(vigencia_magtype, n = Inf)

vigencia_magsource <- sismos %>%
  group_by(magSource) %>%
  summarise(
    numero_eventos = n(),
    primer_año = min(año, na.rm = TRUE),
    ultimo_año = max(año, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(primer_año, magSource)

print(vigencia_magsource, n = Inf)


##Participacion anual del metodo dominante (mww)----
#Muestra el quiebre metodologico del catalogo en torno a 2010.

participacion_mww_anual <- sismos %>%
  group_by(año) %>%
  summarise(
    eventos_total = n(),
    eventos_mww = sum(magType == "mww"),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    fill = list(eventos_total = 0, eventos_mww = 0)
  ) %>%
  mutate(
    porcentaje_mww = if_else(
      eventos_total == 0,
      0,
      eventos_mww / eventos_total * 100
    )
  ) %>%
  arrange(año)

print(participacion_mww_anual, n = Inf)


#Relacion entre magType y zona----
#Detecta si alguna zona se reporta sistematicamente con otro metodo o agencia.

magtype_zona <- sismos %>%
  count(zona, magType, name = "numero_eventos") %>%
  group_by(zona) %>%
  mutate(
    proporcion = numero_eventos / sum(numero_eventos),
    porcentaje = proporcion * 100
  ) %>%
  ungroup() %>%
  arrange(zona, desc(numero_eventos))

print(magtype_zona, n = Inf)


#Relacion entre magType y status----
#Revisa si los eventos revisados o automaticos usan distinto metodo.

magtype_status <- sismos %>%
  count(status, magType, name = "numero_eventos") %>%
  group_by(status) %>%
  mutate(
    proporcion = numero_eventos / sum(numero_eventos),
    porcentaje = proporcion * 100
  ) %>%
  ungroup() %>%
  arrange(status, desc(numero_eventos))

print(magtype_status, n = Inf)


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


#Grafico de eventos por magSource----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 5, 4, 2) + 0.1)

barras_magsource <- barplot(
  eventos_magsource$numero_eventos,
  names.arg = eventos_magsource$magSource,
  col = "gray80",
  border = "gray30",
  las = 2,
  cex.names = 0.8,
  ylim = c(0, max(eventos_magsource$numero_eventos) * 1.18),
  ylab = "Numero de eventos",
  main = "Eventos segun agencia reportante"
)

text(
  x = barras_magsource,
  y = eventos_magsource$numero_eventos,
  labels = eventos_magsource$numero_eventos,
  pos = 3,
  cex = 0.75
)

box()


#Restablecer parametros graficos----

par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)
