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

#Tasas promedio de ocurrencia
tasa_promedio_anual <- numero_total_eventos / cantidad_años      # 45.61538461538461
tasa_promedio_mensual <- numero_total_eventos / cantidad_meses   # 3.801282051282051

#Resumen de resultados
resumen_ocurrencia <- tibble(
  indicador = c(
    "Número total de eventos",
    "Cantidad de años analizados",
    "Cantidad de meses analizados",
    "Tasa promedio anual",
    "Tasa promedio mensual"
  ),
  valor = c(
    numero_total_eventos,
    cantidad_años,
    cantidad_meses,
    round(tasa_promedio_anual, 2),
    round(tasa_promedio_mensual, 2)
  )
)
resumen_ocurrencia

#Conteo anual de terremotos----
conteo_anual <- sismos %>%
  count(año, name = "numero_eventos") %>%
  arrange(año)
print(conteo_anual, n = Inf)
View(conteo_anual)

#Conteo mensual de terremotos----
conteo_mensual <- sismos %>%
  mutate(año_mes = floor_date(fecha, unit = "month")) %>%
  count(año_mes, name = "numero_eventos") %>%
  arrange(año_mes)
conteo_mensual
View(conteo_mensual) # me salieron 301meses con eventos, por lo cual existe 11 meses SIN eventos


#Completar los meses sin eventos----
#Crea una tabla con todos los meses del período:
calendario_mensual <- tibble(
  año_mes = seq(
    as.Date(paste0(año_inicio, "-01-01")),
    as.Date(paste0(año_fin, "-12-01")),
    by = "month"
  )
)
#Agrega los meses faltantes al conteo mensual:
conteo_mensual <- calendario_mensual %>%
  left_join(conteo_mensual, by = "año_mes") %>%
  mutate(
    numero_eventos = coalesce(numero_eventos, 0L)
  ) %>%
  arrange(año_mes)
#Comprobar que estén los 312 meses:
nrow(conteo_mensual)
#Identificar los meses sin eventos:
meses_sin_eventos <- conteo_mensual %>%
  filter(numero_eventos == 0) %>%
  mutate(
    periodo = format(año_mes, "%Y-%m")
  ) %>%
  select(año_mes, periodo)

print(meses_sin_eventos, n = Inf)


#Variación de los conteos anuales----
variacion_anual <- conteo_anual %>%
  summarise(
    promedio = mean(numero_eventos),
    mediana = median(numero_eventos),
    desviacion_estandar = sd(numero_eventos),
    minimo = min(numero_eventos),
    maximo = max(numero_eventos)
  )
variacion_anual

#Variación de los conteos mensuales----
variacion_mensual <- conteo_mensual %>%
  summarise(
    promedio = mean(numero_eventos),
    mediana = median(numero_eventos),
    desviacion_estandar = sd(numero_eventos),
    minimo = min(numero_eventos),
    maximo = max(numero_eventos)
  )
variacion_mensual
#Cambio mensual de eventos----
cambio_mensual <- conteo_mensual %>%
  arrange(año, mes) %>%
  mutate(
    eventos_mes_anterior = lag(numero_eventos),

    diferencia_mes_anterior =
      numero_eventos - eventos_mes_anterior,

    variacion_porcentual = if_else(
      is.na(eventos_mes_anterior) |
        eventos_mes_anterior == 0,
      NA_real_,
      round(
        100 * diferencia_mes_anterior /
          eventos_mes_anterior,
        2
      )
    )
  ) %>%
  select(
    año,
    mes,
    numero_eventos,
    diferencia_mes_anterior,
    variacion_porcentual
  )

View(cambio_mensual)
