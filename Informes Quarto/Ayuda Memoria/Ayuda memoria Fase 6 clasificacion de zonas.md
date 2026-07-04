# Ayuda memoria: Fase 6, clasificación de zonas

## Propósito de la fase

La Fase 6 estudia si la magnitud y la profundidad, consideradas conjuntamente, permiten identificar la zona a la que pertenece un evento. El análisis principal será una regresión logística multinomial con `zona` como variable respuesta. El análisis de correspondencia se utiliza antes como apoyo exploratorio para representar las relaciones entre las zonas y las categorías de magnitud y profundidad.

## Por qué se omiten las correlaciones parciales

Las correlaciones parciales del punto 6.1 solo integrarían variables numéricas y no responderían directamente a la solicitud de estudiar variables numéricas y categóricas dentro de un planteamiento conjunto. Además, las relaciones individuales entre magnitud, profundidad y zona ya fueron examinadas en la Fase 3. El aporte simultáneo de magnitud y profundidad se evaluará de forma directa mediante la regresión multinomial y la comparación de modelos.

## Qué es el análisis de correspondencia

El análisis de correspondencia es una técnica descriptiva para tablas de contingencia. Compara los perfiles porcentuales de las filas y columnas utilizando distancias chi-cuadrado y los representa en un espacio de pocas dimensiones.

En esta fase se estudiarán dos tablas:

- `zona × magnitud_cat`.
- `zona × profundidad_cat`.

La cercanía entre puntos en el mapa ayuda a reconocer categorías con perfiles semejantes. La distancia respecto del origen indica cuánto se aparta un perfil del promedio. Estas relaciones deben confirmarse revisando coordenadas, contribuciones e inercia; la proximidad visual por sí sola no demuestra asociación causal.

## Condiciones y supuestos

El análisis de correspondencia no exige normalidad, homogeneidad de varianzas, linealidad ni una correlación previa. Requiere:

- Frecuencias absolutas no negativas.
- Categorías mutuamente excluyentes.
- Observaciones independientes.
- Ninguna fila o columna con total igual a cero.
- Categorías con significado metodológico claro.

Las celdas con frecuencias pequeñas o iguales a cero no impiden automáticamente calcular el análisis, pero pueden producir posiciones inestables o excesivamente influyentes. Por eso primero se inspeccionan las tablas observadas y luego sus frecuencias esperadas.

## Primer bloque del script

Se construyen dos tablas con frecuencias absolutas. Todavía no se calculan porcentajes ni se ajusta el análisis de correspondencia. La salida permite revisar:

- Si existen filas o columnas vacías.
- Qué combinaciones presentan cero eventos.
- Qué categorías tienen muy pocos eventos.
- Si la Dorsal Meso-Atlántica se concentra en una categoría particular.

En `zona × magnitud_cat` ya se anticipa que la Dorsal no contiene eventos grandes o extremos. En `zona × profundidad_cat` se espera que la Dorsal se concentre en eventos superficiales. Estos patrones pueden dominar parte de la geometría de los mapas y deberán interpretarse considerando que la Dorsal solo contiene 28 eventos.

## Revisión de las tablas observadas y esperadas

Las dos tablas tienen 12 celdas. En cada una aparecen 2 frecuencias esperadas menores que 5, equivalentes al 16,7 %, y ninguna frecuencia esperada es menor que 1. Por ello, las tablas pueden utilizarse para el análisis de correspondencia, aunque las categorías con poca masa deben interpretarse con cautela.

En `zona × magnitud_cat`, las frecuencias esperadas pequeñas corresponden a la categoría Grande o extremo del Cinturón Alpino-Himalayo (3,13) y de la Dorsal Meso-Atlántica (1,39). La Dorsal registra cero eventos en esa categoría. Su ubicación en el mapa puede ser sensible al reducido número de eventos extremos.

En `zona × profundidad_cat`, las frecuencias esperadas pequeñas corresponden a los eventos intermedios (3,54) y profundos (2,90) de la Dorsal. Ambos conteos observados son cero, porque sus 28 eventos son superficiales. Este perfil tan concentrado probablemente separará a la Dorsal en el mapa. El Cinturón Alpino-Himalayo tampoco registra eventos profundos.

Los ceros observados no invalidan el análisis, ya que ninguna fila ni columna tiene total cero. Sin embargo, indican que la interpretación debe considerar el fuerte desbalance entre zonas y evitar presentar la proximidad visual de los puntos como evidencia suficiente por sí sola.

## Interpretación de los perfiles fila

Un perfil fila muestra cómo se distribuyen las categorías dentro de cada zona. Por construcción, las proporciones de cada fila suman 1.

### Categoría de magnitud dentro de cada zona

El Cinturón de Fuego, el Resto del mundo y el Cinturón Alpino-Himalayo presentan perfiles muy semejantes: aproximadamente 66 %-68 % de eventos fuertes, 28 %-29 % de eventos mayores y 3 %-5 % de eventos grandes o extremos. Esta similitud concuerda con la asociación despreciable observada previamente entre zona y categoría de magnitud.

La Dorsal Meso-Atlántica se diferencia parcialmente: 89,3 % de sus eventos son fuertes, 10,7 % son mayores y no registra eventos grandes o extremos. Esta diferencia debe interpretarse con cautela porque la zona contiene solo 28 eventos.

### Categoría de profundidad dentro de cada zona

Los perfiles de profundidad presentan diferencias más claras. El Cinturón de Fuego contiene 77,1 % de eventos superficiales, 13,6 % intermedios y 9,3 % profundos. El Resto del mundo alcanza la mayor proporción de eventos profundos, con 19,7 %. El Cinturón Alpino-Himalayo no registra eventos profundos y presenta 17,5 % de eventos intermedios. La Dorsal se compone exclusivamente de eventos superficiales.

Por lo tanto, las categorías de magnitud ofrecen poca diferenciación entre zonas, mientras que las categorías de profundidad producen perfiles más contrastantes. Esto anticipa que el mapa de profundidad tendrá una estructura más informativa que el mapa de magnitud.

## Interpretación de los perfiles columna

Un perfil columna muestra cómo se distribuyen las zonas dentro de cada categoría. Cada columna suma 1. Su interpretación debe compararse con el peso general de las zonas en la muestra: Cinturón de Fuego 75,2 %, Resto del mundo 17,1 %, Cinturón Alpino-Himalayo 5,3 % y Dorsal Meso-Atlántica 2,4 %. Por ello, que el Cinturón de Fuego concentre la mayor parte de todas las categorías no demuestra por sí mismo una asociación; refleja principalmente su mayor tamaño muestral.

En magnitud, los eventos fuertes y mayores se distribuyen entre las zonas de manera muy cercana a esos pesos generales. Los eventos grandes o extremos presentan una concentración algo mayor en el Cinturón de Fuego (79,7 %) y no aparecen en la Dorsal, pero el patrón global sigue siendo débil.

En profundidad, las diferencias son más visibles. El Resto del mundo contiene 32,5 % de todos los eventos profundos, proporción considerablemente superior a su peso general de 17,1 %. El Cinturón de Fuego concentra 80,7 % de los eventos intermedios, por encima de su peso general, pero solo 67,5 % de los profundos. El Cinturón Alpino-Himalayo aporta 7,3 % de los intermedios y ningún profundo. La Dorsal aporta solamente eventos superficiales.

Los perfiles columna confirman que la estructura de magnitud es reducida y que la principal diferenciación categórica aparece en la profundidad.

## Valores propios e inercia

La inercia cuantifica cuánto se apartan los perfiles observados de la independencia. La inercia total es la suma de los valores propios. El porcentaje de cada dimensión indica cómo se reparte esa inercia, pero no mide por sí solo la fuerza de la asociación.

Para `zona × magnitud_cat`, los valores propios son 0,005580 y 0,000426, por lo que la inercia total es aproximadamente 0,006005. La dimensión 1 concentra 92,9 % de esa inercia y la dimensión 2 el 7,1 %. Aunque la primera dimensión resume casi toda la estructura, la inercia total es muy pequeña. Esto significa que la asociación entre zona y categoría de magnitud sigue siendo débil; el 92,9 % no debe interpretarse como una asociación fuerte.

Para `zona × profundidad_cat`, los valores propios son 0,026266 y 0,005812, con una inercia total aproximada de 0,032078. La dimensión 1 explica 81,9 % y la dimensión 2 el 18,1 %. Esta inercia es mayor que la de magnitud y confirma que la profundidad diferencia mejor los perfiles de las zonas, aunque todavía debe interpretarse junto con las contribuciones y el tamaño desigual de las zonas.

Como las tablas tienen cuatro filas y tres columnas, poseen como máximo dos dimensiones. En ambos análisis las dos dimensiones representan el 100 % de la geometría de la tabla; no existe pérdida adicional por representar el resultado en un plano bidimensional.

## Coordenadas y contribuciones

Las coordenadas indican la posición y el sentido de cada punto en los ejes. Las contribuciones indican qué puntos construyen cada dimensión y suman 100 % dentro de cada eje. Como referencia, una contribución superior a 25 % es elevada entre las cuatro zonas y una superior a 33,3 % es elevada entre las tres categorías. El signo de un eje puede invertirse sin cambiar su significado; lo importante son las oposiciones entre puntos.

### Correspondencia de magnitud

La dimensión 1 está construida casi completamente por la Dorsal Meso-Atlántica, con 95,1 % de contribución y coordenada negativa. En las categorías, esta dimensión contrapone principalmente los eventos fuertes, ubicados en el sentido negativo, con los eventos mayores y grandes o extremos, ubicados en el sentido positivo. Por ello, el eje representa sobre todo el perfil de la Dorsal: alta concentración de eventos fuertes y ausencia de eventos grandes o extremos.

La dimensión 2 está dominada por el Cinturón Alpino-Himalayo (72,0 %) y por la categoría Grande o extremo (70,8 %). Sin embargo, esta dimensión representa solo 7,1 % de una inercia total ya muy pequeña y se apoya en apenas dos eventos extremos del Alpino. No conviene construir una conclusión sustantiva a partir de este eje.

En conjunto, el mapa de magnitud describe principalmente la singularidad de la Dorsal, pero no demuestra una separación general entre todas las zonas.

### Correspondencia de profundidad

La dimensión 1 está construida principalmente por el Resto del mundo (64,1 %) y la categoría Profundo (87,8 %), ambos con coordenadas positivas. En el sentido contrario aparece especialmente el Cinturón Alpino-Himalayo, que no registra eventos profundos. Este eje representa, por tanto, el contraste entre la concentración relativa de eventos profundos en el Resto del mundo y su ausencia en el Alpino.

La dimensión 2 está dominada por la Dorsal Meso-Atlántica (90,8 %) y la categoría Intermedio (80,9 %), ubicadas en sentidos opuestos. La Dorsal comparte el sentido negativo con la categoría Superficial y no contiene eventos intermedios ni profundos. Este eje separa su perfil exclusivamente superficial de las zonas que sí presentan sismicidad intermedia.

El Cinturón de Fuego permanece cerca del origen en ambos ejes y realiza contribuciones pequeñas. Esto indica que su perfil categórico se aproxima más al perfil promedio de la muestra. La profundidad ofrece una estructura descriptiva más clara que la magnitud, pero la interpretación de la Dorsal debe conservar la advertencia de su reducido tamaño muestral.

## Primer ajuste de la regresión multinomial

El modelo `zona ~ mag + depth` utiliza el Cinturón de Fuego como categoría de referencia y estima tres ecuaciones: Resto del mundo, Cinturón Alpino-Himalayo y Dorsal Meso-Atlántica frente al Cinturón de Fuego. Cada coeficiente expresa el cambio en el logaritmo de las odds de pertenecer a esa zona frente a la referencia, manteniendo constante el otro predictor.

En el primer ajuste, los coeficientes de magnitud y profundidad del Resto del mundo son positivos, mientras que la profundidad presenta un coeficiente negativo para el Cinturón Alpino-Himalayo. Estas direcciones son coherentes con los perfiles descriptivos, pero todavía no deben interpretarse como efectos significativos.

La ecuación de la Dorsal presenta coeficientes considerablemente mayores en valor absoluto: -1,492 para magnitud y -0,169 para profundidad, junto con un intercepto de 9,399 y un error estándar del intercepto inusualmente pequeño. El patrón es compatible con una fuerte separación de la Dorsal por sus eventos exclusivamente superficiales y de menor magnitud, pero también puede verse acentuado por la diferencia de escala entre los predictores.

Antes de diagnosticar separación cuasi perfecta se debe repetir el mismo modelo con predictores centrados y estandarizados. Esta reexpresión no cambia las probabilidades ajustadas, la deviance ni el AIC; solo mejora la estabilidad numérica y hace comparables las unidades de los coeficientes. Si los coeficientes de la Dorsal continúan siendo extremos o cambian al aumentar las iteraciones, se justificará utilizar `brglm2::brmultinom()`.

La deviance residual de 1728,757 y el AIC de 1746,757 no se interpretan de forma aislada. Se utilizarán posteriormente para comparar el modelo conjunto con los modelos que contienen solo magnitud o solo profundidad.

## Diagnóstico de separación tras estandarizar

El modelo se reajustó con magnitud y profundidad estandarizadas mediante puntajes Z. La deviance residual (1728,757) y el AIC (1746,757) permanecieron iguales, como corresponde a una reexpresión lineal de los mismos predictores. El algoritmo informó convergencia igual a cero, lo que significa que finalizó su optimización, pero no demuestra ausencia de separación.

Para el Resto del mundo y el Cinturón Alpino-Himalayo, los coeficientes y errores estándar quedaron en rangos regulares. En cambio, la ecuación de la Dorsal produjo un intercepto de -16,58 y un coeficiente de profundidad estandarizada de -27,66, con errores estándar de 3,59 y 7,21, respectivamente. La persistencia y amplificación de estos valores después de estandarizar confirma que el problema no se debía a las unidades originales.

El resultado es evidencia de separación cuasi perfecta: la profundidad permite distinguir de manera casi determinista a la Dorsal porque sus 28 eventos son superficiales y no existen observaciones intermedias o profundas en esa zona. Bajo separación, los estimadores de máxima verosimilitud pueden crecer hacia valores extremos y las pruebas de Wald dejan de ser fiables, incluso si el algoritmo declara convergencia.

Por esta razón, el modelo multinomial convencional se conserva como diagnóstico y para comparaciones globales que se interpreten con cautela, pero los coeficientes finales deben obtenerse mediante reducción de sesgo con `brglm2::brmultinom()`. Esta corrección produce estimaciones finitas ante separación y permite describir el patrón de la Dorsal sin presentar coeficientes divergentes como efectos precisos.

## Verificación de probabilidades del modelo corregido

El ajuste con `brglm2::brmultinom()` emitió la advertencia `fitted rates numerically 0 occurred`. Esta advertencia se refiere a tasas internas del ajuste mediante el truco de Poisson y es coherente con probabilidades extremadamente pequeñas para la Dorsal en eventos profundos.

Las probabilidades finales fueron todas finitas y ninguna resultó exactamente igual a cero. Para el Cinturón de Fuego variaron entre 0,584 y 0,785; para el Resto del mundo, entre 0,110 y 0,353; para el Cinturón Alpino-Himalayo, entre 0,009 y 0,070; y para la Dorsal, entre aproximadamente 1,4 por 10 a la menos 48 y 0,258.

Por lo tanto, la advertencia no invalida el modelo corregido. Confirma que existen combinaciones de magnitud y profundidad para las cuales pertenecer a la Dorsal es prácticamente imposible según los datos, pero la reducción de sesgo evitó probabilidades finales exactamente nulas o coeficientes infinitos. El modelo puede continuar a la etapa de interpretación, conservando la advertencia sobre separación y el pequeño tamaño de la Dorsal.

Los rangos también anticipan un posible problema de clasificación por desbalance: la probabilidad del Cinturón de Fuego nunca baja de 0,584, mientras que ninguna zona alternativa supera 0,353. Es posible que la regla de máxima probabilidad clasifique todos o casi todos los eventos como Cinturón de Fuego. Esto se comprobará posteriormente con la matriz de confusión y las sensibilidades por clase.

## Resultado del modelo con reducción de sesgo

El ajuste `AS_mean` finalizó en 20 iteraciones y entregó coeficientes finitos. Frente al modelo de máxima verosimilitud estandarizado, los coeficientes de la Dorsal se redujeron ligeramente: el intercepto cambió de -16,58 a -15,76, magnitud de -0,622 a -0,550 y profundidad de -27,66 a -26,19. La corrección no elimina el patrón extremo porque este surge de la estructura de los datos; evita que las estimaciones diverjan.

Para el Resto del mundo, una desviación estándar adicional de magnitud presenta un coeficiente cercano a cero (0,050), mientras que profundidad tiene un coeficiente positivo de 0,225. Manteniendo constante la magnitud, los eventos más profundos poseen mayores odds de pertenecer al Resto del mundo que al Cinturón de Fuego.

Para el Cinturón Alpino-Himalayo, magnitud también presenta un coeficiente cercano a cero (0,035), mientras que profundidad tiene un coeficiente negativo de -0,435. Los eventos más profundos poseen menores odds de pertenecer al Alpino que al Cinturón de Fuego, coherente con la ausencia de eventos profundos en esa zona.

Para la Dorsal, magnitud (-0,550) y especialmente profundidad (-26,19) tienen coeficientes negativos. A mayor magnitud o profundidad disminuyen las odds de pertenecer a la Dorsal frente al Cinturón de Fuego. El coeficiente de profundidad no debe traducirse como una estimación precisa de tamaño de efecto porque sigue reflejando separación cuasi perfecta y presenta un error estándar amplio.

El AIC del ajuste corregido es 1747,032, pero no conviene compararlo directamente con el AIC de máxima verosimilitud como si ambos provinieran del mismo procedimiento de estimación. Para comparar el aporte conjunto de magnitud y profundidad se utilizarán modelos de máxima verosimilitud anidados y pruebas de razón de verosimilitud. El modelo corregido se utilizará para presentar coeficientes finitos y probabilidades.

## Significación global por variable

La tabla de deviance tipo II evalúa cada predictor manteniendo el otro dentro del modelo. Cada prueba tiene tres grados de libertad porque el efecto se contrasta conjuntamente en las tres ecuaciones que comparan las zonas alternativas con el Cinturón de Fuego.

Para magnitud, la razón de verosimilitud fue 5,102 con 3 grados de libertad y un valor p de 0,1645. Por lo tanto, una vez considerada la profundidad, no existe evidencia suficiente de que la magnitud mejore globalmente la distinción entre zonas.

Para profundidad, la razón de verosimilitud fue 64,906 con 3 grados de libertad y un valor p menor que 0,001. La profundidad aporta información global para distinguir las zonas incluso después de controlar por magnitud.

Este resultado conecta directamente con la observación docente sobre variables que cambian de relevancia según la formulación del modelo. En la Fase 5, profundidad no predijo si un evento alcanzaba magnitud 7 o superior. En la Fase 6, profundidad sí permite diferenciar la zona tectónica del evento. No hay contradicción: son variables respuesta y preguntas estadísticas diferentes.

La prueba global se obtuvo con el modelo multinomial de máxima verosimilitud porque la razón de verosimilitud compara modelos anidados bajo el mismo criterio de ajuste. Debido a la separación de la Dorsal, los coeficientes individuales se presentan desde el modelo con reducción de sesgo y la evidencia global se interpreta junto con esa advertencia.

## Matriz de confusión del modelo corregido

La clasificación por máxima probabilidad asignó los 1.186 eventos al Cinturón de Fuego. De ese modo clasificó correctamente sus 892 eventos, pero no identificó ningún evento del Resto del mundo, del Cinturón Alpino-Himalayo ni de la Dorsal Meso-Atlántica.

Este resultado no es un error del modelo ni contradice la significación global de profundidad. La prueba de razón de verosimilitud evalúa si profundidad modifica las probabilidades relativas de pertenecer a las zonas. La matriz de confusión evalúa una exigencia distinta: si esos cambios son suficientes para que una zona alternativa supere al Cinturón de Fuego como categoría más probable.

Debido a que el Cinturón de Fuego representa 75,2 % de la muestra y sus distribuciones de magnitud y profundidad se superponen con las demás zonas, su probabilidad ajustada permanece siempre como la mayor. El modelo puede detectar variaciones relativas en las probabilidades, especialmente para profundidad, pero no alcanza una separación suficiente para clasificar correctamente las zonas minoritarias bajo la regla de máxima probabilidad.

La conclusión sustantiva es que magnitud y profundidad no son suficientes para construir un clasificador operativo de las cuatro zonas con las proporciones observadas. La exactitud global será igual a la base trivial de la clase mayoritaria, mientras que la exactitud balanceada revelará el desempeño deficiente en las zonas minoritarias. Esta diferencia debe ocupar un lugar central en la redacción: asociación estadística no equivale a buena capacidad predictiva.

## Métricas de clasificación

La sensibilidad del Cinturón de Fuego fue 1, mientras que las sensibilidades del Resto del mundo, Cinturón Alpino-Himalayo y Dorsal Meso-Atlántica fueron 0. El modelo reconoce la clase mayoritaria, pero no recupera ninguna observación de las tres clases minoritarias.

La exactitud global fue 0,752, exactamente igual a la base trivial de 0,752 obtenida al clasificar siempre como Cinturón de Fuego. Por ello, la exactitud global no representa una mejora predictiva real. La exactitud balanceada fue 0,25, correspondiente al promedio de una sensibilidad igual a 1 y tres sensibilidades iguales a 0.

La exactitud balanceada es la métrica decisiva en este caso porque otorga el mismo peso a cada zona, independientemente de su frecuencia. El resultado de 25 % equivale al desempeño promedio que surge de reconocer solamente una de las cuatro clases. En consecuencia, el modelo tiene utilidad explicativa para mostrar el papel de profundidad, pero no utilidad clasificatoria bajo la regla de máxima probabilidad y las proporciones observadas.

## Comparación de modelos

El modelo que contiene solo magnitud obtuvo un AIC de 1805,663. El modelo que contiene solo profundidad obtuvo un AIC de 1745,858 y el modelo conjunto un AIC de 1746,757. La profundidad sola presenta el menor AIC; la diferencia de 0,899 respecto del modelo conjunto es pequeña, pero favorece al modelo más parsimonioso porque agregar magnitud no entrega una mejora suficiente.

Al agregar profundidad al modelo que ya contiene magnitud, la deviance disminuyó de 1793,663 a 1728,757. La prueba de razón de verosimilitud fue 64,906 con 3 grados de libertad y un valor p menor que 0,001. Por tanto, profundidad aporta información adicional clara una vez considerada magnitud.

Al agregar magnitud al modelo que ya contiene profundidad, la disminución de deviance fue solo 5,102 y el valor p fue 0,1645. Por tanto, magnitud no aporta información adicional suficiente después de considerar profundidad.

La hipótesis de que magnitud y profundidad ganarían relevancia al actuar conjuntamente no queda respaldada en su forma completa. El análisis múltiple sí revela que profundidad es relevante para distinguir probabilidades de zona, pero magnitud no agrega poder explicativo sobre ella. El modelo preferido por parsimonia es `zona ~ depth_z`, aunque el modelo conjunto se conserva para responder directamente a la pregunta docente y mostrar que la contribución adicional de magnitud es nula.

Esta mejora explicativa tampoco se traduce en clasificación operativa: incluso el modelo conjunto reproduce la clase mayoritaria y no supera la base trivial. La conclusión combina ambas piezas: profundidad modifica las probabilidades relativas de zona, pero magnitud y profundidad no bastan para asignar correctamente cada evento a una de las cuatro zonas.

## Odds ratios del modelo corregido

Los odds ratios se interpretan por un aumento de una desviación estándar en el predictor, manteniendo constante la otra variable. Un intervalo que contiene 1 no entrega evidencia clara de cambio en las odds relativas.

Para el Resto del mundo frente al Cinturón de Fuego, magnitud presenta OR = 1,052 con IC 95 % [0,906; 1,222], por lo que no existe evidencia de un cambio claro. Profundidad presenta OR = 1,252 con IC 95 % [1,098; 1,427]: una desviación estándar adicional de profundidad aumenta aproximadamente 25,2 % las odds de pertenecer al Resto del mundo frente al Cinturón de Fuego.

Para el Cinturón Alpino-Himalayo, magnitud presenta OR = 1,035 con IC 95 % [0,809; 1,325]. Profundidad presenta OR = 0,647 con IC 95 % [0,415; 1,009]. Ambos intervalos contienen 1; el efecto de profundidad es compatible con una disminución de las odds, pero queda en el límite de la incertidumbre estadística.

Para la Dorsal Meso-Atlántica, magnitud presenta OR = 0,577 con IC 95 % [0,311; 1,070], sin evidencia concluyente. Profundidad presenta un OR aproximado de 4,3 por 10 a la menos 12, con un intervalo extremadamente pequeño. La tabla redondeada lo muestra como cero, pero el valor real no es cero. Este OR no debe interpretarse literalmente como una estimación precisa: refleja la separación cuasi perfecta producida porque todos los eventos de la Dorsal son superficiales.

En síntesis, magnitud no presenta intervalos que excluyan 1 en ninguna comparación. La profundidad diferencia principalmente al Resto del mundo y, de forma estructural pero inestable, a la Dorsal. Esta lectura es coherente con la prueba global de razón de verosimilitud y con la preferencia por el modelo de solo profundidad.

## Equivalencia de una desviación estándar

Una desviación estándar de magnitud corresponde a 0,417 unidades y una desviación estándar de profundidad corresponde a 164,1 km. Por ello, los odds ratios estandarizados no representan cambios de una unidad original.

En particular, el OR = 1,252 del Resto del mundo indica que, ante un aumento de aproximadamente 164 km en profundidad y manteniendo constante la magnitud, las odds de pertenecer al Resto del mundo frente al Cinturón de Fuego aumentan 25,2 %. Esta escala es útil para comparar el peso relativo de los predictores, pero para una comunicación institucional también puede expresarse el efecto por incrementos menores, por ejemplo cada 10 o 100 km.

Para magnitud, los OR corresponden a incrementos de aproximadamente 0,417 unidades. Aun en esa escala, todos sus intervalos incluyen 1, por lo que la conclusión de ausencia de aporte adicional no cambia.
