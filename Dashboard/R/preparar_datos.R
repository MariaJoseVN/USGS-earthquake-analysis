# =============================================================================
# preparar_datos.R
# -----------------------------------------------------------------------------
# Helper de preparacion de datos para el dashboard.
#
# Reune en una sola funcion limpia la logica que en el proyecto esta repartida
# en:
#   - Scripts/Codigo.R              (carga + variables derivadas + categorias)
#   - Scripts/02_tratamiento_NAs.R  (imputacion decadal de nst y rms)
#   - Scripts/07_analisis_espacial.R(asignacion de la variable zona con sf)
#
# A diferencia de esos scripts, aqui NO se dibujan graficos, NO se usa View()
# ni print(): solo se devuelve el data.frame `sismos` listo para el dashboard.
# Esto evita que el render de Quarto se rompa por efectos secundarios.
#
# Librerias utilizadas:
#   readr      -> read_csv()      : lectura rapida de CSV
#   dplyr      -> mutate/select/  : manipulacion y creacion de variables
#                 left_join/group_by/case_when
#   lubridate  -> ymd_hms/year/   : variables temporales a partir de `time`
#                 month
#   sf         -> st_read/st_as_sf/: interseccion espacial evento-zona
#                 st_join/st_transform
#
# COMO ADAPTAR:
#   - `ruta_proyecto` debe apuntar a la carpeta que contiene BBDD/ y SIG/.
#     Por defecto es ".." porque el dashboard.qmd vive en USGS-.../dashboard/
#     y los datos estan un nivel arriba (USGS-.../BBDD, USGS-.../SIG).
#   - Si mueves los CSV o el geojson, ajusta ruta_base, ruta_sig o ruta_geo.
#   - Si cambian los nombres de columnas del CSV (mag, depth, magType, ...),
#     actualiza los mutate() correspondientes.
# =============================================================================

preparar_datos <- function(ruta_proyecto = "..") {

  # --- Librerias (se cargan en silencio) -----------------------------------
  suppressPackageStartupMessages({
    library(readr)
    library(dplyr)
    library(lubridate)
    library(tidyr)
    library(sf)
  })

  # --- Rutas de entrada ------------------------------------------------------
  # file.path() arma rutas portables (sirve en Windows, Mac y Linux).
  ruta_base <- file.path(ruta_proyecto, "BBDD", "query.csv")
  ruta_sig  <- file.path(ruta_proyecto, "BBDD", "sig.csv")
  ruta_geo  <- file.path(ruta_proyecto, "SIG",  "area_regiones.geojson")

  # --- 1. Carga -------------------------------------------------------------
  # read_csv(show_col_types = FALSE) evita los mensajes de tipos de columna.
  sismos_raw <- read_csv(ruta_base, show_col_types = FALSE)
  sig_raw    <- read_csv(ruta_sig,  show_col_types = FALSE)

  # --- 2. Union con significancia y variables derivadas ---------------------
  # left_join() agrega la columna `sig` emparejando por el identificador `id`.
  # case_when() crea las categorias; factor() fija el orden de los niveles.
  sismos <- sismos_raw %>%
    left_join(sig_raw, by = "id") %>%
    mutate(
      # Variables temporales
      fecha_hora_utc = ymd_hms(time, tz = "UTC"),
      fecha          = as.Date(fecha_hora_utc),
      anio           = year(fecha_hora_utc),   # se usa `anio` (sin ñ) por robustez
      mes            = month(fecha_hora_utc),
      decada         = floor(anio / 10) * 10,

      # Categoria de profundidad (km): cortes geofisicos habituales
      profundidad_cat = factor(
        case_when(
          depth >= 0   & depth <= 70  ~ "Superficial",
          depth > 70   & depth <= 300 ~ "Intermedio",
          depth > 300                 ~ "Profundo"
        ),
        levels = c("Superficial", "Intermedio", "Profundo")
      ),

      # Categoria de magnitud: umbrales del informe (Gutenberg-Richter)
      magnitud_cat = factor(
        case_when(
          mag >= 6.5 & mag < 7.0 ~ "Fuerte",
          mag >= 7.0 & mag < 7.8 ~ "Mayor",
          mag >= 7.8             ~ "Grande o extremo",
          TRUE                   ~ NA_character_
        ),
        levels = c("Fuerte", "Mayor", "Grande o extremo")
      ),

      # Agrupacion del tipo de magnitud: 3 principales + "otros"
      magType_grupo = factor(
        case_when(
          magType %in% c("mww", "mwc", "mwb") ~ magType,
          TRUE                                ~ "otros"
        ),
        levels = c("mww", "mwc", "mwb", "otros")
      )
    ) %>%
    # select() deja solo las variables que el dashboard utiliza
    select(
      id, fecha_hora_utc, fecha, anio, mes, decada,
      latitude, longitude, depth, profundidad_cat,
      mag, sig, magnitud_cat, magType, magType_grupo,
      place, type, status, net, locationSource, magSource, nst, rms
    )

  # --- 3. Imputacion decadal de nst y rms (replica 02_tratamiento_NAs.R) -----
  # Se completa con la mediana de cada decada para conservar todos los eventos
  # sin trasladar valores extremos a los registros ausentes.
  sismos <- sismos %>%
    group_by(decada) %>%
    mutate(
      nst_imp = if_else(is.na(nst), median(nst, na.rm = TRUE), nst),
      rms_imp = if_else(is.na(rms), median(rms, na.rm = TRUE), rms)
    ) %>%
    ungroup()

  # --- 4. Asignacion de zona por interseccion espacial (replica 07) ----------
  # Se transforma cada evento en un punto (CRS 4326) y se cruza con los
  # poligonos de las zonas sismicas. Los eventos fuera de todo poligono quedan
  # como "Resto del mundo".
  area_regiones <- st_read(ruta_geo, quiet = TRUE)

  puntos_sismos <- st_as_sf(
    sismos,
    coords = c("longitude", "latitude"),
    crs = 4326,
    remove = FALSE          # conserva longitude/latitude como columnas
  ) %>%
    st_transform(st_crs(area_regiones))

  sf_use_s2(FALSE)          # geometria plana: evita errores en poligonos amplios

  puntos_sismos <- puntos_sismos %>%
    st_join(
      area_regiones %>% select(Region),
      join = st_intersects,
      left = TRUE
    )

  sismos <- puntos_sismos %>%
    mutate(
      zona = factor(
        if_else(is.na(Region), "Resto del mundo", as.character(Region)),
        levels = c(
          "Cinturon de Fuego",
          "Cinturon Alpino-Himalayo",
          "Dorsal Meso-Atlantica",
          "Resto del mundo"
        )
      ),
      # Marca dentro/fuera del Cinturon de Fuego (comparacion descriptiva)
      en_cinturon_fuego = if_else(
        zona == "Cinturon de Fuego",
        "Dentro del Cinturon de Fuego",
        "Fuera del Cinturon de Fuego"
      )
    ) %>%
    st_drop_geometry() %>%   # vuelve a data.frame normal (sin geometria)
    select(-Region)

  sf_use_s2(TRUE)            # restablece el comportamiento por defecto de sf

  sismos
}
