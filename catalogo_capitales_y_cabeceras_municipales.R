# CATALOGO DE CAPITALES Y CABECERAS MUNICIPALES

# Este programa arma un catalogo de capitales y cabeceras municipales con la
# informacion que proporciona el INEGI. El objetivo de este catalogo es
# identificar en un mapa las cabeceras municipales del pais.

# El Catalogo Unico de Claves de Areas Geoestadisticas Estatales, 
# Municipales y Localidades puede descargarse aqui:
# https://www.inegi.org.mx/app/ageeml/
# Hay que consultar y descargar dos niveles de desagregacion:
# 1. Localidad Geoestadistica
# 2. Area Geoestadistica Municipal

# version de R: 4.0.0 (2020-04-24)
# plataforma: x86_64-w64-mingw32

# autor: Osvaldo Miranda
# LinkedIn: https://www.linkedin.com/in/miranda-osvaldo/
# Contacto: https://t.me/Osvaldo_Miranda

# Script escrito y probado en RStudio

# PAQUETES =====================================================================

# install.packages("dplyr")  # Para manipular tablas
# install.packages("openxlsx")  # Para manipular archivos xlsx
lapply(c("dplyr", "openxlsx"), library, character.only = TRUE)

# CARGA DE DATOS ===============================================================

setwd(file.path(Sys.getenv("USERPROFILE"), "Desktop"))

# Leemos los archivos descargados de INEGI, uno con la informacion a nivel
# localidad y otro a nivel municipal
loc <- read.xlsx("AGEEML_LOC.xlsx")  # Localidades
mun <- read.xlsx("AGEEML_MUN.xlsx")  # Municipios

# MODIFICA LA ESTRUCTURA ORIGINAL DE LOS CATALOGOS =============================

# Remueve renglones sobrantes y cambia nombres a datos de localidad
names(loc) <- loc[3, ]
loc <- loc[-c(1:3), ]
names(loc)[c(9, 19)] <- c("ambito", "total_viviendas_habitadas")

# Remueve renglones sobrantes y cambia nombres a datos de municipios
names(mun) <- mun[3, ]
mun <- mun[-c(1:3), ]
names(mun)[9] <- c("total_viviendas_habitadas")

# GENERA EL CATALOGO DE CAPITALES ESTATALES Y CABECERAS MUNICIPALES ============

# Obtiene por municipio las localidades que son cabeceras municipales
df <- mun %>%
  left_join(
    select(
      loc,
      cve_ent, cve_mun, cve_loc, nom_loc, lat_decimal, lon_decimal
    ),
    by = c("cve_ent", "cve_mun", "cve_cab" = "cve_loc")
  ) %>%
  mutate(capital = 0) %>%
  select(
    cve_ent,
    nom_ent,
    cve_mun,
    nom_mun,
    cve_cab,
    nom_cab,
    capital,
    lon_decimal,
    lat_decimal,
    Pob_total,
    Pob_masculina,
    Pob_femenina,
    total_viviendas_habitadas
  )

# Vector que contiene la cve_mun de las capitales estatales
# Seria preferible tener esta informacion en un archivo externo, para evitar
# el codigo duro dentro del script
v <- c(
  "001", # Aguascalientes
  "002", # Baja California
  "003", # Baja California Sur
  "002", # Campeche
  "030", # Coahuila de Zaragoza
  "002", # Colima
  "101", # Chiapas
  "019", # Chihuahua
  "", # Espacio para CDMX
  "005", # Durango
  "015", # Guanajuato
  "029", # Guerrero
  "048", # Hidalgo
  "039", # Jalisco
  "106", # Mexico
  "053", # Michoacan de Ocampo
  "007", # Morelos
  "017", # Nayarit
  "039", # Nuevo Leon
  "067", # Oaxaca
  "114", # Puebla
  "014", # Queretaro
  "004", # Quintana Roo
  "028", # San Luis Potosi
  "006", # Sinaloa
  "030", # Sonora
  "004", # Tabasco
  "041", # Tamaulipas
  "033", # Tlaxcala
  "087", # Veracruz de Ignacio de la Llave
  "050", # Yucatan
  "056" # Zacatecas
)

# Cambiar a 1 la variable capital para indicar capitales de los estados
for (i in c(1:8, 10:32)) {  # Se excluye CDMX
  df$capital[df$cve_ent == unique(df$cve_ent)[i] & df$cve_mun == v[i]] <- 1
}

# Lista con latitud y longitud de las demarcaciones de CDMX
# Esta informacion se obtuvo a mano:
# No encontre ningun catalogo que la incluyera, por lo que busque en Google Maps
# la localizacion geografica de la alcaldia de cada demarcacion territorial

# Seria preferible tener esta informacion en un archivo externo, para evitar
# el codigo duro dentro del script

l <- list(
  c(  # Vector con la latitud de las demarcaciones
    19.484158, # Azcapotzalco
    19.350380, # Coyoacan
    19.357896, # Cuajimalpa de Morelos
    19.482558, # Gustavo A. Madero
    19.396325, # Iztacalco
    19.359351, # Iztapalapa
    19.304728, # La Magdalena Contreras
    19.191364, # Milpa Alta
    19.389579, # Álvaro Obregon
    19.270541, # Tlahuac
    19.288025, # Tlalpan
    19.263424, # Xochimilco
    19.371565, # Benito Juarez
    19.441644, # Cuauhtemoc
    19.407370, # Miguel Hidalgo
    19.419284 # Venustiano Carranza
  ),
  c(  # Vector con la longitud de las demarcaciones
    -99.184413, # Azcapotzalco
    -99.162259, # Coyoacan
    -99.299480, # Cuajimalpa de Morelos
    -99.113097, # Gustavo A. Madero
    -99.097304, # Iztacalco
    -99.092515, # Iztapalapa
    -99.241493, # La Magdalena Contreras
    -99.023463, # Milpa Alta
    -99.195617, # Álvaro Obregon
    -99.004887, # Tlahuac
    -99.167062, # Tlalpan
    -99.104816, # Xochimilco
    -99.158923, # Benito Juarez
    -99.151859, # Cuauhtemoc
    -99.190953, # Miguel Hidalgo
    -99.113187 # Venustiano Carranza
  )
)

# Agregamos la informacion de la lista al dataframe, para la CDMX
df[df$cve_ent == "09", c("lat_decimal", "lon_decimal")] <- l

# Renombramos el dataframe
cat_ent_mun <- df

rm(l, i, v, df)

# EXPORTACION ==================================================================

write.xlsx(cat_ent_mun, "cat_ent_mun.xlsx")  # Como archivo xlsx
save(cat_ent_mun, file = "cat_ent_mun.RData")  # Como archivo RData
