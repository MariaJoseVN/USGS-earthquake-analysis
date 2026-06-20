#Consideraciones----
#Este script utiliza la base preparada en Codigo.R.


#Preparacion temporal----
sismos_temporal <- sismos %>%
  mutate(
    fecha_mes = floor_date(fecha, unit = "month"),
    decada = floor(año / 10) * 10,
    evento_m70 = mag >= 7.0,
    evento_m75 = mag >= 7.5,
    evento_m80 = mag >= 8.0
  )

#Conteos/Frecuencias----
##Conteo mensual para catálogo completo y eventos por umbral de magnitud----
conteo_mensual <- sismos_temporal %>%
  group_by(fecha_mes) %>%
  summarise(
    n_catalogo_completo = n(),
    n_eventos_m70_o_mayor = sum(evento_m70, na.rm = TRUE),
    n_eventos_m75_o_mayor = sum(evento_m75, na.rm = TRUE),
    n_eventos_m80_o_mayor = sum(evento_m80, na.rm = TRUE),
    .groups = "drop"
  ) %>%         #Solo ejecutando hasta esta parte ya obtendriamos un resultado, pero resulta que hay 11 meses no registraron terremotos y al agrupar se consideran como "NA" en lugar de rellenar con "ceros"
  tidyr::complete( #Este fragmento extra añade los "ceros" en lugar de dejar los "NA"
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


##Conteo anual para catalogo completo y eventos por umbral de magnitud----
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

##Conteo decadal para catalogo completo y eventos por umbral de magnitud----
conteo_decadal <- sismos_temporal %>%
  group_by(decada) %>%
  summarise(
    n_catalogo_completo = n(),
    n_eventos_m70_o_mayor = sum(evento_m70, na.rm = TRUE),
    n_eventos_m75_o_mayor = sum(evento_m75, na.rm = TRUE),
    n_eventos_m80_o_mayor = sum(evento_m80, na.rm = TRUE),
    .groups = "drop"
  )

print(conteo_decadal, n = Inf)

#Serie Temporal de Conteos----

##Serie mensual del catálogo completo----
serie_mensual_catalogo_completo <- ts(
  conteo_mensual$n_catalogo_completo,
  start = c(2000, 1),
  frequency = 12
)

serie_mensual_catalogo_completo
summary(serie_mensual_catalogo_completo)

##Serie mensual de eventos M >= 7.0----
serie_mensual_m70 <- ts(
  conteo_mensual$n_eventos_m70_o_mayor,
  start = c(2000, 1),
  frequency = 12
)

serie_mensual_m70
summary(serie_mensual_m70)

##Serie anual del catálogo completo----
serie_anual_catalogo_completo <- ts(
  conteo_anual$n_catalogo_completo,
  start = 2000,
  frequency = 1
)

serie_anual_catalogo_completo
summary(serie_anual_catalogo_completo)

##Serie anual de eventos M >= 7.0----
serie_anual_m70 <- ts(
  conteo_anual$n_eventos_m70_o_mayor,
  start = 2000,
  frequency = 1
)

serie_anual_m70
summary(serie_anual_m70)

#Visualizacipon de Series Temporales----

#Visualizacion inicial de series temporales----

indice_mensual <- 1:nrow(conteo_mensual)
indice_anual <- conteo_anual$año

marcas_mensuales <- seq(12, nrow(conteo_mensual), by = 12)
marcas_anuales <- conteo_anual$año

par(mfrow = c(2, 1))

##Visualización Mensual completa----

plot(
  indice_mensual,
  conteo_mensual$n_catalogo_completo,
  type = "l",
  main = "Serie mensual - Catálogo completo",
  ylab = "Número de eventos",
  xlab = "Meses observado",
  col = "darkblue",
  lwd = 1,
  xaxt = "n"
)

abline(h = summary(serie_mensual_catalogo_completo)["Mean"], col = "darkblue", lty = 2, lwd = 1.5)

legend(
  "topright",
  legend = c("Conteo observado", "Media"),
  col = c("darkblue", "darkblue"),
  lty = c(1, 2),
  lwd = c(1, 1.5),
  bty = "n",
  cex = 0.8
)

axis(
  side = 1,
  at = marcas_mensuales,
  labels = marcas_mensuales,
  las = 2,
  cex.axis = 0.7
)

##Visualización Mensual mayor 70----

plot(
  indice_mensual,
  conteo_mensual$n_eventos_m70_o_mayor,
  type = "l",
  main = "Serie mensual - M >= 7.0",
  ylab = "Número de eventos",
  xlab = "Meses observado",
  col = "red",
  lwd = 1,
  xaxt = "n"
)

abline(h = summary(serie_mensual_m70)["Mean"], col = "red", lty = 2, lwd = 1.5)

legend(
  "topright",
  legend = c("Conteo observado", "Media"),
  col = c("red", "red"),
  lty = c(1, 2),
  lwd = c(1, 1.5),
  bty = "n",
  cex = 0.8
)

axis(
  side = 1,
  at = marcas_mensuales,
  labels = marcas_mensuales,
  las = 2,
  cex.axis = 0.7
)

##Visualización anual completa----
plot(
  indice_anual,
  conteo_anual$n_catalogo_completo,
  type = "l",
  main = "Serie anual - Catálogo completo",
  ylab = "Número de eventos",
  xlab = "Años",
  col = "darkblue",
  lwd = 1,
  xaxt = "n"
)

abline(h = summary(serie_anual_catalogo_completo)["Mean"], col = "darkblue", lty = 2, lwd = 1.5)

legend(
  "topright",
  legend = c("Conteo observado", "Media"),
  col = c("darkblue", "darkblue"),
  lty = c(1, 2),
  lwd = c(1, 1.5),
  bty = "n",
  cex = 0.8
)

axis(
  side = 1,
  at = marcas_anuales,
  labels = marcas_anuales,
  las = 2,
  cex.axis = 0.7
)

##Visualización anual mayor 70----

plot(
  indice_anual,
  conteo_anual$n_eventos_m70_o_mayor,
  type = "l",
  main = "Serie anual - M >= 7.0",
  ylab = "Número de eventos",
  xlab = "Años",
  col = "red",
  lwd = 1,
  xaxt = "n"
)

abline(h = summary(serie_anual_m70)["Mean"], col = "red", lty = 2, lwd = 1.5)

legend(
  "topright",
  legend = c("Conteo observado", "Media"),
  col = c("red", "red"),
  lty = c(1, 2),
  lwd = c(1, 1.5),
  bty = "n",
  cex = 0.8
)

axis(
  side = 1,
  at = marcas_anuales,
  labels = marcas_anuales,
  las = 2,
  cex.axis = 0.7
)

par(mfrow = c(1, 1))

#Caracterizacion descriptiva temporal----

##Eventos anuales del catalogo completo----

pos_barras_anual_catalogo <- barplot(
  height = conteo_anual$n_catalogo_completo,
  names.arg = conteo_anual$año,
  main = "Eventos anuales - Catalogo completo",
  ylab = "Numero de eventos",
  xlab = "Años",
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
  cex = 0.7
)

axis(
  side = 2,
  las = 1,
  lwd = 0,
  lwd.ticks = 1
)

abline(
  h = summary(serie_anual_catalogo_completo)["Mean"],
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

##Eventos anuales M >= 7.0----

pos_barras_anual_m70 <- barplot(
  height = conteo_anual$n_eventos_m70_o_mayor,
  names.arg = conteo_anual$año,
  main = "Eventos anuales - M >= 7.0",
  ylab = "Numero de eventos",
  xlab = "Años",
  col = "gray80",
  border = "gray30",
  las = 2,
  cex.names = 0.7,
  ylim = c(0, max(conteo_anual$n_eventos_m70_o_mayor) + 4),
  axes = FALSE
)

text(
  x = pos_barras_anual_m70,
  y = conteo_anual$n_eventos_m70_o_mayor,
  labels = conteo_anual$n_eventos_m70_o_mayor,
  pos = 3,
  cex = 0.7
)

axis(
  side = 2,
  las = 1,
  lwd = 0,
  lwd.ticks = 1
)

abline(
  h = summary(serie_anual_m70)["Mean"],
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

##Eventos por decada del catalogo completo----

pos_barras_decadal_catalogo <- barplot(
  height = conteo_decadal$n_catalogo_completo,
  names.arg = conteo_decadal$decada,
  main = "Eventos por decada - Catalogo completo",
  ylab = "Numero de eventos",
  xlab = "Decada",
  col = "gray80",
  border = "gray30",
  las = 1,
  cex.names = 0.8,
  ylim = c(0, max(conteo_decadal$n_catalogo_completo) * 1.15),
  axes = FALSE
)

text(
  x = pos_barras_decadal_catalogo,
  y = conteo_decadal$n_catalogo_completo,
  labels = conteo_decadal$n_catalogo_completo,
  pos = 3,
  cex = 0.8
)

axis(
  side = 2,
  las = 1,
  lwd = 0,
  lwd.ticks = 1
)

abline(
  h = mean(conteo_decadal$n_catalogo_completo, na.rm = TRUE),
  col = "black",
  lty = 2,
  lwd = 1.5
)

legend(
  "topright",
  legend = c("Conteo decadal", "Media decadal"),
  fill = c("gray80", NA),
  border = c("gray30", NA),
  lty = c(NA, 2),
  col = c(NA, "black"),
  lwd = c(NA, 1.5),
  bty = "n",
  cex = 0.8
)

box()

##Eventos por decada M >= 7.0----

pos_barras_decadal_m70 <- barplot(
  height = conteo_decadal$n_eventos_m70_o_mayor,
  names.arg = conteo_decadal$decada,
  main = "Eventos por decada - M >= 7.0",
  ylab = "Numero de eventos",
  xlab = "Decada",
  col = "gray80",
  border = "gray30",
  las = 1,
  cex.names = 0.8,
  ylim = c(0, max(conteo_decadal$n_eventos_m70_o_mayor) * 1.15),
  axes = FALSE
)

text(
  x = pos_barras_decadal_m70,
  y = conteo_decadal$n_eventos_m70_o_mayor,
  labels = conteo_decadal$n_eventos_m70_o_mayor,
  pos = 3,
  cex = 0.8
)

axis(
  side = 2,
  las = 1,
  lwd = 0,
  lwd.ticks = 1
)

abline(
  h = mean(conteo_decadal$n_eventos_m70_o_mayor, na.rm = TRUE),
  col = "black",
  lty = 2,
  lwd = 1.5
)

legend(
  "topright",
  legend = c("Conteo decadal", "Media decadal"),
  fill = c("gray80", NA),
  border = c("gray30", NA),
  lty = c(NA, 2),
  col = c(NA, "black"),
  lwd = c(NA, 1.5),
  bty = "n",
  cex = 0.8
)

box()


