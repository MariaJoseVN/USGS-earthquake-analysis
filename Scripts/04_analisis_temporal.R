#Consideraciones----
#Este script utiliza la base preparada en Código.R.
#Su propósito es explorar la dimensión temporal de los eventos sísmicos.
#No guarda gráficos; las salidas se revisan directamente en consola y panel gráfico.

#Reiniciar dispositivo gráfico----
#Si una ejecución anterior dejó abierto un dispositivo externo, por ejemplo png(),
#los gráficos pueden no aparecer en el panel gráfico. Esta línea limpia la sesión
#antes de iniciar el análisis temporal.
graphics.off()


#Preparación temporal----
#La base sismos ya contiene fecha_hora_utc, fecha, año, mes, decada,
#magnitud_cat y magType_grupo.
#Aquí se agregan variables auxiliares para agregación mensual y umbrales.

sismos_temporal <- sismos %>%
  mutate(
    fecha_mes = floor_date(fecha, unit = "month"),
    evento_m70 = mag >= 7.0,
    evento_m75 = mag >= 7.5,
    evento_m80 = mag >= 8.0
  )

print(sismos_temporal)


#Conteos temporales----
##Conteo mensual para catálogo completo y eventos por umbral de magnitud----
#La serie mensual se completa con ceros porque los meses sin eventos representan
#ausencia observada de terremotos en el catálogo, no datos faltantes.

conteo_mensual <- sismos_temporal %>%
  group_by(fecha_mes) %>%
  summarise(
    n_catalogo_completo = n(),
    n_eventos_m70_o_mayor = sum(evento_m70, na.rm = TRUE),
    n_eventos_m75_o_mayor = sum(evento_m75, na.rm = TRUE),
    n_eventos_m80_o_mayor = sum(evento_m80, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    fecha_mes = seq.Date(
      from = as.Date("2000-01-01"),
      to = as.Date("2025-12-01"),
      by = "month"
    ),
    fill = list(
      n_catalogo_completo = 0,
      n_eventos_m70_o_mayor = 0,
      n_eventos_m75_o_mayor = 0,
      n_eventos_m80_o_mayor = 0
    )
  )

print(conteo_mensual, n = Inf)


##Conteo anual para catálogo completo y eventos por umbral de magnitud----

conteo_anual <- sismos_temporal %>%
  group_by(año) %>%
  summarise(
    n_catalogo_completo = n(),
    n_eventos_m70_o_mayor = sum(evento_m70, na.rm = TRUE),
    n_eventos_m75_o_mayor = sum(evento_m75, na.rm = TRUE),
    n_eventos_m80_o_mayor = sum(evento_m80, na.rm = TRUE),
    .groups = "drop"
  )

print(conteo_anual, n = Inf)


##Conteo decadal y tasas anuales promedio----
#La tasa anual promedio permite comparar décadas completas con 2020-2025,
#que corresponde a un período observado de seis años.

conteo_decadal <- sismos_temporal %>%
  group_by(decada) %>%
  summarise(
    n_catalogo_completo = n(),
    n_eventos_m70_o_mayor = sum(evento_m70, na.rm = TRUE),
    n_eventos_m75_o_mayor = sum(evento_m75, na.rm = TRUE),
    n_eventos_m80_o_mayor = sum(evento_m80, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    años_observados = case_when(
      decada == 2000 ~ 10,
      decada == 2010 ~ 10,
      decada == 2020 ~ 6
    ),
    tasa_anual_catalogo_completo = n_catalogo_completo / años_observados,
    tasa_anual_m70_o_mayor = n_eventos_m70_o_mayor / años_observados,
    tasa_anual_m75_o_mayor = n_eventos_m75_o_mayor / años_observados,
    tasa_anual_m80_o_mayor = n_eventos_m80_o_mayor / años_observados
  )

print(conteo_decadal, n = Inf)


#Series temporales----
##Serie mensual del catálogo completo----

serie_mensual_catalogo_completo <- ts(
  conteo_mensual$n_catalogo_completo,
  start = c(2000, 1),
  frequency = 12
)

print(serie_mensual_catalogo_completo)
summary(serie_mensual_catalogo_completo)


##Serie mensual de eventos M >= 7.0----

serie_mensual_m70 <- ts(
  conteo_mensual$n_eventos_m70_o_mayor,
  start = c(2000, 1),
  frequency = 12
)

print(serie_mensual_m70)
summary(serie_mensual_m70)


##Serie anual del catálogo completo----

serie_anual_catalogo_completo <- ts(
  conteo_anual$n_catalogo_completo,
  start = 2000,
  frequency = 1
)

print(serie_anual_catalogo_completo)
summary(serie_anual_catalogo_completo)


##Serie anual de eventos M >= 7.0----

serie_anual_m70 <- ts(
  conteo_anual$n_eventos_m70_o_mayor,
  start = 2000,
  frequency = 1
)

print(serie_anual_m70)
summary(serie_anual_m70)


#Gráficos de series temporales----

indice_mensual <- 1:nrow(conteo_mensual)
indice_anual <- conteo_anual$año
marcas_mensuales <- seq(12, nrow(conteo_mensual), by = 24)
marcas_anuales <- conteo_anual$año


##Serie mensual - catálogo completo----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

plot(
  indice_mensual,
  conteo_mensual$n_catalogo_completo,
  type = "l",
  main = "Serie mensual - Catálogo completo",
  xlab = "Mes observado",
  ylab = "Número de eventos",
  col = "darkblue",
  lwd = 1,
  xaxt = "n"
)

axis(
  side = 1,
  at = marcas_mensuales,
  labels = marcas_mensuales,
  las = 2,
  cex.axis = 0.7
)

abline(
  h = mean(conteo_mensual$n_catalogo_completo, na.rm = TRUE),
  col = "darkblue",
  lty = 2,
  lwd = 1.5
)

legend(
  "topright",
  legend = c("Conteo observado", "Media"),
  col = c("darkblue", "darkblue"),
  lty = c(1, 2),
  lwd = c(1, 1.5),
  bty = "n",
  cex = 0.8
)

box()


##Serie anual - catálogo completo----

par(mfrow = c(1, 1), bg = "white", mar = c(6, 4, 4, 2) + 0.1)

plot(
  indice_anual,
  conteo_anual$n_catalogo_completo,
  type = "l",
  main = "Serie anual - Catálogo completo",
  xlab = "Año",
  ylab = "Número de eventos",
  col = "darkblue",
  lwd = 1.5,
  xaxt = "n"
)

axis(
  side = 1,
  at = marcas_anuales,
  labels = marcas_anuales,
  las = 2,
  cex.axis = 0.7
)

abline(
  h = mean(conteo_anual$n_catalogo_completo, na.rm = TRUE),
  col = "darkblue",
  lty = 2,
  lwd = 1.5
)

legend(
  "topright",
  legend = c("Conteo observado", "Media"),
  col = c("darkblue", "darkblue"),
  lty = c(1, 2),
  lwd = c(1.5, 1.5),
  bty = "n",
  cex = 0.8
)

box()


##Serie anual - eventos M >= 7.0----

par(mfrow = c(1, 1), bg = "white", mar = c(6, 4, 4, 2) + 0.1)

plot(
  indice_anual,
  conteo_anual$n_eventos_m70_o_mayor,
  type = "l",
  main = "Serie anual - M >= 7.0",
  xlab = "Año",
  ylab = "Número de eventos",
  col = "red",
  lwd = 1.5,
  xaxt = "n"
)

axis(
  side = 1,
  at = marcas_anuales,
  labels = marcas_anuales,
  las = 2,
  cex.axis = 0.7
)

abline(
  h = mean(conteo_anual$n_eventos_m70_o_mayor, na.rm = TRUE),
  col = "red",
  lty = 2,
  lwd = 1.5
)

legend(
  "topright",
  legend = c("Conteo observado", "Media"),
  col = c("red", "red"),
  lty = c(1, 2),
  lwd = c(1.5, 1.5),
  bty = "n",
  cex = 0.8
)

box()


#Caracterización anual y decadal----
##Eventos anuales del catálogo completo----

par(mfrow = c(1, 1), bg = "white", mar = c(6, 4, 4, 2) + 0.1)

pos_barras_anual_catalogo <- barplot(
  height = conteo_anual$n_catalogo_completo,
  names.arg = conteo_anual$año,
  main = "Eventos anuales - Catálogo completo",
  xlab = "Año",
  ylab = "Número de eventos",
  col = "gray80",
  border = "gray30",
  las = 2,
  cex.names = 0.7,
  ylim = c(0, max(conteo_anual$n_catalogo_completo) + 8),
  axes = FALSE
)

text(
  x = pos_barras_anual_catalogo,
  y = conteo_anual$n_catalogo_completo,
  labels = conteo_anual$n_catalogo_completo,
  pos = 3,
  cex = 0.65
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

abline(
  h = mean(conteo_anual$n_catalogo_completo, na.rm = TRUE),
  col = "black",
  lty = 2,
  lwd = 1.5
)

legend(
  "topright",
  legend = c("Conteo anual", "Media anual"),
  fill = c("gray80", NA),
  border = c("gray30", NA),
  lty = c(NA, 2),
  col = c(NA, "black"),
  lwd = c(NA, 1.5),
  bty = "n",
  cex = 0.8
)

box()


##Tasa anual promedio por década - eventos M >= 7.0----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

pos_barras_tasa_decadal_m70 <- barplot(
  height = conteo_decadal$tasa_anual_m70_o_mayor,
  names.arg = conteo_decadal$decada,
  main = "Tasa anual promedio por década - M >= 7.0",
  xlab = "Década",
  ylab = "Eventos promedio por año",
  col = "gray80",
  border = "gray30",
  las = 1,
  ylim = c(0, max(conteo_decadal$tasa_anual_m70_o_mayor) * 1.25),
  axes = FALSE
)

text(
  x = pos_barras_tasa_decadal_m70,
  y = conteo_decadal$tasa_anual_m70_o_mayor,
  labels = round(conteo_decadal$tasa_anual_m70_o_mayor, 1),
  pos = 3,
  cex = 0.85
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

abline(
  h = mean(conteo_decadal$tasa_anual_m70_o_mayor, na.rm = TRUE),
  col = "black",
  lty = 2,
  lwd = 1.5
)

legend(
  "topright",
  legend = c("Tasa anual promedio", "Media de tasas"),
  fill = c("gray80", NA),
  border = c("gray30", NA),
  lty = c(NA, 2),
  col = c(NA, "black"),
  lwd = c(NA, 1.5),
  bty = "n",
  cex = 0.8
)

box()


#Recurrencia temporal----
##Eventos M >= 7.0 ordenados temporalmente----

eventos_m70 <- sismos_temporal %>%
  filter(evento_m70) %>%
  arrange(fecha_hora_utc) %>%
  mutate(
    dias_desde_evento_anterior = as.numeric(
      difftime(fecha_hora_utc, lag(fecha_hora_utc), units = "days")
    )
  )

print(eventos_m70, n = Inf)


##Resumen de días entre eventos M >= 7.0----

resumen_recurrencia_m70 <- eventos_m70 %>%
  summarise(
    n_eventos = n(),
    n_intervalos = sum(!is.na(dias_desde_evento_anterior)),
    tiempo_medio_dias = mean(dias_desde_evento_anterior, na.rm = TRUE),
    tiempo_mediano_dias = median(dias_desde_evento_anterior, na.rm = TRUE),
    q1_dias = quantile(dias_desde_evento_anterior, 0.25, na.rm = TRUE),
    q3_dias = quantile(dias_desde_evento_anterior, 0.75, na.rm = TRUE),
    tiempo_minimo_dias = min(dias_desde_evento_anterior, na.rm = TRUE),
    tiempo_maximo_dias = max(dias_desde_evento_anterior, na.rm = TRUE)
  )

print(resumen_recurrencia_m70)


##Distribución de días entre eventos M >= 7.0----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

hist(
  eventos_m70$dias_desde_evento_anterior,
  main = "Días entre eventos M >= 7.0",
  xlab = "Días desde el evento anterior",
  ylab = "Frecuencia",
  col = "gray80",
  border = "gray30",
  axes = FALSE
)

axis(side = 1, lwd = 0, lwd.ticks = 1)
axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

abline(
  v = resumen_recurrencia_m70$tiempo_medio_dias,
  col = "black",
  lty = 2,
  lwd = 1.5
)

abline(
  v = resumen_recurrencia_m70$tiempo_mediano_dias,
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


##Recurrencia por década----
#La comparación por década se interpreta como recurrencia temporal global del
#catálogo analizado, no como recurrencia física de una zona tectónica específica.

eventos_m70_recurrencia_decadal <- eventos_m70 %>%
  filter(!is.na(dias_desde_evento_anterior))

resumen_recurrencia_decadal_m70 <- eventos_m70_recurrencia_decadal %>%
  group_by(decada) %>%
  summarise(
    n_intervalos = n(),
    tiempo_medio_dias = mean(dias_desde_evento_anterior, na.rm = TRUE),
    tiempo_mediano_dias = median(dias_desde_evento_anterior, na.rm = TRUE),
    q1_dias = quantile(dias_desde_evento_anterior, 0.25, na.rm = TRUE),
    q3_dias = quantile(dias_desde_evento_anterior, 0.75, na.rm = TRUE),
    tiempo_minimo_dias = min(dias_desde_evento_anterior, na.rm = TRUE),
    tiempo_maximo_dias = max(dias_desde_evento_anterior, na.rm = TRUE),
    .groups = "drop"
  )

print(resumen_recurrencia_decadal_m70)

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  dias_desde_evento_anterior ~ decada,
  data = eventos_m70_recurrencia_decadal,
  main = "Días entre eventos M >= 7.0 por década",
  xlab = "Década",
  ylab = "Días desde el evento anterior",
  col = "gray80",
  border = "gray30"
)

box()


#Composición temporal por magnitud_cat----
##Conteo anual por magnitud_cat----

conteo_anual_magnitud_cat <- sismos_temporal %>%
  group_by(año, magnitud_cat) %>%
  summarise(
    n_eventos = n(),
    .groups = "drop"
  )

print(conteo_anual_magnitud_cat, n = Inf)


##Conteo decadal por magnitud_cat----

conteo_decadal_magnitud_cat <- sismos_temporal %>%
  group_by(decada, magnitud_cat) %>%
  summarise(
    n_eventos = n(),
    .groups = "drop"
  )

print(conteo_decadal_magnitud_cat, n = Inf)


##Composición anual por magnitud_cat----

tabla_anual_magnitud <- table(
  sismos_temporal$año,
  sismos_temporal$magnitud_cat
)

matriz_anual_magnitud <- t(tabla_anual_magnitud)

par(mfrow = c(1, 1), bg = "white", mar = c(6, 4, 4, 2) + 0.1)

pos_barras_anual_magnitud <- barplot(
  matriz_anual_magnitud,
  beside = FALSE,
  main = "Eventos anuales por magnitud_cat",
  xlab = "Año",
  ylab = "Número de eventos",
  col = c("gray85", "gray60", "gray30"),
  border = "gray30",
  las = 2,
  cex.names = 0.7,
  ylim = c(0, max(colSums(matriz_anual_magnitud)) * 1.15),
  axes = FALSE
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

legend(
  "topright",
  legend = colnames(tabla_anual_magnitud),
  fill = c("gray85", "gray60", "gray30"),
  border = "gray30",
  bty = "n",
  cex = 0.8
)

box()


##Composición decadal por magnitud_cat----

tabla_decadal_magnitud <- table(
  sismos_temporal$decada,
  sismos_temporal$magnitud_cat
)

matriz_decadal_magnitud <- t(tabla_decadal_magnitud)

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

pos_barras_decadal_magnitud <- barplot(
  matriz_decadal_magnitud,
  beside = FALSE,
  main = "Eventos por década según magnitud_cat",
  xlab = "Década",
  ylab = "Número de eventos",
  col = c("gray85", "gray60", "gray30"),
  border = "gray30",
  ylim = c(0, max(colSums(matriz_decadal_magnitud)) * 1.15),
  axes = FALSE
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

legend(
  "topright",
  legend = colnames(tabla_decadal_magnitud),
  fill = c("gray85", "gray60", "gray30"),
  border = "gray30",
  bty = "n",
  cex = 0.8
)

box()


#Composición temporal por magType----
##Conteo general por magType agrupado----
#magType identifica el método o algoritmo usado para calcular la magnitud
#preferida del evento. Para facilitar la lectura gráfica, se mantienen las tres
#categorías más frecuentes y el resto se reúne en "otros".

conteo_magtype_grupo <- sismos_temporal %>%
  count(magType_grupo, name = "n_eventos", .drop = FALSE) %>%
  mutate(
    porcentaje = n_eventos / sum(n_eventos) * 100
  ) %>%
  arrange(desc(n_eventos))

print(conteo_magtype_grupo, n = Inf)


##Conteo anual por magType agrupado----

conteo_anual_magtype_grupo <- sismos_temporal %>%
  group_by(año, magType_grupo) %>%
  summarise(
    n_eventos = n(),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    magType_grupo,
    fill = list(n_eventos = 0)
  )

print(conteo_anual_magtype_grupo, n = Inf)


##Porcentaje anual por magType agrupado----

porcentaje_anual_magtype_grupo <- conteo_anual_magtype_grupo %>%
  group_by(año) %>%
  mutate(
    porcentaje = n_eventos / sum(n_eventos) * 100
  ) %>%
  ungroup()

print(porcentaje_anual_magtype_grupo, n = Inf)


##Conteo decadal por magType agrupado----

conteo_decadal_magtype_grupo <- sismos_temporal %>%
  group_by(decada, magType_grupo) %>%
  summarise(
    n_eventos = n(),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    decada,
    magType_grupo,
    fill = list(n_eventos = 0)
  )

print(conteo_decadal_magtype_grupo, n = Inf)


##Porcentaje decadal por magType agrupado----

porcentaje_decadal_magtype_grupo <- conteo_decadal_magtype_grupo %>%
  group_by(decada) %>%
  mutate(
    porcentaje = n_eventos / sum(n_eventos) * 100
  ) %>%
  ungroup()

print(porcentaje_decadal_magtype_grupo, n = Inf)


##Composición anual por magType agrupado----

tabla_anual_magtype <- table(
  sismos_temporal$año,
  sismos_temporal$magType_grupo
)

matriz_anual_magtype <- t(tabla_anual_magtype)

colores_magtype <- grDevices::hcl.colors(
  n = nrow(matriz_anual_magtype),
  palette = "Dark 3"
)

par(mfrow = c(1, 1), bg = "white", mar = c(6, 4, 4, 8) + 0.1)

pos_barras_anual_magtype <- barplot(
  matriz_anual_magtype,
  beside = FALSE,
  main = "Eventos anuales por magType agrupado",
  xlab = "Año",
  ylab = "Número de eventos",
  col = colores_magtype,
  border = "gray30",
  las = 2,
  cex.names = 0.7,
  ylim = c(0, max(colSums(matriz_anual_magtype)) * 1.15),
  axes = FALSE
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

legend(
  "topright",
  inset = c(-0.22, 0),
  legend = rownames(matriz_anual_magtype),
  fill = colores_magtype,
  border = "gray30",
  bty = "n",
  cex = 0.8,
  xpd = TRUE
)

box()


##Composición porcentual por década según magType agrupado----

tabla_decadal_magtype <- table(
  sismos_temporal$decada,
  sismos_temporal$magType_grupo
)

matriz_decadal_magtype <- t(tabla_decadal_magtype)

matriz_decadal_magtype_porcentaje <- prop.table(
  matriz_decadal_magtype,
  margin = 2
) * 100

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 8) + 0.1)

pos_barras_decadal_magtype <- barplot(
  matriz_decadal_magtype_porcentaje,
  beside = FALSE,
  main = "Composición porcentual por década según magType agrupado",
  xlab = "Década",
  ylab = "Porcentaje de eventos",
  col = colores_magtype,
  border = "gray30",
  ylim = c(0, 100),
  axes = FALSE
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

legend(
  "topright",
  inset = c(-0.22, 0),
  legend = rownames(matriz_decadal_magtype_porcentaje),
  fill = colores_magtype,
  border = "gray30",
  bty = "n",
  cex = 0.8,
  xpd = TRUE
)

box()

