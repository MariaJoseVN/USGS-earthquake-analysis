# 11 - Sintesis: clasificacion de zonas (Informe Asesoria 2)----
#
# Fase 6 del checklist | Seccion 7.6 del informe | Checkpoint C7 (COMPUERTA DURA, la central)
#
# Responde la segunda componente de la pregunta estadistica: magnitud y profundidad,
# evaluadas EN CONJUNTO, permiten clasificar la zona sismica de un evento?
# El terreno viene armado por las fases anteriores: la magnitud casi no separa zonas
# (Fases 3 y 5), la profundidad si discrimina (Fase 3), la profundidad no predice la
# magnitud (Fase 5) y ambas estan casi descorrelacionadas (Bartlett, Fase 3), de modo que
# cada una aporta informacion DISTINTA a un clasificador.
#
# Paquetes: dplyr, ppcor (parciales), ca (correspondencia), nnet (multinomial),
#           car (Anova por razon de verosimilitud), brglm2 (Firth si hay separacion).


#Paquetes----
library(dplyr)   # Manipulacion de datos (select, mutate, pipes).
library(ppcor)   # Correlaciones PARCIALES (R base solo trae las simples).
library(ca)      # Analisis de correspondencia simple.
library(nnet)    # multinom(): logistica multinomial (internamente una red sin capa oculta,
                 # pero el modelo es la multinomial clasica).
library(car)     # Anova(): docima cada variable por razon de verosimilitud (no Wald).
library(brglm2)  # brmultinom(): correccion de Firth para la separacion (la Dorsal).


#Cargar la base si no esta disponible (ruta rapida de desarrollo)----
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# Semilla fija: la validacion cruzada del 6.6 sortea pliegues al azar.
set.seed(2026)


#Base de trabajo----
# relevel() fija a Cinturon de Fuego como referencia: el multinomial estima una ecuacion
# por cada otra zona y cada una se lee como "esta zona frente al Cinturon de Fuego"
# (mismo criterio que el GLM de conteos de la Fase 2).
# dplyr::select calificado: car arrastra a MASS, que tambien exporta select().
base_fase6 <- sismos %>%
  dplyr::select(zona, mag, depth, sig, magnitud_cat, profundidad_cat) %>%
  mutate(zona = relevel(factor(zona), ref = "Cinturon de Fuego"))

# Verificacion de datos completos. Importa por dos razones: ppcor::pcor() exige datos sin
# NA (con uno solo fallaria o descartaria filas en silencio), y asegura que TODOS los
# analisis de la fase usen los mismos 1186 eventos, sin exclusiones invisibles.
# Resultado: 0 NAs en las seis variables.
colSums(is.na(base_fase6))


#6.1 Correlaciones parciales de Spearman (mag, depth, sig)----
# La parcial mide la asociacion entre dos variables DESCONTANDO la tercera. Como `sig`
# deriva de la magnitud (construccion USGS), la lectura protagonista es depth-sig
# CONTROLANDO mag: si queda asociacion, la profundidad aporta a la relevancia del evento
# mas alla de su magnitud. Spearman por la asimetria de depth y sig (Fase 3).
parciales <- ppcor::pcor(base_fase6[, c("mag", "depth", "sig")], method = "spearman")
round(parciales$estimate, 4)   # matriz de correlaciones parciales
round(parciales$p.value, 4)    # sus p-valores
# Resultado (cada celda = correlacion fila-columna DESCONTANDO la tercera variable):
#   - mag-sig | depth = 0,8156 (p ~ 0): enorme y esperado, sig se calcula a partir de la
#     magnitud (relacion por diseno del indicador, no un hallazgo).
#   - mag-depth | sig = 0,1153 (p = 0,0001): significativo pero DEBIL (n = 1186 vuelve
#     significativo casi todo); coherente con Bartlett (Fase 3): casi descorrelacionadas,
#     por lo que cada una puede aportar informacion distinta a un modelo conjunto.
#   - depth-sig | mag = -0,0493 (p = 0,0896): NO significativa. Descontada la magnitud, la
#     profundidad no agrega nada a la relevancia USGS del evento.
# Asimetria que anticipa el multinomial: la magnitud domina la RELEVANCIA del evento pero
# no distingue zonas (Fases 3 y 5); la profundidad no aporta a la relevancia pero SI
# distingue zonas (Fase 3). Cada variable manda en una pregunta distinta.

#Figura: red de correlaciones parciales (triangulo)----
# Cada variable es un nodo y cada arista una correlacion parcial: el GROSOR es la fuerza,
# linea continua = significativa (alfa 0,05), punteada gris = no significativa. Con tres
# variables este diagrama comunica la asimetria mejor que la matriz: el lado mag-sig
# domina (0,82) y los otros dos son debiles o nulos.
dibujar_parciales <- function() {
  op <- par(bg = "white", mar = c(1, 1, 3, 1))
  plot(NA, xlim = c(0, 1), ylim = c(0, 1), axes = FALSE, xlab = "", ylab = "",
       main = "Correlaciones parciales de Spearman (mag, depth, sig)")
  # coordenadas de los nodos
  xy <- rbind(mag = c(0.50, 0.82), depth = c(0.15, 0.18), sig = c(0.85, 0.18))
  # aristas: pares, valor parcial y p-valor
  aristas <- data.frame(
    a = c("mag", "mag", "depth"), b = c("sig", "depth", "sig"),
    r = c(parciales$estimate["mag", "sig"],
          parciales$estimate["mag", "depth"],
          parciales$estimate["depth", "sig"]),
    p = c(parciales$p.value["mag", "sig"],
          parciales$p.value["mag", "depth"],
          parciales$p.value["depth", "sig"])
  )
  for (i in seq_len(nrow(aristas))) {
    sig_ok <- aristas$p[i] < 0.05
    segments(xy[aristas$a[i], 1], xy[aristas$a[i], 2],
             xy[aristas$b[i], 1], xy[aristas$b[i], 2],
             lwd = 1 + 10 * abs(aristas$r[i]),
             lty = if (sig_ok) 1 else 2,
             col = if (sig_ok) "#00A499" else "gray60")
    # etiqueta en el punto medio, con el valor (y "ns" si no es significativa)
    xm <- mean(xy[c(aristas$a[i], aristas$b[i]), 1])
    ym <- mean(xy[c(aristas$a[i], aristas$b[i]), 2])
    text(xm, ym + 0.05,
         paste0(format(round(aristas$r[i], 2), decimal.mark = ","),
                if (!sig_ok) " (ns)" else ""),
         cex = 0.95, font = 2, col = "gray20")
  }
  # nodos encima de las aristas
  points(xy, pch = 21, bg = "#001632", col = "#001632", cex = 6)
  text(xy, labels = rownames(xy), col = "white", cex = 0.85, font = 2)
  par(op)
}

if (interactive()) dibujar_parciales()

ruta_par <- file.path("Informes Quarto", "Imágenes y Recursos",
                      "inf2-clasificacion-parciales.png")
png(ruta_par, width = 1500, height = 1200, res = 200)
dibujar_parciales()
dev.off()
# Lectura del grafico: el triangulo queda "cojo" a proposito. El lado mag-sig es grueso y
# solido (0,82: la relevancia USGS la determina la magnitud); mag-depth es delgado (0,12:
# casi independientes); depth-sig es punteado (ns: la profundidad no suma relevancia una
# vez descontada la magnitud).


#6.2 Analisis de correspondencia simple----
# Representa las asociaciones de las tablas zona x categoria en un plano. La inercia
# total es proporcional al chi-cuadrado de la tabla: cuanta asociacion hay que explicar.
# Con tablas 4 x 3 hay a lo mas min(4,3) - 1 = 2 dimensiones, asi que el plano recoge el
# 100 % de la inercia y el biplot es una representacion exacta, no una aproximacion.
tabla_ca_mag  <- table(base_fase6$zona, base_fase6$magnitud_cat)
tabla_ca_prof <- table(base_fase6$zona, base_fase6$profundidad_cat)

ca_mag  <- ca::ca(tabla_ca_mag)
ca_prof <- ca::ca(tabla_ca_prof)
summary(ca_mag)
summary(ca_prof)

# Figura: biplots lado a lado. Patron para PLOTS: funcion + llamada interactiva + PNG.
dibujar_correspondencia <- function() {
  op <- par(mfrow = c(1, 2), bg = "white", mar = c(4.5, 4.5, 3, 1) + 0.1)
  plot(ca_mag,  main = "Zona x categoria de magnitud")
  plot(ca_prof, main = "Zona x categoria de profundidad")
  par(op)
}

if (interactive()) dibujar_correspondencia()

ruta_ca <- file.path("Informes Quarto", "Imágenes y Recursos",
                     "inf2-clasificacion-correspondencia.png")
png(ruta_ca, width = 2200, height = 1100, res = 200)
dibujar_correspondencia()
dev.off()


#Figura: espacio de clasificacion (mag vs depth por zona)----
# El grafico muestra el "espacio" en el que trabaja el clasificador: cada punto es un
# evento ubicado por su profundidad (x) y magnitud (y), coloreado por zona.
colores_zona <- c(
  "Cinturon de Fuego"        = "#e31a1c",
  "Cinturon Alpino-Himalayo" = "#47cea8",
  "Dorsal Meso-Atlantica"    = "#8a5a00",
  "Resto del mundo"          = "#9e9e9e"
)

dibujar_espacio_clasificacion <- function() {
  op <- par(bg = "white", mar = c(4.5, 4.5, 3, 1) + 0.1)
  plot(base_fase6$depth, base_fase6$mag,
       col = adjustcolor(colores_zona[as.character(base_fase6$zona)], alpha.f = 0.55),
       pch = 19, cex = 0.7,
       main = "Espacio de clasificacion: magnitud y profundidad por zona",
       xlab = "Profundidad (km)", ylab = "Magnitud")
  legend("topright", legend = names(colores_zona), col = colores_zona,
         pch = 19, bty = "n", cex = 0.8)
  box()
  par(op)
}

if (interactive()) dibujar_espacio_clasificacion()

ruta_esp <- file.path("Informes Quarto", "Imágenes y Recursos",
                      "inf2-clasificacion-espacio.png")
png(ruta_esp, width = 1800, height = 1200, res = 200)
dibujar_espacio_clasificacion()
dev.off()


#6.3 Regresion logistica multinomial----
# Generaliza la logistica a una respuesta con 4 clases: estima 3 ecuaciones (una por zona
# frente a la referencia Cinturon de Fuego), cada una con intercepto, mag y depth.
# La significacion por variable se evalua con car::Anova (razon de verosimilitud), no con
# los Wald por coeficiente, que son poco fiables si hay separacion.
m_full <- nnet::multinom(zona ~ mag + depth, data = base_fase6, trace = FALSE)
summary(m_full)
car::Anova(m_full)


#6.4 Revision de separacion----
# Separacion cuasi perfecta = una combinacion de predictores identifica una clase casi sin
# error; los coeficientes divergen y sus EE se inflan. Criterio de alerta: |coef| > 10 o
# EE desproporcionados. Riesgo esperado: la Dorsal (n = 28, toda superficial y de magnitud
# baja). Si aparece, se reajusta con brglm2::brmultinom (correccion tipo Firth).
round(coef(m_full), 4)
round(summary(m_full)$standard.errors, 4)


#6.5 Matriz de confusion y metricas por clase----
# La exactitud global se compara SIEMPRE contra la base trivial: predecir "Cinturon de
# Fuego" para todo ya acierta el 75,21 % (892/1186). Las metricas honestas con clases
# desbalanceadas son la sensibilidad por clase (que fraccion de cada zona real se
# recupera) y la exactitud balanceada (promedio de esas sensibilidades; base trivial 25 %).
pred_clase <- predict(m_full)

matriz_confusion <- table(observado = base_fase6$zona, predicho = pred_clase)
matriz_confusion

exactitud_global <- mean(pred_clase == base_fase6$zona)
sensibilidad_clase <- diag(matriz_confusion) / rowSums(matriz_confusion)
exactitud_balanceada <- mean(sensibilidad_clase)

exactitud_global        # comparar con 0,7521 (base trivial)
round(sensibilidad_clase, 4)
exactitud_balanceada    # comparar con 0,25 (base trivial balanceada)


#6.6 Validacion cruzada de 10 pliegues----
# Blinda las metricas contra el sobreajuste: cada evento se predice con un modelo ajustado
# SIN el (su pliegue queda fuera del ajuste). Con un modelo de solo 9 parametros y n = 1186
# el sobreajuste esperable es minimo, pero la verificacion cierra la duda.
pliegue <- sample(rep(1:10, length.out = nrow(base_fase6)))
pred_cv <- factor(rep(NA_character_, nrow(base_fase6)), levels = levels(base_fase6$zona))
for (k in 1:10) {
  m_k <- nnet::multinom(zona ~ mag + depth, data = base_fase6[pliegue != k, ], trace = FALSE)
  pred_cv[pliegue == k] <- predict(m_k, newdata = base_fase6[pliegue == k, ])
}
mc_cv <- table(observado = base_fase6$zona, predicho = pred_cv)
sens_cv <- diag(mc_cv) / rowSums(mc_cv)
c(exactitud_cv = mean(pred_cv == base_fase6$zona), balanceada_cv = mean(sens_cv))


#6.7 Aporte conjunto de las variables----
# Cuantifica el argumento docente: variables poco relevantes por separado pueden aportar
# en conjunto. Se comparan los modelos anidados por AIC y por razon de verosimilitud:
#   anova(m_mag, m_full)  -> aporte de depth DADO mag
#   anova(m_depth, m_full) -> aporte de mag DADO depth
m_null  <- nnet::multinom(zona ~ 1,     data = base_fase6, trace = FALSE)
m_mag   <- nnet::multinom(zona ~ mag,   data = base_fase6, trace = FALSE)
m_depth <- nnet::multinom(zona ~ depth, data = base_fase6, trace = FALSE)

AIC(m_null, m_mag, m_depth, m_full)
anova(m_mag, m_full)
anova(m_depth, m_full)
