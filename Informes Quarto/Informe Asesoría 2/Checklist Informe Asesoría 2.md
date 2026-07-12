# Checklist de trabajo: Informe Asesoría 2

**Grupo Tetrametric** | Documento de seguimiento interno | Actualizado: 12 de julio de 2026

**Avance:** Fases 0, 1, 2, 4, 5 y 6 cerradas (C0, C1, C2, C5, C6, C7); **Fases 5 y 6 auditadas línea a línea:** los 16 bloques del script 10 (10 jul) y los 21 bloques del script 11 (11-12 jul) ejecutados con el usuario en Positron y verificados contra el QMD sin discrepancias. Fase 3: C3 cerrado (ruta no paramétrica), C4 sustancialmente cerrado (falta solo el 3.9, bootstrap de medianas). Redacción del informe: secciones 6.2/7.2 (frecuencia), 6.5/7.5 (extremos) y 6.6/7.6 (clasificación) redactadas en `Informe Asesoría 2 - Actual.qmd` (documento oficial vigente), con una capa de anexos didácticos que incluye cinco anexos propios de la Fase 6 (correspondencia, multinomial, separación y reducción de sesgo, métricas de clasificación, ROC/AUC). Figuras de clasificación reproducibles desde `Scripts/11b_figuras_clasificacion.R` (sin modificar el script 11). Siguiente: cerrar el 3.9, Fase 7 (sensibilidad, script 12) y redacción final (conclusiones, resumen ejecutivo, 7.8, portada).

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

> Numeración alineada con `07_inf_frecuencia.R` y reverificada por ejecución con Rscript (10 jul 2026). El script se amplió respecto a la versión inicial: se agregaron los contrastes globales (2.4) y los seis pares con Holm (2.6), por lo que la numeración corrió (razones de tasa al 2.5, tabla puente al 2.7).

- [x] **2.1** Modelo Poisson de conteos zona-año con Cinturón de Fuego como referencia (`m_tasa`). **Hecho:** tasa anual base de Fuego 34,3 eventos/año; grilla de 104 filas (4 zonas x 26 años), suma 1.186, sin `NA` en área.
- [x] **2.2** Diagnóstico de sobredispersión por tres vías convergentes (alfa = 0,05):
  - [x] dispersión de Pearson: **1,409579** (validada con el quasi-Poisson: 1,409584).
  - [x] Cameron-Trivedi (`AER::dispersiontest`): **z = 2,149; p = 0,0158; dispersión 1,36** (alternativa lineal). Con `trafo = 2` (alternativa cuadrática, la de la binomial negativa): **z = 2,349; p = 0,0094; alfa = 0,022**.
  - [x] razón de verosimilitud Poisson vs `glm.nb` con corrección de frontera (p ÷ 2): **LR = 5,63; p = 0,0088** (el `lrtest` sin corregir daría 0,0177, no se reporta). Tercer índice informal: deviance/gl = 1,57.
- [x] **2.3** Compuerta. **Decisión: binomial negativa** (sobredispersión leve pero consistente en las tres vías). Se ajustan los dos modelos finales: tasa anual (`m_nb`, theta = 42,35) y densidad con `offset(log(area_km2))` (`m_nb_dens`).
- [x] **2.4** Contrastes globales de zona (cada modelo final vs su nulo, razón de verosimilitud con 3 gl; parámetros interiores, sin corrección de frontera). **Resultado:** tasa anual **LR = 220,37** (p = 1,67e-47); densidad **LR = 225,85** (p = 1,09e-48). Las cuatro zonas no comparten una misma tasa ni una misma densidad.
- [x] **2.5** Razones de tasa con IC 95 % de perfil vs Cinturón de Fuego. **Resultado (tasa anual):** Resto 0,228 [0,191; 0,270]; Alpino 0,071 [0,053; 0,092]; Dorsal 0,031 [0,021; 0,045] (los tres excluyen 1). **Densidad:** Resto cae a 0,025 [0,021; 0,030], el menor por km².
- [x] **2.6** Comparaciones por pares (6 parejas, p de Wald ajustados por Holm dentro de cada métrica; validadas con `multcomp::glht`). **Resultado:** las seis son significativas en ambas métricas. En tasa, el p ajustado máximo es 0,00045 (Alpino-Dorsal, el par más apretado: razón 2,25 [1,43; 3,54]). Rankings inferenciales completos: tasa **Fuego > Resto > Alpino > Dorsal**; densidad **Fuego > Alpino > Dorsal > Resto**.
- [x] **2.7** Tabla puente con el Informe 1. **Hallazgo:** tasa anual bruta 34,3 / 7,81 / 2,42 / 1,08 (reproduce el Informe 1); por densidad el orden se reordena a Fuego 0,720 > Alpino 0,167 > Dorsal 0,057 > Resto 0,018; "Resto del mundo" cae al último por su enorme superficie.

**Diagnóstico del modelo final (bloque posterior a la inferencia):** dispersión de Pearson de la binomial negativa 1,14 y deviance/gl 1,29 (variabilidad residual controlada); Ljung-Box sobre los residuos por zona sin autocorrelación tras Holm (p mínimo 0,262, Dorsal).

**Qué se espera:** sobredispersión leve o moderada (los conteos anuales globales de grandes sismos suelen ser aproximadamente Poisson); razones de tasa muy grandes y significativas contra la Dorsal. Lo interesante es si el orden de las zonas cambia al normalizar por área.

**Checkpoint C2 (compuerta dura):** ✅ **Cerrado (3 jul 2026; script ampliado y reverificado por ejecución el 10 jul 2026), script `07_inf_frecuencia.R`.** Modelo binomial negativa elegido; contraste global, razones de tasa y densidad, y seis pares con Holm establecidos. Figura `inf2-frecuencia-tasa-densidad.png` y frase ejecutiva en la sección 7.2 del `.qmd`. *Pendiente de limpieza: el bloque del forest plot (`inf2-frecuencia-forest.png`) quedó huérfano tras retirar esa figura del informe por decisión del grupo; el script aún lo genera.*

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

- [x] **4.1** Serie anual (n = 26) y mensual (n = 312): ADF y KPSS. **Resultado:** mensual estacionaria (ADF p < 0,01, KPSS p > 0,10); anual coherente pero baja potencia.
- [x] **4.2** Ljung-Box anual (lag 5) y mensual (lag 12 y 24). **Resultado:** sin autocorrelación (anual p = 0,58; mensual p = 0,15 / 0,091).
- [x] **4.3** Comparación de tasas entre períodos. **Resultado:** 45,5 / 48,9 / 40,3; corregida la sobredispersión (quasi-Poisson F = 1,92, p = 0,170) no difieren. *Nota: se hizo con conteos anuales totales (`n ~ periodo`), no con el `n ~ zona + periodo` de la Fase 2; equivalente para el efecto período global.*
- [x] **4.4** Estacionalidad mensual (GLM `n ~ factor(mes)`). **Resultado:** Poisson daba p = 0,050 (borde); corregida la sobredispersión (quasi-Poisson F = 1,03, p = 0,416) claramente no significativo. Sin ciclo anual, verificación superada.
- [x] **4.5** Tiempos entre eventos vs exponencial (bootstrap paramétrico), M ≥ 7,0 y por categoría. **Resultado:** Mayor (p = 0,102) y Grande o extremo (p = 0,531) compatibles; Fuerte se aparta (p < 0,001); combinado M ≥ 7,0 rechaza por mezcla de bandas. QQ exponencial exportado.
  - [x] intervalos con `diff()` sobre fechas ordenadas,
  - [x] estadístico KS observado con tasa estimada,
  - [x] bootstrap paramétrico (10.000 simulaciones, semilla fija),
  - [x] QQ exponencial como figura (`inf2-temporal-qq-exponencial.png`).

**Checkpoint C5:** ✅ **Cerrado (3 jul 2026), script `09_inf_temporal.R`.** Serie mensual estacionaria (ADF p < 0,01 y KPSS p > 0,10 concuerdan); anual coherente pero baja potencia. Sin autocorrelación (Ljung-Box anual p = 0,58; mensual p = 0,15). Sin estacionalidad (factor mes p = 0,050). Tasas por período: 45,5 / 48,9 / 40,3; corregida la sobredispersión (quasi-Poisson F = 1,92, p = 0,170) NO difieren (el Poisson daba p = 0,047, artefacto). Tiempos entre eventos: Mayor (p = 0,102) y Grande o extremo (p = 0,531) compatibles con exponencial; Fuerte se aparta (p < 0,001); el combinado M ≥ 7,0 rechaza por mezcla de bandas. Frase ejecutiva y figura `inf2-temporal-qq-exponencial.png` en la sección 7.4 del `.qmd`.

---

## Fase 5. Eventos fuertes y extremos (sección 7.5, análisis mínimo 4)

- [x] **5.1** Tabla `zona x magnitud_cat` + chi-cuadrado Monte Carlo + V de Cramér. **Resultado:** p = 0,307 (no significativo), V = 0,022 (despreciable); 2 casillas con esperados < 5. La categoría de magnitud no difiere por zona.
- [x] **5.2** `evento_mayor = (mag >= 7.0)` + logística `glm(evento_mayor ~ zona + depth)`, LR por variable, OR con IC. **Resultado:** depth OR = 1,0002 (p = 0,577, no predice); zona borderline (p = 0,061), solo la Dorsal difiere (OR 0,25 [0,058; 0,712]).
- [x] **5.3** `depth` continua vs `profundidad_cat` por AIC. **Resultado:** AIC 1500,01 vs 1500,26; se elige la continua (menor y más simple).
- [x] **5.4** M >= 7,8 solo conteos por zona. **Resultado:** Fuego 47, Resto 10, Alpino 2, Dorsal 0.

**Qué se espera:** en la logística, la zona Dorsal con odds ratio bajo (su máximo de magnitud es bajo) pero con IC amplio; el efecto de `depth` es la incógnita interesante y conecta con el comentario del profesor sobre variables que ganan relevancia en modelos múltiples.

**Checkpoint C6:** ✅ **Cerrado (3 jul 2026), script `10_inf_extremos.R` (revisado y verificado en ejecución).** La categoría de magnitud no difiere por zona; la profundidad no predice que un evento sea grande (OR ~ 1, coherente con el Bartlett de la Fase 3); solo la Dorsal tiene menor probabilidad de eventos M ≥ 7,0. Contraste clave para la Fase 6: la profundidad no dice qué tan grande es un evento, pero sí ayudará a decir en qué zona ocurre. Frase ejecutiva en la sección 7.5 del `.qmd`.

**Auditoría completa (10 jul 2026):** los 16 bloques del script 10 se ejecutaron con el usuario en Positron y se verificaron contra el QMD sin discrepancias. Bloques 13-16 confirmados: logística con profundidad categórica (Dorsal β = -1,39065, p = 0,024; profundidad categórica no significativa, LR 2,0625, p = 0,357); comparación AIC continua 1500,012 vs categórica 1500,261 (se mantiene la continua, ΔAIC = 0,249, más simple); M ≥ 7,8 por zona 47 / 10 / 2 / 0. Secciones 6.5 (metodología) y 7.5 (resultados) redactadas en el QMD oficial, con una capa de anexos didácticos (verosimilitud, logística, OR, IC, Wald, AIC, tamaño de efecto) y 7 referencias nuevas verificadas en el `.bib`.

---

## Fase 6. Síntesis: clasificación de zonas (sección 7.6)

- [ ] **6.1** Correlaciones parciales de Spearman entre `mag`, `depth` y `sig`: `ppcor::pcor(..., method = "spearman")`. Lectura protagonista: profundidad con significancia controlando magnitud (porque `sig` deriva de `mag`). **EXCLUIDO (4 jul 2026) por decisión del grupo:** C7 se evalúa sin las parciales.
- [x] **6.2** Análisis de correspondencia simple. **Hecho** con `FactoMineR::CA()` en `11_inf_clasificacion.R`, con frecuencias esperadas y perfiles fila/columna como apoyo (4 celdas con esperados < 5, coherente con la Fase 5). **Resultado:** inercia total 0,0060 en magnitud (dim 1 = 92,9 %) y 0,0321 en profundidad (dim 1 = 81,9 %): la tabla de profundidad tiene 5,3 veces más asociación que explicar. La Dorsal aporta el 95,1 % de la dimensión 1 de magnitud; la categoría "Profundo" aporta el 87,8 % de la dimensión 1 de profundidad. **Biplots exportados** (`inf2-clasificacion-correspondencia.png`) y reproducibles desde `Scripts/11b_figuras_clasificacion.R` (el bloque 9 del script 11 solo dibuja en pantalla).
- [x] **6.3** Multinomial `zona ~ mag + depth` con Cinturón de Fuego como referencia. **Resultado** (`car::Anova`, razón de verosimilitud, sobre el modelo estandarizado; los LR son idénticos en la escala cruda): depth LR = 64,906 (p < 0,001); mag LR = 5,102 (p = 0,1645). Solo la profundidad aporta.
- [x] **6.4** Revisión de separación. **Detectada en la Dorsal** (28 eventos, todos superficiales), visible al estandarizar: depth_z = -27,66 con EE 7,21 (dispara el criterio |coef| > 10; en la escala cruda quedaba camuflada por las unidades) y probabilidades ajustadas numéricamente en 0. **Corregida y declarada con `brglm2::brmultinom` (AS_mean):** depth_z Dorsal -26,19, EE 6,74 (equivale a -0,160 por km); estimaciones finitas y EE utilizables. Toda inferencia de la Dorsal se reporta con esta corrección.
- [x] **6.5** Matriz de confusión (predicho x observado) y métricas, sobre el modelo corregido. **Resultado:** predice Cinturón de Fuego para los 1.186 eventos; exactitud global 0,7521 = base trivial; exactitud balanceada 0,25 = base trivial balanceada; sensibilidad 1 / 0 / 0 / 0.
- [ ] **6.6** Opcional si hay tiempo: validación cruzada de 10 pliegues para las métricas. **Sin hacer;** el ajuste dentro de muestra ya coincide con la base trivial y una corrida previa de referencia dio la CV idéntica (0,7521 / 0,25), por lo que no alteraría la conclusión.
- [x] **6.7** Comparación de modelos anidados (AIC y razón de verosimilitud). **Resultado:** AIC solo mag 1805,663; solo depth 1745,858; conjunto 1746,757 (la profundidad sola es el mejor modelo; ΔAIC del conjunto = 0,899, menor que 2). LR depth dado mag = 64,906 (p < 0,001); LR mag dado depth = 5,102 (p = 0,1645). El aporte conjunto se reduce al aporte de la profundidad.
- [x] **6.8** Curvas ROC y AUC uno contra el resto (ampliación externa del script 11, bloques 20-21, con `pROC`). **Resultado:** AUC Dorsal 0,877 (señal discriminante clara pero clase positiva de solo 28 eventos), Fuego 0,689, Alpino 0,528, Resto 0,470 (bajo 0,5, sin señal útil). Lectura: hay señal en las probabilidades, pero no alcanza para reasignar clases; ROC matiza pero no revierte la matriz de confusión. Figura `inf2-clasificacion-roc.png`, exportada por el propio script 11 y regenerada con leyenda ampliada y decimales con coma desde `11b_figuras_clasificacion.R`.

**Checkpoint C7 (compuerta dura, el más importante):** ✅ **Cerrado (12 jul 2026), script `11_inf_clasificacion.R` (auditado línea a línea: los 21 bloques ejecutados con el usuario en Positron y verificados contra el QMD sin discrepancias).** Veredicto: magnitud y profundidad, incluso en conjunto, NO permiten clasificar la zona sísmica de un evento: el Cinturón de Fuego cubre todo el espacio de clasificación con prior 75,21 % y el modelo no supera la base trivial. La profundidad sí desplaza las probabilidades (LR = 64,9; información distribucional real, con la inferencia de la Dorsal reportada vía Firth), pero no alcanza para reasignar clases. Conclusión ejecutiva (ya redactada en la sección 7.6): el Cinturón de Fuego se distingue por cuánto y dónde ocurre su actividad, no por la magnitud o la profundidad de sus eventos individuales.

**Auditoría y redacción (11-12 jul 2026):** secciones 6.6 (metodología) y 7.6 (resultados) completas en el QMD oficial, con hilo narrativo señalizado (descriptivo → significación → tamaño de efecto → clasificación → comparación de modelos). Mejoras incorporadas durante la auditoría: tabla de composición de profundidad por zona (los ceros de la Dorsal y el Alpino que anticipan la separación), cautela de frecuencias esperadas < 5 en el análisis de correspondencia, tabla de AIC ampliada (ΔAIC, LR, valor p y lectura), y cinco anexos didácticos propios de la fase (correspondencia, multinomial, separación y reducción de sesgo, métricas de clasificación, ROC/AUC) con ejemplos numéricos verificados por ejecución. Referencia nueva verificada en el `.bib`: `robin_2011` (pROC, DOI + CRAN).

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
