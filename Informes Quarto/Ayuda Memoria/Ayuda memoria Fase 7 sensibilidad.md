# Ayuda memoria: Fase 7, análisis de sensibilidad

## Propósito de la fase

La Fase 7 verifica que las conclusiones centrales del informe no dependan de dos decisiones metodológicas tomadas al inicio del estudio: el umbral de magnitud 6,5 que define la base y la inclusión de "Resto del mundo" como zona de comparación. Si las conclusiones se mantienen al modificar esas decisiones, el informe gana solidez; si alguna cambia, corresponde declararlo y acotar el alcance de esa conclusión. Los resultados alimentan la sección 7.7 del informe y el checkpoint C8.

## Qué es un análisis de sensibilidad

Un análisis de sensibilidad repite las piezas clave de un estudio bajo escenarios alterados y compara los resultados con el escenario base. No formula hipótesis nuevas ni busca hallazgos adicionales: su única pregunta es si lo ya concluido resiste el cambio de condiciones.

El criterio de comparación es la dirección y la magnitud de los efectos, no los p-valores. Al filtrar la base, el tamaño muestral cae y con él la potencia estadística, de modo que una significancia que desaparece con menos datos no demuestra que el efecto haya cambiado. Lo que sí importaría es una razón de tasas que invierte su orden, un tamaño de efecto que cambia de categoría o una zona que pasa de distinguirse a no distinguirse por razones ajenas a la potencia.

## Los dos escenarios

**Escenario A, umbral más exigente:** se repiten los análisis solo con los eventos de magnitud 7,0 o superior. Quedan 387 eventos: 295 del Cinturón de Fuego, 69 del Resto del mundo, 20 del Cinturón Alpino-Himalayo y 3 de la Dorsal Meso-Atlántica. La categoría "Fuerte" desaparece por definición, porque cubría el rango de 6,5 a 6,9; este hecho se documenta, no es un problema. La advertencia principal es la Dorsal: con solo 3 eventos, cualquier resultado suyo en este escenario es descriptivo y no admite inferencia.

**Escenario B, sin la zona residual:** se repiten los análisis excluyendo "Resto del mundo", que no es un cinturón tectónico sino el complemento geográfico de los otros tres. Quedan 983 eventos en tres zonas: 892 del Cinturón de Fuego, 63 del Cinturón Alpino-Himalayo y 28 de la Dorsal. Las comparaciones post-hoc se reducen de 6 pares a 3. El Cinturón de Fuego sigue siendo la referencia de todos los modelos.

## Qué piezas se repiten y por qué

Se repiten las cuatro piezas que sostienen las conclusiones del informe:

- **Frecuencia (Fase 2):** el modelo de conteos con razones de tasa frente al Cinturón de Fuego. Interesa si el orden de las zonas y el tamaño de las razones se mantienen.
- **Contrastes de magnitud y profundidad (Fase 3, bloque B):** Kruskal-Wallis con epsilon cuadrado y post-hoc de Dunn con corrección de Holm. Interesa si la magnitud sigue sin separar zonas y la profundidad sigue separándolas.
- **Asociación zona-categoría de magnitud (punto 5.1):** chi-cuadrado Monte Carlo y V de Cramér. En el escenario A la tabla pierde la columna "Fuerte" y queda de 4 x 2.
- **Clasificación (puntos 6.3 a 6.5):** la multinomial con su revisión de separación, la matriz de confusión y las métricas. Interesa si el veredicto de C7 (el modelo no supera la base trivial) se repite.

## La base trivial cambia en cada escenario

La exactitud de cada clasificador se compara contra la base trivial de su propio escenario, no contra el 75,21 % de la base completa. En el escenario A, el Cinturón de Fuego representa 295 de 387 eventos, es decir 76,2 %. En el escenario B representa 892 de 983, es decir 90,7 %. Este último valor anticipa que en el escenario B la clase mayoritaria domina aún más que en la base, y que superarla por clasificación será todavía más difícil.

## Qué se espera

En frecuencia, razones de tasa del mismo orden que en la base (Resto, Alpino y Dorsal muy por debajo del Cinturón de Fuego). En los contrastes, un epsilon cuadrado de magnitud despreciable y uno de profundidad mayor, como en la Fase 3. En la asociación categórica, una V de Cramér despreciable. En clasificación, exactitudes iguales a la base trivial de cada escenario y sensibilidades nulas en las zonas minoritarias.

Si aparece separación cuasi perfecta en la multinomial de algún escenario, se repite el protocolo de la Fase 6: reajustar con reducción de sesgo y declararlo. En el escenario A es probable que la Dorsal la produzca con más fuerza aún, porque sus 3 eventos son superficiales y de magnitud acotada.

## Convenciones que se mantienen

Cinturón de Fuego como referencia de todo modelo; `dplyr::select` calificado; `set.seed(2026)` porque la fase usa Monte Carlo en el chi-cuadrado; ceros de conteos rellenados con `tidyr::complete` en las tablas zona-año; corrección por sobredispersión si el diagnóstico la pide; razón de verosimilitud en lugar de Wald para las dócimas.

## Plan de bloques del script

El script 12 se arma de forma secuencial, un bloque por vez, interpretando la salida antes de escribir el siguiente:

1. Preparación de los dos escenarios y verificación de sus conteos de control (387 y 983 eventos).
2. Escenario A: frecuencia, contrastes, asociación categórica y clasificación.
3. Escenario B: las mismas piezas.
4. Tablas espejo con el efecto principal de cada pieza en base, A y B, lado a lado.
5. Veredicto de robustez para la sección 7.7.

## Preparación y verificación de los escenarios

El primer bloque crea las dos sub-bases con `dplyr::filter()` y las verifica de inmediato, antes de ajustar cualquier modelo. Los filtros no recalculan nada: cada evento que sobrevive conserva intactas todas sus variables. La verificación va primero porque todo número posterior de la fase depende de que el recorte sea correcto; los conteos de control del checklist son la firma de ese recorte.

Ambos controles salieron exactos: el escenario A quedó con 387 eventos (el 32,6 % de la base alcanza magnitud 7,0) y el escenario B con 983. El orden de trabajo del bloque sigue la lógica de la fase: se crea un objeto, se inspecciona, y solo entonces se crea el siguiente.

## Composición de los escenarios

En el escenario A, la participación de las zonas casi no cambia respecto de la base: el Cinturón de Fuego pasa de 75,2 % a 76,2 % (295 eventos), el Resto del mundo de 17,1 % a 17,8 % (69), el Cinturón Alpino-Himalayo de 5,3 % a 5,2 % (20). Esta estabilidad es en sí misma un primer resultado de sensibilidad: el reparto de la actividad entre zonas no depende del umbral elegido.

La excepción es la Dorsal Meso-Atlántica, que cae de 28 eventos a 3 (pierde el 89 % cuando la base global pierde el 67 %). El descenso es coherente con la Fase 5, donde la Dorsal mostró menor probabilidad de generar eventos de magnitud 7,0 o superior (OR 0,25). La consecuencia práctica es que la Dorsal queda sin material inferencial en el escenario A: con 3 eventos, cualquier resultado suyo es descriptivo y así debe presentarse cada vez que aparezca.

El escenario B es literalmente la base menos una zona: los eventos de los tres cinturones son los mismos que en la base. Esto orienta la interpretación posterior: si algún resultado cambia entre la base y el escenario B, el cambio no puede venir de datos distintos en los cinturones, solo de haber retirado al Resto del mundo de la comparación. El post-hoc pasa de 6 pares a 3 y la clase mayoritaria sube su peso de 75,2 % a 90,7 %.

## Desaparición de la categoría Fuerte

La tabla de categorías del escenario A registra Fuerte 0, Mayor 328 y Grande o extremo 59 (328 + 59 = 387, consistente con el total). El cero es la documentación que pide el punto 7.1 del checklist: la categoría desaparece por definición, porque cubría exactamente el rango 6,5-6,9 que el filtro elimina, no por un error de datos.

Queda una nota técnica pendiente: el factor conserva el nivel "Fuerte" aunque esté vacío. Cuando se arme la tabla `zona x magnitud_cat` para repetir el punto 5.1, habrá que soltar ese nivel con `droplevels()`, porque un chi-cuadrado no puede calcularse con una columna completa de ceros.

## Frecuencia del escenario A: la tabla zona-año

El modelo de conteos necesita una fila por cada combinación de zona y año, con el número de eventos ocurridos. La tabla se arma en tres pasos. `count()` cuenta los eventos por combinación zona-año, pero solo genera filas para las combinaciones que existieron: si una zona no tuvo eventos en un año, esa fila no aparece. `tidyr::complete()` repara justo eso, agregando las combinaciones faltantes con n = 0; el "ese año no hubo ninguno" es un dato, no un hueco, y sin esta corrección la tasa anual de las zonas poco activas saldría inflada al calcularse solo sobre sus años con eventos. Finalmente, `relevel()` fija al Cinturón de Fuego como categoría de referencia, para que cada coeficiente del modelo se lea como "esta zona comparada con el Fuego", el mismo criterio de todo el informe.

Las dos verificaciones cerraron la contabilidad: 104 filas (4 zonas por 26 años, la grilla completa) y suma 387 (los ceros se agregaron sin inventar ni perder eventos).

## Lectura del modelo Poisson del escenario A

El modelo trabaja en escala logarítmica y sus coeficientes se vuelven interpretables al exponenciarlos. El intercepto (2,42888) es el logaritmo de la tasa anual de la zona de referencia: exp(2,42888) = 11,35 eventos por año para el Cinturón de Fuego, verificable a mano como 295 eventos divididos por 26 años. El modelo parametriza los promedios observados, no inventa nada.

Los demás coeficientes son log-razones de tasa frente al Fuego. Exponenciados: el Resto del mundo tiene el 23,4 % de la tasa del Fuego (exp(-1,45287) = 0,234), el Cinturón Alpino-Himalayo el 6,8 % (exp(-2,69124) = 0,068) y la Dorsal el 1,0 % (exp(-4,58836) = 0,010; sus 3 eventos en 26 años equivalen a 0,12 eventos por año contra 11,35 del Fuego). Los tres p-valores son ínfimos: ninguna zona se acerca a la tasa del Fuego. El error estándar de la Dorsal (0,58) es entre 2 y 4 veces mayor que el de las otras zonas, el precio de estimar con 3 eventos.

El resto de la salida se lee así. La línea "dispersion parameter taken to be 1" recuerda que la Poisson asume varianza igual a la media; R no lo verifica, lo asume, y por eso el diagnóstico se calcula aparte. La caída de la deviance nula (645,79 con 103 grados de libertad) a la residual (118,58 con 100) indica que la zona explica la mayor parte de la variación entre conteos anuales. Las 6 iteraciones de Fisher Scoring señalan una convergencia rutinaria, sin las dificultades numéricas de la multinomial de la Fase 6.

## Sobredispersión y decisión de modelo en el escenario A

La dispersión de Pearson (suma de residuos de Pearson al cuadrado dividida por los grados de libertad residuales) dio 1,306: los conteos varían un 31 % más de lo que la Poisson admite, una sobredispersión leve. En la base el mismo diagnóstico dio 1,41 y fue uno de los tres argumentos de la compuerta C2 para elegir binomial negativa.

Decisión declarada: el escenario A se modela con binomial negativa, por dos razones que se refuerzan. El diagnóstico apunta en la misma dirección que en la base (sobredispersión leve en ambos casos), y usar la misma familia hace las razones de tasa directamente comparables en la tabla espejo, que es el objetivo de la fase.

El anticipo para la tabla espejo ya es visible: Resto 0,234 (base 0,228) y Alpino 0,068 (base 0,071) son casi calcados, primera evidencia de robustez de la conclusión de frecuencia. La Dorsal baja de 0,031 a 0,010, coherente con que sus eventos rara vez alcanzan magnitud 7,0, pero con 3 eventos esa razón es frágil y su intervalo de confianza lo reflejará.

## La binomial negativa del escenario A

La binomial negativa es una Poisson con un parámetro adicional, theta, que absorbe la variación que la Poisson no admite. Sus estimaciones resultaron idénticas a las del Poisson (2,42888; -2,69124; -4,58836; -1,45287): la corrección no cambia las tasas estimadas, cambia cuánta confianza se les asigna. Los errores estándar subieron levemente (el intercepto de 0,05822 a 0,06435, el Resto de 0,13373 a 0,13923, el Alpino de 0,23106 a 0,23429, la Dorsal de 0,58028 a 0,58157) y los z bajaron en consecuencia, pero los tres contrastes siguen siendo abrumadores. Eso es corregir la sobredispersión: errores honestos, misma conclusión.

Theta mide la sobredispersión en dirección inversa: mientras más grande, más se parece la binomial negativa a la Poisson. El valor estimado (51,2) implica que la varianza del Fuego es 11,35 + 11,35²/51,2 = 13,9, un 22 % sobre la varianza Poisson. Que el error estándar de theta (79,4) supere al propio theta confirma que la sobredispersión es leve y está mal determinada, coherente con el Pearson de 1,31. La convergencia en 1 iteración es rutinaria.

El AIC de la binomial negativa (336,15) queda levemente por encima del Poisson (334,7), porque paga un parámetro extra por una sobredispersión leve. La razón de verosimilitud entre ambas familias, calculable desde el 2 x log-likelihood de la salida (-326,152), da 0,55, que con la regla de p dividido en 2 para tests de frontera entrega p = 0,23: en el escenario A la tercera pata de la compuerta C2 no exigiría binomial negativa (en la base sí, con LR = 5,63 y p = 0,009). La decisión declarada es mantener la binomial negativa de todos modos: en un análisis de sensibilidad la comparabilidad con la base manda, y con theta tan grande ambas familias dan resultados casi indistinguibles, de modo que ninguna conclusión depende de esta elección.

## Razones de tasa del escenario A con sus intervalos

El mensaje "Waiting for profiling to be done..." de `confint()` no es un error: en GLM los intervalos no se calculan con la aproximación de Wald sino con verosimilitud perfilada, más fiable cuando la verosimilitud es asimétrica, justo el caso de la Dorsal con 3 eventos.

La fila del intercepto no es una razón sino la tasa anual del Fuego exponenciada: 11,35 eventos por año con IC [9,98; 12,85]. Las demás filas, comparadas con la base: el Resto del mundo da 0,234 [0,177; 0,305] contra 0,228 [0,191; 0,270] de la base; el Alpino 0,068 [0,042; 0,105] contra 0,071 [0,053; 0,092]. Razones casi calcadas e intervalos ampliamente solapados: la conclusión de frecuencia se sostiene con el umbral exigente.

La Dorsal baja de 0,031 [0,021; 0,045] a 0,010 [0,003; 0,027]. No es una contradicción sino una profundización coherente con la Fase 5: la Dorsal no solo tiene pocos eventos, tiene proporcionalmente menos eventos grandes. La advertencia permanente aplica: con 3 eventos, el intervalo abarca un orden de magnitud (del 0,25 % al 2,7 % de la tasa del Fuego) y la estimación es frágil.

Los tres intervalos excluyen el 1, de modo que el ordenamiento Fuego, luego Resto, luego Alpino, luego Dorsal queda intacto. La pieza de frecuencia del escenario A confirma la conclusión de la base y su fila de la tabla espejo queda lista.
