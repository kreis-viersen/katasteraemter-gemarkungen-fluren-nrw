# katasteraemter-gemarkungen-fluren-nrw

[![Update](https://github.com/kreis-viersen/katasteraemter-gemarkungen-fluren-nrw/actions/workflows/update.yml/badge.svg)](https://github.com/kreis-viersen/katasteraemter-gemarkungen-fluren-nrw/actions/workflows/update.yml)

Dieses Repository dient dazu, automatisch Angaben zu Gemarkungen und Fluren in NRW auf Basis der WFS-Daten von https://www.wfs.nrw.de/geobasis/wfs_nw_alkis_vereinfacht?SERVICE=WFS&REQUEST=GetCapabilities&VERSION=1.1.0 (FeatureType `ave:KatasterBezirk`) strukturiert nach Katasterbezirken im JSON-Format bereit zu stellen.

## URL zum Abruf der JSON-Datei:
https://kreis-viersen.github.io/katasteraemter-gemarkungen-fluren-nrw/data/katasteraemter-gemarkungen-fluren-nrw.json

## Struktur der JSON-Datei:
<img src="./screenshot_json.png"/>

## Aktualisierungsrhythmus:

Die JSON-Datei und die Datei mit dem zugehörigen MD5-Hashwert im Verzeichnis `data` werden bei Bedarf täglich jede Nacht automatisch aktualisiert.

URL zum Abruf der Datei mit dem MD5-Hashwert:
https://kreis-viersen.github.io/katasteraemter-gemarkungen-fluren-nrw/data/katasteraemter-gemarkungen-fluren-nrw.json.md5

## Lizenz der Daten

Die Daten im Verzeichnis `data` stehen unter der Datenlizenz Deutschland – Zero – Version 2.0:<br>
https://www.govdata.de/dl-de/zero-2-0
