#!/bin/bash

mkdir temp
mkdir data
wget -q "https://www.wfs.nrw.de/geobasis/wfs_nw_alkis_vereinfacht?service=WFS&version=1.1.0&request=GetFeature&srsname=EPSG:25832&typename=ave:KatasterBezirk&propertyname=art,gmdschl,name,schluessel&outputformat=application/x-zip-shapefile" -O "./temp/wfsdata.zip"
unzip ./temp/wfsdata.zip -d ./temp/
ogr2ogr -f GeoJSON -dialect SQLite -sql "SELECT art, name, schluessel, gmdschl FROM KatasterBezirk" ./temp/data.geojson ./temp/ALKIS-Vereinfacht/KatasterBezirk.shp
jq -c --argfile katasteraemter katasteraemter.json '.features[] | select(.properties.art|contains("Gemarkungsteil/Flur")|not ) | {name: (.properties.name + " (" + (.properties.schluessel | tonumber | tostring | .[1:5]) +")"), schluessel: .properties.schluessel | tonumber | tostring | .[1:5], gmdschl: .properties.gmdschl | tonumber | tostring | .[0:4]} | .gmdschl |= $katasteraemter[.]' ./temp/data.geojson > ./temp/gemarkungen.txt
jq -c '.features[] | select(.properties.art|contains("Gemarkungsteil/Flur")) | {name: .properties.name | tonumber | tostring, schluessel: .properties.schluessel | tonumber | tostring | .[1:5]}' ./temp/data.geojson > ./temp/fluren.txt
jq -c -S --null-input --slurpfile gemarkungen ./temp/gemarkungen.txt --slurpfile fluren ./temp/fluren.txt 'reduce $gemarkungen[] as $i ({}; setpath([$i.gmdschl, $i.name];{schluessel: $i.schluessel, fluren: [$fluren[] | select(.schluessel == $i.schluessel).name]})) | if . == {} then empty else . end' > ./temp/katasteraemter-gemarkungen-fluren-nrw.json
if [ -s ./temp/katasteraemter-gemarkungen-fluren-nrw.json ]; then 
  mv ./temp/katasteraemter-gemarkungen-fluren-nrw.json ./data/katasteraemter-gemarkungen-fluren-nrw.json
fi

#GID7
mkdir temp/gid7
wget -q "https://www.wfs.nrw.de/geobasis/wfs_nw_alkis_vereinfacht_gid7?service=WFS&version=1.1.0&request=GetFeature&srsname=EPSG:25832&typename=ave:KatasterBezirk&propertyname=art,gmdschl,name,schluessel&outputformat=application/x-zip-shapefile" -O "./temp/gid7/wfsdata.zip"
unzip ./temp/gid7/wfsdata.zip -d ./temp/gid7/
ogr2ogr -f GeoJSON -dialect SQLite -sql "SELECT art, name, schluessel, gmdschl FROM KatasterBezirk" ./temp/gid7/data.geojson ./temp/gid7/ALKIS-Vereinfacht/KatasterBezirk.shp
jq -c --argfile katasteraemter katasteraemter.json '.features[] | select(.properties.art|contains("Gemarkungsteil/Flur")|not ) | {name: (.properties.name + " (" + (.properties.schluessel | tonumber | tostring | .[1:5]) +")"), schluessel: .properties.schluessel | tonumber | tostring | .[1:5], gmdschl: .properties.gmdschl | tonumber | tostring | .[0:4]} | .gmdschl |= $katasteraemter[.]' ./temp/gid7/data.geojson > ./temp/gid7/gemarkungen.txt
jq -c '.features[] | select(.properties.art|contains("Gemarkungsteil/Flur")) | {name: .properties.name | tonumber | tostring, schluessel: .properties.schluessel | tonumber | tostring | .[1:5]}' ./temp/gid7/data.geojson > ./temp/gid7/fluren.txt
jq -c -S --null-input --slurpfile gemarkungen ./temp/gid7/gemarkungen.txt --slurpfile fluren ./temp/gid7/fluren.txt 'reduce $gemarkungen[] as $i ({}; setpath([$i.gmdschl, $i.name];{schluessel: $i.schluessel, fluren: [$fluren[] | select(.schluessel == $i.schluessel).name]})) | if . == {} then empty else . end' > ./temp/gid7/katasteraemter-gemarkungen-fluren-nrw.json
if [ -s ./temp/gid7/katasteraemter-gemarkungen-fluren-nrw.json ]; then 
  mv ./temp/gid7/katasteraemter-gemarkungen-fluren-nrw.json ./data/katasteraemter-gemarkungen-fluren-nrw_gid7.json
fi

rm -r temp
cd data
md5sum katasteraemter-gemarkungen-fluren-nrw.json > katasteraemter-gemarkungen-fluren-nrw.json.md5
md5sum katasteraemter-gemarkungen-fluren-nrw_gid7.json > katasteraemter-gemarkungen-fluren-nrw_gid7.json.md5
