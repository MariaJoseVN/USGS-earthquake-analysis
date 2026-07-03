# Ayuda memoria: Fase 5 — Eventos fuertes y extremos

## Propósito de la fase

La Fase 5 estudia si la composición de eventos fuertes y extremos difiere entre las zonas sísmicas definidas en el Informe Asesoría 1. Mantiene las categorías originales de magnitud:

- **Fuerte:** $6{,}5 \leq M < 7{,}0$.
- **Mayor:** $7{,}0 \leq M < 7{,}8$.
- **Grande o extremo:** $M \geq 7{,}8$.

El análisis contempla cuatro componentes:

1. Tabla de contingencia entre zona y categoría de magnitud.
2. Regresión logística para modelar la probabilidad de que un evento alcance $M \geq 7{,}0$.
3. Comparación entre profundidad continua y profundidad categórica como explicadoras.
4. Descripción de los eventos $M \geq 7{,}8$ mediante conteos y tasas, sin ajustar un modelo cuando las frecuencias por zona sean insuficientes.

## Base de trabajo

La base preparada se carga desde el script raíz, sin modificarlo:

```r
source(file.path("Scripts", "00_preparacion_base.R"))
```

Para esta fase se crea el objeto `base_fase5`, que contiene únicamente las variables necesarias:

```r
base_fase5 <- sismos %>%
  dplyr::select(
    zona,
    mag,
    depth,
    magnitud_cat,
    profundidad_cat
  )
```

### Función de cada variable

- `zona`: variable de agrupación y explicadora categórica de la logística.
- `mag`: permite construir el indicador `evento_mayor` y seleccionar eventos extremos.
- `depth`: profundidad continua para el primer modelo logístico.
- `magnitud_cat`: categorías heredadas del Informe Asesoría 1 para la tabla de contingencia.
- `profundidad_cat`: alternativa categórica a `depth` en la regresión logística.

Se utiliza `dplyr::select()` en lugar de `select()` porque otros paquetes cargados durante la preparación pueden enmascarar esa función. El prefijo `dplyr::` asegura que R utilice la función correcta.

## Zona como factor

La variable `zona` se convierte en factor con el siguiente orden:

```r
base_fase5 <- base_fase5 %>%
  mutate(
    zona = factor(
      zona,
      levels = c(
        "Cinturon de Fuego",
        "Resto del mundo",
        "Cinturon Alpino-Himalayo",
        "Dorsal Meso-Atlantica"
      )
    )
  )
```

Esta conversión cumple dos funciones:

1. Mantiene un orden estable en las tablas y resultados.
2. Define al Cinturón de Fuego como categoría de referencia en la regresión logística.

En el modelo, los coeficientes y odds ratios de las demás zonas se interpretarán respecto del Cinturón de Fuego. Esto permite una lectura consistente con las fases anteriores, donde Fuego es la zona de mayor frecuencia y tamaño muestral.

## Tabla de contingencia entre zona y categoría de magnitud

### Propósito

La tabla de contingencia permite observar cómo se distribuyen las categorías "Fuerte", "Mayor" y "Grande o extremo" dentro de cada zona. Su pregunta sustantiva es:

> ¿La composición de severidad de los eventos es semejante en todas las zonas o algunas concentran proporcionalmente más eventos mayores y extremos?

La tabla no busca volver a comparar el número total de terremotos, porque esa frecuencia ya fue estudiada en la Fase 2. Aquí interesa la **composición relativa** de las categorías de magnitud dentro de cada zona.

Los conteos observados se construyen mediante:

```r
tabla_zona_magnitud <- table(
  zona = base_fase5$zona,
  categoria = base_fase5$magnitud_cat
)

tabla_zona_magnitud
addmargins(tabla_zona_magnitud)
```

Cada celda contiene el número de eventos que pertenece simultáneamente a una zona y a una categoría de magnitud. `addmargins()` muestra los totales por fila y columna para facilitar la lectura, pero no modifica el objeto utilizado en las pruebas.

### Relación con la prueba chi-cuadrado

La tabla observada es necesaria para evaluar posteriormente la independencia entre `zona` y `magnitud_cat`:

$$
H_0:\text{ la distribución de categorías de magnitud es independiente de la zona.}
$$

$$
H_1:\text{ existe asociación entre la zona y la categoría de magnitud.}
$$

Bajo independencia se calcularán frecuencias esperadas a partir de los totales marginales. La comparación entre frecuencias observadas y esperadas permitirá determinar si algunas combinaciones aparecen con mayor o menor frecuencia que la prevista si ambas variables fueran independientes.

La revisión de las frecuencias esperadas también cumple una función diagnóstica: si existen celdas esperadas menores que 5, la aproximación chi-cuadrado asintótica puede ser inadecuada. Por esa razón, el checklist establece utilizar un valor p mediante simulación Monte Carlo con 10.000 réplicas.

### Frecuencias observadas

La tabla obtenida fue:

| Zona | Fuerte | Mayor | Grande o extremo | Total |
|---|---:|---:|---:|---:|
| Cinturón de Fuego | 597 | 248 | 47 | 892 |
| Resto del mundo | 134 | 59 | 10 | 203 |
| Cinturón Alpino-Himalayo | 43 | 18 | 2 | 63 |
| Dorsal Meso-Atlántica | 25 | 3 | 0 | 28 |

Los conteos absolutos están dominados por el tamaño desigual de las zonas, especialmente por los 892 eventos del Cinturón de Fuego. Por ello, no deben compararse directamente sin calcular proporciones dentro de cada zona.

De manera preliminar, el Cinturón de Fuego, Resto del mundo y el Cinturón Alpino-Himalayo presentan composiciones semejantes. La Dorsal Meso-Atlántica concentra 25 de sus 28 eventos en la categoría Fuerte, registra solamente 3 eventos Mayores y ningún evento Grande o extremo.

Esta diferencia es únicamente descriptiva. Debido al reducido tamaño de la Dorsal, debe evaluarse mediante porcentajes, frecuencias esperadas, chi-cuadrado por simulación y V de Cramér antes de formular una conclusión.

### Porcentajes dentro de cada zona

Los conteos absolutos no permiten comparar directamente la composición de las zonas porque sus tamaños muestrales son muy diferentes. Por ejemplo, el Cinturón de Fuego registra muchos más eventos en todas las categorías principalmente porque contiene 892 observaciones, mientras que la Dorsal posee solamente 28.

Para eliminar ese efecto de escala se calculan porcentajes por fila:

```r
porcentaje_zona_magnitud <- prop.table(
  tabla_zona_magnitud,
  margin = 1
) * 100

round(porcentaje_zona_magnitud, 1)
```

El argumento `margin = 1` indica que la normalización se realiza dentro de cada fila, es decir, dentro de cada zona. De este modo, las tres categorías suman 100 % para cada zona.

Estos porcentajes responden una pregunta diferente de los conteos absolutos:

> Si se selecciona un evento dentro de una zona determinada, ¿qué proporción corresponde a cada categoría de magnitud?

La comparación porcentual permite identificar patrones de composición, pero continúa siendo descriptiva. La prueba chi-cuadrado evaluará posteriormente si las diferencias observadas son mayores que las esperables bajo independencia, mientras que V de Cramér medirá la intensidad de la asociación.

### Resultados porcentuales observados

Los porcentajes dentro de cada zona fueron:

| Zona | Fuerte | Mayor | Grande o extremo |
|---|---:|---:|---:|
| Cinturón de Fuego | 66,9 % | 27,8 % | 5,3 % |
| Resto del mundo | 66,0 % | 29,1 % | 4,9 % |
| Cinturón Alpino-Himalayo | 68,3 % | 28,6 % | 3,2 % |
| Dorsal Meso-Atlántica | 89,3 % | 10,7 % | 0,0 % |

El Cinturón de Fuego, Resto del mundo y el Cinturón Alpino-Himalayo presentan composiciones muy semejantes: aproximadamente dos tercios de sus eventos son Fuertes, cerca de 28 % son Mayores y menos de 6 % son Grandes o extremos.

La Dorsal Meso-Atlántica presenta un patrón distinto: 89,3 % de sus eventos son Fuertes, 10,7 % son Mayores y no se observan eventos Grandes o extremos. Si se agrupan las categorías Mayor y Grande o extremo, los eventos $M \geq 7{,}0$ representan aproximadamente un tercio en las tres primeras zonas, pero solamente 10,7 % en la Dorsal.

Este resultado sugiere que la Dorsal concentra proporcionalmente magnitudes menores. Sin embargo, la conclusión continúa siendo descriptiva porque la zona contiene solamente 28 eventos. La ausencia observada de eventos extremos no demuestra que estos sean imposibles; la incertidumbre y las frecuencias esperadas deben examinarse antes de realizar inferencia.

## Frecuencias esperadas bajo independencia

Las frecuencias esperadas representan los conteos que deberían observarse en cada celda si la zona y la categoría de magnitud fueran independientes. Se calculan a partir de los totales marginales de filas y columnas.

Los valores obtenidos fueron:

| Zona | Fuerte | Mayor | Grande o extremo |
|---|---:|---:|---:|
| Cinturón de Fuego | 600,93 | 246,69 | 44,37 |
| Resto del mundo | 136,76 | 56,14 | 10,10 |
| Cinturón Alpino-Himalayo | 42,44 | 17,42 | 3,13 |
| Dorsal Meso-Atlántica | 18,86 | 7,74 | 1,39 |

Dos de las doce celdas presentan frecuencias esperadas menores que 5:

- Cinturón Alpino-Himalayo por Grande o extremo: 3,13.
- Dorsal Meso-Atlántica por Grande o extremo: 1,39.

Estas celdas representan 16,7 % del total y ninguna posee una frecuencia esperada menor que 1. Según la regla tradicional de Cochran, la aproximación asintótica no queda automáticamente descartada, ya que menos del 20 % de las celdas está bajo 5. Sin embargo, la escasez se concentra precisamente en las zonas pequeñas y existe una celda observada igual a cero.

Por esta razón se mantiene la decisión metodológica preestablecida de utilizar chi-cuadrado con valor p por simulación Monte Carlo. Esta elección evita depender exclusivamente de la aproximación asintótica y conserva coherencia con el checklist definido antes de observar los resultados.

La comparación descriptiva entre observados y esperados sugiere que la principal desviación se concentra en la Dorsal: se observaron 25 eventos Fuertes frente a 18,86 esperados, y solamente 3 eventos Mayores frente a 7,74 esperados. La prueba formal determinará si el conjunto de desviaciones entrega evidencia suficiente de asociación.

## Prueba chi-cuadrado con simulación Monte Carlo

### Propósito

La prueba chi-cuadrado de independencia permite determinar si las diferencias entre frecuencias observadas y esperadas son suficientemente grandes para respaldar una asociación entre la zona y la categoría de magnitud.

Las hipótesis son:

$$
H_0:\text{ la zona y la categoría de magnitud son independientes.}
$$

$$
H_1:\text{ existe asociación entre la zona y la categoría de magnitud.}
$$

Un rechazo de $H_0$ indicaría que la composición de eventos Fuertes, Mayores y Grandes o extremos no es igual en todas las zonas. No señalaría automáticamente qué celdas explican la asociación ni cuál es su importancia práctica.

### Por qué utilizar simulación

La prueba chi-cuadrado clásica aproxima la distribución del estadístico mediante una distribución chi-cuadrado teórica. Esa aproximación funciona mejor cuando las frecuencias esperadas son suficientemente grandes.

En esta tabla existen dos frecuencias esperadas menores que 5 y una celda observada igual a cero. Aunque la regla tradicional no queda completamente incumplida, la simulación Monte Carlo entrega una estimación del valor p menos dependiente de la aproximación asintótica y respeta la política metodológica definida antes de observar los resultados.

El bloque propuesto es:

```r
set.seed(2026)

chi_montecarlo <- chisq.test(
  tabla_zona_magnitud,
  simulate.p.value = TRUE,
  B = 10000
)

chi_montecarlo
```

### Funcionamiento de la simulación

R genera 10.000 tablas compatibles con los mismos totales marginales bajo la hipótesis de independencia. Para cada tabla calcula el estadístico chi-cuadrado y compara esos valores con el estadístico observado.

El valor p simulado corresponde aproximadamente a la proporción de tablas generadas que presentan una discrepancia igual o mayor que la observada. Por tanto, no significa que la hipótesis nula tenga esa probabilidad de ser verdadera.

### Función de la semilla

`set.seed(2026)` fija el punto de inicio del generador de números pseudoaleatorios. Esto permite que el análisis produzca el mismo valor p simulado cada vez que se ejecute, favoreciendo la reproducibilidad.

### Número de simulaciones

El argumento `B = 10000` solicita 10.000 réplicas. Este número entrega una resolución mínima aproximada de $1/(10000+1)$ y un error Monte Carlo suficientemente reducido para la decisión planteada. El valor p debe reportarse como simulado, junto con el número de réplicas utilizadas.

La significación de la prueba deberá complementarse con V de Cramér corregida por sesgo, porque el valor p evalúa evidencia de asociación, pero no su intensidad.

### Resultado del chi-cuadrado Monte Carlo

La prueba produjo:

$$
X^2=7{,}122,
\qquad p_{MC}=0{,}3072,
$$

con 10.000 réplicas Monte Carlo.

Como el valor p simulado es mayor que $\alpha=0{,}05$, no se rechaza la hipótesis de independencia. En consecuencia, el catálogo no entrega evidencia estadística suficiente para afirmar que la composición de categorías de magnitud difiera entre zonas.

Este resultado no demuestra que las distribuciones sean idénticas. La Dorsal presenta descriptivamente una mayor proporción de eventos Fuertes, pero su tamaño muestral de 28 eventos genera incertidumbre y la desviación observada no basta para establecer una asociación global.

La salida muestra `df = NA` porque, al utilizar `simulate.p.value = TRUE`, R no obtiene el valor p desde una distribución chi-cuadrado teórica con grados de libertad fijos, sino desde la proporción de tablas simuladas con discrepancias iguales o mayores. Los grados de libertad teóricos de una tabla de cuatro filas y tres columnas serían:

$$
(4-1)(3-1)=6,
$$

pero no son los utilizados para calcular el valor p Monte Carlo.

La conclusión deberá complementarse con V de Cramér corregida por sesgo. Un efecto pequeño sería coherente con la falta de asociación global, mientras que un efecto apreciable con valor p no significativo podría indicar falta de precisión por los grupos pequeños.

## Tamaño de asociación: V de Cramér

### Propósito

V de Cramér cuantifica la intensidad de la asociación entre dos variables categóricas. Complementa al chi-cuadrado porque el valor p indica cuánta evidencia existe contra la independencia, mientras que V informa cuán fuerte es la asociación observada.

El coeficiente varía entre 0 y 1:

- Valores cercanos a 0 indican asociación débil o inexistente.
- Valores cercanos a 1 indican asociación intensa.

Se utiliza la versión corregida por sesgo:

```r
v_cramer_magnitud <- rcompanion::cramerV(
  tabla_zona_magnitud,
  bias.correct = TRUE
)
```

La corrección reduce la sobreestimación que puede aparecer por el tamaño y las dimensiones de la tabla, especialmente cuando existen grupos pequeños.

### Resultado

Se obtuvo:

$$
V=0{,}0217.
$$

El valor es muy cercano a cero y corresponde a una asociación prácticamente nula. Para una tabla cuyo menor número de grados de libertad dimensionales es 2, una referencia habitual sitúa un efecto pequeño alrededor de 0,07; el valor obtenido queda claramente por debajo.

La lectura conjunta es consistente:

- Chi-cuadrado Monte Carlo: $p=0{,}3072$, sin evidencia suficiente contra la independencia.
- V de Cramér corregida: $V=0{,}0217$, intensidad global prácticamente nula.

Por tanto, aunque la Dorsal presenta descriptivamente una proporción mayor de eventos Fuertes, el patrón global de categorías de magnitud es muy similar entre zonas y la diferencia observada posee poca relevancia práctica. Esta conclusión se limita al catálogo analizado y no implica que las zonas tengan probabilidades físicas exactamente iguales.

### Redacción sugerida

> La composición de categorías de magnitud no presentó una asociación estadísticamente detectable con la zona ($X^2=7{,}122$; $p_{MC}=0{,}307$, 10.000 réplicas), y el tamaño de asociación corregido por sesgo fue prácticamente nulo ($V=0{,}022$). Aunque la Dorsal Meso-Atlántica concentró descriptivamente una mayor proporción de eventos Fuertes, el patrón global no mostró diferencias sustantivas entre zonas.

## Variable binaria `evento_mayor`

### Propósito

Para la regresión logística se transforma la magnitud en una respuesta binaria:

```r
base_fase5 <- base_fase5 %>%
  mutate(
    evento_mayor = as.integer(mag >= 7.0)
  )
```

La codificación es:

- `0`: evento Fuerte, $6{,}5 \leq M < 7{,}0$.
- `1`: evento Mayor o Grande/extremo, $M \geq 7{,}0$.

La regresión logística modelará la probabilidad:

$$
P(\text{evento\_mayor}=1).
$$

### Conteos observados

| Zona | `0`: Fuerte | `1`: $M\geq7{,}0$ | Total |
|---|---:|---:|---:|
| Cinturón de Fuego | 597 | 295 | 892 |
| Resto del mundo | 134 | 69 | 203 |
| Cinturón Alpino-Himalayo | 43 | 20 | 63 |
| Dorsal Meso-Atlántica | 25 | 3 | 28 |

En total existen 799 eventos codificados como 0 y 387 eventos codificados como 1. Todas las zonas contienen ambos resultados, por lo que no existe separación completa causada únicamente por la variable `zona` y el modelo logístico estándar puede estimarse.

No obstante, la Dorsal posee solamente 3 eventos con $M\geq7{,}0$. Por esta razón, su coeficiente y odds ratio probablemente tendrán un intervalo de confianza amplio. Esa imprecisión debe conservarse y reportarse, no ocultarse.

### Por qué continuar con logística después del chi-cuadrado

El chi-cuadrado evaluó la asociación marginal entre cuatro zonas y tres categorías de magnitud. La regresión logística responde una pregunta distinta:

> ¿La zona y la profundidad, consideradas simultáneamente, explican la probabilidad de que un evento alcance $M\geq7{,}0$?

Además de agrupar las categorías Mayor y Grande o extremo, la logística ajusta el efecto de zona por profundidad. Por ello, una variable que muestra poca asociación marginal puede adquirir relevancia dentro del modelo múltiple, cuestión señalada por los profesores durante la revisión del Informe 1.

### Por qué se utiliza logística binaria y no multinomial

La regresión logística binaria de esta fase y la regresión multinomial propuesta para la Fase 6 responden preguntas diferentes.

En la Fase 5, la variable respuesta es `evento_mayor`:

$$
P(M\geq7{,}0\mid\text{zona, profundidad}).
$$

La pregunta es si la zona y la profundidad ayudan a explicar que un evento supere un umbral sísmicamente relevante. El resultado se interpreta mediante odds ratios de alcanzar $M\geq7{,}0$.

En la Fase 6, la variable respuesta será `zona`, que tiene cuatro categorías:

$$
P(\text{zona}\mid\text{magnitud, profundidad}).
$$

Esa es la regresión multinomial de clasificación sugerida por los profesores: evaluar si magnitud y profundidad permiten identificar la zona de un evento.

Podría plantearse técnicamente una multinomial con `magnitud_cat` como respuesta, pero no es la opción principal por tres razones:

1. Respondería otra pregunta: cuál de las tres categorías de magnitud presenta un evento, en lugar de si supera el umbral $M\geq7{,}0$.
2. La categoría Grande o extremo contiene solamente 59 eventos, con 2 en el Cinturón Alpino-Himalayo y 0 en la Dorsal. Esto puede generar estimaciones inestables y separación en un modelo multinomial estándar.
3. Las categorías de magnitud poseen un orden natural. Una multinomial nominal ignoraría ese orden; una regresión ordinal sería conceptualmente más apropiada, pero exigiría evaluar el supuesto de odds proporcionales y no forma parte del análisis mínimo definido.

Las tres categorías no se descartan: ya se utilizaron en la tabla de contingencia y la categoría Grande o extremo se describirá separadamente mediante conteos y tasas. La dicotomización se utiliza únicamente para construir un modelo estable y directamente interpretable del umbral $M\geq7{,}0$.

## Regresión logística con profundidad continua

El primer modelo se especifica como:

```r
modelo_logit_depth <- glm(
  evento_mayor ~ zona + depth,
  family = binomial(link = "logit"),
  data = base_fase5
)
```

El modelo estima el logaritmo de las odds de que un evento alcance $M\geq7{,}0$. El Cinturón de Fuego es la zona de referencia y `depth` se incorpora como variable continua, medida en kilómetros.

### Resultados iniciales

Los coeficientes estimados fueron:

| Término | Coeficiente | Error estándar | Valor p de Wald |
|---|---:|---:|---:|
| Intercepto | -0,7240 | 0,0790 | < 0,001 |
| Resto del mundo | 0,0317 | 0,1653 | 0,848 |
| Cinturón Alpino-Himalayo | -0,0512 | 0,2804 | 0,855 |
| Dorsal Meso-Atlántica | -1,3986 | 0,6159 | 0,023 |
| Profundidad | 0,000210 | 0,000375 | 0,575 |

La devianza nula fue 1498 y la devianza residual 1490, con AIC igual a 1500. La reducción de devianza es modesta, lo que anticipa una capacidad explicativa limitada del modelo.

### Lectura provisional

- Resto del mundo y el Cinturón Alpino-Himalayo presentan coeficientes cercanos a cero, por lo que sus odds estimadas son similares a las del Cinturón de Fuego al controlar por profundidad.
- La Dorsal presenta un coeficiente negativo, compatible con menores odds de alcanzar $M\geq7{,}0$ respecto de Fuego.
- El coeficiente de profundidad es positivo pero extremadamente pequeño y su p de Wald es alto, por lo que no se observa un aporte marginal claro en esta especificación.
- El intercepto representa las log-odds estimadas para un evento del Cinturón de Fuego con profundidad igual a 0 km; no constituye el foco sustantivo del análisis.

Esta interpretación todavía no es la conclusión formal. Los valores p mostrados por `summary()` corresponden a pruebas de Wald por coeficiente. La política metodológica del informe establece utilizar razones de verosimilitud por bloque mediante `drop1(..., test = "Chisq")`, porque `zona` contiene tres coeficientes y debe evaluarse globalmente como una sola variable.

El AIC tampoco se interpreta de manera aislada. Solo será útil al compararlo con el modelo alternativo que utiliza `profundidad_cat`.

## Razón de verosimilitud por variable

La significación de cada variable se evalúa eliminándola del modelo completo y comparando la pérdida de ajuste:

```r
lr_logit_depth <- drop1(
  modelo_logit_depth,
  test = "Chisq"
)
```

Los resultados fueron:

| Variable eliminada | gl | Devianza reducida | AIC reducido | LRT | Valor p |
|---|---:|---:|---:|---:|---:|
| Ninguna | — | 1490,0 | 1500,0 | — | — |
| `zona` | 3 | 1497,4 | 1501,4 | 7,358 | 0,0613 |
| `depth` | 1 | 1490,3 | 1498,3 | 0,312 | 0,5766 |

### Interpretación de `zona`

La prueba global de `zona` produjo $p=0{,}0613$. Como el criterio confirmatorio fue fijado en $\alpha=0{,}05$, no se rechaza la hipótesis de que los tres coeficientes de zona sean conjuntamente iguales a cero después de controlar por profundidad.

El resultado es cercano a 0,05, pero no debe reclasificarse como significativo utilizando retrospectivamente $\alpha=0{,}10$. Se reporta como evidencia débil o inconclusa, no como una diferencia confirmada.

El p de Wald igual a 0,023 observado para la Dorsal evaluaba exclusivamente ese coeficiente frente a Fuego. En cambio, `drop1()` evalúa a `zona` como una variable completa de tres grados de libertad. Para la conclusión global se prioriza la razón de verosimilitud definida en la política metodológica.

### Interpretación de profundidad

La profundidad continua produjo $LRT=0{,}312$ y $p=0{,}5766$. No existe evidencia de que una relación lineal entre profundidad y log-odds mejore el modelo después de controlar por zona.

Además, al retirar `depth`, el AIC disminuye desde 1500,0 hasta 1498,3. Esto indica que la pequeña mejora de ajuste no compensa el parámetro adicional. Sin embargo, todavía debe probarse `profundidad_cat`, porque una relación no lineal o por estratos podría no ser capturada por un único coeficiente continuo.

### Conclusión provisional

Con profundidad continua, ninguna variable presenta evidencia global al nivel de 0,05. La Dorsal mantiene una señal específica de menores odds, pero la evidencia global de zona es débil y la profundidad continua no aporta capacidad explicativa apreciable.

## Odds ratios del modelo con profundidad continua

Los coeficientes logísticos se transformaron mediante la función exponencial para obtener odds ratios con intervalos de confianza de perfil al 95 %:

```r
or_logit_depth <- exp(
  cbind(
    OR = coef(modelo_logit_depth),
    confint(modelo_logit_depth)
  )
)
```

Los resultados fueron:

| Término | OR | IC 95 % inferior | IC 95 % superior |
|---|---:|---:|---:|
| Intercepto | 0,485 | 0,415 | 0,565 |
| Resto del mundo | 1,032 | 0,744 | 1,423 |
| Cinturón Alpino-Himalayo | 0,950 | 0,538 | 1,625 |
| Dorsal Meso-Atlántica | 0,247 | 0,058 | 0,712 |
| Profundidad, por 1 km | 1,00021 | 0,99946 | 1,00094 |

### Interpretación por zona

- Resto del mundo presenta odds estimadas 3,2 % mayores que Fuego, pero el intervalo incluye 1 ampliamente. No existe evidencia de una diferencia específica.
- El Cinturón Alpino-Himalayo presenta odds estimadas 5,0 % menores que Fuego, con un intervalo también compatible con ausencia de diferencia.
- La Dorsal presenta un OR de 0,247: sus odds estimadas de alcanzar $M\geq7{,}0$ son aproximadamente 75,3 % menores que en Fuego, controlando profundidad. El intervalo es amplio debido a que solamente existen 3 eventos mayores en esta zona.

El intervalo de la Dorsal excluye 1, pero este es un contraste específico no ajustado entre Dorsal y Fuego. La prueba LR global de `zona`, que evalúa simultáneamente los tres coeficientes, produjo $p=0{,}0613$. Por coherencia con la política confirmatoria, no se declara un efecto global de zona; la Dorsal se describe como una señal específica que requiere interpretación prudente.

### Interpretación de profundidad

El OR de profundidad está expresado por un incremento de solamente 1 km, por lo que aparece extremadamente cercano a 1. La estimación corresponde aproximadamente a un aumento de 2,1 % en las odds por cada 100 km adicionales, pero su intervalo incluye ausencia de efecto y la prueba LR produjo $p=0{,}5766$.

En consecuencia, la profundidad continua no muestra un aporte apreciable para explicar la probabilidad de alcanzar $M\geq7{,}0$ en este modelo.

El intercepto representa las odds para un evento del Cinturón de Fuego a profundidad 0 km y no constituye una comparación sustantiva entre zonas.

## Regresión logística con profundidad categórica

El modelo alternativo reemplaza `depth` por las categorías heredadas del Informe 1:

```r
modelo_logit_depth_cat <- glm(
  evento_mayor ~ zona + profundidad_cat,
  family = binomial(link = "logit"),
  data = base_fase5
)
```

La categoría de profundidad omitida en la salida es `Intermedio`, por lo que los coeficientes `Profundo` y `Superficial` se interpretan respecto de eventos intermedios.

### Resultados iniciales

| Término | Coeficiente | Error estándar | Valor p de Wald |
|---|---:|---:|---:|
| Intercepto | -0,4914 | 0,1709 | 0,004 |
| Resto del mundo | 0,0626 | 0,1660 | 0,706 |
| Cinturón Alpino-Himalayo | -0,0789 | 0,2808 | 0,779 |
| Dorsal Meso-Atlántica | -1,3907 | 0,6161 | 0,024 |
| Profundo frente a Intermedio | -0,3342 | 0,2605 | 0,200 |
| Superficial frente a Intermedio | -0,2382 | 0,1831 | 0,193 |

La devianza residual fue 1488,3 y el AIC fue 1500,3. Ninguno de los dos contrastes individuales de profundidad presentó evidencia clara según Wald. La señal específica de la Dorsal se mantiene prácticamente igual a la observada en el modelo continuo.

El modelo categórico reduce algo más la devianza que el continuo, pero utiliza dos coeficientes de profundidad en lugar de uno. Como resultado, sus AIC son prácticamente idénticos: 1500,3 para profundidad categórica y 1500,0 para profundidad continua.

Una diferencia de AIC menor que 2 no constituye evidencia clara a favor de uno de los modelos. La elección debe considerar también la prueba LR global de profundidad, la parsimonia y la interpretabilidad. Todavía no corresponde seleccionar una versión definitiva.

## Comparación definitiva de las representaciones de profundidad

La prueba LR del modelo categórico produjo:

| Variable eliminada | gl | LRT | Valor p |
|---|---:|---:|---:|
| `zona` | 3 | 7,471 | 0,0583 |
| `profundidad_cat` | 2 | 2,063 | 0,3566 |

La profundidad categórica no mejora significativamente el modelo después de controlar por zona. La evidencia global de `zona` continúa siendo débil y no alcanza el nivel confirmatorio de 0,05.

La comparación por AIC fue:

| Modelo | Número de parámetros | AIC |
|---|---:|---:|
| Profundidad continua | 5 | 1500,012 |
| Profundidad categórica | 6 | 1500,261 |

La diferencia es:

$$
\Delta AIC=1500{,}261-1500{,}012=0{,}249.
$$

Una diferencia menor que 2 indica que ambos modelos poseen un respaldo prácticamente equivalente. No existe evidencia de que convertir profundidad en categorías capture una estructura que el término continuo esté omitiendo.

### Decisión metodológica

Se conserva el modelo con `depth` continua por tres razones:

1. Presenta el AIC ligeramente menor.
2. Utiliza un parámetro menos y, por tanto, es más parsimonioso.
3. Evita perder información mediante la categorización de una variable originalmente continua.

La elección de la versión continua no implica que profundidad sea una variable importante. Su prueba LR produjo $p=0{,}5766$ y su odds ratio fue prácticamente igual a 1. La conclusión sustantiva es que profundidad no aportó evidencia para explicar la probabilidad de $M\geq7{,}0$, ni como variable continua ni como variable categórica.

La profundidad se mantiene en el modelo principal para responder explícitamente la pregunta docente sobre su posible aporte dentro de un modelo múltiple. El resultado muestra que, en este caso, la relevancia que podía adquirir al combinarse con zona no se materializó.

### Redacción sugerida

> La profundidad no presentó un aporte significativo en la regresión logística, tanto en su forma continua ($LRT=0{,}312$; $p=0{,}577$) como categórica ($LRT=2{,}063$; $p=0{,}357$). Los modelos mostraron AIC prácticamente equivalentes ($\Delta AIC=0{,}249$), por lo que se conservó la especificación continua debido a su mayor parsimonia y a que evita la pérdida de información asociada a la categorización.

## Por qué los eventos $M\geq7{,}8$ se analizan sin otro modelo

En este contexto, "ajustar un modelo" significaría estimar una nueva regresión, por ejemplo una logística cuya respuesta fuera:

$$
I(M\geq7{,}8).
$$

Esa regresión intentaría estimar cómo cambian las odds de observar un evento Grande o extremo según zona y profundidad.

Sin embargo, la categoría contiene solamente 59 eventos en todo el catálogo:

- 47 en el Cinturón de Fuego.
- 10 en Resto del mundo.
- 2 en el Cinturón Alpino-Himalayo.
- 0 en la Dorsal Meso-Atlántica.

La presencia de solamente dos casos en una zona y ninguno en otra produciría estimaciones muy inestables. En particular, el cero de la Dorsal puede generar separación: el modelo intentaría estimar unas odds iguales a cero mediante un coeficiente que tiende a valores negativos extremos, acompañado de errores estándar e intervalos poco fiables.

Esto no significa que sea matemáticamente imposible ajustar alguna variante penalizada, sino que el tamaño y la distribución de la muestra no justifican convertirla en el análisis principal. Hacerlo agregaría complejidad sin entregar conclusiones estables.

Por esa razón, y siguiendo el punto 5.4 del checklist, para $M\geq7{,}8$ se reportarán únicamente:

- Conteos por zona.
- Tasas anuales por zona durante los 26 años observados.

El resultado será descriptivo. Un conteo igual a cero indica que no se observaron eventos extremos en esa zona dentro del catálogo y período analizados; no demuestra que su ocurrencia sea físicamente imposible.

### Resultados descriptivos para $M\geq7{,}8$

| Zona | Eventos extremos | Tasa anual |
|---|---:|---:|
| Cinturón de Fuego | 47 | 1,81 |
| Resto del mundo | 10 | 0,385 |
| Cinturón Alpino-Himalayo | 2 | 0,0769 |
| Dorsal Meso-Atlántica | 0 | 0 |

En total se observaron 59 eventos Grandes o extremos. El Cinturón de Fuego reunió 47, equivalentes a aproximadamente 79,7 % de esos eventos, y registró en promedio 1,81 por año. Resto del mundo presentó 10, el Cinturón Alpino-Himalayo 2 y la Dorsal ninguno.

La concentración absoluta en Fuego debe interpretarse junto con el desbalance general del catálogo: esta zona contiene 75,2 % de todos los eventos analizados. Por tanto, reunir cerca de 80 % de los extremos representa una sobrerrepresentación relativamente pequeña, coherente con el chi-cuadrado no significativo y la V de Cramér prácticamente nula.

Las tasas anuales presentadas son conteos brutos divididos por los 26 años observados. No están normalizadas por superficie y no representan tasas de amenaza ni probabilidades físicas para la población.

La ausencia de eventos $M\geq7{,}8$ en la Dorsal se limita al período 2000–2025 y al catálogo definido. No permite concluir que un evento extremo sea imposible en esa zona.

### Redacción sugerida

> Entre 2000 y 2025 se registraron 59 eventos de magnitud $M\geq7{,}8$. El Cinturón de Fuego concentró 47 eventos, con una tasa bruta de 1,81 por año; Resto del mundo registró 10, el Cinturón Alpino-Himalayo 2 y la Dorsal Meso-Atlántica ninguno. Esta concentración refleja en gran medida el predominio muestral del Cinturón de Fuego y no se acompañó de una asociación global sustantiva entre zona y categoría de magnitud.

# Verificación del checkpoint C6

## Resultado esperado de la logística

El checklist anticipaba un odds ratio bajo para la Dorsal, con un intervalo amplio, y planteaba el efecto de profundidad como la incógnita central.

Los resultados fueron coherentes con esa expectativa:

- Dorsal frente a Fuego: $OR=0{,}247$; $IC_{95\%}[0{,}058;0{,}712]$.
- La Dorsal presenta odds estimadas aproximadamente 75,3 % menores de alcanzar $M\geq7{,}0$.
- El intervalo es amplio en escala multiplicativa, reflejando que la Dorsal contiene solamente 3 eventos con resultado 1.
- Profundidad continua: $LRT=0{,}312$; $p=0{,}577$; $OR=1{,}00021$ por km.
- Profundidad categórica: $LRT=2{,}063$; $p=0{,}357$.

Por tanto, profundidad no adquirió relevancia al integrarse con zona. Este resultado responde de forma directa a la observación docente: su posible aporte conjunto fue evaluado, pero no se materializó en estos datos.

## Componentes del checkpoint

| Componente exigido | Resultado | Estado |
|---|---|---|
| Tabla observada `zona x magnitud_cat` | 4 zonas por 3 categorías | Completo |
| Frecuencias esperadas | 2 de 12 celdas bajo 5 | Completo |
| Chi-cuadrado Monte Carlo | $X^2=7{,}122$; $p=0{,}3072$; 10.000 réplicas | Completo |
| V de Cramér corregida | $V=0{,}0217$ | Completo |
| Coeficientes logísticos | Modelos continuo y categórico | Completo |
| OR e IC 95 % | Modelo continuo elegido | Completo |
| LR por variable | Ambos modelos | Completo |
| AIC de ambas versiones | 1500,012 frente a 1500,261 | Completo |
| Conteos y tasas de $M\geq7{,}8$ | 47 / 10 / 2 / 0 | Completo |

El checkpoint está completo en términos analíticos. Para cerrarlo de forma reproducible, todas las instrucciones ejecutadas deben quedar incorporadas en `10_inf_extremos.R` y el script debe ejecutarse íntegramente desde una sesión limpia.

# Función de la Fase 5 dentro de la narrativa del informe

La Fase 5 es coherente con la pregunta estadística del Informe 1 porque retoma dos elementos definidos allí:

1. La comparación de magnitud entre zonas.
2. Las categorías Fuerte, Mayor y Grande o extremo, construidas para permitir comparaciones espaciales y temporales posteriores.

El Informe 1 describió la composición observada y declaró explícitamente que su alcance era exploratorio. También propuso como extensión inferencial el contraste chi-cuadrado entre `zona` y `magnitud_cat`, acompañado por V de Cramér. La Fase 5 ejecuta precisamente esa transición.

## Hilo conductor

La secuencia narrativa recomendada es:

1. **Informe 1:** las magnitudes centrales fueron similares entre zonas, con una magnitud algo menor y menor dispersión en la Dorsal.
2. **Fase 3 del Informe 2:** Kruskal-Wallis detectó una diferencia global de magnitud, pero su tamaño de efecto fue prácticamente nulo. Las diferencias por pares se concentraron principalmente en la Dorsal.
3. **Fase 5:** al transformar la magnitud en categorías, no se detectó una asociación global con zona y V de Cramér fue prácticamente cero. En la logística binaria, la Dorsal mantuvo una señal específica de menores odds, pero `zona` no alcanzó significación como bloque y profundidad no aportó información adicional.
4. **Fase 6:** dado que magnitud y profundidad muestran una capacidad marginal limitada, se evalúa si su combinación permite clasificar la zona, tal como sugirieron los profesores.

Los resultados de Kruskal-Wallis y chi-cuadrado no son contradictorios. Kruskal-Wallis utiliza toda la información ordinal de la magnitud continua y puede detectar desplazamientos pequeños. La categorización agrupa valores y pierde detalle, por lo que una diferencia pequeña puede dejar de ser detectable. Ambos análisis coinciden en que la relevancia práctica de la magnitud es reducida.

## Papel respecto de la pregunta estadística

La Fase 5 responde la parte de la pregunta relacionada con diferencias de magnitud y cumple el análisis mínimo de eventos fuertes o extremos. No responde directamente la segunda parte —si magnitud y profundidad permiten clasificar la zona— porque en esta logística la respuesta es `evento_mayor`, no `zona`.

Por ello debe presentarse como un análisis inferencial complementario y como preparación para el modelo multinomial, no como sustituto de la clasificación.

## Límites narrativos

Para mantener coherencia con el alcance del informe:

- No afirmar que la zona causa magnitudes mayores o menores.
- No interpretar las tasas extremas como amenaza sísmica o recurrencia física.
- No declarar un efecto global de zona basándose únicamente en el contraste específico de la Dorsal.
- No interpretar la ausencia de significación como prueba de igualdad exacta.
- Destacar que profundidad fue evaluada conjuntamente, pero no adquirió relevancia en esta respuesta binaria.

## Párrafo de enlace sugerido

> El Informe Asesoría 1 mostró magnitudes centrales similares entre zonas y una distribución más acotada en la Dorsal Meso-Atlántica. La etapa inferencial confirmó que las diferencias de magnitud son pequeñas: aunque la comparación continua detectó desplazamientos de rangos, la composición de categorías no presentó una asociación global sustantiva con la zona. La regresión logística mantuvo una señal específica de menores odds de $M\geq7{,}0$ en la Dorsal, pero la zona no fue significativa como bloque y la profundidad no aportó capacidad explicativa adicional. Estos resultados motivan evaluar, en la sección siguiente, si magnitud y profundidad pueden adquirir utilidad discriminante al considerarse conjuntamente en un modelo de clasificación de zonas.
