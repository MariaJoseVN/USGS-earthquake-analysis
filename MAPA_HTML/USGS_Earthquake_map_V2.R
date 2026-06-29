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
#Clasificar Sismos por profundidad
sismos$grupo_prof <- dplyr::case_when(
  sismos$profundidad >= 0 & sismos$profundidad <= 70 ~ "Superficial",
  sismos$profundidad > 70 & sismos$profundidad <= 300 ~ "Intermedio",
  sismos$profundidad > 300 ~ "Profundo",
  TRUE ~ "Sin clasificar"
)
#Clasificar Sismos por magnitud
sismos$grupo_mag <- dplyr::case_when(
  sismos$mag >= 6.5 & sismos$mag < 7.0 ~ "Fuerte",
  sismos$mag >= 7.0 & sismos$mag <= 7.8 ~ "Mayor",
  sismos$mag > 7.8 ~ "Grande o Extremo",
  TRUE ~ "Sin clasificar"
)

prof_min <- round(min(sismos$profundidad, na.rm = TRUE), 1)
prof_max <- round(max(sismos$profundidad, na.rm = TRUE), 1)
mag_min <- round(min(sismos$mag, na.rm = TRUE), 1)
mag_max <- round(max(sismos$mag, na.rm = TRUE), 1)

sismos_fuertes <- dplyr::filter(sismos, grupo_mag == "Fuerte")
sismos_mayores <- dplyr::filter(sismos, grupo_mag == "Mayor")
sismos_grandes <- dplyr::filter(sismos, grupo_mag == "Grande o Extremo")

sismos_superficiales <- dplyr::filter(sismos, grupo_prof == "Superficial")
sismos_intermedios <- dplyr::filter(sismos, grupo_prof == "Intermedio")
sismos_profundos <- dplyr::filter(sismos, grupo_prof == "Profundo")

#Crear mapa
agregar_sismos <- function(mapa, datos, nombre_grupo) {
  mapa %>%
    addCircleMarkers(
      data = datos,
      group = nombre_grupo,
      radius = ~radio,
      color = ~pal_prof(profundidad),
      fillColor = ~pal_prof(profundidad),
      fillOpacity = 0.75,
      stroke = TRUE,
      weight = 1,
      popup = ~paste0(
        "<b>", title, "</b>",
        "<br><b>Magnitud:</b> ", mag,
        "<br><b>Clasificación magnitud:</b> ", grupo_mag,
        "<br><b>Profundidad:</b> ", profundidad, " km",
        "<br><b>Clasificación profundidad:</b> ", grupo_prof,
        "<br><b>Fecha:</b> ", fecha,
        "<br><b>Lugar:</b> ", place
      )
    )
}

mapa <- leaflet() %>%
  setView(lng = 0, lat = 0, zoom = 2) %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Mapa claro", options = providerTileOptions(noWrap = TRUE)) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "Street Map", options = providerTileOptions(noWrap = TRUE)) %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Satelital", options = providerTileOptions(noWrap = TRUE))

mapa <- agregar_sismos(mapa, sismos, "Sismos - Todos")
mapa <- agregar_sismos(mapa, sismos_fuertes, "Sismos - Magnitud - Fuerte")
mapa <- agregar_sismos(mapa, sismos_mayores, "Sismos - Magnitud - Mayor")
mapa <- agregar_sismos(mapa, sismos_grandes, "Sismos - Magnitud - Grande")
mapa <- agregar_sismos(mapa, sismos_superficiales, "Sismos - Profundidad - Superficial")
mapa <- agregar_sismos(mapa, sismos_intermedios, "Sismos - Profundidad - Intermedio")
mapa <- agregar_sismos(mapa, sismos_profundos, "Sismos - Profundidad - Profundo")

mapa <- mapa %>%
  addPolylines(
    data = placas,
    group = "Placas tectónicas",
    color = ~color_boundary,
    weight = 2,
    opacity = 0.9,
    popup = ~paste0(
      "<b>Tipo:</b> ", tipo_boundary,
      "<br><b>Nombre:</b> ", Name
    )
  ) %>%
  addPolygons(
    data = zonas,
    group = "Zonas de estudio",
    color = ~color_zona,
    fillColor = ~color_zona,
    weight = 2,
    opacity = 1,
    fillOpacity = 0.25,
    popup = ~paste0("<b>Zona:</b> ", Region)
  ) %>%
  addLayersControl(
    baseGroups = c("Mapa claro", "Street Map", "Satelital"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  hideGroup(c(
    "Sismos - Magnitud - Fuerte",
    "Sismos - Magnitud - Mayor",
    "Sismos - Magnitud - Grande",
    "Sismos - Profundidad - Superficial",
    "Sismos - Profundidad - Intermedio",
    "Sismos - Profundidad - Profundo"
  )) %>%
  htmlwidgets::onRender(paste0("
    function(el, x) {
      var map = this;

      var panel = L.DomUtil.create('div', 'panel-capas-personalizado');
      panel.innerHTML = `
        <div style='background:white; padding:14px; border-radius:8px; box-shadow:0 0 10px rgba(0,0,0,0.25); font-size:13px; max-width:260px; line-height:1.35;'>
          <b style='font-size:15px;'>Control de capas</b>
          <hr>

          <label><input type='checkbox' id='chk-sismos' checked> <b>Sismos</b></label>

          <div style='margin-left:14px; margin-top:6px;'>
            <label><input type='radio' name='modo-sismos' value='todos' checked> Todos</label><br>
            <label><input type='radio' name='modo-sismos' value='magnitud'> Por magnitud</label><br>
            <label><input type='radio' name='modo-sismos' value='profundidad'> Por profundidad</label>
          </div>

          <div id='panel-magnitud' style='display:none; margin-left:22px; margin-top:6px;'>
            <label><input type='checkbox' class='chk-mag' value='Sismos - Magnitud - Fuerte' checked> Fuerte 6.5–7.0</label><br>
            <label><input type='checkbox' class='chk-mag' value='Sismos - Magnitud - Mayor' checked> Mayor 7.0–7.8</label><br>
            <label><input type='checkbox' class='chk-mag' value='Sismos - Magnitud - Grande' checked> Grande o Extremo >7.8</label>
          </div>

          <div id='panel-profundidad' style='display:none; margin-left:22px; margin-top:6px;'>
            <label><input type='checkbox' class='chk-prof' value='Sismos - Profundidad - Superficial' checked> Superficial 0–70 km</label><br>
            <label><input type='checkbox' class='chk-prof' value='Sismos - Profundidad - Intermedio' checked> Intermedio 70–300 km</label><br>
            <label><input type='checkbox' class='chk-prof' value='Sismos - Profundidad - Profundo' checked> Profundo >300 km</label>
          </div>

          <hr>

          <label><input type='checkbox' id='chk-placas' checked> <b>Placas tectónicas</b></label><br>
          <div style='margin-left:14px; margin-top:5px;'>
            <span style='display:inline-block;width:13px;height:13px;background:#984ea3;margin-right:5px;'></span>Límite Transformante<br>
            <span style='display:inline-block;width:13px;height:13px;background:#ff7f00;margin-right:5px;'></span>Límite Convergente<br>
            <span style='display:inline-block;width:13px;height:13px;background:#ffd92f;margin-right:5px;'></span>Límite Divergente<br>
            <span style='display:inline-block;width:13px;height:13px;background:#000000;margin-right:5px;'></span>Otros
          </div>

          <hr>

          <label><input type='checkbox' id='chk-zonas' checked> <b>Zonas de estudio</b></label><br>
          <div style='margin-left:14px; margin-top:5px;'>
            <span style='display:inline-block;width:13px;height:13px;background:#e41a1c;margin-right:5px;'></span>Cinturón de Fuego<br>
            <span style='display:inline-block;width:13px;height:13px;background:#377eb8;margin-right:5px;'></span>Cinturón Alpino-Himalayo<br>
            <span style='display:inline-block;width:13px;height:13px;background:#4daf4a;margin-right:5px;'></span>Dorsal Meso-Atlántica
          </div>

          <hr>

          <b>Profundidad</b><br>
          <div style='display:flex; align-items:stretch; gap:8px;'>
            <div style='height:110px;width:18px;background:linear-gradient(to bottom,#000004,#420a68,#932667,#dd513a,#fca50a,#fcffa4);'></div>
            <div style='height:110px;display:flex;flex-direction:column;justify-content:space-between;'>
              <span>", prof_max, " km</span>
              <span>", prof_min, " km</span>
            </div>
          </div>

          <hr>

          <b>Magnitud</b><br>
          <span style='display:inline-block;width:8px;height:8px;border-radius:50%;background:#555;margin-right:6px;'></span> Menor magnitud<br>
          <span style='display:inline-block;width:18px;height:18px;border-radius:50%;background:#555;margin-right:6px;'></span> Mayor magnitud
        </div>
      `;

      panel.style.position = 'absolute';
      panel.style.left = '55px';
      panel.style.top = '12px';
      panel.style.zIndex = 1000;

      el.appendChild(panel);
      L.DomEvent.disableClickPropagation(panel);
      L.DomEvent.disableScrollPropagation(panel);

      var gruposSismos = [
        'Sismos - Todos',
        'Sismos - Magnitud - Fuerte',
        'Sismos - Magnitud - Mayor',
        'Sismos - Magnitud - Grande',
        'Sismos - Profundidad - Superficial',
        'Sismos - Profundidad - Intermedio',
        'Sismos - Profundidad - Profundo'
      ];

      function getGroup(nombre) {
        if (!map.layerManager) return null;
        return map.layerManager.getLayerGroup(nombre, false);
      }

      function mostrarGrupo(nombre) {
        var grupo = getGroup(nombre);
        if (grupo && !map.hasLayer(grupo)) {
          grupo.addTo(map);
        }
      }

      function ocultarGrupo(nombre) {
        var grupo = getGroup(nombre);
        if (grupo && map.hasLayer(grupo)) {
          map.removeLayer(grupo);
        }
      }

      function ocultarTodosLosSismos() {
        gruposSismos.forEach(function(nombre) {
          ocultarGrupo(nombre);
        });
      }

      function actualizarSismos() {
        var activo = document.getElementById('chk-sismos').checked;
        var modo = document.querySelector('input[name=\"modo-sismos\"]:checked').value;

        ocultarTodosLosSismos();

        document.getElementById('panel-magnitud').style.display = modo === 'magnitud' ? 'block' : 'none';
        document.getElementById('panel-profundidad').style.display = modo === 'profundidad' ? 'block' : 'none';

        if (!activo) return;

        if (modo === 'todos') {
          mostrarGrupo('Sismos - Todos');
        }

        if (modo === 'magnitud') {
          document.querySelectorAll('.chk-mag').forEach(function(chk) {
            if (chk.checked) mostrarGrupo(chk.value);
          });
        }

        if (modo === 'profundidad') {
          document.querySelectorAll('.chk-prof').forEach(function(chk) {
            if (chk.checked) mostrarGrupo(chk.value);
          });
        }
      }

      function actualizarGrupoSimple(idCheckbox, nombreGrupo) {
        var activo = document.getElementById(idCheckbox).checked;
        if (activo) {
          mostrarGrupo(nombreGrupo);
        } else {
          ocultarGrupo(nombreGrupo);
        }
      }

      document.getElementById('chk-sismos').addEventListener('change', actualizarSismos);

      document.querySelectorAll('input[name=\"modo-sismos\"]').forEach(function(radio) {
        radio.addEventListener('change', actualizarSismos);
      });

      document.querySelectorAll('.chk-mag').forEach(function(chk) {
        chk.addEventListener('change', actualizarSismos);
      });

      document.querySelectorAll('.chk-prof').forEach(function(chk) {
        chk.addEventListener('change', actualizarSismos);
      });

      document.getElementById('chk-placas').addEventListener('change', function() {
        actualizarGrupoSimple('chk-placas', 'Placas tectónicas');
      });

      document.getElementById('chk-zonas').addEventListener('change', function() {
        actualizarGrupoSimple('chk-zonas', 'Zonas de estudio');
      });

      actualizarSismos();
      actualizarGrupoSimple('chk-placas', 'Placas tectónicas');
      actualizarGrupoSimple('chk-zonas', 'Zonas de estudio');
    }
  "))
#Guardado del HTML
saveWidget(mapa, "mapa_interactivo_sismos_v2.html", selfcontained = TRUE)