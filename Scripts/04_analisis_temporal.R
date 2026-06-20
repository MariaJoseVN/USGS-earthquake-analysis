#Consideraciones----
#Este script utiliza la base preparada en Codigo.R.


#Preparacion temporal----
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
