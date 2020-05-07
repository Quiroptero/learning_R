# MAPA INTERACTIVO DE CABECERAS MUNICIPALES

# Este script nos permite crear un mapa interactivo con marcadores en las
# cabeceras municipales y capitales estatales

# version de R: 4.0.0 (2020-04-24)
# plataforma: x86_64-w64-mingw32

# autor: Osvaldo Miranda
# LinkedIn: https://www.linkedin.com/in/miranda-osvaldo/
# Contacto: https://t.me/Osvaldo_Miranda

# Script escrito y probado en RStudio

# PAQUETES =====================================================================

# install.packages("dplyr")  # Para manipular tablas
# install.packages("openxlsx")  # Para manipular archivos xlsx
# install.packages("sf")  # Para leer archivos shape
# install.packages("leaflet")  # Para crear mapas interactivos en html
p <- c(
  "sf",
  "leaflet",
  "openxlsx",
  "dplyr"
)
lapply(p, library,character.only = TRUE)
rm(p)

# CARGA DE CATALOGO DE CABECERAS MUNICIPALES ===================================

setwd(file.path(Sys.getenv("USERPROFILE"), "Desktop"))
load("cat_ent_mun.RData")

# SHAPES =======================================================================

# Shapes
ruta_shps <- paste0(
  file.path(Sys.getenv("USERPROFILE"), "Desktop"), 
  "/INEGI/nacional/conjunto_de_datos/"
)
# Carga de shapes de municipios
s_mun <- st_read(paste0(ruta_shps, "00mun.shp")) 
# Transforma informacion geografica
s_mun <- st_transform(s_mun, "+proj=longlat +ellps=WGS84 +datum=WGS84")
s_mun <- select(s_mun, CVE_ENT, CVE_MUN, geometry)
# Se renombran variables
s_mun <- rename(s_mun, cve_ent = CVE_ENT, cve_mun = CVE_MUN)

rm(ruta_shps)

# DATOS A MAPEAR ===============================================================

# Clave INEGI de una entidad del pais
ent <- "11"

# Se une la informacion geografica de los shape con la informacion del catalogo
# de cabeceras municipales y se filtra por entidad
datos <- cat_ent_mun %>%
  left_join(s_mun, by = c("cve_ent", "cve_mun")) %>%
  filter(cve_ent == ent)

# MAPA CON CABECERAS MUNICIPALES ===============================================

# Crea el mapa
m <- leaflet() %>% 
  # Agrega un mapa base. Usar si se quiere tener un "fondo"
  # addTiles() %>% 
  # Agrega todos los municipios de la entidad elegida
  addPolygons(
    data = datos$geometry,   # Municipios a ser mapeados
    weight = 1,               # Grosor de la linea de frontera
    color = "#DAADDB",           # Color de la linea de frontera
    fillColor = "#F9F7D5",        # Color de relleno del poligono
    opacity = 1,              # Opacidad de la linea de frontera
    label = datos$nom_mun,
    fillOpacity = 1
  ) %>%
  # Agrega marcadores de capitales y cabeceras municipales
  addCircleMarkers(
    lng = as.numeric(datos$lon_decimal),  # Convierte a numerico los caracteres
    lat = as.numeric(datos$lat_decimal),  # Idem
    # El radio es mas grande si es una capital
    radius = ifelse(datos$capital == 1, 4, 3),
    # El color es rojo si es una capital y negro si es un municipio
    color = ifelse(datos$capital == 1, "red", "black"),
    stroke = F,  # Retira la linea de frontera de los marcadores circulares
    fillOpacity = 1
  )

m  # Visualizar mapa en Viewer
