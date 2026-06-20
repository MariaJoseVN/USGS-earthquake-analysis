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

#Magnitud media, máxima y cuantiles----
sismos %>%
  summarise(
    magnitud_media = mean(mag, na.rm = TRUE),
    magnitud_maxima = max(mag, na.rm = TRUE),
    cuantil_25 = quantile(mag, 0.25, na.rm = TRUE),
    cuantil_50 = quantile(mag, 0.50, na.rm = TRUE),
    cuantil_75 = quantile(mag, 0.75, na.rm = TRUE),
    cuantil_90 = quantile(mag, 0.90, na.rm = TRUE),
    cuantil_95 = quantile(mag, 0.95, na.rm = TRUE)
  )

#Profundidad media----
sismos %>%
  summarise(
    profundidad_media = mean(depth, na.rm = TRUE)
  )


#Proporción de eventos según profundidad----
sismos %>%
  janitor::tabyl(profundidad_cat)


library(sf) #sf permite trabajar en R con puntos, polígonos y archivos geográficos como GeoJSON.

#Lee el área del Cinturón de Fuego
#st_read() importa el GeoJSON.
#El objeto contiene los polígonos que delimitan operacionalmente el Cinturón de Fuego.
area_cinturon_fuego <- st_read(
  "SIG/area_cinturon_fuego.geojson",
  quiet = TRUE
)

#Convertir los terremotos en puntos
puntos_sismos <- st_as_sf(
  sismos,
  coords = c("longitude", "latitude"),
  crs = st_crs(area_cinturon_fuego)
)

#Manejar el antimeridiano
#Desactiva temporalmente el procesamiento esférico, 
#porque el polígono cruza el antimeridiano y contiene coordenadas a ambos lados de los 180 grados de longitud.
sf_use_s2(FALSE)

#Crear la variable zona
sismos <- sismos %>%
  mutate(
    zona = if_else(
      lengths(st_intersects(puntos_sismos, area_cinturon_fuego)) > 0,
      "Cinturón de Fuego",
      "Resto del mundo"
    )
  )

#Comprueba, para cada terremoto de puntos_sismos, si su ubicación 
# intersecta alguno de los polígonos de area_cinturon_fuego.
st_intersects(puntos_sismos, area_cinturon_fuego)

# Reactivar el procesamiento esférico
sf_use_s2(TRUE)

#Total de eventos por zona----
total_eventos_zona <- sismos %>%
  count(zona, name = "total_eventos")
View(total_eventos_zona)

#Contar por zona y año
eventos_zona_anio <- sismos %>%
  count(zona, año, name = "numero_eventos") %>%
  arrange(año, zona)
View(eventos_zona_anio)



