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

# Semilla fija para reproducibilidad. Las docimas de mas abajo calculan el p-valor por
# simulacion Monte Carlo (miles de tablas generadas al azar), y ese azar es
# pseudoaleatorio: con la misma semilla R produce siempre la misma secuencia y, por
# tanto, los mismos p-valores. Sin ella cambiarian levemente en cada corrida. El valor
# 2026 es arbitrario; lo relevante es que quede fijo para que el informe se replique.
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
# Hay casillas con esperados < 5 (p.ej. la Dorsal), donde la aproximacion chi-cuadrado
# teorica no es valida. Por eso el p-valor se obtiene por simulacion Monte Carlo
# (simulate.p.value = TRUE): R genera B = 10000 tablas al azar con los mismos totales de
# fila y columna pero sin asociacion, y calcula en que fraccion el estadistico simulado
# iguala o supera al observado. Ese conteo aleatorio es el que fija la semilla de arriba.
tabla_zt <- table(sismos$zona, sismos$magType_grupo)
tabla_zt
# La tabla de esperados confirma la necesidad del Monte Carlo: varias casillas quedan
# bajo 5 (Alpino x otros = 1,75 ; Dorsal x mwb = 2,74 ; Dorsal x otros = 0,78).
suppressWarnings(chisq.test(tabla_zt)$expected)
chi_zt <- chisq.test(tabla_zt, simulate.p.value = TRUE, B = 10000)
v_zt   <- v_cramer(tabla_zt)
# En chi_zt, df = NA es esperado: con Monte Carlo el p-valor no viene de una distribucion
# chi-cuadrado con grados de libertad, sino de las 10000 simulaciones. X-squared es el
# estadistico observado (el mismo que usa v_cramer por dentro).
chi_zt
v_zt
# Resultado: p = 0,67 (no significativo) y V = 0,044 (fuerza despreciable). Aqui p-valor
# y efecto coinciden en "nada": el metodo de magnitud se reparte de forma homogenea entre
# zonas, por lo que no condiciona la comparacion espacial de magnitud (Fase 3). Es el
# primer "check verde" del portero.


#1.2 Asociacion zona x magSource_grupo----
# La fuente institucional de la magnitud se reparte de forma homogenea entre zonas?
# Todas las zonas estan dominadas por "us" (USGS), con gcmt y hrv como secundarias, y de
# nuevo hay casillas chicas (Dorsal x gcmt = 2, dos ceros en "otros") que justifican el
# Monte Carlo.
tabla_zs <- table(sismos$zona, sismos$magSource_grupo)
tabla_zs
chi_zs <- chisq.test(tabla_zs, simulate.p.value = TRUE, B = 10000)
v_zs   <- v_cramer(tabla_zs)
chi_zs
v_zs
# Resultado: p = 0,28 (no significativo) y V = 0,055 (fuerza despreciable). Segundo
# "check verde": la fuente de la magnitud tampoco condiciona la comparacion espacial.


#1.3 Ajuste RMS por zona y por periodo (Kruskal-Wallis)----
# El RMS es asimetrico, por lo que se compara con una docima no parametrica de
# medianas. Interesa si el ajuste de localizacion difiere entre zonas o entre periodos.
# Nota: aqui df SI aparece (df = grupos - 1), porque Kruskal-Wallis usa la chi-cuadrado
# teorica; en los chi-cuadrado de arriba salia df = NA por ser Monte Carlo.
kw_rms_zona    <- kruskal.test(rms_imp ~ factor(zona), data = sismos)
kw_rms_periodo <- kruskal.test(rms_imp ~ factor(periodo), data = sismos)
eps_rms_zona    <- eps_cuadrado(kw_rms_zona, nrow(sismos))
eps_rms_periodo <- eps_cuadrado(kw_rms_periodo, nrow(sismos))
kw_rms_zona
kw_rms_periodo
# Este es el caso donde p-valor y efecto SE SEPARAN, y por eso se calculan ambos:
#   - Por zona   : p = 0,016 (significativo) pero epsilon2 = 0,009 (despreciable). Con
#     n = 1186 la prueba detecta una diferencia real pero minuscula; el efecto avisa que
#     es irrelevante. Tercer "check verde": el RMS no difiere de forma relevante por zona.
#   - Por periodo: p < 0,0001 y epsilon2 = 0,221 (moderado). Aqui ambas coinciden: el RMS
#     si mejora con el tiempo. Confirma la advertencia temporal (condiciones de reporte
#     que cambian a lo largo de los anios, relevante para la Fase 4).


#1.4 Asociacion periodo x magType_grupo----
# Formaliza la transicion metodologica hacia mww ya descrita en el Informe 1. La tabla
# lo muestra por columnas: 2000-2009 dominado por mwc/mwb, 2010-2019 y 2020-2025 por mww.
tabla_tp <- table(sismos$periodo, sismos$magType_grupo)
tabla_tp
chi_tp <- chisq.test(tabla_tp, simulate.p.value = TRUE, B = 10000)
v_tp   <- v_cramer(tabla_tp)
chi_tp
v_tp
# Contracara de los contrastes espaciales: aqui p-valor Y efecto son fuertes.
#   - X-squared = 882 (enorme frente a los ~7-11 anteriores).
#   - p = 0,00009999 es el PISO del Monte Carlo (~1/(10000+1)): ninguna tabla simulada
#     alcanzo un chi-cuadrado tan extremo, o sea la asociacion es mas fuerte de lo que la
#     simulacion puede resolver.
#   - V = 0,610: efecto fuerte, muy lejos de los 0,044/0,055 espaciales.
# Clave que junta el bloque: el metodo cambio mucho EN EL TIEMPO (V = 0,610) pero es
# homogeneo ENTRE ZONAS (1.1, V = 0,044). Por eso la comparacion espacial queda limpia y
# la temporal queda con su advertencia documentada.


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
