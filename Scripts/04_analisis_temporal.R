#Consideraciones----
#Este script utiliza la base preparada en Codigo.R.


#Preparacion temporal----
# La variable magnitud_cat fue creada previamente en Codigo.R.
# Esta clasifica los eventos en: Fuerte, Mayor y Grande o extremo.
# Los indicadores evento_m70, evento_m75 y evento_m80 se mantienen para responder
# preguntas especificas basadas en umbrales de magnitud.

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
# Las series temporales principales se mantienen para el catalogo completo y M >= 7.0.
# Las categorias de magnitud se utilizaran mas adelante para describir la composicion
# anual y decadal del catalogo, evitando sobrecargar el analisis con multiples series.

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
# En esta visualizacion inicial se prioriza la evolucion general del catalogo
# y de los eventos M >= 7.0. La comparacion por magnitud_cat se reserva para
# graficos de composicion anual y decadal.

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
##Pregunta Orientadora de manera anual:-----
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

#Pregunta Orientadora caso decada:-----
#¿Cómo ha variado la ocurrencia anual o decadal de eventos M >= 7,0?
#no conviene comparar 84 eventos contra décadas completas de 10 años
# En terminos de magnitud_cat, el umbral M >= 7.0 agrupa las categorias
# "Mayor" y "Grande o extremo". Por eso esta pregunta se mantiene por umbral,
# pero su interpretacion se conecta con la clasificacion de magnitud.

##Tasa promedio anual por decada----

conteo_decadal <- conteo_decadal %>%
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

#Ahora si la comparación Gráfica es más justa para responder la pregunta orientadora

pos_barras_tasa_decadal_m70 <- barplot(
  height = conteo_decadal$tasa_anual_m70_o_mayor,
  names.arg = conteo_decadal$decada,
  main = "Tasa anual promedio por decada - M >= 7.0",
  ylab = "Eventos promedio por año",
  xlab = "Decada",
  col = "gray80",
  border = "gray30",
  las = 1,
  cex.names = 0.8,
  ylim = c(0, max(conteo_decadal$tasa_anual_m70_o_mayor) * 1.2),
  axes = FALSE
)
text(
  x = pos_barras_tasa_decadal_m70,
  y = conteo_decadal$tasa_anual_m70_o_mayor,
  labels = round(conteo_decadal$tasa_anual_m70_o_mayor, 1),
  pos = 3,
  cex = 0.8
)
axis(
  side = 2,
  las = 1,
  lwd = 0,
  lwd.ticks = 1
)
box()

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

##posible pregunta inferencial, es o son significativas estas diferencias?


#Tiempo medio y mediano entre eventos relevantes (M >= 7.0)----
#la idea es comparar cada evento M >= 7.0 con el evento M >= 7.0 inmediatamente anterior
# En terminos de magnitud_cat, este analisis de recurrencia considera eventos
# clasificados como "Mayor" o "Grande o extremo".

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

##Resumen de tiempos entre eventos M >= 7.0----

resumen_recurrencia_m70 <- eventos_m70 %>%
  summarise(
    n_eventos = n(),
    n_intervalos = sum(!is.na(dias_desde_evento_anterior)),
    tiempo_medio_dias = mean(dias_desde_evento_anterior, na.rm = TRUE),
    tiempo_mediano_dias = median(dias_desde_evento_anterior, na.rm = TRUE),
    tiempo_minimo_dias = min(dias_desde_evento_anterior, na.rm = TRUE),
    tiempo_maximo_dias = max(dias_desde_evento_anterior, na.rm = TRUE)
  )

print(resumen_recurrencia_m70)

###Gráfico----

hist(
  eventos_m70$dias_desde_evento_anterior,
  main = "Distribucion de dias entre eventos M >= 7.0",
  xlab = "Dias desde el evento anterior",
  ylab = "Frecuencia",
  col = "gray80",
  border = "gray30",
  axes = FALSE
)

axis(
  side = 1,
  lwd = 0,
  lwd.ticks = 1
)

axis(
  side = 2,
  las = 1,
  lwd = 0,
  lwd.ticks = 1
)

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

###La recurrencia de eventos M >= 7.0 entre décadas----
# Esta comparacion por decada mantiene el umbral M >= 7.0.
# Por lo tanto, compara la recurrencia temporal de eventos clasificados como
# "Mayor" o "Grande o extremo" segun magnitud_cat.
# No se compara por categoria separada para evitar grupos con pocos intervalos.

resumen_recurrencia_decadal_m70 <- eventos_m70 %>%
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

print(resumen_recurrencia_decadal_m70)

eventos_m70_recurrencia_decadal <- eventos_m70 %>%
  filter(!is.na(dias_desde_evento_anterior))

decadas_recurrencia_m70 <- sort(unique(eventos_m70_recurrencia_decadal$decada))

boxplot(
  dias_desde_evento_anterior ~ decada,
  data = eventos_m70_recurrencia_decadal,
  main = "Dias entre eventos M >= 7.0 por decada",
  xlab = "Decada",
  ylab = "Dias desde el evento anterior",
  col = "gray80",
  border = "gray30",
  axes = FALSE
)

axis(
  side = 1,
  at = seq_along(decadas_recurrencia_m70),
  labels = decadas_recurrencia_m70,
  lwd = 0,
  lwd.ticks = 1
)

axis(
  side = 2,
  las = 1,
  lwd = 0,
  lwd.ticks = 1
)

box()


#Analisis complementario por categoria de magnitud----
# Despues de revisar los conteos por umbrales, se incorpora magnitud_cat.
# Esta variable proviene de la revision bibliografica y agrupa eventos en
# categorias excluyentes: Fuerte, Mayor y Grande o extremo.
# A diferencia de los umbrales acumulativos, estas categorias permiten leer
# la composicion temporal del catalogo sin contar el mismo evento en varios grupos.

##Conteos por categoria de magnitud----

conteo_anual_magnitud_cat <- sismos_temporal %>%
  group_by(año, magnitud_cat) %>%
  summarise(
    n_eventos = n(),
    .groups = "drop"
  )

print(conteo_anual_magnitud_cat, n = Inf)

conteo_decadal_magnitud_cat <- sismos_temporal %>%
  group_by(decada, magnitud_cat) %>%
  summarise(
    n_eventos = n(),
    .groups = "drop"
  )

print(conteo_decadal_magnitud_cat, n = Inf)

##Composicion anual por categoria de magnitud----
# Estos graficos muestran como se distribuye el catalogo entre eventos
# Fuertes, Mayores y Grandes o extremos en el tiempo.

tabla_anual_magnitud <- table(
  sismos_temporal$año,
  sismos_temporal$magnitud_cat
)

matriz_anual_magnitud <- t(tabla_anual_magnitud)

pos_barras_anual_magnitud <- barplot(
  matriz_anual_magnitud,
  beside = FALSE,
  main = "Eventos anuales por categoria de magnitud",
  ylab = "Numero de eventos",
  xlab = "Años",
  col = c("gray85", "gray60", "gray30"),
  border = "gray30",
  las = 2,
  cex.names = 0.7,
  ylim = c(0, max(colSums(matriz_anual_magnitud)) * 1.15),
  axes = FALSE
)

axis(
  side = 2,
  las = 1,
  lwd = 0,
  lwd.ticks = 1
)

pos_texto_anual_magnitud <- apply(
  matriz_anual_magnitud,
  2,
  cumsum
) - matriz_anual_magnitud / 2

x_texto_anual_magnitud <- matrix(
  rep(pos_barras_anual_magnitud, each = nrow(matriz_anual_magnitud)),
  nrow = nrow(matriz_anual_magnitud)
)

text(
  x = as.vector(x_texto_anual_magnitud),
  y = as.vector(pos_texto_anual_magnitud),
  labels = ifelse(as.vector(matriz_anual_magnitud) > 0, as.vector(matriz_anual_magnitud), ""),
  col = rep(c("gray20", "gray20", "white"), times = ncol(matriz_anual_magnitud)),
  cex = 0.45
)

legend(
  "topright",
  legend = colnames(tabla_anual_magnitud),
  fill = c("gray85", "gray60", "gray30"),
  border = "gray30",
  bty = "n",
  cex = 0.8
)

box()

##Composicion decadal por categoria de magnitud----

tabla_decadal_magnitud <- table(
  sismos_temporal$decada,
  sismos_temporal$magnitud_cat
)

matriz_decadal_magnitud <- t(tabla_decadal_magnitud)

pos_barras_decadal_magnitud <- barplot(
  matriz_decadal_magnitud,
  beside = FALSE,
  main = "Eventos por decada segun categoria de magnitud",
  ylab = "Numero de eventos",
  xlab = "Decada",
  col = c("gray85", "gray60", "gray30"),
  border = "gray30",
  las = 1,
  cex.names = 0.8,
  ylim = c(0, max(colSums(matriz_decadal_magnitud)) * 1.15),
  axes = FALSE
)

axis(
  side = 2,
  las = 1,
  lwd = 0,
  lwd.ticks = 1
)

pos_texto_decadal_magnitud <- apply(
  matriz_decadal_magnitud,
  2,
  cumsum
) - matriz_decadal_magnitud / 2

x_texto_decadal_magnitud <- matrix(
  rep(pos_barras_decadal_magnitud, each = nrow(matriz_decadal_magnitud)),
  nrow = nrow(matriz_decadal_magnitud)
)

text(
  x = as.vector(x_texto_decadal_magnitud),
  y = as.vector(pos_texto_decadal_magnitud),
  labels = ifelse(as.vector(matriz_decadal_magnitud) > 0, as.vector(matriz_decadal_magnitud), ""),
  col = rep(c("gray20", "gray20", "white"), times = ncol(matriz_decadal_magnitud)),
  cex = 0.8
)

legend(
  "topright",
  legend = colnames(tabla_decadal_magnitud),
  fill = c("gray85", "gray60", "gray30"),
  border = "gray30",
  bty = "n",
  cex = 0.8
)

box()
