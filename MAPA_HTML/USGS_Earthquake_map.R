#Bloque de importación de librerías
library(sf)              #Lectura, tranformación y manejo de Json y GeoJson
library(leaflet)         #Crear el mapa interactivo
library(htmlwidgets)     #Permite guardar el HTML e insertar JavaScript
library(dplyr)           #Sirve para manipular datos
library(viridis)         #Permite usar paletas de colores
library(stringr)         #Sirve para buscar texto dentro de columnas

#Lectura de archivos
#Toma los archivos espaciales y los tranformar en objetos sf
sismos <- st_read("Datos/sismos.json", quiet = TRUE)
placas <- st_read("Datos/placas.geojson", quiet = TRUE)
zonas  <- st_read("Datos/zonas.geojson", quiet = TRUE)

#Extracción de coordenadas y profundidad
coords <- st_coordinates(sismos)        #Extrae coordenadas X,Y,Z
sismos$profundidad <- coords[, "Z"]     #Agrega a sismos una columna llamada profundidad con el valor correspondiente

#Eliminar dimensión Z
#Esto para evitar errores dado que Leaflet dibuja en 2D
sismos <- st_zm(sismos, drop = TRUE, what = "ZM")
placas <- st_zm(placas, drop = TRUE, what = "ZM")

#Sistema de coordenadas
#Establece que las capas están en SRC WGS84 (lat, lon)
st_crs(sismos) <- 4326
st_crs(placas) <- 4326
st_crs(zonas)  <- 4326

#Clasificación de límites tectónicos
#Crea una nueva capa llamada tipo_boundary con el tipo de límite tectónico correspondiente
placas$tipo_boundary <- dplyr::case_when(
  str_detect(placas$description, regex("Transform Boundary", ignore_case = TRUE)) ~ "Límite Transformante",
  str_detect(placas$description, regex("Convergent Boundary", ignore_case = TRUE)) ~ "Límite Convergente",
  str_detect(placas$description, regex("Divergent Boundary", ignore_case = TRUE)) ~ "Límite Divergente",
  TRUE ~ "Otros"
)

#Colores de límites tectónicos
#Crea una nueva capa llamada color_boundary con el color del límite tectónico correspondiente
placas$color_boundary <- dplyr::case_when(
  placas$tipo_boundary == "Límite Transformante" ~ "#984ea3",
  placas$tipo_boundary == "Límite Convergente" ~ "#ff7f00",
  placas$tipo_boundary == "Límite Divergente" ~ "#ffd92f",
  TRUE ~ "#000000"
)

#Corrección de zonas que cruzan el antimeridiano
zonas <- st_wrap_dateline(
  zonas,
  options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180"),
  quiet = TRUE
)

#Formato de fecha
# Transforma el formato de fecha a uno más legible
sismos$fecha <- as.POSIXct(sismos$time / 1000, origin = "1970-01-01", tz = "UTC")

#Colores de zona
#Crea una nueva capa llamada color_zona con el color de la zona correspondiente
zonas$color_zona <- dplyr::case_when(
  zonas$Region == "Cinturon de Fuego" ~ "#e41a1c",
  zonas$Region == "Cinturon Alpino-Himalayo" ~ "#377eb8",
  zonas$Region == "Dorsal Meso-Atlantica" ~ "#4daf4a",
  TRUE ~ "#000000"
)

#Paleta de profundidad
#Crea una paleta de colores para profundidad, se usa la paleta inferno inversa
pal_prof <- colorNumeric(
  palette = rev(viridisLite::inferno(256)),
  domain = sismos$profundidad
)

#Tamaño por magnitud
#Convierte la magnitud de los sismos en tamaño de puntos, con un radio que va de 4 a 30
sismos$radio <- scales::rescale(
  sismos$mag,
  to = c(4, 30)
)

#Crear mapa
mapa <- leaflet()%>%   #Inicia un mapa en leaflet vacío
  setView(lng = 0, lat = 0, zoom = 2) %>%  #Centra el mapa el longitud y latitud 0, con un zoom 2
  #Añade mapas base, noWrap = TRUE evita que el mapa se repita hacia los lados
  addProviderTiles(providers$CartoDB.Positron, group = "Mapa claro",options = providerTileOptions(noWrap = TRUE)) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "Street Map",options = providerTileOptions(noWrap = TRUE)) %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Satelital",options = providerTileOptions(noWrap = TRUE)) %>%
  #Añade capa de sismos como puntos circulares
  addCircleMarkers(
    data = sismos,      #Utiliza la capa sismos
    group = "Sismos",   #Permite activar/desactivar esta capa
    radius = ~radio,    #El tamaño del punto depende de la magnitud
    color = ~pal_prof(profundidad),    #Borde depende de la profundidad
    fillColor = ~pal_prof(profundidad),    #Relleno depende la profundidad
    fillOpacity = 0.75,    #Hace los puntos semitransparente
    stroke = TRUE,    #Activa borde
    weight = 1,    #Le da grosor 1 al borde
    #Crea una ventana emergente con esa información
    popup = ~paste0(
      "<b>", title, "</b>",
      "<br><b>Magnitud:</b> ", mag,
      "<br><b>Profundidad:</b> ", profundidad, " km",
      "<br><b>Fecha:</b> ", fecha,
      "<br><b>Lugar:</b> ", place
    )
  ) %>%
  #Añade capa de placas como polilinea
  addPolylines(
    data = placas,
    group = "Placas tectónicas",
    color = ~color_boundary, #Color depende de color_boundary definido antes
    weight = 2,
    opacity = 0.9,
    popup = ~paste0(
      "<b>Tipo:</b> ", tipo_boundary,
      "<br><b>Nombre:</b> ", Name
    )
  ) %>%
  #Añade capa de zonas como poligonos
  addPolygons(
    data = zonas,
    group = "Zonas de estudio",
    color = ~color_zona, #Borde depende de color_zona definido antes
    fillColor = ~color_zona, #Relleno depende de color_zona definido antes
    weight = 2,
    opacity = 1,
    fillOpacity = 0.25,
    popup = ~paste0("<b>Zona:</b> ", Region)
  ) %>%
  #Control de capas
  #Crea el menú superior derecho
  addLayersControl(
    baseGroups = c("Mapa claro", "Street Map", "Satelital"),  #Mapas base, solo 1 activo
    overlayGroups = c("Sismos", "Placas tectónicas", "Zonas de estudio"),#Capas superpuestas, se pueden activar varias
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  #Leyenda de profundidad
  #Se crea en la esquina inferior izquierda
  addLegend(
    position = "bottomleft",
    pal = pal_prof,
    values = sismos$profundidad,
    title = "Profundidad (km)",
    opacity = 0.9,
    group = "Sismos"
  ) %>%
  #Leyenda de zonas de estudio
  addLegend(
    position = "bottomleft",
    colors = unique(zonas$color_zona),
    labels = unique(zonas$Region),
    title = "Zonas de estudio",
    opacity = 0.8,
    group = "Zonas de estudio"
  ) %>%
  #Leyenda de placas tectónicas
  addLegend(
    position = "bottomleft",
    colors = unique(placas$color_boundary),
    labels = unique(placas$tipo_boundary),
    title = "Límites tectónicos",
    opacity = 1,
    group = "Placas tectónicas"
  ) %>%
  #Leyenda manual de magnitud
  #Dado que la magnitud depende de el tamaño de los puntos, se creó una escala manual que lo diera a entender
  #Inserta un JavaScript personalizado
  htmlwidgets::onRender("  
    function(el, x) {
      var map = this;
      var magnitudLegend = L.control({position: 'bottomleft'});

      magnitudLegend.onAdd = function(map) {
        var div = L.DomUtil.create('div', 'legend-magnitud');
        div.innerHTML =
          '<div style=\"background:white; padding:10px; border-radius:6px; box-shadow:0 0 8px rgba(0,0,0,0.25); font-size:13px; line-height:1.4;\">' +
          '<b>Magnitud</b><br>' +
          '<span style=\"display:inline-block; width:8px; height:8px; border-radius:50%; background:#555; margin-right:6px;\"></span> Menor magnitud<br>' +
          '<span style=\"display:inline-block; width:16px; height:16px; border-radius:50%; background:#555; margin-right:6px;\"></span> Mayor magnitud' +
          '</div>';
        return div;
      };

      magnitudLegend.addTo(map);

      map.on('overlayadd', function(e) {
        if (e.name === 'Sismos') {
          magnitudLegend.addTo(map);
        }
      });

      map.on('overlayremove', function(e) {
        if (e.name === 'Sismos') {
          map.removeControl(magnitudLegend);
        }
      });
    }
  ")
#Guardado del HTML
saveWidget(mapa, "mapa_interactivo_sismos.html", selfcontained = TRUE)