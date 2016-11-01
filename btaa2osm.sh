#!/bin/bash
# 
# Extrae, reproyecta, fusiona y convierte a formato OSM fenómenos BTAA.
# Las hojas deberán estar como las deja descargaBTAA.sh,
# descomprimidas en carpetas por municipio, por ejemplo:
# ./BTAA/Fuentes_de_Ebro
# 
# Santiago Crespo y Matías Taborda 2016 WTFL http://www.wtfpl.net/txt/copying/
# Es necesario tener la carpeta translations en la misma carpeta que este script

######## CONFIGURACIÓN ##########
# ¿Dónde tienes la BTAA?
DIRECTORIO_BTAA=/home/`whoami`/BTAA
######## FIN DE LA CONFIGURACIÓN ##########

LUGAR=$1
NOMBRE_BTAA=$2
NOMBRE_PROYECTO=$NOMBRE_BTAA-$LUGAR

if [ $# -ne 2 ] ; then
    echo "Uso: $0 Nombre-de-la-zona FENÓMENO-BTAA"
    echo "Por ejemplo, si el directorio con las hojas es $DIRECTORIO_BTAA/Guipuzkoa"
    echo "y los archivos con el elemento tienen nombres como BTA-ZA_2012_E05_384-64_Hidrografia_pol_BTAv1.0_25830.shp:"
    echo "$0 Fuentes_de_Ebro Hidrografia_pol"
    exit 1
fi

#if [ ! -f translations/$NOMBRE_BTAA.py ]; then
#    echo "ERROR! No encuentro la traducción que debería estar en translations/$NOMBRE_BTAA.py"
#    exit 1
#fi

if [ ! -d $DIRECTORIO_BTAA/$LUGAR ]; then
    echo "ERROR! No encuentro el directorio $DIRECTORIO_BTAA/$LUGAR"
    echo "Configura la variable DIRECTORIO_BTAA al principio del script"
    echo "o descarga los datos con descargaBTAA.sh."
    exit 1
fi

echo "## Copiando capas $NOMBRE_BTAA..."
RUTA_INICIAL="`pwd`"
cd $DIRECTORIO_BTAA/$LUGAR
rm -rf /tmp/fusionar ; mkdir /tmp/fusionar
find | grep $NOMBRE_BTAA | awk -F '/' '{print "cp -i ./"$2" /tmp/fusionar/"$2}' | sh

cd /tmp/fusionar
mkdir /tmp/fusionar/guardar
echo "## Fusionando shp..."
for f in *.shp; do ogr2ogr -update -append /tmp/fusionar/guardar/$NOMBRE_PROYECTO-25830.shp $f -f "ESRI Shapefile" 2> /dev/null; done;
rm *
mv guardar/* .
rmdir guardar

echo "## Reproyectando coordenadas a EPSG:4326..."
ogr2ogr -s_srs "+init=epsg:25830 +wktext" -t_srs EPSG:4326 $NOMBRE_PROYECTO.shp $NOMBRE_PROYECTO-25830.shp

echo "## Borrando archivos shp sobrantes..."
rm $NOMBRE_PROYECTO-*

echo "## Copiando archivos shp a $RUTA_INICIAL/$NOMBRE_PROYECTO..."
mkdir "$RUTA_INICIAL/$NOMBRE_PROYECTO"
cp /tmp/fusionar/* "$RUTA_INICIAL/$NOMBRE_PROYECTO/"

#echo "## Transformando $NOMBRE_PROYECTO.shp $NOMBRE_PROYECTO.osm..."
#cd "$RUTA_INICIAL"
#ogr2osm.py /tmp/fusionar/$NOMBRE_PROYECTO.shp -t $NOMBRE_BTAA -o "$RUTA_INICIAL/$NOMBRE_PROYECTO/$NOMBRE_PROYECTO.osm" && echo "## Creado $RUTA_INICIAL/$NOMBRE_PROYECTO/$NOMBRE_PROYECTO.osm :)" && exit 0

#echo "## Error al transformar :("
#exit 1
