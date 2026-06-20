#Cargar paquetes----
library(readr)
library(dplyr)
library(lubridate)
library(naniar) #Analizar datos faltantes
library(skimr) #Analizar datos faltantes y resumen de estadisticas básicas
library(janitor) #Analizar datos duplicados
#Rutas y Carga de datos----
ruta_base <- "BBDD/query.csv"

sismos_raw <- read_csv(ruta_base, show_col_types = FALSE) #Datos crudos

#Analisis Preliminar de la estructura de los datos----

#View(sismos_raw)
summary(sismos_raw)
dim(sismos_raw) #Observacioes por filas y columnas / 1186 observaciones y 22 variables
str(sismos_raw) #Naturaleza de la variable
glimpse(sismos_raw) #Filas, columnas y head...

##Análisis de Datos Faltantes----
miss_var_summary(sismos_raw)
skim(sismos_raw) # Resumen de Datos faltantes, estadisticas básicas y distributivas.

#Preparar variables básicas para análisis temporal----
sismos <- sismos_raw %>%
  mutate(
    fecha_hora_utc = ymd_hms(time, tz = "UTC"),
    fecha = as.Date(fecha_hora_utc),
    año = year(fecha_hora_utc),
    mes = month(fecha_hora_utc)
  )

#Preparar variables para análisis categórico de profundidad----
sismos <- sismos %>%
  mutate(
    profundidad_cat = case_when(
      depth >= 0 & depth <= 70 ~ "Superficial",
      depth > 70 & depth <= 300 ~ "Intermedio",
      depth > 300 ~ "Profundo"
    )
  )

##Selección de Variables para el análisis general preliminar----
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
    profundidad_cat,
    mag,
    magType, #Varía según quien midio. Puede que sea con parámetros diferentes
    place, 
    type, #Todos son Terremotos, nosé que otra categoría podría haber
    status,
    net, #En su mayoría son "USA" ¿Por que?
    locationSource,
    magSource #Revisar la relación entre MagType y MagSource !!!!
  )
View(sismos)
skim(sismos)

##Revisión de Duplicados----

###duplicados por identificador único (id)----
anyDuplicated(sismos$id) #0 duplicados
###duplicados por caracterización del evento----
anyDuplicated(sismos[, c("fecha_hora_utc", "latitude", "longitude", "depth", "mag")]) #0 duplicados

##Revisión de eventos no tectónicos----
eventos_no_tectonicos <- sismos %>%filter(type != "earthquake")
eventos_no_tectonicos
count(eventos_no_tectonicos) #Solo existe eventos relacionados a eventos tectónicos


##Consistencia Temporal----
#¿Todas las observaciones tienen fecha y hora?
sum(is.na(sismos$fecha_hora_utc)) #La respuesta es no, todas las observaciones tienen fecha y hora.
#¿Las fechas están dentro del período definido para la asesoría?
eventos_fuera_periodo <- sismos %>%filter(fecha < as.Date("2000-01-01") | fecha > as.Date("2025-12-31"))
eventos_fuera_periodo
count(eventos_fuera_periodo)
#Otras revisiones
range(sismos$fecha) #estan dentro del intervalo estipulado en la documentación

##Consistencia Espacial----

#coordenadas geográficamente posibles
rango_espacial <- sismos %>%
  summarise(
    latitud_minima = min(latitude, na.rm = TRUE),
    latitud_maxima = max(latitude, na.rm = TRUE),
    longitud_minima = min(longitude, na.rm = TRUE),
    longitud_maxima = max(longitude, na.rm = TRUE),
    profundidad_minima = min(depth, na.rm = TRUE),
    profundidad_maxima = max(depth, na.rm = TRUE)
  )
rango_espacial
#Latitud válida: entre -90 y 90
#Longitud válida: entre -180 y 180
#Profundidad válida: >= 0

#Ejecutar scripts posteriores----
source("Scripts/01_analisis_descriptivo.R")
source("Scripts/02_visualizaciones.R")
source("Scripts/03_tablas_informe.R")
source("Scripts/04_analisis_temporal.R")
