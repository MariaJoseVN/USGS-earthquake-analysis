#Analisis de la variable magType----
#magType indica el metodo/escala con que se estimo la magnitud y depende del magSource.



#Reiniciar dispositivo grafico----
#Evita que los graficos se envien a un dispositivo externo abierto previamente.
graphics.off()


#Distribucion de eventos segun magType----

eventos_magtype <- sismos %>%
  count(
    magType,
    name = "numero_eventos",
    .drop = FALSE
  ) %>%
  mutate(
    proporcion = numero_eventos / if_else(
      sum(numero_eventos) == 0,
      1,
      sum(numero_eventos)
    ),
    porcentaje = proporcion * 100
  ) %>%
  arrange(desc(numero_eventos))

print(eventos_magtype, n = Inf)


#Resumen de magnitud por magType----

magnitud_por_magtype <- sismos %>%
  group_by(magType) %>%
  summarise(
    numero_eventos = n(),
    magnitud_media = mean(mag, na.rm = TRUE),
    magnitud_mediana = median(mag, na.rm = TRUE),
    magnitud_desviacion = sd(mag, na.rm = TRUE),
    magnitud_minima = min(mag, na.rm = TRUE),
    magnitud_maxima = max(mag, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(numero_eventos))

print(magnitud_por_magtype, n = Inf)


#Evolucion temporal de magType----
#Permite ver el cambio metodologico del catalogo a lo largo del periodo.

magtype_anio <- sismos %>%
  count(año, magType, name = "numero_eventos") %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    magType,
    fill = list(numero_eventos = 0)
  ) %>%
  arrange(año, magType)

print(magtype_anio, n = Inf)


#Relacion entre magType y magSource----
#Revisa que agencia (magSource) reporta cada tipo de magnitud.

magtype_magsource <- sismos %>%
  count(magType, magSource, name = "numero_eventos") %>%
  arrange(magType, desc(numero_eventos))

print(magtype_magsource, n = Inf)


#Grafico de eventos por magType----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 5, 4, 2) + 0.1)

barras_magtype <- barplot(
  eventos_magtype$numero_eventos,
  names.arg = eventos_magtype$magType,
  col = "gray80",
  border = "gray30",
  las = 1,
  cex.names = 0.9,
  ylim = c(0, max(eventos_magtype$numero_eventos) * 1.18),
  ylab = "Numero de eventos",
  main = "Eventos segun tipo de magnitud"
)

text(
  x = barras_magtype,
  y = eventos_magtype$numero_eventos,
  labels = paste0(
    eventos_magtype$numero_eventos,
    " (",
    format(eventos_magtype$porcentaje, decimal.mark = ",", nsmall = 1),
    "%)"
  ),
  pos = 3,
  cex = 0.8
)

box()

#Restablecer parametros graficos----
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)




##########

