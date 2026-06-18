#Cargar paquetes----
library(readr)
library(dplyr)
library(lubridate)
library(naniar) #Analisar datos faltantes
library(skimr) #Analisar datos faltantes y resumen de estadisticas básicas

#Rutas y Carga de datos----
ruta_base <- "BBDD/query.csv"

sismos_raw <- read_csv(ruta_base, show_col_types = FALSE) #Datos crudos

#Analisis Preliminar de la estructura de los datos----

View(sismos_raw)
summary(sismos_raw)
dim(sismos_raw) #Observacioes por filas y columnas
str(sismos_raw) #Naturaleza de la variable
glimpse(sismos_raw) #Filas, columnas y head...

##Análisis de Datos Faltantes----
miss_var_summary(sismos_raw)
skim(sismos_raw) # Resumen de Datos faltantes, estadisticas básicas y distributivas.

# Preparar variables básicas para análisis temporal
sismos <- sismos_raw %>%
  mutate(
    fecha_hora_utc = ymd_hms(time, tz = "UTC"),
    fecha = as.Date(fecha_hora_utc),
    año = year(fecha_hora_utc),
    mes = month(fecha_hora_utc)
  )
#Selección de Variables para el análisis general
sismos <- sismos %>%
  select(
    id,
    fecha_hora_utc,
    fecha,
    año,
    mes,
    latitude,
    longitude,
    depth,
    mag,
    magType,
    place,
    type,
    status,
    net,
    locationSource,
    magSource
  )
View(sismos)
skim(sismos)
