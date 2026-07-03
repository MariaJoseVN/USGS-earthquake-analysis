# 08 - Magnitud y profundidad entre zonas (Informe Asesoria 2)----
# Fase 3 del checklist | Checkpoints C3 y C4


# 1. Cargar la base preparada----

source(file.path("Scripts", "00_preparacion_base.R"))


# 2. Seleccionar las variables de estudio----

base_fase3 <- sismos %>%
  dplyr::select(       # calificado: MASS (cargado por el script 07) tambien exporta select()
    zona,
    mag,
    depth
  )


# 3. Definir la variable de agrupacion----

base_fase3 <- base_fase3 %>%
  mutate(
    zona = factor(
      zona,
      levels = c(
        "Cinturon de Fuego",
        "Resto del mundo",
        "Cinturon Alpino-Himalayo",
        "Dorsal Meso-Atlantica"
      )
    )
  )

levels(base_fase3$zona)
table(base_fase3$zona)

# 4. QQ-plot de magnitud por zona----

colores_zona <- c(
  "Cinturon de Fuego" = "#e31a1c",
  "Resto del mundo" = "#9e9e9e",
  "Cinturon Alpino-Himalayo" = "#47cea8",
  "Dorsal Meso-Atlantica" = "#dfbf8a"
)

op <- par(mfrow = c(2, 2), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

invisible(Map(function(zona_actual, color) {
  x <- base_fase3$mag[base_fase3$zona == zona_actual]
  qqnorm(x, main = zona_actual, xlab = "Cuantiles teoricos",
         ylab = "Cuantiles observados", pch = 19, col = color)
  qqline(x, col = "black", lty = 2, lwd = 1.5)
  box()
}, levels(base_fase3$zona), colores_zona[levels(base_fase3$zona)]))

par(op)

# 5. QQ-plot de profundidad por zona----

op <- par(mfrow = c(2, 2), bg = "white", mar = c(5, 4, 4, 2) + 0.1)

invisible(Map(function(zona_actual, color) {
  x <- base_fase3$depth[base_fase3$zona == zona_actual]
  qqnorm(x, main = zona_actual, xlab = "Cuantiles teoricos",
         ylab = "Cuantiles observados", pch = 19, col = color)
  qqline(x, col = "black", lty = 2, lwd = 1.5)
  box()
}, levels(base_fase3$zona), colores_zona[levels(base_fase3$zona)]))

par(op)


## 5.1 QQ-plot conjunto gracias a mahalanobi----

# 7. QQ multivariante de Mahalanobis----

colores_zona <- c(
  "#e31a1c", "#9e9e9e", "#47cea8", "#dfbf8a"
)

qq_mahalanobis <- function(zona_actual, color) {
  
  datos <- as.matrix(
    base_fase3[base_fase3$zona == zona_actual, c("mag", "depth")]
  )
  
  distancias <- mahalanobis(
    datos,
    center = colMeans(datos),
    cov = cov(datos)
  )
  
  cuantiles <- qchisq(
    ppoints(nrow(datos)),
    df = ncol(datos)
  )
  
  plot(
    cuantiles,
    sort(distancias),
    main = zona_actual,
    xlab = "Cuantiles teóricos chi-cuadrado",
    ylab = "Distancias de Mahalanobis",
    pch = 19,
    col = color
  )
  
  abline(0, 1, lty = 2)
}

par(mfrow = c(2, 2))

invisible(
  Map(
    qq_mahalanobis,
    levels(base_fase3$zona),
    colores_zona
  )
)

par(mfrow = c(1, 1))

# 6. Normalidad univariada y multivariante----
# Requiere MVN version >= 6 (API con mvn_test / univariate_test). En v5 y anteriores
# estos argumentos se llaman distinto (mvnTest / univariateTest) y el script romperia:
# todos los integrantes deben tener la misma version (>= 6) para que el informe se
# reproduzca en cualquier maquina. Verificado con MVN 6.3.

normalidad_fase3 <- MVN::mvn(
  data = base_fase3,
  subset = "zona",
  mvn_test = "mardia",
  univariate_test = "SW",
  alpha = 0.10,
  descriptives = FALSE,
  multivariate_outlier_method = "none"
)

# Normalidad multivariante de Mardia
summary(normalidad_fase3, select = "mvn")

# Normalidad univariada de Shapiro-Wilk
summary(normalidad_fase3, select = "univariate")


# 7. Homogeneidad de matrices de covarianza----
library(heplots)
box_m_fase3 <- heplots::boxM(
  cbind(mag, depth) ~ zona,
  data = base_fase3
)

box_m_fase3

# 8. Relación entre magnitud y profundidad----

# Bartlett utiliza correlación de Pearson
matriz_pearson <- cor(
  base_fase3[, c("mag", "depth")],
  method = "pearson"
)

bartlett_fase3 <- psych::cortest.bartlett(
  R = matriz_pearson,
  n = nrow(base_fase3)
)

# Spearman describe la asociación observada
spearman_fase3 <- cor.test(
  base_fase3$mag,
  base_fase3$depth,
  method = "spearman",
  exact = FALSE
)

matriz_pearson
bartlett_fase3
spearman_fase3


#Decision de la compuerta C3----
# Resultados de los supuestos (Bloque A):
#   - Mardia (asimetria y curtosis): rechaza normalidad en las 4 zonas (p < 0,001).
#   - Shapiro-Wilk (mag y depth): rechaza normalidad en todas (p < 0,001).
#   - Box-M: chi2 = 286,5 ; p < 2,2e-16 -> matrices de covarianza heterogeneas (rechaza).
#   - Bartlett (esfericidad): chi2 = 0,26 ; p = 0,607 -> NO rechaza; mag y depth casi no
#     correlacionan (dato util para la Fase 6: cada variable aporta informacion distinta).
#
# DECISION: normalidad rechazada Y covarianzas heterogeneas, por lo que la ruta
# parametrica (MANOVA) no se justifica. Se toma la RUTA NO PARAMETRICA (Kruskal-Wallis,
# Dunn y tamanos de efecto), que es el Bloque B. Este es el punto de quiebre del relato:
# la etapa inferencial deja de comparar vectores de medias y pasa a comparar distribuciones.


#Bloque B del Checklist----

# 9. Resumen descriptivo robusto por zona----

resumen_fase3 <- base_fase3 %>%
  group_by(zona) %>%
  summarise(
    n = n(),
    mediana_mag = median(mag),
    q1_mag = quantile(mag, 0.25),
    q3_mag = quantile(mag, 0.75),
    ric_mag = IQR(mag),
    mediana_depth = median(depth),
    q1_depth = quantile(depth, 0.25),
    q3_depth = quantile(depth, 0.75),
    ric_depth = IQR(depth),
    .groups = "drop"
  )

resumen_fase3


# 10. Comparación global entre zonas: Kruskal-Wallis----

kruskal_mag <- kruskal.test(
  mag ~ zona,
  data = base_fase3
)

kruskal_depth <- kruskal.test(
  depth ~ zona,
  data = base_fase3
)

kruskal_mag
kruskal_depth



# 11. Tamaño de efecto global(Epsilon al cuadrado)----
library(rcompanion)

epsilon_mag <- rcompanion::epsilonSquared(
  x = base_fase3$mag,
  g = base_fase3$zona,
  digits = 4
)

epsilon_depth <- rcompanion::epsilonSquared(
  x = base_fase3$depth,
  g = base_fase3$zona,
  digits = 4
)

efecto_global <- tibble::tibble(
  variable = c("Magnitud", "Profundidad"),
  epsilon2 = c(epsilon_mag, epsilon_depth)
)

efecto_global

# 12. Comparaciones post-hoc de Dunn-Holm (Diferencias pero a pares)----

dunn_mag <- FSA::dunnTest(
  mag ~ zona,
  data = base_fase3,
  method = "holm"
)$res

dunn_depth <- FSA::dunnTest(
  depth ~ zona,
  data = base_fase3,
  method = "holm"
)$res

tabla_dunn <- dplyr::bind_rows(
  "Magnitud" = dunn_mag,
  "Profundidad" = dunn_depth,
  .id = "variable"
)

tabla_dunn

# 13. Tamaños de efecto por pares: delta de Cliff----

library(effsize)

cliff_fase3 <- function(variable, zona_comparada) {
  effsize::cliff.delta(
    base_fase3[[variable]][base_fase3$zona == "Cinturon de Fuego"],
    base_fase3[[variable]][base_fase3$zona == zona_comparada],
    conf.level = 0.95
  )
}

resultados_cliff <- Map(
  cliff_fase3,
  c("mag", "mag", "depth", "depth"),
  c(
    "Dorsal Meso-Atlantica",
    "Cinturon Alpino-Himalayo",
    "Dorsal Meso-Atlantica",
    "Cinturon Alpino-Himalayo"
  )
)

names(resultados_cliff) <- c(
  "Magnitud: Fuego-Dorsal",
  "Magnitud: Fuego-Alpino",
  "Profundidad: Fuego-Dorsal",
  "Profundidad: Fuego-Alpino"
)

resultados_cliff
