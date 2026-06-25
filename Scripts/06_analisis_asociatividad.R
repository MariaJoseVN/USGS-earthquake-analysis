# Matriz de correlacion numerica
matriz_correlacion_numericas <- sismos %>%
  select(where(is.numeric), -any_of(c("nst", "rms"))) %>%
  cor(method = "spearman", use = "pairwise.complete.obs") %>%
  round(3)

matriz_correlacion_numericas

library(corrplot)
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


library(GGally)
library(ggplot2)
# Panel superior con color y correlacion centrada
panel_cor_color <- function(data, mapping, ...) {
  x <- GGally::eval_data_col(data, mapping$x)
  y <- GGally::eval_data_col(data, mapping$y)
  correlacion <- cor(x, y, method = "spearman", use = "pairwise.complete.obs")
  ggplot(data = data, mapping = mapping) +
    geom_rect(
      data = tibble::tibble(correlacion = correlacion),
      aes(
        xmin = -Inf,
        xmax = Inf,
        ymin = -Inf,
        ymax = Inf,
        fill = correlacion
      ),
      inherit.aes = FALSE
    ) +
    annotate(
      "text",
      x = mean(range(x, na.rm = TRUE)),
      y = mean(range(y, na.rm = TRUE)),
      label = round(correlacion, 2),
      size = 3.3,
      fontface = "bold"
    ) +
    scale_fill_gradient2(
      low = "#2166AC",
      mid = "white",
      high = "#B2182B",
      midpoint = 0,
      limits = c(-1, 1),
      breaks = seq(-1, 1, 0.2),
      name = "Correlacion"
    ) +
    theme_void()
}
# Panel inferior con nube de puntos
panel_puntos <- function(data, mapping, ...) {
  ggplot(data = data, mapping = mapping) +
    geom_point(color = "#2166AC", alpha = 0.35, size = 0.7) +
    theme_minimal(base_size = 8)
}
# Grafico completo
grafico_correlacion_numericas <- sismos %>%
  select(where(is.numeric), -any_of(c("nst", "rms"))) %>%
  GGally::ggpairs(
    upper = list(continuous = panel_cor_color),
    lower = list(continuous = panel_puntos),
    diag = list(
      continuous = GGally::wrap(
        "barDiag",
        bins = 20,
        fill = "#B2182B",
        color = "white"
      )
    ),
    title = "Matriz de correlacion de variables numericas",
    legend = c(1, 2)
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
