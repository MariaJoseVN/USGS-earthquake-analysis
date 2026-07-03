# 12 - Analisis de sensibilidad (Informe Asesoria 2)----
#
# Fase 7 del checklist | Seccion 7.7 del informe | Checkpoint C8
# Objetivo: verificar la robustez de las conclusiones ante dos decisiones
# metodologicas. NO ejecutar hasta que las fases 2, 3, 5 y 6 esten cerradas,
# porque este script las re-ejecuta con filtros (si no, se rehace dos veces).
#
# Reutiliza las funciones/modelos de 07, 08, 10 y 11 sobre subconjuntos.
# El estado de revision NO se usa como eje: los 1.186 eventos son `reviewed`.


# Cargar la base si no esta disponible (ruta rapida de desarrollo).
if (!exists("sismos") || !"zona" %in% names(sismos)) {
  source(file.path("Scripts", "00_preparacion_base.R"))
}

# Pasos previstos:
# 7.1 Escenario A (umbral): filtrar mag >= 7.0 (387 eventos) y repetir fases
#     2, 3B, 5.1 y 6.3-6.5. Nota: "Fuerte" desaparece por definicion.
# 7.2 Escenario B (sin residual): excluir "Resto del mundo" (983 eventos, 3 zonas,
#     3 pares post-hoc) y repetir las mismas piezas.
# 7.3 Tablas espejo: efecto principal en base, A y B lado a lado (razones de tasa,
#     epsilon cuadrado, conclusion de Dunn por par, metricas de clasificacion).
#     Criterio: direccion y magnitud de los efectos, no p-valores.
# 7.4 Veredicto de robustez: que conclusiones se mantienen y cuales se debilitan.

message("12_inf_sensibilidad.R: stub pendiente de implementacion (Fase 7 / C8).")
