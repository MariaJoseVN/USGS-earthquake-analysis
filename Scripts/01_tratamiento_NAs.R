#Evaluacion e imputacion de nst y rms----

#Diagnostico minimo de datos faltantes----

faltantes_nst_rms <- sismos %>%
  summarise(
    nst_n_na = sum(is.na(nst)),
    nst_porcentaje_na = mean(is.na(nst)) * 100,
    rms_n_na = sum(is.na(rms)),
    rms_porcentaje_na = mean(is.na(rms)) * 100
  )

faltantes_nst_rms
#Imputacion por mediana decadal----
#Se conserva la estructura temporal general y se reduce la influencia de
#valores extremos.

sismos <- sismos %>%
  mutate(
    decada = floor(año / 10) * 10
  ) %>%
  group_by(decada) %>%
  mutate(
    nst_imp = if_else(is.na(nst), median(nst, na.rm = TRUE), nst),
    rms_imp = if_else(is.na(rms), median(rms, na.rm = TRUE), rms)
  ) %>%
  ungroup()


#Comparacion observada e imputada----

resumen_nst_rms_observado_imputado <- sismos %>%
  summarise(
    nst_observado_media = mean(nst, na.rm = TRUE),
    nst_imputado_media = mean(nst_imp, na.rm = TRUE),
    nst_observado_mediana = median(nst, na.rm = TRUE),
    nst_imputado_mediana = median(nst_imp, na.rm = TRUE),
    rms_observado_media = mean(rms, na.rm = TRUE),
    rms_imputado_media = mean(rms_imp, na.rm = TRUE),
    rms_observado_mediana = median(rms, na.rm = TRUE),
    rms_imputado_mediana = median(rms_imp, na.rm = TRUE)
  )

resumen_nst_rms_observado_imputado