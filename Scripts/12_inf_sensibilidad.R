# 12 - Analisis de sensibilidad (Informe Asesoria 2)----
#
# Fase 7 del checklist | Seccion 7.7 del informe | Checkpoint C8
# Objetivo: verificar la robustez de las conclusiones ante dos decisiones
# metodologicas. NO ejecutar hasta que las fases 2, 3, 5 y 6 esten cerradas,
# porque este script las re-ejecuta con filtros (si no, se rehace dos veces).
#
# Reutiliza las funciones/modelos de 07, 08, 10 y 11 sobre subconjuntos.
# El estado de revision NO se usa como eje: los 1.186 eventos son `reviewed`.


# Cargar la base si no esta disponible (ruta rapida de desarrollo).
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# Pasos previstos:
# 7.1 Escenario A (umbral): filtrar mag >= 7.0 (387 eventos) y repetir fases
#     2, 3B, 5.1 y 6.3-6.5. Nota: "Fuerte" desaparece por definicion.
# 7.2 Escenario B (sin residual): excluir "Resto del mundo" (983 eventos, 3 zonas,
#     3 pares post-hoc) y repetir las mismas piezas.
# 7.3 Tablas espejo: efecto principal en base, A y B lado a lado (razones de tasa,
#     epsilon cuadrado, conclusion de Dunn por par, metricas de clasificacion).
#     Criterio: direccion y magnitud de los efectos, no p-valores.
# 7.4 Veredicto de robustez: que conclusiones se mantienen y cuales se debilitan.

message("12_inf_sensibilidad.R: stub pendiente de implementacion (Fase 7 / C8).")

# 1. Preparar los dos escenarios----
source(file.path("Scripts", "00_preparacion_base.R"))

set.seed(2026)

# Escenario A: umbral mas exigente, solo eventos con magnitud 7,0 o superior
sismos_A <- sismos %>%
  dplyr::filter(mag >= 7.0)
nrow(sismos_A)
count(sismos_A, zona, name = "numero_eventos")

# Escenario B: sin la zona residual "Resto del mundo"
sismos_B <- sismos %>%
  dplyr::filter(zona != "Resto del mundo")
nrow(sismos_B)
count(sismos_B, zona, name = "numero_eventos")

table(sismos_A$magnitud_cat)


# 2. Escenario A: frecuencia entre zonas----
conteos_anuales_A <- sismos_A %>%
  count(zona, año, name = "n") %>%                                        # cuenta cuántos eventos hubo en cada combinación zona-año observada. Problema: solo genera filas para combinaciones que existieron; si la Dorsal no tuvo eventos en 2004, esa fila simplemente no aparece.
  tidyr::complete(zona, año = 2000:2025, fill = list(n = 0)) %>%          # repara justo eso, agregando las combinaciones faltantes con n = 0. El "ese año no hubo ninguno" es un dato, no un hueco: sin esta línea, la tasa anual de la Dorsal se calcularía solo sobre sus años activos y saldría inflada.
  dplyr::mutate(zona = relevel(factor(zona), ref = "Cinturon de Fuego"))  # relevel(factor(zona), ref = "Cinturon de Fuego"): fija al Cinturón de Fuego como categoría de referencia. Es lo que hace que cada coeficiente del modelo se lea como "esta zona comparada con el Fuego", el mismo criterio de todo el informe.
# Verificaciones nrow y sum:
nrow(conteos_anuales_A)         # =104: son 4 zonas x 26 años, la grilla completa. Confirma que complete() generó todas las celdas.
sum(conteos_anuales_A$n)        # =387: los ceros se agregaron sin inventar ni perder eventos. La tabla reorganiza los mismos 387; contabilidad cerrada.

modelo_tasa_A <- glm(n ~ zona, family = poisson, data = conteos_anuales_A)

summary(modelo_tasa_A)

dispersion_pearson_A <- sum(residuals(modelo_tasa_A, type = "pearson")^2) /
  modelo_tasa_A$df.residual

dispersion_pearson_A


# 3. Escenario A: binomial negativa y razones de tasa----
modelo_nb_A <- MASS::glm.nb(n ~ zona, data = conteos_anuales_A)

summary(modelo_nb_A)

razones_tasa_A <- exp(cbind(
  razon_tasa = coef(modelo_nb_A),
  confint(modelo_nb_A)
))

round(razones_tasa_A, 4)
