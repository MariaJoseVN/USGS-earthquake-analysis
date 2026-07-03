# 06 - Comparabilidad del registro (Informe Asesoria 2)----
#
# Fase 1 del checklist | Seccion 7.1 del informe | Checkpoint C1
#
# Rol de "portero": antes de interpretar las comparaciones entre zonas se verifica si
# estas podrian estar condicionadas por la estructura de reporte (con que metodo y
# fuente se estimo la magnitud, y el ajuste de localizacion RMS). No busca explicar la
# sismicidad, sino declarar si las comparaciones principales son limpias.
#
# Bloque exploratorio: se reunen todos los p-valores y se ajustan por Benjamini-Hochberg
# (FDR), que controla la tasa de falsos descubrimientos, apropiado para un cribado de
# varias docimas sin hipotesis sustantiva individual.
#
# Sin dependencias externas: V de Cramer manual (como en 04_analisis_espacial.R) y
# epsilon cuadrado por su formula directa.


#Paquetes----
library(dplyr)


#Cargar la base si no esta disponible (ruta rapida de desarrollo)----
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# Semilla fija: los p-valores por simulacion Monte Carlo deben ser reproducibles.
set.seed(2026)


#Funciones de tamanio de efecto----
# V de Cramer con el estadistico chi-cuadrado de Pearson (mismo criterio que el
# Informe 1). Mide la fuerza de asociacion entre dos categoricas, entre 0 y 1.
v_cramer <- function(tab) {
  chi <- suppressWarnings(chisq.test(tab)$statistic)
  as.numeric(sqrt(chi / (sum(tab) * (min(dim(tab)) - 1))))
}
# Epsilon cuadrado para Kruskal-Wallis: E2 = H / (n - 1). Fraccion de variabilidad de
# rangos explicada por el grupo; 0 = sin efecto.
eps_cuadrado <- function(kw, n) as.numeric(kw$statistic) / (n - 1)


#Variables auxiliares----
# periodo: mismos tramos del Informe 1 (2020-2025 es incompleto).
# magSource_grupo: se agrupan las fuentes menos frecuentes (< 20 eventos) en "otros"
# para evitar una tabla excesivamente dispersa.
frec_src <- table(sismos$magSource)
src_frecuentes <- names(frec_src[frec_src >= 20])

sismos <- sismos %>%
  mutate(
    periodo = case_when(
      año <= 2009 ~ "2000-2009",
      año <= 2019 ~ "2010-2019",
      TRUE        ~ "2020-2025"
    ),
    magSource_grupo = if_else(magSource %in% src_frecuentes, magSource, "otros")
  )


#1.1 Asociacion zona x magType_grupo----
# Con que metodo se estimo la magnitud se reparte de forma homogenea entre zonas?
# Se usa p-valor por simulacion Monte Carlo porque hay casillas con esperados < 5
# (la aproximacion chi-cuadrado no seria valida con esas frecuencias).
tabla_zt <- table(sismos$zona, sismos$magType_grupo)
tabla_zt
suppressWarnings(chisq.test(tabla_zt)$expected)      # revisar celdas esperadas < 5
chi_zt <- chisq.test(tabla_zt, simulate.p.value = TRUE, B = 10000)
v_zt   <- v_cramer(tabla_zt)
chi_zt
v_zt


#1.2 Asociacion zona x magSource_grupo----
# La fuente institucional de la magnitud se reparte de forma homogenea entre zonas?
tabla_zs <- table(sismos$zona, sismos$magSource_grupo)
tabla_zs
chi_zs <- chisq.test(tabla_zs, simulate.p.value = TRUE, B = 10000)
v_zs   <- v_cramer(tabla_zs)
chi_zs
v_zs


#1.3 Ajuste RMS por zona y por periodo (Kruskal-Wallis)----
# El RMS es asimetrico, por lo que se compara con una docima no parametrica de
# medianas. Interesa si el ajuste de localizacion difiere entre zonas o entre periodos.
kw_rms_zona    <- kruskal.test(rms_imp ~ factor(zona), data = sismos)
kw_rms_periodo <- kruskal.test(rms_imp ~ factor(periodo), data = sismos)
eps_rms_zona    <- eps_cuadrado(kw_rms_zona, nrow(sismos))
eps_rms_periodo <- eps_cuadrado(kw_rms_periodo, nrow(sismos))
kw_rms_zona
kw_rms_periodo


#1.4 Asociacion periodo x magType_grupo----
# Formaliza la transicion metodologica hacia mww ya descrita en el Informe 1.
tabla_tp <- table(sismos$periodo, sismos$magType_grupo)
tabla_tp
chi_tp <- chisq.test(tabla_tp, simulate.p.value = TRUE, B = 10000)
v_tp   <- v_cramer(tabla_tp)
chi_tp
v_tp


#1.5 Ajuste por multiplicidad (FDR de Benjamini-Hochberg)----
# Se reunen los cinco contrastes con su p-valor y su tamanio de efecto, y se ajustan
# los p-valores en conjunto. El efecto (V de Cramer o epsilon cuadrado) es tan
# importante como el p-valor: con n = 1186 casi todo resulta significativo, por lo que
# la fuerza de asociacion decide si el reporte condiciona o no las comparaciones.
comparabilidad <- data.frame(
  contraste = c("zona x magType", "zona x magSource",
                "rms por zona", "rms por periodo", "periodo x magType"),
  p_valor   = c(chi_zt$p.value, chi_zs$p.value,
                kw_rms_zona$p.value, kw_rms_periodo$p.value, chi_tp$p.value),
  efecto    = c(v_zt, v_zs, eps_rms_zona, eps_rms_periodo, v_tp),
  tipo_efecto = c("V Cramer", "V Cramer", "epsilon2", "epsilon2", "V Cramer")
)
comparabilidad$p_ajustado_BH <- p.adjust(comparabilidad$p_valor, method = "BH")

# Impresion legible (los valores exactos quedan en el objeto `comparabilidad`).
comparabilidad_print <- transform(
  comparabilidad,
  p_valor       = format.pval(p_valor, digits = 2, eps = 1e-4),
  efecto        = round(efecto, 3),
  p_ajustado_BH = format.pval(p_ajustado_BH, digits = 2, eps = 1e-4)
)
comparabilidad_print


#1.6 Veredicto de comparabilidad----
# Resultado (C1): separacion nitida entre asociaciones espaciales y temporales.
#
# ESPACIALES (no condicionan la comparacion entre zonas):
#   - zona x magType : p_BH = 0,66 ; V = 0,044 -> sin asociacion.
#   - zona x magSource: p_BH = 0,35 ; V = 0,055 -> sin asociacion.
#   - rms por zona   : p_BH = 0,026 (significativo) pero epsilon2 = 0,009, efecto
#     despreciable. Con n = 1186 la significancia no implica relevancia: manda el efecto.
#
# TEMPORALES (condicionan solo las comparaciones entre periodos, Fase 4):
#   - periodo x magType: V = 0,610 -> transicion metodologica hacia mww (fuerte).
#   - rms por periodo  : epsilon2 = 0,221 -> mejora del ajuste con el tiempo.
#
# Veredicto: las comparaciones ESPACIALES entre zonas (Fases 2, 3 y 6) no estan
# condicionadas por la estructura de reporte y son validas. Las comparaciones
# TEMPORALES de magnitud (Fase 4) deben interpretarse con cautela, porque parte de
# cualquier cambio en el tiempo puede reflejar el cambio de metodo y no sismicidad.
