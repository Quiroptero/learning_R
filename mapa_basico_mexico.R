# CARGA DE ARCHIVOS SHAPE Y CREACION DE UN MAPA SIMPLE DE MEXICO

# Este script nos permite utilizar la libreria Leaflet para crear dos mapas 
# basicos de Mexico: uno de la republica con division estatal y otro de un 
# estado especifico con division municipal.

# version de R: 3.6.3 (2020-02-29)
# plataforma: x86_64-w64-mingw32

# autor: Osvaldo Miranda
# LinkedIn: https://www.linkedin.com/in/miranda-osvaldo/
# Contacto: https://t.me/Osvaldo_Miranda

# CARGA DE PAQUETES NECESARIOS =================================================

p <- c(
  "sf",  # El paquete que nos permite leer los archivos shape
  "leaflet"  # El paquete que nos permite renderizar mapas interactivos
)
lapply(p, library, character.only = TRUE)
rm(p)

# CARGA DE SHAPES ==============================================================

# La ruta al directorio donde se encuentran los archivos shapes
# La informacion geografica de Mexico puede descargarse desde INEGI:
# https://www.inegi.org.mx/temas/mg/default.html#Descargas
ruta_shps <- paste0(
  file.path(Sys.getenv("USERPROFILE"),"Desktop"), 
  "/INEGI/Shapes/nacional/conjunto_de_datos/"
)

# Estados
# La funcion st_read nos permite leer el archivo shape
s_ent <- st_read(paste0(ruta_shps, "00ent.shp"))
# La funcion st_transform nos permite cambiar el tipo de coordenadas que viene
# por defecto en el archivo shape. No entiendo del todo (aun) la razon 
# cartografica de hacer esto, lo voy a investigar y agregare una explicacion
# al respecto.
s_ent <- st_transform(s_ent, "+proj=longlat +ellps=WGS84 +datum=WGS84")

# Municipios
s_mun <- st_read(paste0(ruta_shps, "00mun.shp")) 
s_mun <- st_transform(s_mun, "+proj=longlat +ellps=WGS84 +datum=WGS84")
# Selecciona las variables de interes
s_mun <- dplyr::select(s_mun, CVE_ENT, CVE_MUN, geometry)
# s_mun <- rename(s_mun, cve_ent = CVE_ENT, cve_mun = CVE_MUN)

rm(ruta_shps)

# MAPA DE TODO MEXICO CON DIVISION POR ESTADOS =================================

# La funcion leaflet nos permite renderizar los datos del shape
# Guardamos el mapa en un objeto (m) para manipularlo mas adelante
m <- leaflet() %>%
  # addTiles nos permite agregar capas de informacion. La capa por defecto es la 
  # de OpenStreetMaps
  addTiles() %>%
  # addPolygons nos permite dibujar los poligonos de nuestro archivo shape, en
  # este caso se trata de los estados del pais
  addPolygons(
    data = s_ent,  # Los datos geograficos a renderizar
    weight = 0.2,  # Grosor de la linea del poligono (la frontera)
    color = "gray",  # Color de la linea de frontera
    # fillColor = "blue",  # Color de relleno del poligono
    opacity = .3,  # Opacidad de la linea de frontera
    # fillOpacity = .1  # Opacidad del relleno del poligono
  )

m  # Visualizamos el mapa en Viewer de RStudio

# MAPA DE UN ESTADO ESPECIFICO CON DIVISION MUNICIPAL ==========================

m2 <- leaflet() %>%
  # addTiles nos permite agregar capas de informacion. La capa por defecto es la 
  # de OpenStreetMaps
  addTiles() %>%
  # addPolygons nos permite dibujar los poligonos de nuestro archivo shape, en
  # este caso se trata de los estados del pais
  addPolygons(
    # La clave del estado del INEGI, viene como caracter
    data = s_ent[s_ent$CVE_ENT == "01", ],
    weight = 0.2,
    color = "gray",
    # fillColor = "blue",
    opacity = .3,
    # fillOpacity = .1
  ) %>%
  addPolygons(
    data = s_mun[s_mun$CVE_ENT == "01", ],  # Los datos geograficos a renderizar
    weight = 0.2,  # Grosor de la linea del poligono (la frontera)
    color = "gray",  # Color de la linea de frontera
    # fillColor = "blue",  # Color de relleno del poligono
    opacity = .3,  # Opacidad de la linea de frontera
    # fillOpacity = .1  # Opacidad del relleno del poligono
  )

m2  # Visualizamos el mapa en Viewer de RStudio
