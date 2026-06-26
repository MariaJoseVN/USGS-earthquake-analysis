#Analisis descriptivo de variables categoricas----
#Este script reorganiza el analisis de magType y magSource.
#Requiere que Codigo.R ya haya preparado sismos, magnitud_cat,
#profundidad_cat, magType_grupo, zona, año, año_inicio y año_fin.


#Preparacion general----

graphics.off()

niveles_magnitud <- c("Fuerte", "Mayor", "Grande o extremo")
niveles_profundidad <- c("Superficial", "Intermedio", "Profundo")
niveles_magtype_grupo <- c("mww", "mwc", "mwb", "otros")

sismos_categoricas <- sismos %>%
  mutate(
    magnitud_cat = factor(magnitud_cat, levels = niveles_magnitud),
    profundidad_cat = factor(profundidad_cat, levels = niveles_profundidad),
    magType_grupo = factor(magType_grupo, levels = niveles_magtype_grupo)
  )

calcular_v_cramer <- function(prueba_chi, tabla_contingencia) {
  denominador <- sum(tabla_contingencia) *
    (min(dim(tabla_contingencia)) - 1)

  if (denominador == 0) {
    return(NA_real_)
  }

  sqrt(as.numeric(prueba_chi$statistic) / denominador)
}


#Frecuencias generales----
##Distribucion de eventos segun magType----

eventos_magtype <- sismos_categoricas %>%
  count(
    magType,
    name = "numero_eventos",
    .drop = FALSE
  ) %>%
  arrange(desc(numero_eventos)) %>%
  mutate(
    total_eventos = sum(numero_eventos),
    proporcion = if_else(
      total_eventos == 0,
      0,
      numero_eventos / total_eventos
    ),
    porcentaje = proporcion * 100
  ) %>%
  select(-total_eventos)

print(eventos_magtype, n = Inf)


##Distribucion de eventos segun magSource----

eventos_magsource <- sismos_categoricas %>%
  count(
    magSource,
    name = "numero_eventos",
    .drop = FALSE
  ) %>%
  arrange(desc(numero_eventos)) %>%
  mutate(
    total_eventos = sum(numero_eventos),
    proporcion = if_else(
      total_eventos == 0,
      0,
      numero_eventos / total_eventos
    ),
    porcentaje = proporcion * 100
  ) %>%
  select(-total_eventos)

print(eventos_magsource, n = Inf)


##Distribucion del grupo simplificado de magType----

eventos_magtype_grupo <- sismos_categoricas %>%
  count(
    magType_grupo,
    name = "numero_eventos",
    .drop = FALSE
  ) %>%
  arrange(desc(numero_eventos)) %>%
  mutate(
    total_eventos = sum(numero_eventos),
    proporcion = if_else(
      total_eventos == 0,
      0,
      numero_eventos / total_eventos
    ),
    porcentaje = proporcion * 100
  ) %>%
  select(-total_eventos)

print(eventos_magtype_grupo, n = Inf)


##Resumen de categorias dominantes----

resumen_categorias <- tibble::tibble(
  variable = c("magType", "magSource", "magType_grupo"),
  categorias_distintas = c(
    n_distinct(sismos_categoricas$magType),
    n_distinct(sismos_categoricas$magSource),
    n_distinct(sismos_categoricas$magType_grupo)
  ),
  categoria_dominante = c(
    as.character(eventos_magtype$magType[1]),
    as.character(eventos_magsource$magSource[1]),
    as.character(eventos_magtype_grupo$magType_grupo[1])
  ),
  porcentaje_dominante = c(
    eventos_magtype$porcentaje[1],
    eventos_magsource$porcentaje[1],
    eventos_magtype_grupo$porcentaje[1]
  )
)

print(resumen_categorias)


#Descriptivos de magnitud segun variables categoricas----
##Resumen de magnitud por magType----

magnitud_por_magtype <- sismos_categoricas %>%
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


##Resumen de magnitud por magType_grupo----

magnitud_por_magtype_grupo <- sismos_categoricas %>%
  group_by(magType_grupo) %>%
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

print(magnitud_por_magtype_grupo, n = Inf)


##Boxplot de magnitud por magType----

sismos_boxplot_magtype <- sismos_categoricas %>%
  filter(!is.na(magType), !is.na(mag)) %>%
  mutate(
    magType_plot = factor(
      magType,
      levels = sort(unique(magType))
    )
  )

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  mag ~ magType_plot,
  data = sismos_boxplot_magtype,
  main = "Distribucion de magnitud por tipo de magnitud",
  xlab = "Tipo de magnitud",
  ylab = "Magnitud",
  col = "gray80",
  border = "gray30",
  las = 1,
  outline = TRUE
)

medias_magtype <- tapply(
  sismos_boxplot_magtype$mag,
  sismos_boxplot_magtype$magType_plot,
  mean,
  na.rm = TRUE
)

points(
  x = seq_along(medias_magtype),
  y = medias_magtype,
  pch = 19,
  col = "black"
)

legend(
  "topright",
  legend = "Media",
  pch = 19,
  col = "black",
  bty = "n",
  cex = 0.8
)

box()


##Boxplot de magnitud por magType_grupo----

sismos_boxplot_magtype_grupo <- sismos_categoricas %>%
  filter(!is.na(magType_grupo), !is.na(mag))

par(mfrow = c(1, 1), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

boxplot(
  mag ~ magType_grupo,
  data = sismos_boxplot_magtype_grupo,
  main = "Distribucion de magnitud por grupo de magType",
  xlab = "Grupo de magType",
  ylab = "Magnitud",
  col = "gray80",
  border = "gray30",
  las = 1,
  outline = TRUE
)

medias_magtype_grupo <- tapply(
  sismos_boxplot_magtype_grupo$mag,
  sismos_boxplot_magtype_grupo$magType_grupo,
  mean,
  na.rm = TRUE
)

points(
  x = seq_along(medias_magtype_grupo),
  y = medias_magtype_grupo,
  pch = 19,
  col = "black"
)

legend(
  "topright",
  legend = "Media",
  pch = 19,
  col = "black",
  bty = "n",
  cex = 0.8
)

box()


#Relacion entre variables de fuente----
##magType y magSource----
#Revisa que agencia reporta cada tipo de magnitud. Las proporciones se calculan por fila.

magtype_magsource <- sismos_categoricas %>%
  count(magType, magSource, name = "numero_eventos") %>%
  group_by(magType) %>%
  mutate(
    total_fila = sum(numero_eventos),
    proporcion_fila = if_else(
      total_fila == 0,
      0,
      numero_eventos / total_fila
    ),
    porcentaje_fila = proporcion_fila * 100
  ) %>%
  ungroup() %>%
  select(-total_fila) %>%
  arrange(magType, desc(numero_eventos))

print(magtype_magsource, n = Inf)


##Chi-cuadrado y V de Cramer para magType y magSource----
#La V de Cramer va de 0 a 1 y resume la fuerza de asociacion.
tabla_contingencia <- sismos_categoricas %>%
  filter(!is.na(magType), !is.na(magSource)) %>%
  with(table(magType, magSource))

prueba_chi <- suppressWarnings(chisq.test(tabla_contingencia))
v_cramer <- calcular_v_cramer(prueba_chi, tabla_contingencia)

asociacion_magtype_magsource <- tibble::tibble(
  estadistico_chi = as.numeric(prueba_chi$statistic),
  grados_libertad = as.numeric(prueba_chi$parameter),
  valor_p = prueba_chi$p.value,
  v_cramer = v_cramer
)
print(asociacion_magtype_magsource)
#El valor_p = 0 no significa literalmente cero, sino que es tan pequeño que R lo muestra como 0. En términos prácticos: hay evidencia estadística muy fuerte para rechazar la hipótesis de independencia. Es decir, magType y magSource no parecen ser variables independientes.
#La V de Cramer = 0.681 indica una asociación fuerte. Como V de Cramer va entre 0 y 1, un valor cercano a 0.68 sugiere que el tipo de magnitud usado está bastante relacionado con la fuente que reporta la magnitud.


##magType_grupo y magSource----
#Aquí se compara magType_grupo contra magSource. Es decir, ya no se usa cada tipo de magnitud por separado, sino la versión agrupada
#Este cruce resume la relacion de fuente usando la variable agrupada que se usara
#en la interpretacion final.
magtype_grupo_magsource <- sismos_categoricas %>%
  count(magType_grupo, magSource, name = "numero_eventos") %>%
  group_by(magType_grupo) %>%
  mutate(
    total_fila = sum(numero_eventos),
    proporcion_fila = if_else(
      total_fila == 0,
      0,
      numero_eventos / total_fila
    ),
    porcentaje_fila = proporcion_fila * 100
  ) %>%
  ungroup() %>%
  select(-total_fila) %>%
  arrange(magType_grupo, desc(numero_eventos))

print(magtype_grupo_magsource, n = Inf)


##Chi-cuadrado y V de Cramer para magType_grupo y magSource----
#La V de Cramer va de 0 a 1 y resume la fuerza de asociacion.

tabla_magtype_grupo_magsource <- sismos_categoricas %>%
  filter(!is.na(magType_grupo), !is.na(magSource)) %>%
  mutate(magType_grupo = droplevels(magType_grupo)) %>%
  with(table(magType_grupo, magSource))

prueba_chi_magtype_grupo_magsource <- suppressWarnings(
  chisq.test(tabla_magtype_grupo_magsource)
)

v_cramer_magtype_grupo_magsource <- calcular_v_cramer(
  prueba_chi_magtype_grupo_magsource,
  tabla_magtype_grupo_magsource
)

asociacion_magtype_grupo_magsource <- tibble::tibble(
  estadistico_chi = as.numeric(prueba_chi_magtype_grupo_magsource$statistic),
  grados_libertad = as.numeric(prueba_chi_magtype_grupo_magsource$parameter),
  valor_p = prueba_chi_magtype_grupo_magsource$p.value,
  v_cramer = v_cramer_magtype_grupo_magsource
)
print(asociacion_magtype_grupo_magsource)
#El valor_p = 1.60e-296 también es extremadamente pequeño. Nuevamente, indica asociación estadísticamente significativa entre el grupo de tipo de magnitud y la fuente.
#La V de Cramer = 0.651 también indica una asociación fuerte. Es un poco menor que 0.681, pero sigue siendo alta.

#Existe una asociación fuerte y estadísticamente significativa entre el tipo de magnitud reportado y la fuente de magnitud. Esto sugiere que el método o escala de magnitud utilizado en el catálogo depende en gran medida de la agencia o fuente que reporta el evento. Esta relación se mantiene incluso al agrupar los tipos de magnitud en categorías más generales.


#Relacion entre magType_grupo y categorias analiticas----
##magType_grupo y magnitud_cat----
#Se usa magType_grupo para reducir celdas de frecuencia esperada muy baja.

magtype_magnitud_cat <- sismos_categoricas %>%
  count(
    magType_grupo,
    magnitud_cat,
    name = "numero_eventos",
    .drop = FALSE
  ) %>%
  group_by(magType_grupo) %>%
  mutate(
    total_fila = sum(numero_eventos),
    proporcion_fila = if_else(
      total_fila == 0,
      0,
      numero_eventos / total_fila
    ),
    porcentaje_fila = proporcion_fila * 100
  ) %>%
  ungroup() %>%
  select(-total_fila) %>%
  arrange(magType_grupo, magnitud_cat)

print(magtype_magnitud_cat, n = Inf)


##Chi-cuadrado, V de Cramer y Fisher para magType_grupo y magnitud_cat----

tabla_magtype_magnitud <- sismos_categoricas %>%
  filter(!is.na(magType_grupo), !is.na(magnitud_cat)) %>%
  mutate(
    magType_grupo = droplevels(magType_grupo),
    magnitud_cat = droplevels(magnitud_cat)
  ) %>%
  with(table(magType_grupo, magnitud_cat))

prueba_chi_magnitud <- suppressWarnings(chisq.test(tabla_magtype_magnitud))

set.seed(123)
prueba_fisher_magnitud <- fisher.test(
  tabla_magtype_magnitud,
  simulate.p.value = TRUE,
  B = 10000
)

v_cramer_magnitud <- calcular_v_cramer(
  prueba_chi_magnitud,
  tabla_magtype_magnitud
)

asociacion_magtype_magnitud <- tibble::tibble(
  estadistico_chi = as.numeric(prueba_chi_magnitud$statistic),
  grados_libertad = as.numeric(prueba_chi_magnitud$parameter),
  valor_p_chi = prueba_chi_magnitud$p.value,
  valor_p_fisher = prueba_fisher_magnitud$p.value,
  v_cramer = v_cramer_magnitud
)

print(asociacion_magtype_magnitud)


##magType_grupo y profundidad_cat----

magtype_profundidad_cat <- sismos_categoricas %>%
  count(
    magType_grupo,
    profundidad_cat,
    name = "numero_eventos",
    .drop = FALSE
  ) %>%
  group_by(magType_grupo) %>%
  mutate(
    total_fila = sum(numero_eventos),
    proporcion_fila = if_else(
      total_fila == 0,
      0,
      numero_eventos / total_fila
    ),
    porcentaje_fila = proporcion_fila * 100
  ) %>%
  ungroup() %>%
  select(-total_fila) %>%
  arrange(magType_grupo, profundidad_cat)

print(magtype_profundidad_cat, n = Inf)


##Chi-cuadrado, V de Cramer y Fisher para magType_grupo y profundidad_cat----

tabla_magtype_profundidad <- sismos_categoricas %>%
  filter(!is.na(magType_grupo), !is.na(profundidad_cat)) %>%
  mutate(
    magType_grupo = droplevels(magType_grupo),
    profundidad_cat = droplevels(profundidad_cat)
  ) %>%
  with(table(magType_grupo, profundidad_cat))

prueba_chi_profundidad <- suppressWarnings(chisq.test(tabla_magtype_profundidad))

set.seed(123)
prueba_fisher_profundidad <- fisher.test(
  tabla_magtype_profundidad,
  simulate.p.value = TRUE,
  B = 10000
)

v_cramer_profundidad <- calcular_v_cramer(
  prueba_chi_profundidad,
  tabla_magtype_profundidad
)

asociacion_magtype_profundidad <- tibble::tibble(
  estadistico_chi = as.numeric(prueba_chi_profundidad$statistic),
  grados_libertad = as.numeric(prueba_chi_profundidad$parameter),
  valor_p_chi = prueba_chi_profundidad$p.value,
  valor_p_fisher = prueba_fisher_profundidad$p.value,
  v_cramer = v_cramer_profundidad
)

print(asociacion_magtype_profundidad)


#Cruces descriptivos adicionales----
##Relacion entre magType y zona----

magtype_zona <- sismos_categoricas %>%
  count(zona, magType, name = "numero_eventos") %>%
  group_by(zona) %>%
  mutate(
    total_fila = sum(numero_eventos),
    proporcion = if_else(
      total_fila == 0,
      0,
      numero_eventos / total_fila
    ),
    porcentaje = proporcion * 100
  ) %>%
  ungroup() %>%
  select(-total_fila) %>%
  arrange(zona, desc(numero_eventos))

print(magtype_zona, n = Inf)


##Relacion entre magType_grupo y zona----

magtype_grupo_zona <- sismos_categoricas %>%
  count(zona, magType_grupo, name = "numero_eventos") %>%
  group_by(zona) %>%
  mutate(
    total_fila = sum(numero_eventos),
    proporcion = if_else(
      total_fila == 0,
      0,
      numero_eventos / total_fila
    ),
    porcentaje = proporcion * 100
  ) %>%
  ungroup() %>%
  select(-total_fila) %>%
  arrange(zona, desc(numero_eventos))

print(magtype_grupo_zona, n = Inf)


##Relacion entre magType y status----

magtype_status <- sismos_categoricas %>%
  count(status, magType, name = "numero_eventos") %>%
  group_by(status) %>%
  mutate(
    total_fila = sum(numero_eventos),
    proporcion = if_else(
      total_fila == 0,
      0,
      numero_eventos / total_fila
    ),
    porcentaje = proporcion * 100
  ) %>%
  ungroup() %>%
  select(-total_fila) %>%
  arrange(status, desc(numero_eventos))

print(magtype_status, n = Inf)


##Relacion entre magType_grupo y status----

magtype_grupo_status <- sismos_categoricas %>%
  count(status, magType_grupo, name = "numero_eventos") %>%
  group_by(status) %>%
  mutate(
    total_fila = sum(numero_eventos),
    proporcion = if_else(
      total_fila == 0,
      0,
      numero_eventos / total_fila
    ),
    porcentaje = proporcion * 100
  ) %>%
  ungroup() %>%
  select(-total_fila) %>%
  arrange(status, desc(numero_eventos))

print(magtype_grupo_status, n = Inf)


#Evolucion temporal----
##Eventos por año y magType----

magtype_anio <- sismos_categoricas %>%
  count(año, magType, name = "numero_eventos") %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    magType = sort(unique(stats::na.omit(sismos_categoricas$magType))),
    fill = list(numero_eventos = 0)
  ) %>%
  arrange(año, magType)

print(magtype_anio, n = Inf)


##Eventos por año y magType_grupo----

magtype_grupo_anio <- sismos_categoricas %>%
  count(año, magType_grupo, name = "numero_eventos", .drop = FALSE) %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    magType_grupo = niveles_magtype_grupo,
    fill = list(numero_eventos = 0)
  ) %>%
  mutate(
    magType_grupo = factor(magType_grupo, levels = niveles_magtype_grupo)
  ) %>%
  arrange(año, magType_grupo)

print(magtype_grupo_anio, n = Inf)


##Vigencia de cada magType, magType_grupo y magSource----
#Muestra el primer y ultimo año observado para cada categoria.

vigencia_magtype <- sismos_categoricas %>%
  group_by(magType) %>%
  summarise(
    numero_eventos = n(),
    primer_año = min(año, na.rm = TRUE),
    ultimo_año = max(año, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(primer_año, magType)

print(vigencia_magtype, n = Inf)

vigencia_magtype_grupo <- sismos_categoricas %>%
  group_by(magType_grupo) %>%
  summarise(
    numero_eventos = n(),
    primer_año = min(año, na.rm = TRUE),
    ultimo_año = max(año, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(primer_año, magType_grupo)

print(vigencia_magtype_grupo, n = Inf)

vigencia_magsource <- sismos_categoricas %>%
  group_by(magSource) %>%
  summarise(
    numero_eventos = n(),
    primer_año = min(año, na.rm = TRUE),
    ultimo_año = max(año, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(primer_año, magSource)

print(vigencia_magsource, n = Inf)


##Participacion anual del metodo dominante mww----
#Permite observar cambios metodologicos del catalogo a lo largo del periodo.

participacion_mww_anual <- sismos_categoricas %>%
  group_by(año) %>%
  summarise(
    eventos_total = n(),
    eventos_mww = sum(magType_grupo == "mww", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::complete(
    año = año_inicio:año_fin,
    fill = list(eventos_total = 0, eventos_mww = 0)
  ) %>%
  mutate(
    porcentaje_mww = if_else(
      eventos_total == 0,
      0,
      eventos_mww / eventos_total * 100
    )
  ) %>%
  arrange(año)

print(participacion_mww_anual, n = Inf)


#Graficos de frecuencias----
##Eventos por magType----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 5, 4, 2) + 0.1)

barras_magtype <- barplot(
  eventos_magtype$numero_eventos,
  names.arg = if_else(
    is.na(eventos_magtype$magType),
    "Sin dato",
    as.character(eventos_magtype$magType)
  ),
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


##Eventos por magType_grupo----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 5, 4, 2) + 0.1)

barras_magtype_grupo <- barplot(
  eventos_magtype_grupo$numero_eventos,
  names.arg = if_else(
    is.na(eventos_magtype_grupo$magType_grupo),
    "Sin dato",
    as.character(eventos_magtype_grupo$magType_grupo)
  ),
  col = "gray80",
  border = "gray30",
  las = 1,
  cex.names = 0.9,
  ylim = c(0, max(eventos_magtype_grupo$numero_eventos) * 1.18),
  ylab = "Numero de eventos",
  main = "Eventos segun grupo de magType"
)

text(
  x = barras_magtype_grupo,
  y = eventos_magtype_grupo$numero_eventos,
  labels = paste0(
    eventos_magtype_grupo$numero_eventos,
    " (",
    format(eventos_magtype_grupo$porcentaje, decimal.mark = ",", nsmall = 1),
    "%)"
  ),
  pos = 3,
  cex = 0.8
)

box()


##Eventos por magSource----

par(mfrow = c(1, 1), bg = "white", mar = c(5, 5, 4, 2) + 0.1)

barras_magsource <- barplot(
  eventos_magsource$numero_eventos,
  names.arg = if_else(
    is.na(eventos_magsource$magSource),
    "Sin dato",
    as.character(eventos_magsource$magSource)
  ),
  col = "gray80",
  border = "gray30",
  las = 2,
  cex.names = 0.8,
  ylim = c(0, max(eventos_magsource$numero_eventos) * 1.18),
  ylab = "Numero de eventos",
  main = "Eventos segun agencia reportante"
)

text(
  x = barras_magsource,
  y = eventos_magsource$numero_eventos,
  labels = eventos_magsource$numero_eventos,
  pos = 3,
  cex = 0.75
)


box()


#Restablecer parametros graficos----

par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)
