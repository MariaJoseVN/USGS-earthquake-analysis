graphics.off()


# Seleccion de analisis----
# Este script usa exclusivamente las variables categoricas ya construidas en
# Codigo.R. No crea indicadores auxiliares por umbral como evento_m70,
# evento_m75 o evento_m80.

if (!exists("año_inicio")) año_inicio <- 2000
if (!exists("año_fin")) año_fin <- 2025

niveles_magnitud <- c("Fuerte", "Mayor", "Grande o extremo")

sismos_temporal <- sismos %>%
  mutate(
    fecha_mes = floor_date(fecha, unit = "month"),
    magnitud_cat = factor(magnitud_cat, levels = niveles_magnitud)
  )

print(sismos_temporal)


# Conteos temporales del catalogo completo----
## Conteo anual para catalogo completo----

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

print(conteo_anual, n = Inf)


## Resumen anual para resultados y discusion----

resumen_anual_catalogo <- conteo_anual %>%
  summarise(
    n_eventos_periodo = sum(n_catalogo_completo),
    promedio_anual = mean(n_catalogo_completo),
    año_maximo = año[which.max(n_catalogo_completo)],
    maximo_anual = max(n_catalogo_completo),
    año_minimo = año[which.min(n_catalogo_completo)],
    minimo_anual = min(n_catalogo_completo)
  )

print(resumen_anual_catalogo)


## Conteo mensual para catalogo completo----

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

print(conteo_mensual, n = Inf)


## Series temporales del catalogo completo----

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

print(serie_mensual_catalogo_completo)
summary(serie_mensual_catalogo_completo)

print(serie_anual_catalogo_completo)
summary(serie_anual_catalogo_completo)


# Conteos por categoria de magnitud----
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

print(conteo_anual_magnitud_cat, n = Inf)


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

print(conteo_decadal_cat, n = Inf)


# Recurrencia temporal por categorias----
## Eventos Mayor o Grande o extremo ordenados temporalmente----
# Esta seleccion es la version categorica del subconjunto de eventos desde
# M >= 7.0, porque la categoria "Mayor" comienza en 7.0.

eventos_mayor_o_extremo <- sismos_temporal %>%
  filter(magnitud_cat %in% c("Mayor", "Grande o extremo")) %>%
  arrange(fecha_hora_utc) %>%
  mutate(
    dias_desde_evento_anterior = as.numeric(
      difftime(fecha_hora_utc, lag(fecha_hora_utc), units = "days")
    )
  )

print(eventos_mayor_o_extremo, n = Inf)


## Resumen de recurrencia entre eventos Mayor o Grande o extremo----

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

print(resumen_recurrencia_mayor_o_extremo)


## Resumen de recurrencia por magnitud_cat----
# En este caso los intervalos se calculan dentro de cada categoria de magnitud.

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

print(resumen_recurrencia_magnitud_cat, n = Inf)


# Grafico para resultados----
### Composicion anual por magnitud_cat y serie mensual del catalogo completo----

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
