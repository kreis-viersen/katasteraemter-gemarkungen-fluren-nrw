#!/bin/bash

mkdir temp
mkdir data
wget -q "https://www.wfs.nrw.de/geobasis/wfs_nw_alkis_vereinfacht?service=WFS&version=1.1.0&request=GetFeature&srsname=EPSG:25832&typename=ave:KatasterBezirk&propertyname=art,gmdschl,name,schluessel&outputformat=application/x-zip-shapefile" -O "./temp/wfsdata.zip"
unzip ./temp/wfsdata.zip -d ./temp/
ogr2ogr -f GeoJSON -dialect SQLite -sql "SELECT art, name, schluessel, gmdschl FROM KatasterBezirk" ./temp/data.geojson ./temp/ALKIS-Vereinfacht/KatasterBezirk.shp
jq -c --argfile katasteraemter katasteraemter.json '.features[] | select(.properties.art|contains("Gemarkungsteil/Flur")|not ) | {name: (.properties.name + " (" + (.properties.schluessel | tostring | .[1:5]) +")"), schluessel: .properties.schluessel | tostring | .[1:5], gmdschl: .properties.gmdschl | tostring | .[1:5]} | .gmdschl |= $katasteraemter[.]' ./temp/data.geojson > ./temp/gemarkungen.txt
jq -c '.features[] | select(.properties.art|contains("Gemarkungsteil/Flur")) | {name: .properties.name | tonumber | tostring, schluessel: .properties.schluessel | tostring | .[1:5]}' ./temp/data.geojson > ./temp/fluren.txt
jq -c -S --null-input --slurpfile gemarkungen ./temp/gemarkungen.txt --slurpfile fluren ./temp/fluren.txt 'reduce $gemarkungen[] as $i ({}; setpath([$i.gmdschl, $i.name];{schluessel: $i.schluessel, fluren: [$fluren[] | select(.schluessel == $i.schluessel).name]}))' > ./data/katasteraemter-gemarkungen-fluren-nrw.json
rm -r temp
cd data
md5sum katasteraemter-gemarkungen-fluren-nrw.json > katasteraemter-gemarkungen-fluren-nrw.json.md5
