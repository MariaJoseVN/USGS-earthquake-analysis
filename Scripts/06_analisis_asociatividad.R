# Matriz de correlacion numerica
matriz_correlacion_numericas <- sismos %>%
  select(where(is.numeric), -any_of(c("nst", "rms"))) %>%
  cor(method = "spearman", use = "pairwise.complete.obs") %>%
  round(3)

matriz_correlacion_numericas

