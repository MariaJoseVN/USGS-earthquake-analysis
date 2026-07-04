# 10 - Eventos fuertes y extremos (Informe Asesoria 2)----
#
# Fase 5 del checklist | Seccion 7.5 del informe | Checkpoint C6
# Objetivo: analizar los eventos fuertes usando las categorias del Informe 1
# ("Mayor" M >= 7,0; "Grande o extremo" M >= 7,8), mediante tabla de contingencia
# y regresion logistica.
#
# Paquetes: dplyr, rcompanion (cramerV). chisq y glm binomial son base.


# 1. Cargar la base preparada----

source(file.path("Scripts", "00_preparacion_base.R"))


# 2. Seleccionar las variables de estudio----

base_fase5 <- sismos %>%
  dplyr::select(
    zona,
    mag,
    depth,
    magnitud_cat,
    profundidad_cat
  )


# 3. Definir la variable de agrupacion----

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


# 4. Frecuencias observadas por zona y categoria----

tabla_zona_magnitud <- table(
  zona = base_fase5$zona,
  categoria = base_fase5$magnitud_cat
)

tabla_zona_magnitud
addmargins(tabla_zona_magnitud)


# 5. Distribucion porcentual dentro de cada zona----

porcentaje_zona_magnitud <- prop.table(
  tabla_zona_magnitud,
  margin = 1
) * 100

round(porcentaje_zona_magnitud, 1)


# 6. Frecuencias esperadas bajo independencia----

chi_diagnostico <- suppressWarnings(
  chisq.test(tabla_zona_magnitud)
)

frecuencias_esperadas <- chi_diagnostico$expected

round(frecuencias_esperadas, 2)
frecuencias_esperadas < 5
sum(frecuencias_esperadas < 5)


# 7. Chi-cuadrado con simulacion Monte Carlo----

set.seed(2026)

chi_montecarlo <- chisq.test(
  tabla_zona_magnitud,
  simulate.p.value = TRUE,
  B = 10000
)

chi_montecarlo


# 8. Tamanio de asociacion: V de Cramer----

v_cramer_magnitud <- rcompanion::cramerV(
  tabla_zona_magnitud,
  bias.correct = TRUE
)

v_cramer_magnitud
# Resultado: chi MC p = 0,307 (no significativo) y V = 0,022 (efecto despreciable). La
# composicion de categorias de magnitud NO difiere entre zonas, coherente con la Fase 3
# (la magnitud casi no separa zonas). El Monte Carlo se justifica por 2 casillas con
# esperados < 5 (Dorsal x Grande = 1,39 ; Alpino x Grande = 3,13).


# 9. Crear indicador de evento mayor----

base_fase5 <- base_fase5 %>%
  mutate(
    evento_mayor = as.integer(mag >= 7.0)
  )

table(
  zona = base_fase5$zona,
  evento_mayor = base_fase5$evento_mayor
)


# 10. Regresion logistica con profundidad continua----

modelo_logit_depth <- glm(
  evento_mayor ~ zona + depth,
  family = binomial(link = "logit"),
  data = base_fase5
)

summary(modelo_logit_depth)

# 11. Significación por razón de verosimilitud----

lr_logit_depth <- drop1(
  modelo_logit_depth,
  test = "Chisq"
)

lr_logit_depth

# 12. Odds ratios e intervalos de confianza----

or_logit_depth <- exp(
  cbind(
    OR = coef(modelo_logit_depth),
    confint(modelo_logit_depth)
  )
)

or_logit_depth
# Resultado de la logistica P(M >= 7,0) ~ zona + depth:
#   - depth: OR = 1,0002 [0,9995; 1,0009], p = 0,577 -> la profundidad NO predice que un
#     evento sea grande (coherente con el Bartlett de la Fase 3: mag y depth casi no
#     correlacionan).
#   - zona (global): LR p = 0,061, borderline. Resto (OR 1,03) y Alpino (OR 0,95) no se
#     distinguen de Fuego (sus IC incluyen 1). El unico efecto real es la DORSAL:
#     OR 0,25 [0,058; 0,712], IC que excluye 1 -> ~4 veces menos probabilidad de eventos
#     M >= 7,0 (solo 3 de 28). El borderline de zona lo arrastra unicamente la Dorsal.

# 13. Regresión logística con profundidad categórica----

modelo_logit_depth_cat <- glm(
  evento_mayor ~ zona + profundidad_cat,
  family = binomial(link = "logit"),
  data = base_fase5
)

summary(modelo_logit_depth_cat)

# 14. LR del modelo con profundidad categórica----

lr_logit_depth_cat <- drop1(
  modelo_logit_depth_cat,
  test = "Chisq"
)

lr_logit_depth_cat


# 15. Comparación de modelos por AIC----

comparacion_aic_depth <- AIC(
  modelo_logit_depth,
  modelo_logit_depth_cat
)

comparacion_aic_depth
# Resultado: AIC 1500,01 (depth continua) vs 1500,26 (categorica). Se elige depth CONTINUA:
# menor AIC y mas simple (5 gl vs 6). En ambas versiones la profundidad no es significativa.

# 16. Eventos grandes o extremos por zona----

resumen_extremos <- base_fase5 %>%
  group_by(zona) %>%
  summarise(
    eventos_extremos = sum(mag >= 7.8),
    tasa_anual = eventos_extremos / 26,
    .groups = "drop"
  )

resumen_extremos
# Resultado: M >= 7,8 concentrados en el Cinturon de Fuego (47), luego Resto (10),
# Alpino (2) y Dorsal (0). Solo conteos, sin modelo, por el tamano muestral de las zonas
# menores.
#
# VEREDICTO C6: la categoria de magnitud no difiere por zona (chi p = 0,31, V = 0,02); la
# profundidad no predice que un evento sea grande (OR ~ 1); la unica zona con menor
# probabilidad de eventos M >= 7,0 es la Dorsal. Contraste que arma la Fase 6: la
# profundidad no dice que tan GRANDE es un evento, pero si ayudara a decir en que ZONA ocurre.
