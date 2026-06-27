graphics.off()


# Preparacion temporal----

if (!exists("año_inicio")) año_inicio <- 2000
if (!exists("año_fin")) año_fin <- 2025

niveles_magnitud <- c("Fuerte", "Mayor", "Grande o extremo")
niveles_magtype <- c("mww", "mwc", "mwb", "otros")

sismos_temporal <- sismos %>%
  mutate(
    fecha_mes = floor_date(fecha, unit = "month"),
    magnitud_cat = factor(magnitud_cat, levels = niveles_magnitud),
    magType_grupo = factor(magType_grupo, levels = niveles_magtype)
  )


# Catalogo completo----
## Conteo anual y resumen para resultados----

conteo_anual <- sismos_temporal %>%
  group_by(año) %>%
  summarise(
    n_catalogo_completo = n(),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    fill = list(n_catalogo_completo = 0)
  )

resumen_anual_catalogo <- conteo_anual %>%
  summarise(
    n_eventos_periodo = sum(n_catalogo_completo),
    promedio_anual = mean(n_catalogo_completo),
    año_maximo = año[which.max(n_catalogo_completo)],
    maximo_anual = max(n_catalogo_completo),
    año_minimo = año[which.min(n_catalogo_completo)],
    minimo_anual = min(n_catalogo_completo)
  )


## Conteo mensual y series temporales----

conteo_mensual <- sismos_temporal %>%
  group_by(fecha_mes) %>%
  summarise(
    n_catalogo_completo = n(),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    fecha_mes = seq.Date(
      from = as.Date(paste0(año_inicio, "-01-01")),
      to = as.Date(paste0(año_fin, "-12-01")),
      by = "month"
    ),
    fill = list(n_catalogo_completo = 0)
  )

serie_mensual_catalogo_completo <- ts(
  conteo_mensual$n_catalogo_completo,
  start = c(año_inicio, 1),
  frequency = 12
)

serie_anual_catalogo_completo <- ts(
  conteo_anual$n_catalogo_completo,
  start = año_inicio,
  frequency = 1
)

resumen_serie_mensual_catalogo <- summary(serie_mensual_catalogo_completo)
resumen_serie_anual_catalogo <- summary(serie_anual_catalogo_completo)


# Composicion por categoria de magnitud----
## Conteo anual por magnitud_cat----

conteo_anual_magnitud_cat <- sismos_temporal %>%
  count(año, magnitud_cat, name = "n_eventos", .drop = FALSE) %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    magnitud_cat = niveles_magnitud,
    fill = list(n_eventos = 0)
  ) %>%
  mutate(
    magnitud_cat = factor(magnitud_cat, levels = niveles_magnitud)
  ) %>%
  arrange(año, magnitud_cat)

tabla_anual_magnitud <- table(
  sismos_temporal$año,
  sismos_temporal$magnitud_cat
)

matriz_anual_magnitud <- t(tabla_anual_magnitud)


## Conteo decadal por magnitud_cat----

conteo_decadal_cat <- sismos_temporal %>%
  count(decada, magnitud_cat, name = "n_eventos", .drop = FALSE) %>%
  tidyr::complete(
    decada = sort(unique(sismos_temporal$decada)),
    magnitud_cat = niveles_magnitud,
    fill = list(n_eventos = 0)
  ) %>%
  mutate(
    magnitud_cat = factor(magnitud_cat, levels = niveles_magnitud),
    años_observados = case_when(
      decada == 2000 ~ 10,
      decada == 2010 ~ 10,
      decada == 2020 ~ 6
    ),
    tasa_anual = n_eventos / años_observados
  ) %>%
  arrange(decada, magnitud_cat)

tabla_decadal_magnitud <- table(
  sismos_temporal$decada,
  sismos_temporal$magnitud_cat
)

matriz_decadal_magnitud <- t(tabla_decadal_magnitud)


# Recurrencia temporal por categorias----
## Grupo agregado Mayor o Grande o extremo----

eventos_mayor_o_extremo <- sismos_temporal %>%
  filter(magnitud_cat %in% c("Mayor", "Grande o extremo")) %>%
  arrange(fecha_hora_utc) %>%
  mutate(
    dias_desde_evento_anterior = as.numeric(
      difftime(fecha_hora_utc, lag(fecha_hora_utc), units = "days")
    )
  )

resumen_recurrencia_mayor_o_extremo <- eventos_mayor_o_extremo %>%
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

resumen_recurrencia_decadal_mayor_o_extremo <- eventos_mayor_o_extremo %>%
  filter(!is.na(dias_desde_evento_anterior)) %>%
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


## Recurrencia dentro de cada magnitud_cat----

eventos_recurrencia_magnitud_cat <- sismos_temporal %>%
  arrange(magnitud_cat, fecha_hora_utc) %>%
  group_by(magnitud_cat) %>%
  mutate(
    dias_desde_evento_anterior = as.numeric(
      difftime(fecha_hora_utc, lag(fecha_hora_utc), units = "days")
    )
  ) %>%
  ungroup()

resumen_recurrencia_magnitud_cat <- eventos_recurrencia_magnitud_cat %>%
  group_by(magnitud_cat) %>%
  summarise(
    n_eventos = n(),
    n_intervalos = sum(!is.na(dias_desde_evento_anterior)),
    tiempo_medio_dias = mean(dias_desde_evento_anterior, na.rm = TRUE),
    tiempo_mediano_dias = median(dias_desde_evento_anterior, na.rm = TRUE),
    q1_dias = quantile(dias_desde_evento_anterior, 0.25, na.rm = TRUE),
    q3_dias = quantile(dias_desde_evento_anterior, 0.75, na.rm = TRUE),
    tiempo_minimo_dias = min(dias_desde_evento_anterior, na.rm = TRUE),
    tiempo_maximo_dias = max(dias_desde_evento_anterior, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(magnitud_cat)


# Composicion temporal por tipo de magnitud----
## Frecuencia y agrupacion de magType----

conteo_magtype_grupo <- sismos_temporal %>%
  count(magType_grupo, name = "n_eventos", .drop = FALSE) %>%
  mutate(
    porcentaje = n_eventos / sum(n_eventos) * 100
  ) %>%
  arrange(desc(n_eventos))


## Composicion anual por magType_grupo----

conteo_anual_magtype_grupo <- sismos_temporal %>%
  count(año, magType_grupo, name = "n_eventos", .drop = FALSE) %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    magType_grupo = niveles_magtype,
    fill = list(n_eventos = 0)
  ) %>%
  mutate(
    magType_grupo = factor(magType_grupo, levels = niveles_magtype)
  ) %>%
  arrange(año, magType_grupo)

porcentaje_anual_magtype_grupo <- conteo_anual_magtype_grupo %>%
  group_by(año) %>%
  mutate(
    total_anual = sum(n_eventos),
    porcentaje = if_else(
      total_anual == 0,
      0,
      n_eventos / total_anual * 100
    )
  ) %>%
  ungroup() %>%
  select(-total_anual)

participacion_mww_anual <- sismos_temporal %>%
  group_by(año) %>%
  summarise(
    eventos_total = n(),
    eventos_mww = sum(magType_grupo == "mww", na.rm = TRUE),
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

tabla_anual_magtype <- table(
  sismos_temporal$año,
  sismos_temporal$magType_grupo
)

matriz_anual_magtype <- t(tabla_anual_magtype)

matriz_anual_magtype_porcentaje <- prop.table(
  matriz_anual_magtype,
  margin = 2
) * 100


# Ajuste RMS a lo largo del tiempo----
# Se utiliza rms_imp para mantener todos los eventos. Los valores faltantes se
# completaron previamente con la mediana decadal, que conserva el nivel temporal
# general y reduce la influencia de valores atipicos. La mediana y el rango
# intercuartilico se usan como resumen temporal por la misma razon.

resumen_rms_anual <- sismos_temporal %>%
  group_by(año) %>%
  summarise(
    n_eventos = n(),
    rms_mediana = median(rms_imp),
    rms_q25 = quantile(rms_imp, 0.25),
    rms_q75 = quantile(rms_imp, 0.75),
    .groups = "drop"
  ) %>%
  arrange(año)

resumen_rms_decadal <- sismos_temporal %>%
  group_by(decada) %>%
  summarise(
    n_eventos = n(),
    rms_mediana = median(rms_imp),
    rms_q25 = quantile(rms_imp, 0.25),
    rms_q75 = quantile(rms_imp, 0.75),
    .groups = "drop"
  ) %>%
  arrange(decada)


# Graficos para resultados y discusion----
## Figura temporal 1: magnitud_cat anual y serie mensual del catalogo----

indice_mensual <- 1:nrow(conteo_mensual)
marcas_mensuales <- seq(12, nrow(conteo_mensual), by = 24)

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
  legend = rownames(matriz_anual_magnitud),
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


## Figura temporal 2: composicion decadal por magnitud_cat----

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

fila_fuerte_decadal <- which(rownames(matriz_decadal_magnitud) == "Fuerte")
totales_acumulados_decadal <- apply(matriz_decadal_magnitud, 2, cumsum)
posiciones_texto_decadal <- totales_acumulados_decadal - matriz_decadal_magnitud / 2
colores_texto_decadal <- matrix(
  "white",
  nrow = nrow(matriz_decadal_magnitud),
  ncol = ncol(matriz_decadal_magnitud)
)

colores_texto_decadal[fila_fuerte_decadal, ] <- "black"

text(
  x = rep(pos_barras_decadal_magnitud, each = nrow(matriz_decadal_magnitud)),
  y = as.vector(posiciones_texto_decadal),
  labels = ifelse(
    as.vector(matriz_decadal_magnitud) > 0,
    as.vector(matriz_decadal_magnitud),
    ""
  ),
  cex = 0.8,
  col = as.vector(colores_texto_decadal)
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

legend(
  "topright",
  legend = rownames(matriz_decadal_magnitud),
  fill = c("gray85", "gray60", "gray30"),
  border = "gray30",
  bty = "n",
  cex = 0.8
)

box()


## Figura temporal 3: evolucion de magType_grupo y participacion de mww----

colores_magtype <- c("gray30", "gray55", "gray75", "gray90")

par(mfrow = c(1, 2), bg = "white", mar = c(7, 4, 4, 2) + 0.1)

pos_barras_anual_magtype <- barplot(
  matriz_anual_magtype_porcentaje,
  beside = FALSE,
  main = "Composición anual por magType_grupo",
  xlab = "Año",
  ylab = "Porcentaje de eventos",
  col = colores_magtype,
  border = "gray30",
  las = 2,
  cex.names = 0.7,
  ylim = c(0, 100),
  axes = FALSE
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

legend(
  "bottom",
  inset = c(0, -0.28),
  legend = rev(rownames(matriz_anual_magtype_porcentaje)),
  fill = rev(colores_magtype),
  border = "gray30",
  bty = "n",
  cex = 0.85,
  horiz = TRUE,
  xpd = TRUE
)

box()

par(mar = c(6, 4, 4, 2) + 0.1)

plot(
  participacion_mww_anual$año,
  participacion_mww_anual$porcentaje_mww,
  type = "l",
  main = "Participación anual de mww",
  xlab = "Año",
  ylab = "Porcentaje de eventos mww",
  col = "gray30",
  lwd = 1.8,
  ylim = c(0, 100),
  xaxt = "n",
  axes = FALSE
)

points(
  participacion_mww_anual$año,
  participacion_mww_anual$porcentaje_mww,
  pch = 16,
  col = "gray30",
  cex = 0.75
)

axis(
  side = 1,
  at = participacion_mww_anual$año,
  labels = participacion_mww_anual$año,
  las = 2,
  cex.axis = 0.7,
  lwd = 0,
  lwd.ticks = 1
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

abline(
  h = 50,
  col = "gray60",
  lty = 2,
  lwd = 1.2
)

legend(
  "topleft",
  legend = c("mww", "50 %"),
  col = c("gray30", "gray60"),
  lty = c(1, 2),
  lwd = c(1.8, 1.2),
  pch = c(16, NA),
  bty = "n",
  cex = 0.8
)

box()

par(mfrow = c(1, 1))


## Figura temporal 4: evolucion anual del ajuste RMS----

par(mfrow = c(1, 1), bg = "white", mar = c(4.3, 4, 3, 1) + 0.1)

plot(
  resumen_rms_anual$año,
  resumen_rms_anual$rms_mediana,
  type = "n",
  main = "Evolución anual del ajuste RMS",
  xlab = "Año",
  ylab = "RMS imputado (segundos)",
  ylim = range(
    resumen_rms_anual$rms_q25,
    resumen_rms_anual$rms_q75
  ),
  xaxt = "n",
  axes = FALSE
)

polygon(
  x = c(resumen_rms_anual$año, rev(resumen_rms_anual$año)),
  y = c(resumen_rms_anual$rms_q25, rev(resumen_rms_anual$rms_q75)),
  col = adjustcolor("gray70", alpha.f = 0.55),
  border = NA
)

lines(
  resumen_rms_anual$año,
  resumen_rms_anual$rms_mediana,
  col = "gray20",
  lwd = 1.8
)

points(
  resumen_rms_anual$año,
  resumen_rms_anual$rms_mediana,
  pch = 16,
  col = "gray20",
  cex = 0.7
)

axis(
  side = 1,
  at = seq(año_inicio, año_fin, by = 5),
  labels = seq(año_inicio, año_fin, by = 5),
  las = 1,
  cex.axis = 0.8,
  lwd = 0,
  lwd.ticks = 1
)

axis(side = 2, las = 1, lwd = 0, lwd.ticks = 1)

legend(
  "topright",
  legend = c("Mediana anual", "Rango intercuartílico"),
  col = c("gray20", "gray70"),
  lty = c(1, NA),
  lwd = c(1.8, NA),
  pch = c(16, 15),
  pt.cex = c(0.7, 1.5),
  bty = "n",
  cex = 0.8
)

box()

par(mfrow = c(1, 1))

