
# 11 - Clasificacion de zonas (Informe Asesoria 2)----
# Fase 6 del checklist | Seccion 7.6 del informe | Checkpoint C7


# 1. Cargar la base preparada----

source(file.path("Scripts", "00_preparacion_base.R"))


# 2. Seleccionar las variables de estudio----

base_fase6 <- sismos %>%
  dplyr::select(
    zona,
    mag,
    depth,
    magnitud_cat,
    profundidad_cat
  ) %>%
  dplyr::mutate(
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


# 3. Tablas para el analisis de correspondencia----

tabla_ca_magnitud <- table(
  zona = base_fase6$zona,
  categoria = base_fase6$magnitud_cat
)

tabla_ca_profundidad <- table(
  zona = base_fase6$zona,
  categoria = base_fase6$profundidad_cat
)

tabla_ca_magnitud
tabla_ca_profundidad


# 4. Frecuencias esperadas----

esperadas_ca_magnitud <- suppressWarnings(
  chisq.test(tabla_ca_magnitud)$expected
)

esperadas_ca_profundidad <- suppressWarnings(
  chisq.test(tabla_ca_profundidad)$expected
)

round(esperadas_ca_magnitud, 2)
round(esperadas_ca_profundidad, 2)
esperadas_ca_magnitud < 5
esperadas_ca_profundidad < 5


# 5. Perfiles fila----

perfil_fila_magnitud <- prop.table(tabla_ca_magnitud, margin = 1)
perfil_fila_profundidad <- prop.table(tabla_ca_profundidad, margin = 1)

round(perfil_fila_magnitud, 3)
round(perfil_fila_profundidad, 3)


# 6. Perfiles columna----

perfil_columna_magnitud <- prop.table(tabla_ca_magnitud, margin = 2)
perfil_columna_profundidad <- prop.table(tabla_ca_profundidad, margin = 2)

round(perfil_columna_magnitud, 3)
round(perfil_columna_profundidad, 3)


# 7. Analisis de correspondencia----

ac_magnitud <- FactoMineR::CA(
  as.data.frame.matrix(tabla_ca_magnitud),
  graph = FALSE
)

ac_profundidad <- FactoMineR::CA(
  as.data.frame.matrix(tabla_ca_profundidad),
  graph = FALSE
)

ac_magnitud$eig
ac_profundidad$eig


# 8. Coordenadas y contribuciones----

round(ac_magnitud$row$coord, 3)
round(ac_magnitud$row$contrib, 2)
round(ac_magnitud$col$coord, 3)
round(ac_magnitud$col$contrib, 2)

round(ac_profundidad$row$coord, 3)
round(ac_profundidad$row$contrib, 2)
round(ac_profundidad$col$coord, 3)
round(ac_profundidad$col$contrib, 2)


# 9. Mapas de correspondencia----

graficar_ca <- function(modelo, titulo, color_zona) {
  filas <- modelo$row$coord[, 1:2]
  columnas <- modelo$col$coord[, 1:2]

  graphics::plot(
    NA,
    xlim = grDevices::extendrange(c(filas[, 1], columnas[, 1]), f = 0.25),
    ylim = grDevices::extendrange(c(filas[, 2], columnas[, 2]), f = 0.25),
    xlab = sprintf("Dimension 1 (%.1f %%)", modelo$eig[1, 2]),
    ylab = sprintf("Dimension 2 (%.1f %%)", modelo$eig[2, 2]),
    main = titulo
  )

  graphics::abline(h = 0, v = 0, lty = 2, col = "grey70")
  graphics::points(filas, col = color_zona, pch = 16)
  graphics::text(
    filas,
    labels = rownames(filas),
    col = color_zona,
    pos = 3,
    cex = 0.75
  )
  graphics::points(columnas, col = "#2c3e50", pch = 17)
  graphics::text(
    columnas,
    labels = rownames(columnas),
    col = "#2c3e50",
    pos = 3,
    cex = 0.75
  )
  graphics::legend(
    "topright",
    legend = c("Zonas", "Categorias"),
    col = c(color_zona, "#2c3e50"),
    pch = c(16, 17),
    bty = "n"
  )
}

graficar_ca(
  ac_magnitud,
  "Correspondencia entre zona y categoria de magnitud",
  "#e31a1c"
)

graficar_ca(
  ac_profundidad,
  "Correspondencia entre zona y categoria de profundidad",
  "#47cea8"
)


# 10. Modelo multinomial conjunto----

modelo_multinomial <- nnet::multinom(
  zona ~ mag + depth,
  data = base_fase6,
  trace = FALSE
)

summary(modelo_multinomial)


# 11. Reajuste con predictores estandarizados----

base_fase6 <- base_fase6 %>%
  dplyr::mutate(
    mag_z = as.numeric(scale(mag)),
    depth_z = as.numeric(scale(depth))
  )

modelo_multinomial_z <- nnet::multinom(
  zona ~ mag_z + depth_z,
  data = base_fase6,
  trace = FALSE,
  Hess = TRUE,
  maxit = 1000
)

summary(modelo_multinomial_z)
modelo_multinomial_z$convergence


# 12. Multinomial con reduccion de sesgo----

modelo_multinomial_br <- brglm2::brmultinom(
  zona ~ mag_z + depth_z,
  data = base_fase6,
  type = "AS_mean"
)

summary(modelo_multinomial_br)


# 13. Probabilidades del modelo corregido----

probabilidades_br <- predict(
  modelo_multinomial_br,
  type = "probs"
)

apply(probabilidades_br, 2, range)
colSums(probabilidades_br == 0)

# 14. Significacion global por variable----

lr_multinomial <- car::Anova(
  modelo_multinomial_z,
  type = 2,
  test.statistic = "LR"
)

lr_multinomial


# 15. Matriz de confusion----

clase_predicha_br <- factor(
  colnames(probabilidades_br)[
    max.col(probabilidades_br, ties.method = "first")
  ],
  levels = levels(base_fase6$zona)
)

matriz_confusion_br <- table(
  Predicho = clase_predicha_br,
  Observado = base_fase6$zona
)

matriz_confusion_br


# 16. Metricas de clasificacion----

exactitud_global <- sum(diag(matriz_confusion_br)) /
  sum(matriz_confusion_br)

sensibilidad_zona <- diag(matriz_confusion_br) /
  colSums(matriz_confusion_br)

exactitud_balanceada <- mean(sensibilidad_zona)

base_trivial <- max(
  prop.table(table(base_fase6$zona))
)

metricas_clasificacion <- tibble::tibble(
  metrica = c(
    "Exactitud global",
    "Exactitud balanceada",
    "Base trivial"
  ),
  valor = c(
    exactitud_global,
    exactitud_balanceada,
    base_trivial
  )
)

sensibilidad_zona
metricas_clasificacion


# 17. Comparacion de modelos----

modelo_solo_mag <- nnet::multinom(
  zona ~ mag_z,
  data = base_fase6,
  trace = FALSE
)

modelo_solo_depth <- nnet::multinom(
  zona ~ depth_z,
  data = base_fase6,
  trace = FALSE
)

comparacion_aic <- AIC(
  modelo_solo_mag,
  modelo_solo_depth,
  modelo_multinomial_z
)

lr_depth_dado_mag <- anova(
  modelo_solo_mag,
  modelo_multinomial_z,
  test = "Chisq"
)

lr_mag_dado_depth <- anova(
  modelo_solo_depth,
  modelo_multinomial_z,
  test = "Chisq"
)

comparacion_aic
lr_depth_dado_mag
lr_mag_dado_depth


# 18. Odds ratios del modelo corregido----

resumen_br <- summary(modelo_multinomial_br)
coef_br <- resumen_br$coefficients
ee_br <- resumen_br$standard.errors

tabla_or_br <- tibble::tibble(
  zona = rep(rownames(coef_br), each = ncol(coef_br)),
  predictor = rep(colnames(coef_br), times = nrow(coef_br)),
  beta = as.vector(t(coef_br)),
  error_estandar = as.vector(t(ee_br))
) %>%
  dplyr::filter(predictor != "(Intercept)") %>%
  dplyr::mutate(
    OR = exp(beta),
    limite_inferior = exp(beta - 1.96 * error_estandar),
    limite_superior = exp(beta + 1.96 * error_estandar)
  )

tabla_or_br %>%
  dplyr::mutate(
    dplyr::across(
      c(
        beta,
        error_estandar,
        OR,
        limite_inferior,
        limite_superior
      ),
      round,
      4
    )
  )


# 19. Equivalencia de los predictores estandarizados----

sd(base_fase6$mag)
sd(base_fase6$depth)


# 20. Curvas ROC y AUC por zona----
# Evaluacion complementaria del modelo multinomial corregido.
# La matriz de confusion evalua la clase final asignada por maxima probabilidad.
# El AUC evalua si las probabilidades ajustadas ordenan correctamente cada zona
# frente al resto, aun cuando esa zona no sea finalmente la clase predicha.

if (!requireNamespace("pROC", quietly = TRUE)) {
  stop("Instalar el paquete 'pROC' para calcular ROC/AUC.")
}

roc_por_zona <- lapply(
  levels(base_fase6$zona),
  function(zona_objetivo) {
    respuesta_binaria <- as.integer(base_fase6$zona == zona_objetivo)

    pROC::roc(
      response = respuesta_binaria,
      predictor = probabilidades_br[, zona_objetivo],
      quiet = TRUE,
      direction = "<"
    )
  }
)

names(roc_por_zona) <- levels(base_fase6$zona)

auc_zona <- tibble::tibble(
  zona = names(roc_por_zona),
  auc = as.numeric(vapply(roc_por_zona, pROC::auc, numeric(1)))
)

auc_zona


# 21. Grafico ROC uno contra el resto----
# Ejecutar graficar_roc_zonas() en Positron para revisar el resultado en Plots.
# La misma funcion se usa para exportar el PNG que consume el informe.

graficar_roc_zonas <- function() {
  colores_zona <- c(
    "Cinturon de Fuego" = "#e31a1c",
    "Resto del mundo" = "#1f78b4",
    "Cinturon Alpino-Himalayo" = "#33a02c",
    "Dorsal Meso-Atlantica" = "#6a3d9a"
  )

  graphics::plot(
    NA,
    xlim = c(0, 1),
    ylim = c(0, 1),
    xaxs = "i",
    yaxs = "i",
    main = "Curvas ROC por zona: uno contra el resto",
    xlab = "1 - especificidad",
    ylab = "Sensibilidad"
  )

  graphics::abline(a = 0, b = 1, lty = 2, col = "grey65")

  for (zona_i in names(roc_por_zona)) {
    curva_i <- roc_por_zona[[zona_i]]
    x_i <- 1 - curva_i$specificities
    y_i <- curva_i$sensitivities
    orden_i <- order(x_i, y_i)

    graphics::lines(
      x_i[orden_i],
      y_i[orden_i],
      type = "s",
      col = colores_zona[zona_i],
      lwd = 2
    )
  }

  graphics::legend(
    "bottomright",
    legend = sprintf("%s (AUC = %.3f)", auc_zona$zona, auc_zona$auc),
    col = colores_zona[auc_zona$zona],
    lwd = 2,
    bty = "n",
    cex = 0.75
  )
}

graficar_roc_zonas()

png(
  filename = file.path(
    "Informes Quarto",
    "Imágenes y Recursos",
    "inf2-clasificacion-roc.png"
  ),
  width = 1600,
  height = 1050,
  res = 150
)
graficar_roc_zonas()
dev.off()
