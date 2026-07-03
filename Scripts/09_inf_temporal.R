# 09 - Estructura temporal de la ocurrencia (Informe Asesoria 2)----
#
# Fase 4 del checklist | Seccion 7.4 del informe | Checkpoint C5
#
# Formaliza la lectura temporal del Informe 1 (fluctuaciones sin tendencia uniforme).
# El analisis se hace a DOS granularidades:
#   - Anual  : serie de 26 conteos (2000-2025).
#   - Mensual: serie de 312 conteos (2000-01 a 2025-12).
# Enlaza con la advertencia de la Fase 1: el metodo de magnitud cambio en el tiempo, por
# lo que los cambios temporales de composicion deben leerse con esa cautela.
#
# Paquetes: dplyr, tidyr, tseries (adf.test, kpss.test). Box.test y glm son base.


#Paquetes----
library(dplyr)
library(tidyr)
library(tseries)


#Cargar la base si no esta disponible (ruta rapida de desarrollo)----
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# Semilla fija: el ajuste exponencial usa bootstrap parametrico (mas abajo).
set.seed(2026)


#Series de conteo anual y mensual----
# Los meses/anios sin eventos son ceros observados, no faltantes: se rellenan con
# complete(). Se arman como objetos ts para las docimas de series de tiempo.

serie_anual_df <- sismos %>%
  count(año, name = "n") %>%
  complete(año = 2000:2025, fill = list(n = 0)) %>%
  arrange(año)
serie_anual <- ts(serie_anual_df$n, start = 2000, frequency = 1)

serie_mensual_df <- sismos %>%
  count(año, mes, name = "n") %>%
  complete(año = 2000:2025, mes = 1:12, fill = list(n = 0)) %>%
  arrange(año, mes)
serie_mensual <- ts(serie_mensual_df$n, start = c(2000, 1), frequency = 12)

# Verificaciones
length(serie_anual)    # 26
length(serie_mensual)  # 312
sum(serie_anual)       # 1186
sum(serie_mensual)     # 1186


#4.1 Estacionariedad: ADF y KPSS (anual y mensual)----
# Son docimas con hipotesis nulas OPUESTAS, por eso se leen en conjunto:
#   - ADF : H0 = raiz unitaria (no estacionaria). Rechazar (p bajo) apoya estacionariedad.
#   - KPSS: H0 = estacionaria en nivel. NO rechazar (p alto) apoya estacionariedad.
# Se concluye "estacionaria" solo si AMBAS concuerdan. Con 26 puntos anuales la potencia
# es baja y hay que declararlo; la serie mensual (312) es mas informativa.
adf_anual    <- adf.test(serie_anual)
kpss_anual   <- kpss.test(serie_anual, null = "Level")
adf_mensual  <- adf.test(serie_mensual)
kpss_mensual <- kpss.test(serie_mensual, null = "Level")
adf_anual
kpss_anual
adf_mensual
kpss_mensual
# Resultado: anual ADF p = 0,48 (no concluye) y KPSS p > 0,10 (apoya estacionaria):
# ambigua por la baja potencia con 26 puntos. Mensual ADF p < 0,01 y KPSS p > 0,10: AMBAS
# concuerdan -> serie estacionaria, sin tendencia (coherente con el Informe 1). Los avisos
# "p menor/mayor que el impreso" son normales: el p real queda fuera del rango de la tabla.


#4.2 Independencia serial: Ljung-Box (anual y mensual)----
# H0 = no hay autocorrelacion hasta el rezago indicado. Rechazar indica dependencia
# temporal (los conteos de un periodo predicen los del siguiente).
lb_anual     <- Box.test(serie_anual, lag = 5, type = "Ljung-Box")
lb_mensual12 <- Box.test(serie_mensual, lag = 12, type = "Ljung-Box")
lb_mensual24 <- Box.test(serie_mensual, lag = 24, type = "Ljung-Box")
lb_anual
lb_mensual12
lb_mensual24
# Resultado: anual(5) p = 0,58 ; mensual(12) p = 0,15 ; mensual(24) p = 0,091 (roza pero
# no rechaza a 0,05). No hay autocorrelacion relevante: los conteos de un periodo no
# predicen los del siguiente.


#4.3 Comparacion de tasas entre periodos----
# Cada fila es un anio, por lo que glm(n ~ periodo) compara la MEDIA ANUAL de conteos
# entre periodos y no depende de que 2020-2025 tenga menos anios (se promedia por anio).
serie_anual_df <- serie_anual_df %>%
  mutate(periodo = case_when(
    año <= 2009 ~ "2000-2009",
    año <= 2019 ~ "2010-2019",
    TRUE        ~ "2020-2025"
  ))

m_periodo <- glm(n ~ periodo, family = poisson, data = serie_anual_df)
drop1(m_periodo, test = "Chisq")     # razon de verosimilitud del efecto periodo (Poisson)
# Dispersion (coherencia con la Fase 2): >1 indica sobredispersion.
disp_periodo <- sum(residuals(m_periodo, "pearson")^2) / df.residual(m_periodo)
disp_periodo                         # 1,57 -> hay sobredispersion

# Correccion por sobredispersion: la Poisson subestima los errores estandar, por lo que
# su p-valor es anticonservador (demasiado bajo). Se reajusta con quasi-Poisson, que
# escala la varianza, y se docima el efecto periodo con un test F (no LR, porque
# quasi-Poisson no tiene verosimilitud completa).
m_periodo_quasi <- glm(n ~ periodo, family = quasipoisson, data = serie_anual_df)
drop1(m_periodo_quasi, test = "F")

# Tasa media anual por periodo
tasas_periodo <- serie_anual_df %>%
  group_by(periodo) %>%
  summarise(media_anual = mean(n), min = min(n), max = max(n), .groups = "drop")
tasas_periodo
# Resultado: tasas medias 45,5 / 48,9 / 40,3 eventos/anio. La Poisson daba p = 0,047
# (aparentemente significativo), pero corregida la sobredispersion (quasi-Poisson,
# F = 1,92) el efecto periodo NO es significativo (p = 0,170). Coherente con el Informe 1:
# fluctuaciones interanuales sin tendencia ni cambio de tasa robusto entre periodos.


#4.4 Estacionalidad mensual----
# GLM Poisson de los conteos mensuales con el mes como factor. La razon de verosimilitud
# del factor mes docima si algun mes concentra mas eventos. Se ESPERA no significativo:
# los terremotos no tienen ciclo anual, y esa ausencia es un resultado valido, no un fallo.
serie_mensual_df <- serie_mensual_df %>%
  mutate(mes_f = factor(mes))
m_mes <- glm(n ~ mes_f, family = poisson, data = serie_mensual_df)
drop1(m_mes, test = "Chisq")
# Resultado: LR = 19,65 (11 gl), p = 0,0503 -> NO significativo. Sin ciclo anual, que es
# lo esperado (los terremotos no tienen estacion). Verificacion superada, no un fallo.


#4.5 Tiempos entre eventos frente a la exponencial----
# Si la ocurrencia fuese un proceso de Poisson homogeneo, los tiempos entre eventos
# consecutivos seguirian una exponencial. Se contrasta con Kolmogorov-Smirnov, pero como
# la tasa se estima de los mismos datos, el p-valor teorico de KS no es valido (problema
# tipo Lilliefors). Por eso se usa BOOTSTRAP PARAMETRICO: se simulan B muestras
# exponenciales del mismo tamano, se reestima la tasa y se recalcula KS en cada una; el
# p-valor es la fraccion de estadisticos simulados >= al observado.

ks_exp_boot <- function(x, B = 10000) {
  x <- x[is.finite(x) & x > 0]
  n <- length(x)
  tasa  <- 1 / mean(x)
  d_obs <- as.numeric(suppressWarnings(ks.test(x, "pexp", rate = tasa)$statistic))
  d_sim <- replicate(B, {
    xs <- rexp(n, rate = tasa)
    suppressWarnings(ks.test(xs, "pexp", rate = 1 / mean(xs))$statistic)
  })
  data.frame(n = n, tasa_diaria = tasa, mediana_dias = median(x),
             D = d_obs, p_boot = mean(d_sim >= d_obs))
}

# Intervalos en dias entre eventos consecutivos (ordenados por fecha)
gaps_dias <- function(df) {
  as.numeric(diff(sort(df$fecha_hora_utc)), units = "days")
}

# Grupo M >= 7,0 (equivale a "Mayor" + "Grande o extremo")
gaps_m70 <- gaps_dias(dplyr::filter(sismos, mag >= 7.0))
exp_m70  <- ks_exp_boot(gaps_m70)

# Por categoria de magnitud
exp_por_cat <- lapply(levels(sismos$magnitud_cat), function(cat) {
  g <- gaps_dias(dplyr::filter(sismos, magnitud_cat == cat))
  cbind(categoria = cat, ks_exp_boot(g))
})
exp_por_cat <- do.call(rbind, exp_por_cat)

exp_m70
exp_por_cat
# Resultado (medianas 15,6 y 122,8 dias reproducen el Informe 1):
#   - M >= 7,0 (n=386, mediana 15,6): p = 0,0012 -> rechaza exponencial.
#   - Fuerte (mediana 7,3): p = 0,0000 -> rechaza; los eventos menores se agrupan
#     (enjambres, replicas), se apartan de un proceso sin memoria.
#   - Mayor (mediana 19,6): p = 0,102 -> compatible con exponencial.
#   - Grande o extremo (mediana 122,8): p = 0,531 -> compatible con exponencial.
# Lectura: los eventos GRANDES son compatibles con un proceso de Poisson sin memoria; los
# menores se agrupan. El grupo combinado M >= 7,0 rechaza porque MEZCLA dos exponenciales
# de tasas distintas (Mayor 0,035/dia, Grande 0,006/dia), y una mezcla de exponenciales ya
# no es exponencial: es un artefacto de mezcla, no evidencia contra Poisson dentro de cada banda.


#Figura: QQ exponencial de los tiempos entre eventos (M >= 7,0)----
# Se guarda a PNG para el .qmd. Puntos sobre la recta = compatible con exponencial.
ruta_qq <- file.path("Informes Quarto", "Imágenes y Recursos",
                     "inf2-temporal-qq-exponencial.png")
png(ruta_qq, width = 1400, height = 1200, res = 200)
q_teoricos <- qexp(ppoints(length(gaps_m70)), rate = 1 / mean(gaps_m70))
plot(sort(q_teoricos), sort(gaps_m70),
     main = "QQ exponencial: tiempos entre eventos (M >= 7,0)",
     xlab = "Cuantiles teoricos (exponencial)", ylab = "Cuantiles observados (dias)",
     pch = 19, col = "#00A499")
abline(0, 1, lty = 2, lwd = 1.5)
box()
dev.off()
