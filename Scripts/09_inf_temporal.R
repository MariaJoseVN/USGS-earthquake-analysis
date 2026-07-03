# 09 - Estructura temporal de la ocurrencia (Informe Asesoria 2)----
#
# Fase 4 del checklist | Seccion 7.4 del informe | Checkpoint C5
# Objetivo: formalizar la lectura temporal del Informe 1 (fluctuaciones sin
# tendencia uniforme) mediante estacionariedad, independencia, comparacion de
# tasas por periodo y ajuste de los tiempos entre eventos.
#
# Paquetes: tseries (adf.test, kpss.test), Box.test (base), dplyr.
# Reutiliza las series construidas en 03_analisis_temporal.R del Informe 1.


# Cargar la base si no esta disponible (ruta rapida de desarrollo).
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# library(tseries)
# library(dplyr)

# Pasos previstos:
# 4.1 Serie anual (n = 26): tseries::adf.test (unilateral, H0 raiz unitaria) y
#     tseries::kpss.test(null = "Level"). Concluir solo si concuerdan; declarar
#     la baja potencia con 26 puntos.
# 4.2 Box.test(serie, type = "Ljung-Box"): anual lag = 5; mensual (n = 312) lag = 12 y 24.
# 4.3 Comparacion de tasas por periodo: agregar `periodo` al GLM de conteos
#     (n ~ zona + periodo con offset) y contrastar por razon de verosimilitud.
# 4.4 Estacionalidad mensual: GLM Poisson con el mes como factor + LR global.
#     Se espera no significativo (verificacion superada, no fracaso).
# 4.5 Tiempos entre eventos vs exponencial (M >= 7,0 y por categoria):
#     intervalos con diff() sobre fechas ordenadas, KS observado, bootstrap
#     parametrico tipo Lilliefors (10.000 sim), p sin dicotomizar + QQ exponencial.

message("09_inf_temporal.R: stub pendiente de implementacion (Fase 4 / C5).")
