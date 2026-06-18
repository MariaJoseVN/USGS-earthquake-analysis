#Cargar paquetes----
library(readr)
library(dplyr)
library(lubridate)

#Rutas y Carga de datos----
ruta_base <- "BBDD/query.csv"

sismos_raw <- read_csv(ruta_base, show_col_types = FALSE) #Datos crudos
View(sismos_raw)

# Preparar variables básicas para análisis temporal

sismos <- sismos_raw %>%
  mutate(
    fecha_hora_utc = ymd_hms(time, tz = "UTC"),
    fecha = as.Date(fecha_hora_utc),
    año = year(fecha_hora_utc),
    mes = month(fecha_hora_utc)
  )

View(sismos)