# Ayuda memoria: Fase 2, frecuencia de eventos entre zonas

**Script:** `Scripts/07_inf_frecuencia.R` | **Sección del informe:** 7.2 | **Checkpoint:** C2 (compuerta dura, cerrada)
**Última revisión:** 5 de julio de 2026 (recorrido completo del script, bloque a bloque, con validaciones por librería).

## Propósito del documento

Registro del razonamiento completo de la Fase 2: por qué existe cada bloque del script 07, cómo se leen sus salidas, qué supuestos hay detrás de cada método, qué validaciones se hicieron y con qué bibliografía se respalda cada decisión. No es redacción final del informe; es la memoria para no perder el hilo al redactar la metodología y los resultados de la sección 7.2.

## 1. Para qué se hizo la fase

El Informe 1 describió tasas anuales de 34,3 / 7,8 / 2,4 / 1,1 eventos por año según zona, pero una descripción no dice si esas diferencias son sistemáticas o fluctuación. La Fase 2 toma el primer componente de la pregunta estadística (¿difieren las zonas en la tasa de ocurrencia?) y lo formaliza con un modelo, intervalos y tamaños de efecto.

Claves de diseño:

- La frecuencia es un conteo (eventos por zona y año), así que el modelo natural es un GLM de conteos (Poisson y su extensión binomial negativa), no una comparación de medias: los conteos no pueden ser negativos y su variabilidad crece con su nivel.
- Se estiman dos miradas complementarias: **tasa anual** (comparable con el Informe 1) y **densidad por superficie** (offset de área), que responde la objeción del desbalance de tamaños de zona (429 contra 14,5 millones de km²) señalada en la revisión docente.
- El hallazgo central vive en el contraste entre ambas: Fuego lidera en las dos; Resto del mundo es segundo por conteo bruto pero último por km².

## 2. Preparación de los datos (pasos 0.2 y 0.3)

- Superficies desde `MAPA_HTML/zonas_inf2.geojson` (campo `Area` en km²). Las 4 zonas cubren ~510,1 millones de km²; Resto del mundo (429,05 M) es el complemento de los tres cinturones.
- Tabla zona-año: 104 filas (4 zonas × 26 años), suma 1.186 eventos, sin NA de área. `complete()` rellena con 0 los años sin eventos: **un año sin sismos es un cero observado, no un dato faltante**; omitirlos inflaría la tasa de las zonas tranquilas (Dorsal).

### Por qué el Cinturón de Fuego es la referencia y no tiene indicadora

- Regla matemática: con 4 categorías solo caben 4 parámetros (1 base + 3 diferencias). Darle indicadora a las 4 más intercepto crearía infinitas soluciones equivalentes (el modelo no queda identificado). Una categoría se funde con el intercepto: la referencia.
- Decisión nuestra (`relevel`): Fuego, por tres razones: es la comparación que la pregunta pide (todo se lee "contra Fuego"), es la base mejor estimada (892 de 1.186 eventos), y da continuidad con el Informe 1. Sin `relevel`, R usaría orden alfabético (Alpino).
- La elección de referencia no cambia ajuste, predicciones ni conclusiones; solo cambia qué comparaciones aparecen impresas. Cualquier razón entre dos zonas se recupera dividiendo.

## 3. Modelo Poisson inicial (paso 2.1)

`m_tasa <- glm(n ~ zona, family = poisson)`. Enlace logarítmico: garantiza predicciones positivas, vuelve los efectos multiplicativos, y hace que exp(coeficiente) sea directamente una razón de tasas. Con un solo factor, el modelo reproduce exactamente las tasas observadas (exp(3,53537) = 34,31 = 892/26); lo que agrega es la maquinaria inferencial.

**Este modelo no se interpreta**: es el punto de partida y el paciente del diagnóstico. Sus errores estándar solo valen si varianza = media, que es lo que se examina a continuación.

### Lectura del summary Poisson (registro)

- Estimates: 3,53537 / -2,65033 / -3,46126 / -1,48026 (escala log; exp() → 34,31 / 0,071 / 0,031 / 0,228).
- SE refleja el desbalance: Dorsal 0,192 (28 eventos) contra intercepto 0,033 (Fuego, 892).
- "Dispersion parameter taken to be 1": ASUMIDO, no estimado. Con dispersión real ~1,41, los SE de esa tabla quedan ~19 % angostos (raíz de 1,41): **sus p no se reportan**.
- Deviance residual/gl = 156,75/100 = 1,57: tercer índice informal de sobredispersión.
- AIC 500,46 (la binomial negativa da 496,83: gana aun pagando la multa del parámetro extra).

## 4. Diagnóstico de sobredispersión (paso 2.2)

La Poisson exige varianza = media. Si la varianza es mayor (sobredispersión), los intervalos salen más angostos de lo honesto y la significación se infla. Se evaluó por tres vías convergentes (alfa = 0,05):

| Vía | Naturaleza | Resultado | Lectura |
|---|---|---|---|
| Dispersión de Pearson (suma de residuos² / gl) | Descriptiva | 1,41 | 41 % más variabilidad de la permitida |
| Test de Cameron-Trivedi (`AER::dispersiontest`) | Dócima formal | z = 2,149; p = 0,016 (dispersión 1,36) | El exceso no es azar |
| Razón de verosimilitud Poisson vs binomial negativa | Comparación de modelos | LR = 5,63; p = 0,009 | La binomial negativa lo maneja mejor |

**Supuestos de estos diagnósticos:** ninguno exige normalidad (los conteos nunca son normales y los métodos están hechos para eso; la "normalidad" del z es asintótica, del estadístico, no de los datos). Piden media bien especificada, independencia entre celdas zona-año y muestra suficiente (104 holgado). El supuesto delicado es la independencia (secuencias de réplicas); ese mecanismo es justamente una causa plausible de la sobredispersión detectada y la binomial negativa lo absorbe. La estructura temporal se examina formalmente en la Fase 4.

### La corrección del p dividido por dos (vía 3)

Bajo H0 el parámetro de dispersión vale 0, que es el **borde** de su espacio (no puede ser negativo). En esa condición no estándar la distribución nula del LR es una mezcla 50:50 entre un punto en cero y la chi-cuadrado con 1 gl (Self y Liang 1987), y la receta práctica es dividir el p por dos: 0,018 → 0,009. Umbral de rechazo con la mezcla: 2,71 en vez de 3,84.

- `lmtest::lrtest(m_tasa, m_nb)` valida la aritmética (logLik -246,23 y -243,42; Chisq 5,6276) pero su p (0,0177) NO lleva la corrección: es función genérica y no sabe que el parámetro está en frontera. No reportar ese p.
- `pscl::odTest` hace exactamente el cálculo manual (verificado en su código fuente: `d <- 2*(llhNB - llhPoisson)`; `pval <- pchisq(d, 1, lower.tail=FALSE)/2`). No se instaló: dos líneas no justifican la dependencia.

### Validaciones adicionales corridas en esta máquina

| Chequeo | Herramienta | Resultado |
|---|---|---|
| Índice de Pearson por librería | `summary(glm quasipoisson)$dispersion` (R base) | 1,409584 vs 1,409579 manual (idéntico) |
| Cameron-Trivedi con alternativa cuadrática | `dispersiontest(m_tasa, trafo = 2)` | z = 2,349; p = 0,0094; alfa = 0,022 (robusto a la forma de la alternativa; la cuadrática es la varianza de la NB) |
| Índice + test chi-cuadrado global | `performance::check_overdispersion(m_tasa)` | ratio 1,410; chi² = 140,958; p = 0,004 (instalado en esta máquina; solo chequeo rápido: su aproximación chi² se degrada con medias chicas como la Dorsal) |

**Por qué tres vías y no una:** miden lo mismo con lógicas independientes y debilidades no superpuestas (medición sin p / dócima sin alternativa comprometida / comparación directa de los candidatos). Las tres coincidieron; si hubieran discrepado, la instrucción era detenerse.

**Nota general sobre supuestos:** no existe "la" fase de supuestos del informe; cada método verifica los suyos antes de su compuerta (C2 aquí, C3 en la Fase 3), y algunos solo pueden chequearse después de ajustar (la sobredispersión se mide sobre los residuos del modelo ya ajustado). Lo común a todas las comparaciones sí fue primero: la Fase 1 (comparabilidad del registro).

## 5. Decisión de modelo: binomial negativa (paso 2.3)

**De dónde sale la binomial negativa:** no es un parche; emerge sola de relajar el supuesto ingenuo de que todos los años tienen la misma tasa. Si la tasa anual fluctúa según una distribución gamma y, dado el año, los conteos son Poisson, la distribución resultante es exactamente la binomial negativa (argumento de Greenwood y Yule 1920 con conteos de accidentes). Es "la Poisson que admite que no todos los años son iguales".

**La varianza y el parámetro θ:** varianza = media + media²/θ. **θ divide: θ chico = MÁS sobredispersión** (contraintuitivo). θ → infinito recupera la Poisson exacta (por eso Poisson y NB están anidadas y el LR de la compuerta es legítimo). En esta fase: modelo con zona θ = 42,35 (exceso leve, varianza ~1,8 veces la media en Fuego); modelo nulo θ = 0,577 (exceso brutal: el nulo absorbe como varianza extra las diferencias entre zonas que no puede explicar). Chequeo cruzado: el α = 0,0219 de `dispersiontest(trafo=2)` es 1/θ → θ ≈ 45,6, misma vecindad.

**Alternativas consideradas y descartadas:**

| Remedio | Por qué no |
|---|---|
| Quasi-Poisson | Sin verosimilitud: no permite LR de compuerta, ni AIC, ni IC de perfil (Ver Hoef y Boveng 2007 para la disyuntiva) |
| Errores robustos (sandwich) | Parche sobre modelo mal especificado; no modela el mecanismo |
| Ceros inflados | El problema es varianza extra, no exceso de ceros (los ceros de la Dorsal son los esperables) |
| Efectos aleatorios por año | Más complejo de estimar y comunicar; la NB ya es su versión integrada |

**Efecto práctico del cambio:** los puntos estimados casi no se mueven; lo que se corrige es la amplitud de los intervalos (a su tamaño honesto).

## 6. El offset (modelo de densidad)

`m_nb_dens <- glm.nb(n ~ zona + offset(log(area_km2)))`.

- **Qué es:** una variable que entra con coeficiente fijado en 1, sin estimarse. En escala log: log(eventos) = b0 + b_zona + 1·log(área) equivale a log(eventos/área) = b0 + b_zona → el modelo pasa a describir densidades.
- **Por qué en logaritmo:** para que la resta de logs sea el cociente eventos/área en escala original.
- **Por qué coeficiente 1 y no estimado:** es una normalización impuesta por diseño ("el doble de superficie, el doble de eventos a igual densidad"), no una pregunta empírica. Documentación oficial: `?glm` lo define como "an a priori known component to be included in the linear predictor".
- **Por qué el nombre:** *offset* = desplazamiento. Corre el punto de partida del predictor lineal de cada observación en una cantidad fija y conocida a priori; lo estimado opera por encima de ese corrimiento.
- **Analogía:** delitos por cada 100 mil habitantes; el offset mete el "por cada" dentro del modelo de conteos.

**Descubrimiento clave (visto en las salidas):** los modelos de tasa y densidad tienen la MISMA log-verosimilitud (-243,42) y los MISMOS errores estándar por coeficiente (0,0450 / 0,137 / 0,197 / 0,0887). Sabiendo la zona, el área ya está determinada, así que el offset no aporta información: **reparametriza** (cambia qué significan los coeficientes: tasas → densidades) sin cambiar ajuste ni precisión. Las razones cambian exactamente por los cocientes de superficies (Resto: 0,228 → 0,228/9,01 = 0,025).

## 7. Contrastes globales de zona (paso 2.4)

**Pregunta:** ¿aporta algo la zona, en conjunto? Cada modelo final contra su modelo nulo:

- Nulo de tasa: `n ~ 1` (una tasa común; exp(intercepto) = 1.186/104 = 11,4 por celda).
- Nulo de densidad: `n ~ offset(log(area_km2))` (una densidad común). **Conserva el offset** para que la dócima aísle exclusivamente la zona: los modelos comparados deben diferir solo en lo contrastado.

**Resultados:** LR = 220,374 (tasa) y 225,851 (densidad), 3 gl (4 zonas - 1), p = 1,67e-47 y 1,09e-48 → se reporta p < 0,001 (nunca "p = 0").

- **Aquí NO se divide el p por dos:** los coeficientes de zona son parámetros interiores (pueden ser positivos, negativos o cero), no hay frontera. La corrección de Self y Liang era para la dispersión, no un ritual.
- La evidencia es mayor en densidad (225,9 > 220,4) porque "todo el planeta con la misma densidad" es una descripción aún peor que "la misma tasa por celda".
- Comparación con el global Poisson gratis del summary (caída de deviance 1.484 con 3 gl): la NB da 220 porque su nulo absorbe heterogeneidad vía θ; misma conclusión, evidencia a tamaño honesto.

**Validaciones:** `lmtest::lrtest` y `anova()` de MASS reproducen ambos estadísticos exactos (aquí el p de lrtest sí vale). **Trampa detectada:** `car::Anova(m_nb)` y `drop1(m_nb, test="Chisq")` reportan 1.156,9 porque reajustan el nulo con θ FIJO en 42,35 (contrastan otra pregunta); no usar para esta dócima.

**Para qué sirvió:** responde la pregunta del informe en su forma literal (una sola hipótesis sobre las 4 zonas); es el guardián contra hurgar pares sin protección; legitima los análisis siguientes; replica la coreografía de la Fase 3 (global → post-hoc); y con estos datos su valor es la formalidad correcta, no el descubrimiento.

## 8. Razones de tasa con IC 95 % (paso 2.5)

`exp(cbind(RR = coef(m), confint(m)))`. El "Waiting for profiling to be done..." indica **verosimilitud perfilada** (método de MASS): en vez de estimación ± 1,96·SE (Wald, que asume simetría), R prueba valores candidatos del parámetro y retiene los compatibles con los datos. Comparación corrida: Wald y perfil difieren recién en la 3ª cifra (Dorsal: [0,0214; 0,0462] vs [0,0209; 0,0452]) → ninguna conclusión depende del método (robustez citable).

**Resultados (tasa anual), contra Fuego (intercepto = tasa base 34,308 [31,404; 37,470]):**

| Zona | RR | IC 95 % perfil | 1/RR (Fuego multiplica por) |
|---|---|---|---|
| Resto del mundo | 0,228 | [0,191; 0,270] | 4,4 |
| Alpino-Himalayo | 0,071 | [0,053; 0,092] | 14,2 |
| Dorsal Meso-Atlántica | 0,031 | [0,021; 0,045] | 31,9 |

**Resultados (densidad), contra Fuego (intercepto = 7,2e-7 por km²·año = 0,720 por millón de km²·año):** Alpino 0,232 [0,176; 0,302]; Dorsal 0,079 [0,053; 0,114]; Resto 0,025 [0,021; 0,030]. Reordenamiento: en densidad Resto pasa a ser la zona MÁS lejana de Fuego.

- El valor nulo en escala de razones es 1 (no 0). Los seis intervalos lo excluyen.
- IC más ancho en términos relativos: Dorsal (28 eventos); el desbalance queda documentado.
- Validación: `broom::tidy(m, exponentiate = TRUE, conf.int = TRUE)` reproduce RR e IC exactos. **Trampas de esa tabla:** `std.error` y `statistic` quedan en escala log aunque `estimate` esté exponenciado (z = log(RR)/SE, no RR/SE); el p del intercepto contrasta "tasa base = 1", hipótesis irrelevante que se ignora; p mostrado como 0 = underflow (reportar p < 0,001).

## 9. Comparaciones por pares con ajuste de Holm (paso 2.6)

**La función `contrastes_pares_nb`:** obtiene las 6 comparaciones desde el modelo ya ajustado, sin reajustar. `model.matrix` arma la receta de coeficientes de cada zona; restar dos filas da el vector de contraste (el intercepto se cancela: por eso se puede comparar Alpino con Dorsal aunque el modelo hable "contra Fuego"); `sum(contraste * coef)` es la diferencia de log-tasas; `sqrt(t(c) %*% vcov %*% c)` es su error estándar exacto (los coeficientes están correlacionados por compartir referencia; la forma cuadrática incluye las covarianzas); z, IC de Wald y p bilateral; `p.adjust(method = "holm")`.

**Por qué ajustar:** 6 tests a 5 % cada uno acumulan ~26 % de probabilidad de al menos una falsa alarma si nada difiriera (1 - 0,95⁶). El ajuste protege la tabla completa al 5 %.

**Qué hace Holm (1979):** ordena los p de menor a mayor y multiplica por 6, 5, 4, 3, 2, 1. Lógica secuencial: cada test se protege contra las hipótesis que aún quedan en pie. Misma garantía que Bonferroni (válida bajo dependencia arbitraria) con menos castigo; la documentación de `?p.adjust` dice textual que no hay razón para usar Bonferroni porque Holm lo domina. Verificado en la tabla: 3,36e-83 × 6 = 2,02e-82, ..., 4,50e-4 × 1 = 4,50e-4.

**Resultados:** las 6 comparaciones significativas tras Holm en AMBAS métricas (p ajustado máximo 0,00045, Alpino-Dorsal en tasa). Quedan establecidos inferencialmente los rankings completos, escalón por escalón:

- Tasa anual: Fuego > Resto > Alpino > Dorsal.
- Densidad: Fuego > Alpino > Dorsal > Resto.

Pares nuevos respecto del 2.5: Alpino duplica a la Dorsal en tasa (2,25 [1,43; 3,54], el eslabón más débil y resiste); Alpino = 0,310 de Resto; Dorsal = 0,138 de Resto. El cambio de signo de los pares de Resto entre las dos métricas (+1,17 → -2,22 contra Alpino) es el reordenamiento en su forma más compacta.

**Validación:** `multcomp::glht(m, mcp(zona = "Tukey"))` con `adjusted("holm")` reproduce estimaciones, SE, z y p (rótulos al revés: "Alpino - Fuego"; ahí "Tukey" nombra el conjunto de contrastes, no el ajuste). `emmeans` con `adjust = "holm"` y `type = "response"` da lo mismo exponenciado.

**Nota de honestidad para la redacción:** los p llevan Holm, pero los IC de la tabla son **individuales** al 95 % (no simultáneos). Si se quisieran intervalos ajustados por la familia: `multcomp` (single-step) o `emmeans` (`adjust = "mvt"`). Con estas magnitudes no cambia nada, pero el texto debe decir "intervalos individuales".

## 10. Tabla puente y figura (paso 2.7)

**Tabla puente:** totales por zona (892 / 203 / 63 / 28), superficie en millones de km², tasa anual (÷26) y densidad por millón de km² y año. Es la bisagra en dos direcciones: hacia atrás reproduce las cifras del Informe 1 (34,3 / 7,81 / 2,42 / 1,08); hacia el modelo, cada cociente descriptivo es la contraparte de un número inferencial (7,81/34,31 = 0,228 = RR de Resto; 0,720 = intercepto de densidad × 1 millón). El modelo no inventó números: agregó inferencia a estos cocientes. Cautela del script: el reordenamiento queda condicionado a la delimitación de zonas adoptada.

**Figura (`inf2-frecuencia-tasa-densidad.png`):** dos paneles de barras, cada uno ordenado por su métrica, colores fijos por zona (paleta Informe 1); el reordenamiento de Resto (gris) se ve de inmediato. La versión vigente del bloque abre `png()` directo y cierra con `dev.off()`: reproducible por Rscript, pero **no aparece en PLOTS** (el dibujo va al archivo, no a la pantalla; el `null device 1` final confirma cierre correcto). Para verla en pantalla: correr solo las líneas de dibujo saltándose `png(...)` y `dev.off()`. Alternativa probada y validada visualmente (idéntica): versión `ggplot2` + `patchwork` (ambos instalados), donde la figura es un objeto que se muestra en PLOTS y se exporta con `ggsave` sin duplicar código. Decisión de reemplazo pendiente de coordinar con el grupo.

## 11. Conclusiones de la fase (registradas en el script)

- **Paso 2.4:** las cuatro zonas no comparten una misma tasa (LR = 220,4) ni una misma densidad (LR = 225,9), 3 gl, p < 0,001. La diferencia descrita en el Informe 1 pasa a afirmación inferencial y habilita los análisis siguientes.
- **Paso 2.5:** Resto opera al 22,8 % de la tasa de Fuego, Alpino al 7,1 % y Dorsal al 3,1 % (Fuego multiplica por 4,4 / 14,2 / 31,9); en densidad Resto cae al último lugar (2,5 % de Fuego por km²). Los seis intervalos excluyen el 1.
- **Paso 2.6:** las 6 comparaciones significativas tras Holm en ambas métricas; rankings completos establecidos escalón por escalón; el reordenamiento de Resto es inferencial, no solo descriptivo.

## 12. Reglas de reporte acordadas en esta fase

- Nunca "p = 0" ni cuarenta decimales: reportar p < 0,001 (los ceros de pantalla son underflow o piso de impresión; 2,22e-16 es la precisión de la máquina, no un p exacto).
- No reportar SE/z/p del summary Poisson (dispersión asumida en 1) ni el p sin corregir de `lrtest` en el contraste de frontera.
- El p del intercepto no se interpreta (hipótesis "tasa base = 1", irrelevante).
- Distinguir siempre significación (los p) de magnitud (las razones de tasa con sus IC): la conclusión descansa en el tamaño del efecto, los intervalos, el desbalance reconocido (Dorsal, 28 eventos) y el alcance del catálogo (USGS, M ≥ 6,5, 2000-2025, zonificación adoptada).
- IC de la tabla de pares: individuales, no simultáneos; decirlo.
- Los asteriscos de significación de R son mecánicos: marcan umbrales sin entender el contraste.

## 13. Bibliografía verificada (para referencias.bib al redactar)

| Referencia | Qué respalda | Verificación |
|---|---|---|
| McCullagh, P. y Nelder, J. A. (1989). *Generalized Linear Models*, 2ª ed. Chapman & Hall | Dispersión de Pearson como estimador estándar; offset en GLM | Libro canónico; complementa la doc oficial de `?glm` (verificable local) |
| Cameron, A. C. y Trivedi, P. K. (1990). "Regression-based tests for overdispersion in the Poisson model". *J. of Econometrics*, 46(3), 347-364. DOI: 10.1016/0304-4076(90)90014-K | El test de sobredispersión (vía b) | Metadatos en RePEc/ScienceDirect; la ayuda de `AER::dispersiontest` lo cita como fuente (verificado local) |
| Self, S. G. y Liang, K.-Y. (1987). "Asymptotic properties of maximum likelihood estimators and likelihood ratio tests under nonstandard conditions". *JASA*, 82(398), 605-610. DOI: 10.1080/01621459.1987.10478472 | La mezcla 50:50 y el p dividido por dos en el LR de frontera | Metadatos en T&F/JSTOR; corroborado por nota arXiv 2509.00223 y por el código fuente de `pscl::odTest` (que además cita Cameron y Trivedi 1998, libro) |
| Ver Hoef, J. M. y Boveng, P. L. (2007). "Quasi-Poisson vs. negative binomial regression...". *Ecology*, 88(11), 2766-2772. DOI: 10.1890/07-0043.1 | La disyuntiva quasi-Poisson vs NB (alternativas consideradas); no recomienda una por defecto, la elección de NB es nuestra (necesidad de verosimilitud completa) | Abstract leído (repositorio UNL); metadatos en Wiley/JSTOR |
| Holm, S. (1979). "A simple sequentially rejective multiple test procedure". *Scand. J. of Statistics*, 6(2), 65-70 (sin DOI, era pre-DOI) | El ajuste de los 6 pares; garantía bajo dependencia arbitraria | PDF completo libre (USP); `?p.adjust` lo cita y declara que domina a Bonferroni (verificado local) |
| Documentación oficial de R: `?glm`, `?p.adjust`, ayuda de `AER` | Offset "a priori known component"; Holm domina Bonferroni; implementaciones exactas | Ejecutada en R 4.6.1 de esta máquina |

Criterio aplicado: artículo original, documentación oficial o libro metodológico; cada fuente sostiene una decisión puntual del script; ninguna decorativa.

## 14. Pendientes al cierre de esta sesión

1. Confirmar el origen de la versión ampliada del script 07 (llegó con pasos nuevos 2.4 y 2.6, renumeración y figura con `png()` directo) y **actualizar el checklist** de la Fase 2, que quedó con la numeración vieja y sin los contrastes globales ni los pares con Holm.
2. Decidir el bloque de figura: dejar base R, versión ggplot2 + patchwork (probada, idéntica), o patrón `dibujar_()` + `if (interactive())`.
3. Redactar en el QMD (orden acordado): **metodología de la Fase 2 primero** (corrigiendo la inconsistencia detectada: la metodología actual describe un solo modelo con offset, pero el script estima dos modelos finales, y el resultado principal sale del modelo sin offset), luego resultados según la estructura de 7 puntos, con los desarrollos extensos (mezcla 50:50, especificación de modelos) al anexo `sec-anexo-especificacion`.
4. La sección 7.2 del QMD está dentro de `::: {.content-hidden when-format="pdf"}`: decidir si se hace visible al redactar.
