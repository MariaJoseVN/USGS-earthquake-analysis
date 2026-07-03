# Ayuda memoria: interpretación de gráficos QQ

## Propósito

Un gráfico cuantil-cuantil o gráfico QQ permite evaluar visualmente si la distribución observada de una variable es compatible con una distribución teórica. En este análisis, la distribución de referencia es la normal.

El gráfico QQ es un diagnóstico visual. No constituye por sí solo una prueba formal de normalidad y debe interpretarse junto con los antecedentes de la variable, el tamaño muestral y los demás supuestos del procedimiento estadístico.

## Elementos del gráfico

Cada punto relaciona dos posiciones ordenadas de la distribución:

- El eje horizontal contiene los cuantiles que se esperarían bajo una distribución normal.
- El eje vertical contiene los cuantiles observados de la magnitud, ordenados desde los valores menores hasta los mayores.

Los puntos situados a la izquierda representan las magnitudes más bajas y los puntos situados a la derecha representan las magnitudes más altas. No corresponden a pares de variables ni deben interpretarse como observaciones con dos mediciones diferentes.

## Línea de referencia

La línea punteada generada por `qqline()` representa el comportamiento esperado si los datos tuvieran una forma aproximadamente normal, considerando su centro y dispersión. En R, esta línea se determina a partir del primer y tercer cuartil de la distribución observada.

La línea no corresponde a una regresión ni a un intervalo de confianza.

## Comportamiento esperado bajo normalidad

Si la distribución es razonablemente normal, se espera que:

- Los puntos sigan aproximadamente una línea recta.
- Las separaciones respecto de la línea sean pequeñas y no sistemáticas.
- No aparezcan curvaturas marcadas.
- No existan acumulaciones horizontales prolongadas.
- Las colas izquierda y derecha permanezcan relativamente próximas a la línea.

No es necesario que todos los puntos estén exactamente sobre la línea. Pequeñas fluctuaciones aleatorias son compatibles con normalidad.

## Patrones frecuentes

| Patrón observado | Interpretación general |
|---|---|
| Puntos aproximadamente rectos | Normalidad razonable |
| Cola derecha por encima de la línea | Asimetría positiva o cola derecha más extensa |
| Desviación de los cuantiles inferiores | Comportamiento anormal de los valores bajos |
| Forma de S | Diferencia respecto de la normalidad en el peso de las colas |
| Segmentos horizontales | Valores repetidos, redondeo o variable discreta |
| Pocos puntos muy separados | Posibles observaciones extremas |

## Particularidades del catálogo analizado

La magnitud presenta dos características que afectan directamente los gráficos QQ:

1. El catálogo está truncado en $M\geq6{,}5$, por lo que no contiene valores inferiores al umbral.
2. Las magnitudes presentan valores repetidos, principalmente en incrementos de 0,1, lo que genera segmentos escalonados.

Por estas razones, la acumulación de observaciones en $M=6{,}5$ y la forma escalonada de los gráficos no representan errores de los datos. Son consecuencias de la definición del catálogo y de la precisión con que se reporta la magnitud.

## Interpretación por zona

### Cinturón de Fuego

La desviación respecto de la línea de referencia es clara. Se observa una acumulación extensa de eventos en $M=6{,}5$, una aproximación parcial a la línea en la zona central y una curvatura marcada hacia arriba en la cola superior.

El patrón indica una distribución truncada por la izquierda, con numerosos valores repetidos y una cola hacia la derecha formada por los eventos de mayor magnitud. La normalidad no resulta razonable para esta zona.

### Resto del mundo

El gráfico presenta un comportamiento semejante al Cinturón de Fuego. Existe acumulación en el umbral $M=6{,}5$, una forma escalonada y una separación progresiva de los valores superiores respecto de la línea.

La cola derecha es más extensa que la esperada bajo una distribución normal. En consecuencia, el gráfico tampoco respalda la normalidad de la magnitud en esta categoría.

### Cinturón Alpino-Himalayo

Los puntos centrales se aproximan mejor a la línea de referencia, pero persisten una acumulación en $M=6{,}5$, empates, escalones y desviaciones en los extremos.

Aunque el comportamiento visual es más cercano a la linealidad que en los dos grupos anteriores, la distribución completa no puede considerarse normal. La interpretación debe considerar además el menor tamaño muestral, correspondiente a 63 eventos.

### Dorsal Meso-Atlántica

La zona central del gráfico es relativamente cercana a la línea, pero la muestra contiene solo 28 eventos y un rango de magnitudes reducido. Se observan múltiples valores repetidos en 6,5 y 6,6, junto con el efecto del truncamiento inferior.

La desviación visual es menos marcada, pero el gráfico no entrega evidencia suficiente para sostener normalidad. El tamaño reducido disminuye la capacidad del diagnóstico gráfico para detectar desviaciones.

## Conclusión conjunta

Los puntos no presentan separaciones aleatorias respecto de la línea de referencia, sino patrones sistemáticos asociados con el truncamiento, los empates y la cola superior. La normalidad de la magnitud no resulta razonable para las cuatro zonas, con evidencia especialmente clara en el Cinturón de Fuego y Resto del mundo.

Este resultado entrega respaldo gráfico para considerar procedimientos no paramétricos en la comparación de magnitud entre zonas. Sin embargo, la decisión metodológica final debe incorporar también el diagnóstico de profundidad, la homogeneidad de dispersión y las demás condiciones del procedimiento considerado.

## Redacción sugerida para el informe

> Los gráficos cuantil-cuantil evidencian desviaciones sistemáticas respecto de la normalidad en las cuatro zonas, asociadas al truncamiento del catálogo en $M\geq6{,}5$, la concentración de observaciones en el umbral y la presencia de una cola superior. Las desviaciones son especialmente claras en el Cinturón de Fuego y Resto del mundo. En las zonas con menor tamaño muestral, particularmente la Dorsal Meso-Atlántica, el diagnóstico presenta mayor incertidumbre, aunque la acumulación de valores y el carácter discreto de la magnitud tampoco respaldan el supuesto normal.

# Aplicación a la profundidad

## Cinturón de Fuego

La mayoría de los eventos se concentra en profundidades bajas. Desde los cuantiles centrales, los puntos se curvan bruscamente hacia arriba y forman una cola derecha muy extensa, con profundidades cercanas a 700 km.

La forma observada refleja la coexistencia de eventos superficiales, intermedios y profundos. La profundidad presenta una asimetría positiva muy marcada y no es compatible con una distribución normal.

## Resto del mundo

El gráfico muestra una concentración inicial de eventos superficiales, seguida por un salto abrupto hacia profundidades intermedias y profundas. La cola superior supera los 600 km y permanece ampliamente separada de la línea de referencia.

El patrón parece corresponder a una combinación de grupos de profundidad diferentes y no a una única distribución normal.

## Cinturón Alpino-Himalayo

La mayoría de los eventos se concentra en profundidades bajas. Desde la zona central aparece una curvatura ascendente y la cola superior alcanza aproximadamente 230 km.

Aunque no presenta las profundidades extremas del Cinturón de Fuego o Resto del mundo, existe una asimetría positiva clara. La normalidad tampoco resulta razonable para esta zona.

## Dorsal Meso-Atlántica

La mayoría de los 28 eventos presenta una profundidad cercana o igual a 10 km. Como el primer y tercer cuartil son prácticamente iguales, `qqline()` genera una línea casi horizontal en 10 km. Esta línea horizontal no corresponde a un error gráfico, sino a la elevada concentración de observaciones en ese valor.

Unos pocos eventos presentan profundidades superiores, con un máximo cercano a 35 km. La distribución tiene muy poca variabilidad, numerosos empates y algunas observaciones alejadas del valor dominante. En consecuencia, tampoco puede considerarse normal.

La acumulación en 10 km debe interpretarse además como una posible característica de la forma en que se reporta la profundidad en esta zona. No demuestra por sí sola una homogeneidad física perfecta de los eventos.

## Conclusión conjunta para profundidad

La profundidad original no presenta normalidad en ninguna zona:

- Cinturón de Fuego y Resto del mundo presentan asimetría extrema y eventos muy profundos.
- El Cinturón Alpino-Himalayo presenta una cola derecha marcada.
- La Dorsal Meso-Atlántica presenta una concentración casi completa en 10 km, numerosos empates y escasa variabilidad.

Una distribución normal multivariante exige que cada variable marginal sea normal. Como los diagnósticos de magnitud y profundidad muestran desviaciones importantes, existe evidencia gráfica fuerte contra la normalidad multivariante del vector $(mag,depth)$.

Estos resultados respaldan el uso de Kruskal-Wallis para comparar profundidad entre zonas y una ruta no paramétrica para magnitud. MANOVA no debería utilizarse como análisis principal bajo estas condiciones, aunque las pruebas de Mardia y Box-M pueden conservarse para documentar formalmente la decisión.

Una transformación como $\log(1+depth)$ podría reducir la asimetría de la profundidad en algunas zonas, pero no resolvería la concentración de la Dorsal ni la falta de normalidad de la magnitud. Por ello, debe entenderse como una comprobación complementaria y no como una solución automática.

## Redacción sugerida para profundidad

> Los gráficos cuantil-cuantil de profundidad muestran desviaciones pronunciadas respecto de la normalidad en todas las zonas. El Cinturón de Fuego y Resto del mundo presentan colas derechas extensas asociadas con eventos de gran profundidad, mientras que el Cinturón Alpino-Himalayo conserva una asimetría positiva de menor alcance. En la Dorsal Meso-Atlántica, la elevada concentración de observaciones en 10 km produce una línea de referencia prácticamente horizontal y evidencia una distribución con escasa variabilidad y numerosos empates. En conjunto, estos patrones no respaldan el supuesto de normalidad de la profundidad.

# Resultados formales de normalidad

## Política para interpretar los valores p

El valor p no es seleccionado por el equipo: se obtiene a partir de los datos y de la prueba estadística. La decisión que debe justificarse previamente es el nivel de significación $\alpha$.

Para las hipótesis sustantivas del informe se propone mantener $\alpha=0{,}05$. Para el diagnóstico de supuestos se utiliza $\alpha=0{,}10$ como umbral preventivo, porque no detectar una desviación relevante podría conducir a seleccionar una ruta paramétrica inadecuada. Este criterio aumenta la sensibilidad frente al incumplimiento, aunque también incrementa la posibilidad de rechazar un supuesto ante desviaciones menores. Por esa razón, los valores p se interpretan junto con los gráficos QQ, los tamaños muestrales y la naturaleza de las variables.

El valor p no representa la probabilidad de que la hipótesis nula sea verdadera ni mide el tamaño de la desviación. Para Shapiro-Wilk y Mardia se utiliza la siguiente regla:

- $p<\alpha$: existe evidencia para rechazar normalidad.
- $p\geq\alpha$: no existe evidencia suficiente para rechazarla, lo cual no demuestra normalidad.

## Resultados de Shapiro-Wilk

Shapiro-Wilk contrasta la normalidad marginal de cada variable dentro de cada zona. Los resultados obtenidos fueron $p<0{,}001$ para `mag` y `depth` en los cuatro grupos. En consecuencia, se rechaza normalidad univariada en todos los casos con $\alpha=0{,}10$, $0{,}05$ y $0{,}01$.

El estadístico $W$ se aproxima a 1 cuando la distribución es cercana a normal. Para magnitud, los valores variaron entre 0,835 y 0,854; para profundidad, entre 0,431 y 0,617. La profundidad de la Dorsal Meso-Atlántica presentó el menor valor, $W=0{,}431$, consistente con la concentración de observaciones en 10 km.

## Resultados de Mardia

Mardia evalúa la normalidad conjunta de `(mag, depth)` mediante dos componentes: asimetría y curtosis multivariante. Para considerar razonable la normalidad conjunta, ambos componentes deberían resultar compatibles con la hipótesis nula.

| Zona | Mardia: asimetría | $p$ | Mardia: curtosis | $p$ | SW magnitud | SW profundidad |
|---|---:|---:|---:|---:|---:|---:|
| Cinturón de Fuego | 1.356,483 | $<0{,}001$ | 30,724 | $<0{,}001$ | 0,835 | 0,537 |
| Resto del mundo | 130,684 | $<0{,}001$ | 3,435 | $<0{,}001$ | 0,854 | 0,602 |
| Cinturón Alpino-Himalayo | 49,331 | $<0{,}001$ | 2,059 | 0,039 | 0,840 | 0,617 |
| Dorsal Meso-Atlántica | 86,180 | $<0{,}001$ | 10,549 | $<0{,}001$ | 0,849 | 0,431 |

Las pruebas de asimetría y curtosis rechazaron la normalidad multivariante en todas las zonas. En el Cinturón Alpino-Himalayo, la curtosis presentó $p=0{,}039$; aunque no se rechazaría bajo un criterio de 1 %, la asimetría presentó $p<0{,}001$. Por tanto, la conclusión conjunta sigue siendo el rechazo de normalidad.

La decisión es estable frente a distintos umbrales razonables:

- Con $\alpha=0{,}10$, se rechaza normalidad en todas las zonas.
- Con $\alpha=0{,}05$, se mantiene la misma conclusión.
- Con $\alpha=0{,}01$, la curtosis del Cinturón Alpino-Himalayo no se rechaza, pero su asimetría sí; por ello, la normalidad conjunta continúa rechazándose.

Los estadísticos de Mardia no deben compararse directamente entre grupos para decidir cuál zona es ``menos normal'', porque los tamaños muestrales son muy diferentes.

## Decisión metodológica

Existe concordancia entre tres fuentes de evidencia:

1. Los gráficos QQ muestran truncamiento, empates, asimetría y colas extensas.
2. Shapiro-Wilk rechaza la normalidad marginal de magnitud y profundidad.
3. Mardia rechaza la normalidad multivariante del vector `(mag, depth)`.

En consecuencia, no se cumple el supuesto de normalidad marginal ni multivariante dentro de las zonas. Esta evidencia descarta MANOVA como procedimiento principal y orienta la comparación de magnitud y profundidad hacia procedimientos no paramétricos o robustos. M-Box puede mantenerse como diagnóstico complementario de las matrices de covarianza, pero su resultado no puede revertir el incumplimiento de normalidad.

## Redacción sugerida para los resultados formales

> Los diagnósticos gráficos y formales mostraron incumplimiento del supuesto de normalidad. Shapiro-Wilk rechazó la normalidad de magnitud y profundidad en las cuatro zonas ($p<0{,}001$). Asimismo, las pruebas de asimetría y curtosis multivariante de Mardia rechazaron la normalidad conjunta de ambas variables en todos los grupos. La única excepción parcial correspondió a la curtosis del Cinturón Alpino-Himalayo bajo un criterio de 1 % ($p=0{,}039$); sin embargo, su asimetría permaneció significativa. En consecuencia, la decisión metodológica no depende del nivel de significación seleccionado y se descarta MANOVA como procedimiento principal.

# Homogeneidad de matrices de varianza-covarianza

## Propósito de la prueba M de Box

La prueba M de Box evalúa si las matrices de varianza-covarianza del vector `(mag, depth)` son iguales entre las zonas. La hipótesis nula es:

$$
H_0:\boldsymbol{\Sigma}_{\text{Fuego}}
=\boldsymbol{\Sigma}_{\text{Resto}}
=\boldsymbol{\Sigma}_{\text{Alpino}}
=\boldsymbol{\Sigma}_{\text{Dorsal}}.
$$

La hipótesis alternativa establece que al menos una de estas matrices difiere. La prueba es global: permite detectar heterogeneidad, pero no identifica por sí sola qué pares de zonas presentan las diferencias.

## Resultado obtenido

La aplicación de `heplots::boxM()` produjo:

$$
\chi^2(9)=286{,}5034,
\qquad p<2{,}2\times10^{-16}.
$$

El valor mostrado por R no significa que $p=0$, sino que el valor es menor que aproximadamente $2{,}2\times10^{-16}$. En consecuencia, se rechaza la hipótesis de igualdad de matrices de varianza-covarianza.

La conclusión es estable frente a los niveles de significación convencionales de 0,10, 0,05, 0,01, 0,001 e incluso 0,0001. Por tanto, no depende de la elección puntual de $\alpha$.

## Interpretación sustantiva

La heterogeneidad detectada es coherente con los resultados descriptivos del Informe 1:

- El Cinturón de Fuego y Resto del mundo presentan dispersiones elevadas en profundidad.
- El Cinturón Alpino-Himalayo presenta una dispersión intermedia.
- La Dorsal Meso-Atlántica concentra gran parte de sus profundidades en 10 km y presenta una dispersión reducida.
- La Dorsal también presenta una dispersión de magnitud menor que las demás zonas.

Estas diferencias afectan tanto las varianzas individuales como la covariación entre magnitud y profundidad. Sin embargo, Box-M no permite atribuir formalmente el rechazo a una zona o a un par específico sin diagnósticos adicionales.

## Precauciones de interpretación

Box-M es sensible a dos condiciones presentes en los datos:

1. Incumplimiento de normalidad multivariante.
2. Tamaños muestrales desiguales entre zonas.

Por esta razón, el resultado no debe interpretarse aisladamente ni usarse con un umbral preventivo de $\alpha=0{,}10$. Se reporta el valor p exacto y se considera evidencia complementaria, especialmente porque es extremadamente pequeño y coincide con los gráficos QQ, Shapiro-Wilk, Mardia y las diferencias descriptivas de dispersión.

Si Box-M no hubiera rechazado, ese resultado tampoco habría restablecido la viabilidad de MANOVA, porque la normalidad marginal y multivariante ya había sido rechazada.

## Decisión metodológica conjunta

El diagnóstico de supuestos entrega cuatro resultados consistentes:

- No existe normalidad marginal de magnitud o profundidad.
- No existe normalidad multivariante del vector `(mag, depth)`.
- No existe homogeneidad de matrices de varianza-covarianza.
- Los tamaños muestrales son considerablemente desiguales.

En consecuencia, MANOVA no se considera apropiada como procedimiento principal. La comparación formal debe continuar mediante procedimientos no paramétricos o robustos para magnitud y profundidad por separado, comenzando con Kruskal-Wallis y, si corresponde, comparaciones post-hoc y tamaños de efecto.

## Redacción sugerida para Box-M

> La prueba M de Box rechazó la igualdad de las matrices de varianza-covarianza entre zonas, $\chi^2(9)=286{,}503$, $p<0{,}001$. Aunque este contraste es sensible al incumplimiento de normalidad y al desbalance muestral, su resultado coincide con las diferencias descriptivas de dispersión y con los diagnósticos de Shapiro-Wilk y Mardia. En conjunto, la evidencia no respalda la aplicación de MANOVA como procedimiento principal.

# Relación entre magnitud y profundidad

## Diferencia entre Pearson, Bartlett y Spearman

La correlación de Pearson mide asociación lineal entre dos variables. La prueba de esfericidad de Bartlett se formula sobre una matriz de correlaciones de Pearson y contrasta si esta matriz es igual a la identidad. Con solamente `mag` y `depth`, la hipótesis se reduce a:

$$
H_0:\rho_{\text{Pearson}}=0.
$$

Aunque Pearson es la correlación técnicamente correspondiente a Bartlett, no constituye la medida sustantiva más apropiada para estos datos, debido a la asimetría, los valores extremos y los numerosos empates.

Spearman utiliza los rangos de las observaciones y evalúa asociación monotónica. Es más adecuado para describir la relación entre magnitud y profundidad bajo incumplimiento de normalidad. No debe reemplazarse Pearson por Spearman dentro de `cortest.bartlett()`, porque el valor p dejaría de corresponder a la prueba clásica de Bartlett.

## Resultados obtenidos

La correlación lineal de Pearson fue:

$$
r=0{,}015.
$$

La prueba de Bartlett produjo:

$$
\chi^2(1)=0{,}265,
\qquad p=0{,}607.
$$

Como $p>0{,}05$, no se rechaza la ausencia de correlación lineal entre magnitud y profundidad. El coeficiente cercano a cero confirma que no existe una relación lineal relevante ni un problema de colinealidad entre ambas variables.

La correlación de Spearman fue:

$$
\rho_s=0{,}130,
\qquad p=0{,}0000073.
$$

Este resultado identifica una asociación monotónica positiva, pero débil. En términos sustantivos, los eventos de mayor profundidad tienden a presentar magnitudes ligeramente mayores, aunque la relación tiene poca intensidad y conserva una dispersión elevada.

## Por qué los resultados no son contradictorios

Pearson y Spearman responden preguntas diferentes:

- Pearson no detecta una relación lineal.
- Spearman detecta una tendencia monotónica débil basada en rangos.

La significación de Spearman se encuentra influida por el tamaño de la muestra, correspondiente a 1.186 eventos. Con muestras grandes, asociaciones pequeñas pueden producir valores p muy bajos. Por ello, la interpretación debe destacar el tamaño del coeficiente, $\rho_s=0{,}130$, y no limitarse al resultado significativo.

## Consecuencia metodológica

La ausencia de correlación lineal elevada indica que magnitud y profundidad no son variables redundantes. Ambas pueden incorporarse simultáneamente en los modelos posteriores sin evidencia de colinealidad lineal problemática.

La asociación débil observada de manera marginal no impide que profundidad aporte información cuando se combine con magnitud en un modelo de clasificación. Este punto responde a la observación docente sobre variables que pueden adquirir relevancia al integrarse dentro de un modelo múltiple.

Los resultados de Bartlett y Spearman no modifican la ruta no paramétrica de comparación entre zonas ni recuperan la viabilidad de MANOVA, porque Shapiro-Wilk, Mardia y Box-M ya evidenciaron incumplimientos sustantivos.

## Redacción sugerida

> La correlación lineal entre magnitud y profundidad fue prácticamente nula ($r=0{,}015$; prueba de Bartlett, $p=0{,}607$). En cambio, Spearman identificó una asociación monotónica positiva, aunque débil ($\rho_s=0{,}130$; $p<0{,}001$). La diferencia se atribuye a la asimetría, los empates y los valores extremos de las distribuciones. La baja magnitud del coeficiente indica que ambas variables no son redundantes y justifica evaluar posteriormente su aporte conjunto en el modelo de clasificación.

# Gráfico QQ multivariante de Mahalanobis

## Propósito

El gráfico QQ multivariante permite evaluar visualmente si el comportamiento conjunto de magnitud y profundidad es compatible con una distribución normal multivariante dentro de cada zona. A diferencia de los gráficos QQ univariantes, no examina cada variable por separado, sino cada combinación `(mag, depth)`.

Para cada evento se calcula su distancia cuadrática de Mahalanobis:

$$
D_i^2=(\mathbf{x}_i-\bar{\mathbf{x}})'\mathbf{S}^{-1}(\mathbf{x}_i-\bar{\mathbf{x}}).
$$

Esta distancia indica cuán alejado se encuentra un evento del centro multivariante de su zona, considerando simultáneamente las escalas, varianzas y correlación de las variables. Así, puede identificar combinaciones inusuales que no necesariamente serían extremas al examinar magnitud y profundidad por separado.

## Qué se compara

Si el vector formado por magnitud y profundidad sigue aproximadamente una distribución normal multivariante, sus distancias cuadráticas de Mahalanobis deberían comportarse aproximadamente como una distribución chi-cuadrado con tantos grados de libertad como variables analizadas. En este caso:

$$
D_i^2 \sim \chi^2_{(2)}.
$$

El eje horizontal contiene los cuantiles teóricos de una distribución $\chi^2$ con 2 grados de libertad y el eje vertical contiene las distancias de Mahalanobis observadas y ordenadas.

## Interpretación

- Puntos aproximadamente alineados con la diagonal: compatibilidad razonable con normalidad multivariante.
- Curvatura sistemática: forma conjunta incompatible con la normalidad multivariante.
- Puntos de la cola superior muy por encima de la diagonal: observaciones multivariantes extremas o colas más pesadas de lo esperado.
- Saltos o agrupaciones: empates, concentraciones o posibles mezclas de subpoblaciones.

La línea diagonal representa el comportamiento esperado bajo normalidad multivariante; no es una recta de regresión ajustada a los datos.

## Relación con las demás pruebas

Este gráfico complementa la prueba de Mardia: Mardia entrega un contraste formal mediante asimetría y curtosis, mientras que el QQ de Mahalanobis permite observar dónde y cómo aparece el incumplimiento. No reemplaza a Box-M, porque Box-M evalúa la igualdad de matrices de varianza-covarianza entre zonas, no la normalidad dentro de ellas.

En estos datos, el gráfico no se utiliza para volver a decidir la ruta metodológica —Mardia, Shapiro-Wilk y Box-M ya respaldan la ruta no paramétrica—, sino para completar el diagnóstico y mostrar visualmente la naturaleza de la desviación multivariante.

## Resultados observados por zona

### Cinturón de Fuego

Las distancias iniciales se sitúan bajo la diagonal y, desde aproximadamente el cuantil teórico 4, aparece una curvatura ascendente pronunciada. La cola superior alcanza distancias de Mahalanobis cercanas a 28, considerablemente mayores que las esperadas bajo normalidad multivariante.

El patrón indica colas multivariantes pesadas y varios eventos con combinaciones inusuales de magnitud y profundidad. La desviación no se limita a una única observación extrema, por lo que la normalidad multivariante no resulta plausible.

### Resto del mundo

Esta zona presenta el mejor ajuste relativo en la parte central de la distribución. Sin embargo, las distancias iniciales quedan ligeramente bajo la diagonal y la cola superior se separa progresivamente de ella, incluyendo observaciones claramente extremas.

Aunque el centro muestra una aproximación razonable, el comportamiento de la cola impide sostener normalidad multivariante y coincide con el rechazo obtenido mediante Mardia.

### Cinturón Alpino-Himalayo

Se observa una curvatura sistemática: las distancias bajas se sitúan principalmente bajo la diagonal, mientras que desde los cuantiles intermedios los puntos comienzan a ubicarse por encima. La cola superior contiene distancias mayores que las esperadas.

El patrón sugiere una concentración central elevada y una cola multivariante más pesada que la normal. En consecuencia, tampoco existe compatibilidad razonable con normalidad multivariante.

### Dorsal Meso-Atlántica

La mayor parte de las distancias queda bajo la diagonal, seguida por unas pocas observaciones moderadamente alejadas y una observación con distancia superior a 20, frente a un valor teórico cercano a 8.

Este punto representa una combinación extremadamente atípica de magnitud y profundidad. La concentración de numerosas profundidades alrededor de 10 km ayuda a explicar el patrón poco continuo. La interpretación debe mantenerse prudente debido al reducido tamaño muestral de esta zona, correspondiente a 28 eventos, pero el gráfico no respalda normalidad multivariante.

## Conclusión conjunta del gráfico

Los cuatro gráficos presentan desviaciones respecto de la diagonal. Se observan curvaturas sistemáticas, concentraciones y colas superiores más pesadas que las esperadas, especialmente en el Cinturón de Fuego y la Dorsal Meso-Atlántica. Por tanto, el incumplimiento no puede atribuirse solamente a uno o dos eventos aislados.

El diagnóstico visual coincide con las pruebas de asimetría y curtosis multivariante de Mardia y fortalece la decisión de no utilizar MANOVA como procedimiento principal.

## Redacción sugerida

> Los gráficos QQ de las distancias de Mahalanobis evidenciaron desviaciones respecto de los cuantiles teóricos chi-cuadrado en todas las zonas. Se observaron curvaturas sistemáticas y distancias extremas en las colas superiores, especialmente en el Cinturón de Fuego y la Dorsal Meso-Atlántica. Estos resultados respaldan el rechazo de normalidad multivariante obtenido mediante la prueba de Mardia y refuerzan la decisión de utilizar procedimientos no paramétricos o robustos.

# Comparación entre zonas mediante Kruskal-Wallis

## Propósito de la prueba

Kruskal-Wallis permite evaluar formalmente si la distribución de una variable numérica es igual entre tres o más grupos independientes. En este análisis responde dos preguntas:

1. ¿La distribución de magnitud es igual en las cuatro zonas?
2. ¿La distribución de profundidad es igual en las cuatro zonas?

El resumen descriptivo permite observar diferencias en medianas y dispersiones, pero no determina si estas podrían atribuirse a variación muestral. Kruskal-Wallis aporta esa comparación inferencial global.

La prueba ordena todas las observaciones de menor a mayor, les asigna rangos y compara cómo se distribuyen esos rangos entre las zonas. Por ello, es menos sensible que ANOVA a la falta de normalidad y a los valores extremos.

Su aplicación se justifica porque los datos presentan asimetría, empates, valores extremos, tamaños muestrales desiguales e incumplimiento de normalidad. Además, existen cuatro grupos, por lo que una prueba de Mann-Whitney no sería suficiente como contraste global.

## Hipótesis

Para magnitud y profundidad se plantean las mismas hipótesis generales:

$$
H_0:\text{ las cuatro zonas presentan la misma distribución.}
$$

$$
H_1:\text{ al menos una zona presenta una distribución diferente.}
$$

Debido a que las formas y dispersiones no son iguales entre zonas, la prueba debe interpretarse como una comparación de distribuciones o rangos y no exclusivamente como una prueba de igualdad de medianas.

## Grados de libertad

Los grados de libertad se calculan como:

$$
gl=k-1,
$$

donde $k$ es el número de grupos. Como se comparan cuatro zonas:

$$
gl=4-1=3.
$$

Por eso los resultados se expresan como $H(3)$: $H$ es el estadístico de Kruskal-Wallis y el 3 entre paréntesis corresponde a sus grados de libertad.

## Resultado para magnitud

La comparación global produjo:

$$
H(3)=8{,}324,
\qquad p=0{,}0398.
$$

Con $\alpha=0{,}05$, se rechaza la igualdad global de las distribuciones de magnitud. Por tanto, existe evidencia de que al menos una zona difiere de otra.

Sin embargo, la evidencia es relativamente débil: el resultado sería significativo con $\alpha=0{,}05$, pero no con $\alpha=0{,}01$. Además, las medianas observadas son cercanas, entre 6,6 y 6,8. Esto hace necesario complementar el valor p con un tamaño de efecto y un análisis de sensibilidad. Descriptivamente, la Dorsal Meso-Atlántica parece concentrar magnitudes algo menores, pero Kruskal-Wallis todavía no permite atribuir formalmente la diferencia a ese par o zona.

## Resultado para profundidad

La comparación global produjo:

$$
H(3)=69{,}498,
\qquad p<0{,}001.
$$

Se rechaza claramente la igualdad global de las distribuciones de profundidad. La evidencia es mucho más fuerte y estable que para magnitud frente a los niveles de significación convencionales.

El resultado es coherente con el resumen descriptivo: el Cinturón de Fuego presenta una profundidad central mayor, Resto del mundo posee la mayor dispersión y la Dorsal Meso-Atlántica concentra gran parte de sus observaciones en 10 km.

## Alcance y paso posterior

Kruskal-Wallis es una prueba global. Un resultado significativo indica que existe alguna diferencia, pero no identifica cuáles pares de zonas difieren. Esa identificación requiere comparaciones post-hoc de Dunn con corrección por multiplicidad.

Antes de interpretar los pares, debe calcularse el tamaño de efecto global, ya que un valor p pequeño no demuestra que la diferencia sea sustantivamente importante. Esto es especialmente relevante para magnitud, donde la muestra grande puede hacer detectable una diferencia práctica muy pequeña.

## Papel dentro del hilo conductor

Kruskal-Wallis conecta el análisis exploratorio del Informe 1 con la inferencia del Informe 2: convierte las diferencias visuales y descriptivas en comparaciones estadísticas formales. Posteriormente, el modelo de clasificación abordará una pregunta distinta y complementaria: si magnitud y profundidad, consideradas conjuntamente, permiten predecir la zona de un evento.

## Redacción sugerida

> La prueba de Kruskal-Wallis evidenció diferencias globales en las distribuciones de magnitud, $H(3)=8{,}324$, $p=0{,}0398$, y profundidad, $H(3)=69{,}498$, $p<0{,}001$, entre las zonas. La evidencia fue considerablemente más fuerte para profundidad. Debido a la heterogeneidad en las formas y dispersiones, los resultados se interpretan como diferencias de distribución o rangos y no exclusivamente de medianas. La prueba global no identifica los pares responsables, por lo que se complementará con tamaños de efecto y comparaciones post-hoc ajustadas.

# Tamaño de efecto epsilon cuadrado

## Propósito

El valor p de Kruskal-Wallis permite evaluar si existe evidencia estadística de diferencias entre zonas, pero no indica cuán importantes son esas diferencias. El coeficiente epsilon cuadrado, $\varepsilon^2$, complementa la prueba cuantificando la intensidad de la asociación entre la zona y los rangos de la variable analizada.

En este análisis se calculó mediante `rcompanion::epsilonSquared()`. Esta función utiliza la definición equivalente al coeficiente de determinación obtenido al aplicar un análisis de varianza sobre los rangos. Por ello, los porcentajes se refieren a variabilidad de los rangos y no directamente a la varianza de los valores originales de magnitud o profundidad.

Como guía orientativa se consideran los siguientes intervalos:

- Menor que 0,01: efecto prácticamente nulo.
- Desde 0,01 hasta menos de 0,08: efecto pequeño.
- Desde 0,08 hasta menos de 0,26: efecto moderado.
- Desde 0,26: efecto grande.

Estos límites son referencias interpretativas y no fronteras universales o absolutas.

## Resultado para magnitud

Se obtuvo:

$$
\varepsilon^2=0{,}00702.
$$

El efecto es prácticamente nulo. La zona se asocia aproximadamente con el 0,7 % de la variabilidad de los rangos de magnitud. Por tanto, aunque Kruskal-Wallis produjo un resultado significativo con $p=0{,}0398$, la diferencia detectada tiene muy poca relevancia práctica.

Este resultado muestra que una muestra grande puede permitir detectar diferencias estadísticas muy pequeñas. En consecuencia, no debe afirmarse que las zonas presentan magnitudes sustantivamente distintas basándose solamente en el valor p.

## Resultado para profundidad

Se obtuvo:

$$
\varepsilon^2=0{,}0586.
$$

El efecto es pequeño. La zona se asocia aproximadamente con el 5,9 % de la variabilidad de los rangos de profundidad. El efecto es claramente mayor que el observado para magnitud, aunque todavía existe una superposición considerable entre las distribuciones de profundidad de las zonas.

El valor p extremadamente pequeño de Kruskal-Wallis evidencia que la diferencia es difícil de atribuir al azar, mientras que $\varepsilon^2$ muestra que su magnitud global continúa siendo pequeña. Ambos resultados responden preguntas distintas y deben interpretarse conjuntamente.

## Conclusión metodológica

Los resultados permiten distinguir significación estadística de importancia práctica:

- Magnitud: diferencia estadísticamente detectable, pero efecto prácticamente nulo.
- Profundidad: diferencia estadística muy clara y efecto pequeño.

El análisis post-hoc de Dunn permitirá identificar qué pares de zonas presentan diferencias, pero sus valores p también deberán complementarse con tamaños de efecto por pares para evitar conclusiones exageradas.

## Redacción sugerida

> Los tamaños de efecto mostraron que la diferencia global fue prácticamente nula para magnitud ($\varepsilon^2=0{,}007$) y pequeña para profundidad ($\varepsilon^2=0{,}059$). En consecuencia, aunque Kruskal-Wallis detectó diferencias estadísticamente significativas en ambas variables, la importancia práctica fue reducida, especialmente para magnitud. Esto evidencia la necesidad de interpretar conjuntamente los valores p y los tamaños de efecto.

# Comparaciones post-hoc de Dunn

## Propósito

La prueba de Kruskal-Wallis permite determinar si existe alguna diferencia global entre las cuatro zonas, pero no identifica cuáles zonas difieren entre sí. La prueba post-hoc de Dunn se aplica después de un resultado global significativo para localizar los pares responsables de esa diferencia.

En este análisis responde preguntas como:

- ¿Difiere el Cinturón de Fuego de Resto del mundo?
- ¿Difiere el Cinturón de Fuego de la Dorsal Meso-Atlántica?
- ¿Difiere el Cinturón Alpino-Himalayo de la Dorsal Meso-Atlántica?

## Funcionamiento

Dunn utiliza los mismos rangos globales empleados por Kruskal-Wallis. Para cada par de zonas compara sus rangos promedio y calcula un estadístico estandarizado $Z$, considerando el tamaño de los grupos y la presencia de empates.

Para cada comparación se plantean las hipótesis:

$$
H_0:\text{ las dos zonas presentan la misma distribución de rangos.}
$$

$$
H_1:\text{ las distribuciones de rangos de las dos zonas difieren.}
$$

Con cuatro zonas existen seis comparaciones posibles:

1. Cinturón de Fuego frente a Resto del mundo.
2. Cinturón de Fuego frente a Cinturón Alpino-Himalayo.
3. Cinturón de Fuego frente a Dorsal Meso-Atlántica.
4. Resto del mundo frente a Cinturón Alpino-Himalayo.
5. Resto del mundo frente a Dorsal Meso-Atlántica.
6. Cinturón Alpino-Himalayo frente a Dorsal Meso-Atlántica.

## Ajuste de Holm

Realizar seis pruebas simultáneas aumenta la probabilidad de declarar alguna diferencia significativa solamente por azar. Para controlar este error familiar se utilizará el ajuste de Holm.

El procedimiento ordena los valores p y aplica una corrección progresiva. Controla el error de tipo I familiar y suele conservar más potencia que la corrección simple de Bonferroni. Las decisiones inferenciales deben basarse en los valores p ajustados y no en los valores p originales.

## Información entregada

Para cada par de zonas, el análisis proporcionará:

- Las zonas comparadas.
- El estadístico estandarizado $Z$.
- El valor p sin ajustar.
- El valor p ajustado mediante Holm.

El signo de $Z$ puede orientar sobre la dirección de los rangos, pero la interpretación sustantiva debe apoyarse también en las medianas y los cuartiles de cada zona.

## Limitaciones

Dunn permite identificar qué pares presentan evidencia de diferencia, pero no cuantifica por sí solo la magnitud práctica de esas diferencias. Por ello, sus resultados deben complementarse con tamaños de efecto por pares, como delta de Cliff.

Además, debido a que las formas y dispersiones difieren entre zonas, las comparaciones se interpretan en términos de distribuciones o rangos y no exclusivamente como diferencias de medianas.

## Secuencia metodológica

La secuencia de análisis queda definida de la siguiente manera:

1. Kruskal-Wallis detecta si existe una diferencia global.
2. Epsilon cuadrado cuantifica el tamaño del efecto global.
3. Dunn-Holm identifica cuáles pares difieren.
4. Delta de Cliff cuantifica la magnitud y dirección de cada diferencia por pares.

Como Kruskal-Wallis fue significativo para magnitud y profundidad, Dunn-Holm se aplicará a ambas variables. No obstante, los resultados de magnitud deberán interpretarse con especial cautela porque su tamaño de efecto global fue prácticamente nulo.

## Resultados de Dunn-Holm para magnitud

Se identificaron diferencias significativas en dos de los seis pares:

- Cinturón de Fuego frente a Dorsal Meso-Atlántica: $Z=2{,}713$, $p_{aj}=0{,}0333$.
- Resto del mundo frente a Dorsal Meso-Atlántica: $Z=2{,}877$, $p_{aj}=0{,}0241$.

No se detectaron diferencias significativas en los demás pares:

- Cinturón de Fuego frente a Resto del mundo: $p_{aj}=1{,}000$.
- Cinturón de Fuego frente a Cinturón Alpino-Himalayo: $p_{aj}=0{,}888$.
- Resto del mundo frente a Cinturón Alpino-Himalayo: $p_{aj}=1{,}000$.
- Cinturón Alpino-Himalayo frente a Dorsal Meso-Atlántica: $p_{aj}=0{,}0705$.

Los signos de $Z$ y el resumen descriptivo indican que la Dorsal Meso-Atlántica presenta rangos de magnitud menores que el Cinturón de Fuego y Resto del mundo. Sin embargo, el tamaño de efecto global fue prácticamente nulo, $\varepsilon^2=0{,}007$, por lo que estas diferencias no deben describirse como grandes o sustantivas.

La comparación entre el Cinturón Alpino-Himalayo y la Dorsal produjo $p_{aj}=0{,}0705$: no es significativa bajo el criterio inferencial previamente establecido de $\alpha=0{,}05$. Su conclusión cambiaría si se adoptara $\alpha=0{,}10$, lo que refuerza la necesidad de mantener el umbral definido de antemano y complementar el valor p con tamaños de efecto.

## Resultados de Dunn-Holm para profundidad

Se identificaron diferencias significativas en cinco de los seis pares:

- Cinturón de Fuego frente a Resto del mundo: $Z=3{,}965$, $p_{aj}=0{,}000294$.
- Cinturón de Fuego frente a Cinturón Alpino-Himalayo: $Z=3{,}552$, $p_{aj}=0{,}000764$.
- Cinturón de Fuego frente a Dorsal Meso-Atlántica: $Z=7{,}020$, $p_{aj}<0{,}001$.
- Resto del mundo frente a Dorsal Meso-Atlántica: $Z=5{,}154$, $p_{aj}<0{,}001$.
- Cinturón Alpino-Himalayo frente a Dorsal Meso-Atlántica: $Z=3{,}893$, $p_{aj}=0{,}000297$.

La única comparación no significativa fue Resto del mundo frente al Cinturón Alpino-Himalayo, con $Z=1{,}073$ y $p_{aj}=0{,}283$.

El patrón de rangos puede resumirse como:

$$
\text{Cinturón de Fuego}>
\{\text{Resto del mundo, Cinturón Alpino-Himalayo}\}>
\text{Dorsal Meso-Atlántica}.
$$

El Cinturón de Fuego presenta rangos de profundidad mayores; Resto del mundo y el Cinturón Alpino-Himalayo no difieren formalmente entre sí; y la Dorsal Meso-Atlántica presenta los rangos más bajos. Este orden describe una tendencia distributiva y no implica que todos los eventos de una zona sean más profundos que los de otra.

## Conclusión conjunta de Dunn-Holm

Las diferencias de magnitud se concentran en comparaciones que incluyen a la Dorsal Meso-Atlántica, pero su relevancia práctica global es mínima. En profundidad, las diferencias son más sistemáticas: el Cinturón de Fuego concentra eventos relativamente más profundos y la Dorsal los más superficiales.

El siguiente paso es calcular delta de Cliff para los pares protagonistas definidos en el checklist —Cinturón de Fuego frente a Dorsal Meso-Atlántica y Cinturón de Fuego frente a Cinturón Alpino-Himalayo— en magnitud y profundidad.

## Redacción sugerida para Dunn-Holm

> Las comparaciones post-hoc de Dunn con ajuste de Holm mostraron que las diferencias de magnitud se concentraron entre la Dorsal Meso-Atlántica y el Cinturón de Fuego ($p_{aj}=0{,}033$), y entre la Dorsal y Resto del mundo ($p_{aj}=0{,}024$). No obstante, el tamaño de efecto global de magnitud fue prácticamente nulo. Para profundidad, el Cinturón de Fuego presentó rangos mayores que las otras zonas, mientras que la Dorsal presentó rangos menores. Resto del mundo y el Cinturón Alpino-Himalayo no difirieron entre sí ($p_{aj}=0{,}283$). En conjunto, las diferencias fueron más consistentes para profundidad que para magnitud.

# Tamaño de efecto por pares: delta de Cliff

## Definición y propósito

Delta de Cliff, representado por $\delta$, es un tamaño de efecto no paramétrico que cuantifica cuánto se separan dos distribuciones y en qué dirección ocurre esa separación. Su propósito no es decidir si una diferencia es estadísticamente significativa, sino evaluar con qué frecuencia los valores de una zona tienden a ser mayores que los de otra.

Se define como:

$$
\delta=P(X>Y)-P(X<Y).
$$

Para calcularlo se compara cada observación del primer grupo con cada observación del segundo. Se obtiene la proporción de pares en los que el primer grupo presenta un valor mayor y se resta la proporción de pares en los que presenta un valor menor. Los empates no favorecen a ninguno de los grupos.

## Interpretación del signo

El coeficiente varía entre $-1$ y $1$:

- $\delta=1$: todos los valores del primer grupo son mayores que los del segundo.
- $\delta=-1$: todos los valores del primer grupo son menores.
- $\delta=0$: no existe predominio de un grupo sobre el otro.
- $\delta>0$: el primer grupo tiende a presentar valores mayores.
- $\delta<0$: el segundo grupo tiende a presentar valores mayores.

La dirección depende del orden en que se entregan los grupos. En este informe se utilizará siempre el Cinturón de Fuego como primer grupo. Por tanto, un delta positivo indicará que Fuego tiende a presentar magnitudes o profundidades mayores que la zona comparada.

## Interpretación de la magnitud

La intensidad se evalúa mediante el valor absoluto $|\delta|$:

- Menor que 0,147: efecto despreciable.
- Desde 0,147 hasta 0,329: efecto pequeño.
- Desde 0,330 hasta 0,473: efecto moderado.
- Desde 0,474: efecto grande.

El signo entrega la dirección y el valor absoluto entrega la magnitud. Estos puntos de corte son referencias orientativas y no límites universales.

## Pertinencia para los datos

Delta de Cliff es apropiado porque no requiere normalidad y es resistente frente a asimetría y valores extremos. También puede emplearse con tamaños muestrales desiguales y admite empates, condición especialmente relevante para la profundidad de la Dorsal Meso-Atlántica.

No debe interpretarse únicamente como una diferencia de medianas. Dos grupos pueden presentar medianas semejantes y, aun así, mostrar cierto predominio distributivo debido a diferencias en la forma, dispersión o colas.

## Relación con los análisis anteriores

Cada procedimiento responde una pregunta complementaria:

- Kruskal-Wallis: ¿existe alguna diferencia entre las cuatro zonas?
- Epsilon cuadrado: ¿cuál es el tamaño de la diferencia global?
- Dunn-Holm: ¿qué pares presentan evidencia de diferencia?
- Delta de Cliff: ¿cuánto difiere cada par y en qué dirección?

En este informe se aplicará a los pares definidos en el checklist: Cinturón de Fuego frente a Dorsal Meso-Atlántica y Cinturón de Fuego frente a Cinturón Alpino-Himalayo, tanto para magnitud como para profundidad. Esto permitirá determinar si las diferencias estadísticas detectadas poseen también importancia práctica.

## Resultados para magnitud

### Cinturón de Fuego frente a Dorsal Meso-Atlántica

Se obtuvo:

$$
\delta=0{,}298,
\qquad IC_{95\%}=[0{,}114;\ 0{,}463].
$$

El efecto puntual es pequeño y positivo. Esto indica que los eventos del Cinturón de Fuego tienden a presentar magnitudes mayores que los de la Dorsal Meso-Atlántica. El intervalo de confianza no incluye cero, resultado coherente con la diferencia identificada por Dunn-Holm, $p_{aj}=0{,}033$.

Aunque el extremo superior del intervalo alcanza valores compatibles con un efecto moderado, la estimación central continúa siendo pequeña y debe interpretarse junto con el tamaño de efecto global prácticamente nulo de magnitud.

### Cinturón de Fuego frente a Cinturón Alpino-Himalayo

Se obtuvo:

$$
\delta=-0{,}011,
\qquad IC_{95\%}=[-0{,}159;\ 0{,}137].
$$

El efecto es despreciable y prácticamente igual a cero. No existe predominio distributivo relevante entre ambas zonas respecto de la magnitud. El intervalo incluye cero y el resultado coincide con la ausencia de diferencia detectada por Dunn-Holm, $p_{aj}=0{,}888$.

## Resultados para profundidad

### Cinturón de Fuego frente a Dorsal Meso-Atlántica

Se obtuvo:

$$
\delta=0{,}783,
\qquad IC_{95\%}=[0{,}679;\ 0{,}856].
$$

El efecto es grande y positivo. Los eventos del Cinturón de Fuego tienden claramente a presentar profundidades mayores que los de la Dorsal Meso-Atlántica. El intervalo completo permanece dentro de la categoría de efecto grande, por lo que esta es la separación práctica más importante identificada en las comparaciones estudiadas.

### Cinturón de Fuego frente a Cinturón Alpino-Himalayo

Se obtuvo:

$$
\delta=0{,}269,
\qquad IC_{95\%}=[0{,}109;\ 0{,}416].
$$

El efecto puntual es pequeño y positivo. El Cinturón de Fuego tiende a presentar eventos más profundos que el Cinturón Alpino-Himalayo. No obstante, el intervalo refleja incertidumbre en la magnitud: abarca desde un efecto despreciable hasta uno moderado. Su dirección positiva es consistente con Dunn-Holm, que detectó diferencias entre ambas zonas.

## Relación entre el efecto global y los efectos por pares

El efecto global de profundidad fue pequeño, $\varepsilon^2=0{,}059$, mientras que delta de Cliff mostró un efecto grande entre Fuego y Dorsal. Estos resultados no son contradictorios:

- Epsilon cuadrado resume simultáneamente las diferencias entre las cuatro zonas.
- Delta de Cliff examina exclusivamente una comparación entre dos zonas.

Una separación intensa en un par específico puede diluirse al calcular una medida global que incluye grupos con mayor superposición, como Resto del mundo y el Cinturón Alpino-Himalayo.

Para las decisiones inferenciales por pares se mantienen los valores p ajustados de Dunn-Holm. Los intervalos de delta de Cliff se utilizan para describir la dirección, magnitud e incertidumbre del tamaño de efecto, no para reemplazar el control de multiplicidad aplicado en Dunn.

## Conclusión conjunta

La magnitud diferencia poco las zonas estudiadas: solamente aparece un efecto pequeño entre el Cinturón de Fuego y la Dorsal, mientras que Fuego y el Cinturón Alpino-Himalayo presentan distribuciones prácticamente equivalentes. La profundidad posee mayor capacidad discriminante, especialmente entre Fuego y Dorsal, donde el efecto es grande.

## Redacción sugerida

> Los tamaños de efecto por pares mostraron una diferencia pequeña de magnitud entre el Cinturón de Fuego y la Dorsal Meso-Atlántica ($\delta=0{,}298$; $IC_{95\%}[0{,}114;0{,}463]$), y una diferencia despreciable entre Fuego y el Cinturón Alpino-Himalayo ($\delta=-0{,}011$; $IC_{95\%}[-0{,}159;0{,}137]$). Para profundidad, la separación fue grande entre Fuego y Dorsal ($\delta=0{,}783$; $IC_{95\%}[0{,}679;0{,}856]$) y pequeña entre Fuego y el Cinturón Alpino-Himalayo ($\delta=0{,}269$; $IC_{95\%}[0{,}109;0{,}416]$). En consecuencia, la profundidad presentó mayor capacidad para diferenciar las zonas que la magnitud.
