# Checklist de trabajo: Informe Asesoría 2

**Grupo Tetrametric** | Documento de seguimiento interno | Actualizado: 2 de julio de 2026

Este checklist ordena el desarrollo del Informe Asesoría 2 en fases de ejecución con puntos de control (C0 a C9). En cada punto de control se comparten los resultados (salida de consola de R en texto, con los llamados exactos utilizados) para validar el camino antes de avanzar. Las compuertas duras son **C2, C3 y C7**: no se avanza de fase sin cerrarlas.

**Reglas del juego:**

1. Compartir la salida de consola en texto, con los llamados exactos utilizados: así se detectan errores de especificación, no solo de interpretación.
2. No avanzar de fase sin cerrar el checkpoint anterior cuando hay compuerta de decisión (C2, C3 y C7).
3. Si un resultado contradice lo anticipado en "qué se espera", detenerse y revisarlo antes de redactar nada con él.
4. Todo número que aparezca en el informe sale de un script de `Scripts/`, nunca de la consola suelta: si no está en un script, no existe.

---

## Fase 0. Preparación de datos y exposición

- [ ] **0.1** Cargar la base `sismos` del Informe 1 y verificar que reproduce las cifras de control: 1.186 eventos, 892 / 203 / 63 / 28 por zona, categorías `magnitud_cat` y `profundidad_cat` con los cortes documentados. Si algún conteo no calza, detenerse aquí.
- [ ] **0.2** Calcular la superficie de cada polígono de `area_regiones.geojson`. Detalle crítico: el área debe calcularse en una proyección de igual área (por ejemplo EPSG:6933) o con `sf::st_area()` sobre geometría esférica (s2 activado, default de `sf` moderno con CRS 4326). Nunca calcular área en grados. Reportar en km². "Resto del mundo" no tiene polígono: su superficie es la superficie total de referencia menos la suma de las tres zonas (aprox. 510,1 millones de km² como total terrestre; declarar y documentar la definición adoptada).
- [ ] **0.3** Generar la tabla zona-año con `tidyr::complete()`: 26 años x 4 zonas = 104 filas, rellenando con 0 los años sin eventos. La Dorsal tendrá muchos ceros; eso es correcto y esperado, no un error de datos.
- [ ] **0.4** Fijar `set.seed()` global para bootstrap y simulaciones Monte Carlo, y anotarlo (reproducibilidad).
- [ ] **0.5** Crear el script de esta etapa en `Scripts/` siguiendo la convención numerada del proyecto, exportando figuras a `Informes Quarto/Imágenes y Recursos/`.

**Checkpoint C0:** compartir las superficies por zona en km² y la tabla resumen de conteos anuales por zona (media, mínimo, máximo por zona), para validar que el offset tenga sentido antes de modelar.

---

## Fase 1. Comparabilidad del registro (sección 7.1)

- [ ] **1.1** Tabla de contingencia `zona x magType_grupo` y chi-cuadrado. Si hay casillas con esperados < 5 (probable en Dorsal), usar `chisq.test(..., simulate.p.value = TRUE, B = 10000)`.
- [ ] **1.2** Tabla `zona x magSource` (agrupando fuentes minoritarias si fragmenta mucho) y su contraste, mismo criterio.
- [ ] **1.3** Kruskal-Wallis de `rms_imp` entre zonas y entre períodos (2000-2009, 2010-2019, 2020-2025).
- [ ] **1.4** Contraste de `magType_grupo` por período (la transición hacia `mww` ya se conoce del Informe 1; aquí se formaliza).
- [ ] **1.5** Reunir todos los p-valores del bloque y ajustarlos con Benjamini-Hochberg: `p.adjust(p, method = "BH")`. Reportar crudos y ajustados.
- [ ] **1.6** Redactar el veredicto: ¿las comparaciones siguientes están o no condicionadas por la estructura de reporte?

**Qué se espera:** asociación fuerte de `magType`/`magSource` con el período y débil o moderada con la zona. Si `magType_grupo` resultara fuertemente asociado a zona, detenerse: obligaría a agregar el control en los modelos de las fases 5 y 6.

**Checkpoint C1:** tabla con cada contraste, estadístico, p crudo y p ajustado BH.

---

## Fase 2. Frecuencia entre zonas: GLM de conteos (sección 7.2, análisis mínimo 1)

- [ ] **2.1** Ajustar `m_pois <- glm(n ~ zona, family = poisson, offset = log(area_km2), data = tabla_zona_anio)`, con Cinturón de Fuego como referencia.
- [ ] **2.2** Diagnóstico de sobredispersión, tres vías y las tres se reportan:
  - [ ] dispersión de Pearson: `sum(residuals(m_pois, "pearson")^2) / df.residual(m_pois)` (valores cerca de 1 = sin sobredispersión),
  - [ ] `AER::dispersiontest(m_pois)` (unilateral, alfa = 0,05),
  - [ ] razón de verosimilitud contra `MASS::glm.nb()` recordando dividir el p-valor por dos (parámetro en la frontera del espacio paramétrico).
- [ ] **2.3** Compuerta: si hay sobredispersión, el modelo final es binomial negativa; si no, Poisson. Documentar la decisión con los tres diagnósticos.
- [ ] **2.4** Del modelo final: razones de tasa `exp(coef())` con IC 95 % vía `confint()`, para cada zona contra el Cinturón de Fuego.
- [ ] **2.5** Tabla puente con el Informe 1: tasa anual bruta (34,3 / 7,8 / 2,4 / 1,1) junto a la tasa por millón de km² y año, para mostrar cuánto cambia la lectura al normalizar por superficie.

**Qué se espera:** sobredispersión leve o moderada (los conteos anuales globales de grandes sismos suelen ser aproximadamente Poisson); razones de tasa muy grandes y significativas contra la Dorsal. Lo interesante es si el orden de las zonas cambia al normalizar por área.

**Checkpoint C2 (compuerta dura):** los tres diagnósticos de sobredispersión, el modelo elegido y la tabla de razones de tasa con IC. Aquí se decide la frase ejecutiva de la sección.

---

## Fase 3. Magnitud y profundidad: supuestos y ruta no paramétrica (sección 7.3, análisis mínimo 2)

### Bloque A: supuestos (propuesta rescatada del Informe 1, alfa = 0,10 + gráficos)

- [ ] **3.1** Normalidad multivariante de Mardia por zona (no global): `MVN::mvn(datos[, c("mag","depth")], subset = "zona", mvnTest = "mardia")`. Reportar asimetría y curtosis con sus p-valores por zona.
- [ ] **3.2** QQ chi-cuadrado de las distancias de Mahalanobis por zona y QQ univariados de `mag` y `depth`. Guardar las figuras.
- [ ] **3.3** M-Box: `heplots::boxM(cbind(mag, depth) ~ zona, data = sismos)`. Advertencia para el texto: M-Box es hipersensible a la no normalidad, así que su rechazo se interpreta junto al de Mardia, no aislado.
- [ ] **3.4** Esfericidad de Bartlett sobre la matriz de correlaciones: `psych::cortest.bartlett()`.
- [ ] **3.5** Compuerta documentada: con los resultados de 3.1 a 3.4 se declara la ruta paramétrica o no paramétrica.

**Qué se espera:** rechazo claro de normalidad (la profundidad es extremadamente asimétrica: media 89,6 km contra mediana 29,4 km) y por tanto ruta no paramétrica. Si algo NO rechazara, detenerse y revisar antes de seguir.

**Checkpoint C3 (compuerta dura):** resultados de supuestos (3.1 a 3.4) ANTES de correr el bloque B, para validar la decisión de ruta.

### Bloque B: contrastes

- [ ] **3.6** `kruskal.test(mag ~ zona)` y `kruskal.test(depth ~ zona)`. Reportar H, grados de libertad, p, y epsilon cuadrado (`rcompanion::epsilonSquared()` o a mano: (H - k + 1)/(n - k)).
- [ ] **3.7** Post-hoc: `FSA::dunnTest(..., method = "holm")` para las 6 comparaciones por variable. Tabla completa de Z, p crudo y p ajustado.
- [ ] **3.8** Delta de Cliff (`effsize::cliff.delta()`) para los pares protagonistas: Fuego-Dorsal y Fuego-Alpino en ambas variables.
- [ ] **3.9** IC bootstrap (percentil o BCa, R = 10.000) para la mediana de `mag` y `depth` por zona. Con n = 28 en la Dorsal el IC saldrá ancho; eso es el resultado, no un problema.

**Checkpoint C4:** tabla completa del bloque B (KW, Dunn, tamaños de efecto, IC por zona).

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
