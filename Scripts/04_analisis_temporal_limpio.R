graphics.off()


#Selección de análisis----
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

###Gráfico Conteo Mensual y Anual----
par(mfrow = c(1, 2), bg = "white", mar = c(6, 4, 4, 2) + 0.1)

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

fila_fuerte <- which(rownames(matriz_anual_magnitud) == "Fuerte")

totales_acumulados <- apply(matriz_anual_magnitud, 2, cumsum)
posiciones_texto <- totales_acumulados - matriz_anual_magnitud / 2

colores_texto <- matrix(
  "white",
  nrow = nrow(matriz_anual_magnitud),
  ncol = ncol(matriz_anual_magnitud)
)

colores_texto[fila_fuerte, ] <- "black"

text(
  x = rep(pos_barras_anual_magnitud, each = nrow(matriz_anual_magnitud)),
  y = as.vector(posiciones_texto),
  labels = ifelse(
    as.vector(matriz_anual_magnitud) > 0,
    as.vector(matriz_anual_magnitud),
    ""
  ),
  cex = 0.55,
  col = as.vector(colores_texto)
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

par(mfrow = c(1, 1))

##Conteo mensual----
conteo_decadal_cat <- sismos_temporal_cat %>%
  count(decada, magnitud_cat, name = "n_eventos", .drop = FALSE) %>%
  tidyr::complete(
    decada,
    magnitud_cat = levels(sismos_temporal_cat$magnitud_cat),
    fill = list(n_eventos = 0)
  ) %>%
  mutate(
    años_observados = case_when(
      decada == 2000 ~ 10,
      decada == 2010 ~ 10,
      decada == 2020 ~ 6
    ),
    tasa_anual = n_eventos / años_observados
  )

print(conteo_decadal_cat, n = Inf)
