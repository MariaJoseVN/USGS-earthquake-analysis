# 11b - Figuras reproducibles de clasificacion (Informe Asesoria 2)----
#
# Fase 6 | Seccion 7.6 del informe
# Objetivo: regenerar de forma reproducible las dos figuras de la seccion de
# clasificacion que consume el .qmd, SIN modificar el script 11 del grupo:
#   - inf2-clasificacion-correspondencia.png (biplots del analisis de correspondencia)
#   - inf2-clasificacion-roc.png             (curvas ROC uno contra el resto)
#
# Reproduce la logica de los bloques 2-9 (correspondencia) y 10-21 (multinomial y
# ROC) del script 11, con dos ajustes de presentacion en la figura ROC: leyenda mas
# grande (cex = 0,95) y decimales con coma. Se ejecuta desde la raiz del proyecto.
#
# Paquetes: dplyr, FactoMineR (CA), nnet (multinom), brglm2 (brmultinom), pROC (roc/auc).


# 1. Base y variables----

source(file.path("Scripts", "00_preparacion_base.R"))

suppressPackageStartupMessages(library(dplyr))

base_fase6 <- sismos %>%
  dplyr::select(zona, mag, depth, magnitud_cat, profundidad_cat) %>%
  dplyr::mutate(
    zona = factor(
      zona,
      levels = c(
        "Cinturon de Fuego",
        "Resto del mundo",
        "Cinturon Alpino-Himalayo",
        "Dorsal Meso-Atlantica"
      )
    ),
    mag_z = as.numeric(scale(mag)),
    depth_z = as.numeric(scale(depth))
  )


# 2. Analisis de correspondencia----

tabla_ca_magnitud <- table(
  zona = base_fase6$zona,
  categoria = base_fase6$magnitud_cat
)

tabla_ca_profundidad <- table(
  zona = base_fase6$zona,
  categoria = base_fase6$profundidad_cat
)

ac_magnitud <- FactoMineR::CA(
  as.data.frame.matrix(tabla_ca_magnitud),
  graph = FALSE
)

ac_profundidad <- FactoMineR::CA(
  as.data.frame.matrix(tabla_ca_profundidad),
  graph = FALSE
)


# 3. Figura de correspondencia (biplots)----
# Mismo aspecto que el bloque 9 del script 11 (zonas como circulos de color,
# categorias como triangulos oscuros, ejes rotulados por inercia), pero combinando
# ambos paneles con mfrow y con un margen de extension mayor para que las etiquetas
# de los puntos extremos no queden cortadas (xpd = NA permite dibujarlas fuera).

graficar_ca <- function(modelo, titulo, color_zona, f_ext) {
  filas <- modelo$row$coord[, 1:2]
  columnas <- modelo$col$coord[, 1:2]

  graphics::plot(
    NA,
    xlim = grDevices::extendrange(c(filas[, 1], columnas[, 1]), f = f_ext),
    ylim = grDevices::extendrange(c(filas[, 2], columnas[, 2]), f = f_ext),
    xlab = sprintf("Dimension 1 (%.1f %%)", modelo$eig[1, 2]),
    ylab = sprintf("Dimension 2 (%.1f %%)", modelo$eig[2, 2]),
    main = titulo
  )

  graphics::abline(h = 0, v = 0, lty = 2, col = "grey70")
  graphics::points(filas, col = color_zona, pch = 16)
  graphics::text(filas, labels = rownames(filas), col = color_zona,
                 pos = 3, cex = 0.75, xpd = NA)
  graphics::points(columnas, col = "#2c3e50", pch = 17)
  graphics::text(columnas, labels = rownames(columnas), col = "#2c3e50",
                 pos = 3, cex = 0.75, xpd = NA)
  graphics::legend("topright", legend = c("Zonas", "Categorias"),
                   col = c(color_zona, "#2c3e50"), pch = c(16, 17), bty = "n")
}

ruta_biplot <- file.path("Informes Quarto", "Imágenes y Recursos",
                         "inf2-clasificacion-correspondencia.png")

png(filename = ruta_biplot, width = 2200, height = 1100, res = 200, bg = "white")
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1.5) + 0.1)
graficar_ca(ac_magnitud, "Zona x categoria de magnitud", "#e31a1c", 0.45)
graficar_ca(ac_profundidad, "Zona x categoria de profundidad", "#47cea8", 0.30)
dev.off()


# 4. Modelo multinomial corregido y probabilidades----
# dplyr::select se califica siempre porque MASS/nnet no se cargan aqui, pero se
# mantiene la convencion del proyecto.

modelo_multinomial_z <- nnet::multinom(
  zona ~ mag_z + depth_z,
  data = base_fase6,
  trace = FALSE,
  maxit = 1000
)

modelo_multinomial_br <- brglm2::brmultinom(
  zona ~ mag_z + depth_z,
  data = base_fase6,
  type = "AS_mean"
)

probabilidades_br <- predict(modelo_multinomial_br, type = "probs")


# 5. Curvas ROC y AUC por zona (uno contra el resto)----

roc_por_zona <- lapply(
  levels(base_fase6$zona),
  function(zona_objetivo) {
    pROC::roc(
      response = as.integer(base_fase6$zona == zona_objetivo),
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


# 6. Figura ROC----
# Igual que el bloque 21 del script 11, con dos ajustes de presentacion:
#   - leyenda mas grande (cex = 0,95 en vez de 0,75),
#   - decimales con coma en el AUC (formatC con decimal.mark = ",").

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

    graphics::lines(x_i[orden_i], y_i[orden_i], type = "s",
                    col = colores_zona[zona_i], lwd = 2)
  }

  etiquetas <- sprintf(
    "%s (AUC = %s)",
    auc_zona$zona,
    formatC(auc_zona$auc, format = "f", digits = 3, decimal.mark = ",")
  )

  graphics::legend(
    "bottomright",
    legend = etiquetas,
    col = colores_zona[auc_zona$zona],
    lwd = 2,
    bty = "n",
    cex = 0.95
  )
}

ruta_roc <- file.path("Informes Quarto", "Imágenes y Recursos",
                      "inf2-clasificacion-roc.png")

png(filename = ruta_roc, width = 1600, height = 1050, res = 150)
graficar_roc_zonas()
dev.off()
