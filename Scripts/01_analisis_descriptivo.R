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
