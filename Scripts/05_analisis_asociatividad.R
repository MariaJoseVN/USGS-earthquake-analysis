#VARIABLES NUMÉRICAS
# Matriz de correlacion numerica
matriz_correlacion_numericas <- sismos %>%
  select(where(is.numeric), -any_of(c("nst", "rms"))) %>%
  cor(method = "spearman", use = "pairwise.complete.obs") %>%
  round(3)

matriz_correlacion_numericas

# Grafico de la matriz de correlacion
corrplot::corrplot(
  matriz_correlacion_numericas,
  method = "color",
  type = "upper",
  addCoef.col = "black",
  number.cex = 0.7,
  tl.col = "black",
  tl.cex = 0.8,
  col = grDevices::colorRampPalette(c("#2166AC", "white", "#B2182B"))(200),
  diag = TRUE
)


# Grafico completo
grafico_correlacion_numericas <- sismos %>%
  select(where(is.numeric), -any_of(c("nst", "rms"))) %>%
  GGally::ggpairs(
    title = "Matriz de correlacion de variables numericas"
  ) +
  theme(legend.position = "right")

grafico_correlacion_numericas

#La matriz de correlación muestra que la mayoría de las variables numéricas 
# presentan asociaciones débiles. La relación más marcada se observa entre magnitud y significancia,
# lo que es coherente con la forma en que USGS construye el indicador sig. 
# También se observa una asociación alta entre año y década, atribuible a que década deriva directamente del año. 
# Las variables instrumentales imputadas, nst_imp y rms_imp, presentan asociaciones negativas moderadas 
# con el tiempo, aunque este resultado debe interpretarse con cautela debido al procedimiento de imputación por década.

# Relacion entre magnitud y significancia
sismos %>%
  ggplot(aes(x = mag, y = sig)) +
  geom_point(color = "#2166AC", alpha = 0.45, size = 1.2) +
  geom_smooth(method = "lm", se = TRUE, color = "#B2182B") +
  labs(
    title = "Relacion entre magnitud y significancia",
    x = "Magnitud",
    y = "Significancia USGS"
  ) +
  theme_minimal()

# Correlacion entre magnitud y significancia
cor.test(
  sismos$mag,
  sismos$sig,
  method = "spearman"
)
# La correlación de Spearman entre magnitud y significancia fue alta y positiva
# (rho = 0,816; p < 0,001). Esto indica que los eventos con mayor magnitud tienden
# a presentar mayor significancia USGS. La advertencia del test se debe a la
# presencia de empates en los rangos, esperable en variables como la magnitud,
# por lo que el p-valor se interpreta como aproximado.


# Significancia segun categoria de magnitud
sismos %>%
  ggplot(aes(x = magnitud_cat, y = sig, fill = magnitud_cat)) +
  geom_boxplot(alpha = 0.75) +
  labs(
    title = "Significancia segun categoria de magnitud",
    x = "Categoria de magnitud",
    y = "Significancia USGS"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
#La significancia USGS aumenta conforme aumenta la categoría de magnitud. 
# Los eventos clasificados como "Fuerte" presentan los valores más bajos de 
# significancia y una distribución más concentrada. 
# Los eventos "Mayor" muestran una mediana más alta y mayor dispersión, 
# mientras que los eventos "Grande o extremo" presentan la mediana más elevada y valores más altos en general. 
# Esto es coherente con la correlación positiva observada entre magnitud y significancia.

#Aunque existe una tendencia clara, las tres categorías presentan valores atípicos altos. 
# Esto indica que algunos eventos pueden alcanzar alta significancia aun dentro de 
# categorías menores, probablemente porque el indicador sig no depende solo de la magnitud, 
# sino también de otros elementos considerados por USGS.

# Comparacion de significancia segun categoria de magnitud
#Se usa Kruskal-Wallis porque permite evaluar si la significancia difiere entre categorías de 
# magnitud sin asumir normalidad en la distribución de sig.
kruskal.test(sig ~ magnitud_cat, data = sismos)
#La prueba de Kruskal-Wallis muestra diferencias estadísticamente significativas en la significancia USGS 
# según la categoría de magnitud (χ² = 546,98; gl = 2; p < 0,001). Esto indica que los valores de sig 
# cambian entre eventos Fuerte, Mayor y Grande o extremo.

#Kruskal-Wallis solo dice que al menos una categoría difiere de otra, no dice exactamente cuáles pares son distintos. 
#Como tu boxplot muestra una tendencia bastante clara, el siguiente paso sería una comparación por pares:
# Comparaciones por pares entre categorias de magnitud
pairwise.wilcox.test(
  sismos$sig,
  sismos$magnitud_cat,
  p.adjust.method = "bonferroni"
)
#Ese resultado confirma que las tres categorías difieren entre sí.
#Las comparaciones por pares mediante Wilcoxon, con ajuste de Bonferroni, indican diferencias significativas 
#entre todas las categorías de magnitud. La significancia USGS aumenta progresivamente 
# desde los eventos Fuerte hacia los eventos Mayor y Grande o extremo, 
# lo que confirma que las categorías de magnitud separan grupos con niveles de significancia distintos.


#Relación temporal de nst_imp y rms_imp, porque ahí la matriz mostró asociaciones moderadas negativas con año/decada
#Asociacion temporal de variables instrumentales:
#tabla resume la asociación entre el tiempo (año) y las variables instrumentales imputadas nst_imp y rms_imp, usando correlación de Spearman.
asociacion_tiempo_instrumental <- tibble::tibble(
  variable = c("nst_imp", "rms_imp"),
  rho_spearman = c(
    suppressWarnings(cor.test(sismos$año, sismos$nst_imp, method = "spearman")$estimate),
    suppressWarnings(cor.test(sismos$año, sismos$rms_imp, method = "spearman")$estimate)
  ),
  valor_p = c(
    suppressWarnings(cor.test(sismos$año, sismos$nst_imp, method = "spearman")$p.value),
    suppressWarnings(cor.test(sismos$año, sismos$rms_imp, method = "spearman")$p.value)
  )
)
asociacion_tiempo_instrumental
#nst presenta una correlación negativa moderada con el año, lo que indica que en los años más recientes los eventos tienden a estar asociados a un menor número de estaciones reportadas.
#rms presenta una correlación negativa moderada con el año, lo que indica que en los años más recientes los eventos tienden a presentar menores residuos RMS, es decir, un mejor ajuste del modelo de localización del evento.

#GRÁFICO / Variables instrumentales imputadas por decada
sismos %>%
  select(decada, nst_imp, rms_imp) %>%
  tidyr::pivot_longer(
    cols = c(nst_imp, rms_imp),
    names_to = "variable",
    values_to = "valor"
  ) %>%
  ggplot(aes(x = factor(decada), y = valor, fill = factor(decada))) +
  geom_boxplot(alpha = 0.75) +
  facet_wrap(~ variable, scales = "free_y") +
  labs(
    title = "Variables instrumentales imputadas por decada",
    x = "Decada",
    y = "Valor"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
# En el periodo observado, nst_imp y rms_imp presentan valores centrales menores
# en la decada de 2020 respecto de 2000 y 2010. Esta diferencia sugiere cambios
# temporales en las variables instrumentales del catalogo. Sin embargo, la
# decada de 2020 esta incompleta, por lo que la comparacion debe interpretarse
# como una tendencia del tramo disponible y no como una conclusion definitiva
# para toda la decada.


#VARIABLES CATEGÓRICAS
#Chi-cuadrado: sirve para probar si existe asociación, pero depende mucho del tamaño de la muestra y no mide tan claramente la fuerza.
#V de Cramer: mide fuerza de asociación entre variables categóricas nominales, incluso con más de dos categorías.
#Coeficiente Phi: parecido a V de Cramer, pero solo ideal para tablas 2x2.
#Coeficiente de contingencia: también mide asociación, pero su máximo no siempre llega a 1, por eso es menos intuitivo.
#Lambda de Goodman-Kruskal: mide cuánto mejora la predicción de una variable categórica usando otra.
#Theil’s U: mide asociación direccional, útil si quieres saber cuánto una variable ayuda a predecir otra.
#Tau-b o Tau-c de Kendall: sirven más para variables categóricas ordinales, no tanto nominales.

# Variables categoricas de interes
variables_categoricas <- c(
  "locationSource",
  "magSource",
  "net",
  "magType_grupo",
  "zona",
  "profundidad_cat",
  "magnitud_cat"
)

pares_categoricos <- t(combn(variables_categoricas, 2))
asociacion_categoricas <- tibble::tibble()

for (i in 1:nrow(pares_categoricos)) {
  variable_1 <- pares_categoricos[i, 1]
  variable_2 <- pares_categoricos[i, 2]
  tabla <- table(sismos[[variable_1]], sismos[[variable_2]])
  prueba <- suppressWarnings(chisq.test(tabla))

  asociacion_categoricas <- bind_rows(
    asociacion_categoricas,
    tibble::tibble(
      variable_1 = variable_1,
      variable_2 = variable_2,
      valor_p = prueba$p.value,
      v_cramer = sqrt(
        as.numeric(prueba$statistic) /
          (sum(tabla) * (min(dim(tabla)) - 1))
      )
    )
  )
}

asociacion_categoricas <- asociacion_categoricas %>%
  arrange(desc(v_cramer))

# Ver todas las asociaciones
asociacion_categoricas %>%
  as.data.frame()
# Las asociaciones mas fuertes aparecen entre variables de fuente del catalogo:
# magSource, net y locationSource. Esto indica que la red de reporte y las
# fuentes de localizacion y magnitud estan estrechamente relacionadas.
# Tambien se observa una asociacion moderada-alta entre magSource y
# magType_grupo, lo que sugiere que el tipo de magnitud utilizado depende en
# parte de la fuente que reporta la magnitud. En cambio, zona, profundidad_cat
# y magnitud_cat presentan asociaciones debiles con el resto de variables.

#Las asociaciones más fuertes se observan entre variables de fuente o reporte del catálogo: magSource con net, locationSource con net y locationSource con magSource. Esto indica que la red que reporta el evento y las fuentes de localización/magnitud están muy relacionadas entre sí.
#Las variables geofísicas o analíticas, como zona, profundidad_cat y magnitud_cat, presentan asociaciones débiles con las variables de fuente. Esto sugiere que las categorías de magnitud, profundidad y zona no dependen fuertemente de la fuente de reporte.

# Matriz de asociacion categorica
matriz_asociacion_categoricas <- asociacion_categoricas %>%
  select(variable_1, variable_2, v_cramer) %>%
  tidyr::pivot_wider(
    names_from = variable_2,
    values_from = v_cramer
  )

# Matriz vacia con el mismo orden en filas y columnas
matriz_cramer <- matrix(
  NA,
  nrow = length(variables_categoricas),
  ncol = length(variables_categoricas),
  dimnames = list(variables_categoricas, variables_categoricas)
)

# Se completan los valores de V de Cramer
for (i in 1:nrow(asociacion_categoricas)) {
  matriz_cramer[
    asociacion_categoricas$variable_1[i],
    asociacion_categoricas$variable_2[i]
  ] <- asociacion_categoricas$v_cramer[i]

  matriz_cramer[
    asociacion_categoricas$variable_2[i],
    asociacion_categoricas$variable_1[i]
  ] <- asociacion_categoricas$v_cramer[i]
}

diag(matriz_cramer) <- 1

# Grafico de asociacion categorica
corrplot::corrplot(
  matriz_cramer,
  method = "color",
  type = "upper",
  addCoef.col = "black",
  number.cex = 1,
  tl.col = "black",
  tl.cex = 0.9,
  col = grDevices::colorRampPalette(c("#2166AC", "white", "#B2182B"))(200),
  diag = TRUE,
  title = "Matriz de asociacion categorica (V de Cramer)",
  mar = c(0, 0, 2, 0)
)

#Primero estudiaría las asociaciones fuertes que sí tienen sentido analítico:
#magSource con magType_grupo: importante, porque muestra si la fuente de magnitud se relaciona con el tipo de magnitud usado.
#locationSource, magSource y net: las reportaría como asociación administrativa del catálogo, pero no las profundizaría mucho.
#zona con profundidad_cat: aunque es débil, tiene más sentido geofísico que algunas asociaciones de fuente.

# Asociacion entre fuente de magnitud y tipo de magnitud
magSource_magType <- sismos %>%
  count(magSource, magType_grupo, name = "n") %>%
  group_by(magSource) %>%
  mutate(
    porcentaje = n / sum(n) * 100
  ) %>%
  ungroup() %>%
  arrange(magSource, desc(porcentaje))

magSource_magType

# Distribucion de magType_grupo segun magSource
magSource_magType %>%
  ggplot(aes(x = magSource, y = porcentaje, fill = magType_grupo)) +
  geom_col(color = "white", linewidth = 0.3) +
  scale_fill_manual(
    values = c(
      "mww" = "#D7F1EE",
      "mwc" = "#8FD8D0",
      "mwb" = "#3FAFA7",
      "otros" = "#2F6F73"
    )
  ) +
  labs(
    title = "Tipo de magnitud segun fuente de magnitud",
    x = "Fuente de magnitud",
    y = "Porcentaje",
    fill = "Tipo de magnitud"
  ) +
  theme_minimal()


# Asociacion entre zona y categoria de profundidad
zona_profundidad <- sismos %>%
  count(zona, profundidad_cat, name = "n") %>%
  group_by(zona) %>%
  mutate(
    porcentaje = n / sum(n) * 100
  ) %>%
  ungroup() %>%
  arrange(zona, desc(porcentaje))

zona_profundidad

# Distribucion de profundidad segun zona
zona_profundidad %>%
  ggplot(aes(x = zona, y = porcentaje, fill = profundidad_cat)) +
  geom_col(color = "white", linewidth = 0.3) +
  scale_fill_manual(
    values = c(
      "Superficial" = "#D7F1EE",
      "Intermedio" = "#3FAFA7",
      "Profundo" = "#2F6F73"
    )
  ) +
  labs(
    title = "Categoria de profundidad segun zona",
    x = "Zona",
    y = "Porcentaje",
    fill = "Profundidad"
  ) +
  theme_minimal()


# Asociacion especifica entre zona y profundidad
asociacion_categoricas %>%
  filter(
    variable_1 == "zona" & variable_2 == "profundidad_cat" |
      variable_1 == "profundidad_cat" & variable_2 == "zona"
  )

# Porcentaje de profundidad por zona
zona_profundidad <- sismos %>%
  count(zona, profundidad_cat, name = "n") %>%
  group_by(zona) %>%
  mutate(
    porcentaje = n / sum(n) * 100
  ) %>%
  ungroup() %>%
  arrange(zona, desc(porcentaje))

zona_profundidad


# En las variables categoricas, las asociaciones mas fuertes se concentran en
# variables administrativas o de fuente del catalogo, como magSource, net y
# locationSource. La asociacion entre magSource y magType_grupo muestra que el
# tipo de magnitud usado depende en parte de la fuente que reporta la magnitud.
# En cambio, las variables geofisicas como zona, profundidad_cat y magnitud_cat
# presentan asociaciones mas debiles, por lo que sus relaciones se interpretan
# principalmente de forma descriptiva.
