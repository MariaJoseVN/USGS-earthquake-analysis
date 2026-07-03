# Checklist de trabajo: Informe Asesoría 2

**Grupo Tetrametric** | Documento de seguimiento interno | Actualizado: 3 de julio de 2026

**Avance:** Fases 0, 1 y 2 cerradas (C0, C1, C2). Fase 3 revisada y verificada: C3 cerrado (ruta no paramétrica confirmada), C4 sustancialmente cerrado (falta solo el 3.9, bootstrap de medianas). Siguiente: Fase 4 (temporal, script 09).

Este checklist ordena el desarrollo del Informe Asesoría 2 en fases de ejecución con puntos de control (C0 a C9). En cada punto de control se comparten los resultados (salida de consola de R en texto, con los llamados exactos utilizados) para validar el camino antes de avanzar. Las compuertas duras son **C2, C3 y C7**: no se avanza de fase sin cerrarlas.

**Reglas del juego:**

1. Compartir la salida de consola en texto, con los llamados exactos utilizados: así se detectan errores de especificación, no solo de interpretación.
2. No avanzar de fase sin cerrar el checkpoint anterior cuando hay compuerta de decisión (C2, C3 y C7).
3. Si un resultado contradice lo anticipado en "qué se espera", detenerse y revisarlo antes de redactar nada con él.
4. Todo número que aparezca en el informe sale de un script de `Scripts/`, nunca de la consola suelta: si no está en un script, no existe.

---

## Fase 0. Preparación de datos y exposición

- [x] **0.1** Cargar la base `sismos` del Informe 1 y verificar que reproduce las cifras de control. **Verificado:** 1.186 eventos y 892 / 203 / 63 / 28 por zona, vía `Scripts/00_preparacion_base.R`.
- [x] **0.2** Calcular la superficie de cada polígono. **Hecho** en `MAPA_HTML/zonas_inf2.geojson` (campo `Area` ya en km²): 47,64 / 14,48 / 18,90 / 429,05 millones de km². "Resto del mundo" quedó como complemento real de los tres cinturones (suma total ≈ 510,1 M km² = superficie terrestre), por lo que su área sí corresponde a sus eventos.
- [x] **0.3** Generar la tabla zona-año con `tidyr::complete()`. **Verificado:** 104 filas, suma 1.186, sin `NA` en área (en `07_inf_frecuencia.R`).
- [x] **0.4** Fijar `set.seed()` para simulaciones Monte Carlo. **Hecho:** `set.seed(2026)` en `06_inf_comparabilidad.R`. Pendiente replicarlo en 08/09 cuando usen bootstrap.
- [x] **0.5** Crear los scripts en `Scripts/`. **Hecho:** `00_preparacion_base.R` (ruta rápida de base), `06` y `07`; figura exportada a `Imágenes y Recursos/`.

**Checkpoint C0:** ✅ **Cerrado (3 jul 2026).** Superficies por zona confirmadas y tabla zona-año validada (104 filas, 1.186 eventos).

---

## Fase 1. Comparabilidad del registro (sección 7.1)

- [x] **1.1** Tabla `zona x magType_grupo` y chi-cuadrado Monte Carlo. **Resultado:** p = 0,671; V = 0,044 (sin asociación).
- [x] **1.2** Tabla `zona x magSource` y su contraste. **Resultado:** p = 0,351; V = 0,055 (sin asociación).
- [x] **1.3** Kruskal-Wallis de `rms_imp` por zona y por período. **Resultado:** por zona p = 0,026 pero ε² = 0,009 (significativo pero trivial); por período p < 0,0001, ε² = 0,221.
- [x] **1.4** Contraste `magType_grupo` por período. **Resultado:** V = 0,610 (transición fuerte hacia `mww`).
- [x] **1.5** Ajuste Benjamini-Hochberg de los cinco p-valores. **Hecho:** ninguna conclusión cambió tras el ajuste (robustas).
- [x] **1.6** Veredicto redactado (en el script y en la sección 7.1 del `.qmd`).

**Qué se espera:** asociación fuerte de `magType`/`magSource` con el período y débil o moderada con la zona. Si `magType_grupo` resultara fuertemente asociado a zona, detenerse: obligaría a agregar el control en los modelos de las fases 5 y 6.

**Checkpoint C1:** ✅ **Cerrado (3 jul 2026), script `06_inf_comparabilidad.R`.** Separación nítida: contrastes espaciales limpios (zona no condiciona el reporte); contrastes temporales fuertes (cambio de método y mejora del RMS en el tiempo). Veredicto: comparaciones espaciales válidas; comparaciones temporales de magnitud con advertencia para la Fase 4. Frase ejecutiva en la sección 7.1 del `.qmd`.

---

## Fase 2. Frecuencia entre zonas: GLM de conteos (sección 7.2, análisis mínimo 1)

- [x] **2.1** Modelo de conteos con Cinturón de Fuego como referencia. **Hecho:** Poisson de tasa anual (`m_tasa`) como principal, más versión con `offset = log(area_km2)` para densidad.
- [x] **2.2** Diagnóstico de sobredispersión por las tres vías:
  - [x] dispersión de Pearson: **1,41**.
  - [x] `AER::dispersiontest`: **z = 2,149; p = 0,016; dispersión 1,36**.
  - [x] razón de verosimilitud vs `glm.nb` (p ÷ 2): **LR = 5,63; p = 0,009**.
- [x] **2.3** Compuerta. **Decisión: binomial negativa** (sobredispersión leve pero consistente en las tres vías).
- [x] **2.4** Razones de tasa con IC 95 % vs Cinturón de Fuego. **Resultado:** Resto 0,228 [0,191; 0,270]; Alpino 0,071 [0,053; 0,092]; Dorsal 0,031 [0,021; 0,045] (los tres excluyen 1).
- [x] **2.5** Tabla puente. **Hallazgo:** por densidad el orden se reordena a Fuego 0,720 > Alpino 0,167 > Dorsal 0,057 > Resto 0,018; "Resto del mundo" cae al último por su enorme superficie.

**Qué se espera:** sobredispersión leve o moderada (los conteos anuales globales de grandes sismos suelen ser aproximadamente Poisson); razones de tasa muy grandes y significativas contra la Dorsal. Lo interesante es si el orden de las zonas cambia al normalizar por área.

**Checkpoint C2 (compuerta dura):** ✅ **Cerrado (3 jul 2026), script `07_inf_frecuencia.R`.** Modelo binomial negativa elegido. Figura `inf2-frecuencia-tasa-densidad.png` y frase ejecutiva en la sección 7.2 del `.qmd`.

---

## Fase 3. Magnitud y profundidad: supuestos y ruta no paramétrica (sección 7.3, análisis mínimo 2)

### Bloque A: supuestos (propuesta rescatada del Informe 1, alfa = 0,10 + gráficos)

- [x] **3.1** Normalidad multivariante de Mardia por zona (no global): `MVN::mvn(datos[, c("mag","depth")], subset = "zona", mvnTest = "mardia")`. Reportar asimetría y curtosis con sus p-valores por zona.
- [x] **3.2** QQ chi-cuadrado de las distancias de Mahalanobis por zona y QQ univariados de `mag` y `depth`. Guardar las figuras.
- [x] **3.3** M-Box: `heplots::boxM(cbind(mag, depth) ~ zona, data = sismos)`. Advertencia para el texto: M-Box es hipersensible a la no normalidad, así que su rechazo se interpreta junto al de Mardia, no aislado.
- [x] **3.4** Esfericidad de Bartlett sobre la matriz de correlaciones: `psych::cortest.bartlett()`.
- [x] **3.5** Compuerta documentada: con los resultados de 3.1 a 3.4 se declara la ruta paramétrica o no paramétrica.

**Qué se espera:** rechazo claro de normalidad (la profundidad es extremadamente asimétrica: media 89,6 km contra mediana 29,4 km) y por tanto ruta no paramétrica. Si algo NO rechazara, detenerse y revisar antes de seguir.

**Checkpoint C3 (compuerta dura):** ✅ **Cerrado (3 jul 2026), script `08_inf_magnitud_profundidad.R` (revisado y verificado en ejecución con MVN 6.3).** Mardia y Shapiro-Wilk rechazan normalidad en las 4 zonas (p < 0,001); Box-M χ² = 286,5, p < 2,2e-16 (covarianzas heterogéneas); Bartlett χ² = 0,26, p = 0,607 (mag y depth casi no correlacionan). **Decisión: ruta no paramétrica** (MANOVA no se justifica). Decisión documentada en el script. Nota: requiere MVN ≥ 6 en todas las máquinas.

### Bloque B: contrastes

- [x] **3.6** `kruskal.test(mag ~ zona)` y `kruskal.test(depth ~ zona)`. Reportar H, grados de libertad, p, y epsilon cuadrado (`rcompanion::epsilonSquared()` o a mano: (H - k + 1)/(n - k)).
- [x] **3.7** Post-hoc: `FSA::dunnTest(..., method = "holm")` para las 6 comparaciones por variable. Tabla completa de Z, p crudo y p ajustado.
- [x] **3.8** Delta de Cliff (`effsize::cliff.delta()`) para los pares protagonistas: Fuego-Dorsal y Fuego-Alpino en ambas variables.
- [ ] **3.9** IC bootstrap (percentil o BCa, R = 10.000) para la mediana de `mag` y `depth` por zona. Con n = 28 en la Dorsal el IC saldrá ancho; eso es el resultado, no un problema.

**Checkpoint C4:** 🟡 **Sustancialmente cerrado (3 jul 2026); falta el 3.9 (bootstrap).** Magnitud: KW H = 8,32, p = 0,040, pero ε² = 0,007 (significativo pero **despreciable**; solo la Dorsal se separa). Profundidad: KW H = 69,50, p ≈ 0, ε² = 0,059; Cliff Fuego-Dorsal = 0,783 (grande). Lectura: la magnitud casi no separa zonas, la profundidad sí. Ninguna variable sola discrimina bien todas las zonas, lo que arma el terreno para la clasificación de la Fase 6.

---

## Fase 4. Estructura temporal (sección 7.4, análisis mínimo 3)

- [ ] **4.1** Serie anual de conteos (n = 26): `tseries::adf.test()` (unilateral, H0 raíz unitaria) y `tseries::kpss.test(..., null = "Level")` (H0 estacionaria). Se concluye solo si concuerdan; si se contradicen, se reporta la ambigüedad con la advertencia de baja potencia (26 puntos).
- [ ] **4.2** `Box.test(serie_anual, lag = 5, type = "Ljung-Box")` para independencia serial. Para la serie mensual (n = 312), repetir con lag = 12 y 24.
- [ ] **4.3** Comparación de tasas entre períodos: agregar `periodo` al GLM de la fase 2 (`n ~ zona + periodo` con el mismo offset) y contrastar el efecto período por razón de verosimilitud (`drop1(..., test = "Chisq")` o `anova`).
- [ ] **4.4** Estacionalidad mensual: GLM Poisson de conteos mensuales con el mes como factor (offset por días del mes si se quiere finura) y contraste LR global del factor mes. Se espera no significativo; la ausencia de estacionalidad se redacta como verificación superada, no como fracaso.
- [ ] **4.5** Tiempos entre eventos frente a la exponencial, para el grupo M >= 7,0 y por categoría:
  - [ ] calcular intervalos en días con `diff()` sobre fechas ordenadas,
  - [ ] estimar la tasa (1/media) y calcular el estadístico KS observado,
  - [ ] bootstrap paramétrico (tipo Lilliefors): simular 10.000 muestras exponenciales del mismo n con la tasa estimada, reestimar y recalcular KS en cada una; el p-valor es la proporción de estadísticos simulados mayores o iguales al observado,
  - [ ] QQ exponencial como figura.
  Reportar el p sin dicotomizar, según la política declarada en el informe.

**Checkpoint C5:** ADF + KPSS + Ljung-Box, el efecto período del GLM, el contraste de estacionalidad y el resultado del bootstrap exponencial.

---

## Fase 5. Eventos fuertes y extremos (sección 7.5, análisis mínimo 4)

- [ ] **5.1** Tabla `zona x magnitud_cat` con frecuencias observadas y esperadas (verificar cuáles quedan bajo 5). Chi-cuadrado con `simulate.p.value = TRUE, B = 10000`. V de Cramér con corrección de sesgo (`rcompanion::cramerV(..., bias.correct = TRUE)`).
- [ ] **5.2** Variable indicadora `evento_mayor = (mag >= 7.0)` y regresión logística: `glm(evento_mayor ~ zona + depth, family = binomial)`. Significación por razón de verosimilitud por variable (`drop1(..., test = "Chisq")`), odds ratios con IC 95 % (`exp(confint())`).
- [ ] **5.3** Revisar si conviene `depth` continua o `profundidad_cat` en el modelo (probar ambas, comparar por AIC, quedarse con una y justificar).
- [ ] **5.4** Para M >= 7,8: solo conteos por zona y tasa anual, sin modelo. Verificar cuántos hay por zona (se espera casi todos en el Cinturón de Fuego y cero o casi cero en la Dorsal).

**Qué se espera:** en la logística, la zona Dorsal con odds ratio bajo (su máximo de magnitud es bajo) pero con IC amplio; el efecto de `depth` es la incógnita interesante y conecta con el comentario del profesor sobre variables que ganan relevancia en modelos múltiples.

**Checkpoint C6:** tabla de contingencia con esperados, p Monte Carlo, V de Cramér, y la salida completa de la logística (coeficientes, OR, IC, LR por variable, AIC de las dos versiones de profundidad).

---

## Fase 6. Síntesis: clasificación de zonas (sección 7.6)

- [ ] **6.1** Correlaciones parciales de Spearman entre `mag`, `depth` y `sig`: `ppcor::pcor(..., method = "spearman")`. Lectura protagonista: profundidad con significancia controlando magnitud (porque `sig` deriva de `mag`).
- [ ] **6.2** Análisis de correspondencia simple: `FactoMineR::CA()` o `ca::ca()` sobre `zona x magnitud_cat` y `zona x profundidad_cat`. Reportar inercia total, porcentaje por dimensión y el biplot como figura.
- [ ] **6.3** Multinomial: `nnet::multinom(zona ~ mag + depth, data = sismos)`, Cinturón de Fuego como referencia. Significación por variable con `car::Anova()` (razón de verosimilitud, no Wald).
- [ ] **6.4** Revisión de separación: si algún coeficiente o error estándar sale desproporcionado (por ejemplo |coef| > 10 o EE gigantes), hay separación cuasi perfecta; reajustar con `brglm2::brmultinom()` (corrección tipo Firth) y declararlo. Se espera que esto pase con la Dorsal; si pasa, es un hallazgo para redactar, no un fracaso.
- [ ] **6.5** Matriz de confusión (predicho x observado), y calcular: exactitud global, exactitud balanceada (promedio de las sensibilidades por clase) y sensibilidad de cada zona. Comparar SIEMPRE contra la base trivial del 75,21 %.
- [ ] **6.6** Opcional si hay tiempo: validación cruzada de 10 pliegues para las métricas; el ajuste dentro de muestra es aceptable para el alcance, pero la CV blinda la conclusión.
- [ ] **6.7** Probar `zona ~ mag + depth` contra `zona ~ mag` y `zona ~ depth` (AIC y razón de verosimilitud): cuantifica el argumento del profesor sobre el aporte conjunto de las variables.

**Checkpoint C7 (compuerta dura, el más importante):** compartir parciales, inercia de correspondencia, coeficientes multinomiales con EE, resultado de `Anova`, matriz de confusión con métricas por clase, y la comparación 6.7. Con esto se define la conclusión central del informe.

---

## Fase 7. Sensibilidad (sección 7.7, análisis mínimo 5)

- [ ] **7.1** Escenario A: repetir fases 2, 3B, 5.1 y 6.3-6.5 con el filtro `mag >= 7.0` (quedan 387 eventos). Ojo: aquí "Fuerte" desaparece por definición; documentarlo.
- [ ] **7.2** Escenario B: repetir las mismas piezas excluyendo "Resto del mundo" (quedan 983 eventos, 3 zonas, 3 pares post-hoc en vez de 6).
- [ ] **7.3** Armar las tablas espejo: efecto principal en escenario base, A y B, lado a lado (razones de tasa, epsilon cuadrado, conclusión de Dunn por par, métricas de clasificación). Sin p-valores como criterio: dirección y magnitud de los efectos.
- [ ] **7.4** Redactar el veredicto de robustez: qué conclusiones se mantienen y cuáles se debilitan.

**Checkpoint C8:** las tablas espejo, para redactar el veredicto en conjunto.

---

## Fase 8. Redacción y cierre del informe

- [ ] **8.1** Completar las secciones de resultados 7.1 a 7.7 en el `.qmd` siguiendo el patrón acordado: hallazgo del Informe 1, hipótesis, resultado, frase ejecutiva. Las salidas completas van al anexo de especificación.
- [ ] **8.2** Actualizar "Supuestos, limitaciones y alcance" (7.8) con lo que realmente pasó (separación, ancho de IC de la Dorsal, decisiones tomadas en las compuertas).
- [ ] **8.3** Redactar conclusiones y recomendaciones con cifras exactas e intervalos.
- [ ] **8.4** Redactar el resumen ejecutivo al final de todo (estructura ya comentada dentro del `.qmd`).
- [ ] **8.5** Completar los anexos: áreas y offset, especificaciones, diagnósticos, tablas de sensibilidad, declaración de IA.
- [ ] **8.6** Diseñar la portada versión II (el PNG actual dice "Informe Asesoría I" y fecha 30 de junio de 2026), guardarla en `Imágenes y Recursos` y actualizar la ruta en el bloque de portada del `.qmd` (está comentado dónde).
- [ ] **8.7** Revisión de estilo: sin "construir", sin guiones largos, sin "intensidad" para asociación estadística, cifras sin redondear, rangos con guion simple.
- [ ] **8.8** Render final del PDF, revisión del índice, referencias cruzadas y captions, y verificación de que ningún marcador *Pendiente* quedó vivo.

**Checkpoint C9:** revisión de borradores de sección: consistencia narrativa, estilo y que ninguna conclusión exceda lo que el análisis respalda.

---

## Orden de ataque sugerido

1. **C0 y C2 primero:** el cálculo de áreas es el único paso con riesgo técnico nuevo y el GLM es la sección más autocontenida.
2. **C3 en paralelo con C1.**
3. Luego el resto en orden de fases.
