#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUT_DIR="$ROOT_DIR/data"
OUT="$OUT_DIR/katasteraemter-gemarkungen-fluren-nrw.json"
OFFICES="$ROOT_DIR/katasteraemter.json"

mkdir -p "$OUT_DIR"

ogr2ogr \
  -f GeoJSON \
  -oo PAGE_SIZE=10000 \
  -select art,name,schluessel,gmdschl \
  -nlt NONE \
  "$TMP_DIR/data.geojson" \
  "OAPIF:https://ogc-api.nrw.de/lika/v1" \
  katasterbezirk

jq -c \
  --slurpfile katasteraemter "$OFFICES" \
  '
    .features[]
    | select(.properties.art | contains("Gemarkungsteil/Flur") | not)
    | {
        name:
          (
            .properties.name
            + " ("
            + (.properties.schluessel | tonumber | tostring | .[1:5])
            + ")"
          ),
        schluessel:
          (.properties.schluessel | tonumber | tostring | .[1:5]),
        gmdschl:
          (.properties.gmdschl | tonumber | tostring | .[0:4])
      }
    | .gmdschl |= $katasteraemter[0][.]
  ' \
  "$TMP_DIR/data.geojson" \
  > "$TMP_DIR/gemarkungen.txt"

jq -c \
  '
    .features[]
    | select(.properties.art | contains("Gemarkungsteil/Flur"))
    | {
        name:
          (
            (
              .properties.name
              // .properties.schluessel[-3:]
            )
            | tonumber
            | tostring
          ),
        schluessel:
          (.properties.schluessel | tonumber | tostring | .[1:5])
      }
  ' \
  "$TMP_DIR/data.geojson" \
  > "$TMP_DIR/fluren.txt"

jq -c -S \
  --null-input \
  --slurpfile gemarkungen "$TMP_DIR/gemarkungen.txt" \
  --slurpfile fluren "$TMP_DIR/fluren.txt" \
  '
    reduce $gemarkungen[] as $i
      ({};
        setpath(
          [$i.gmdschl, $i.name];
          {
            schluessel: $i.schluessel,
            fluren:
              (
                [
                  $fluren[]
                  | select(.schluessel == $i.schluessel)
                  .name
                  | tonumber
                ]
                | sort
                | map(tostring)
              )
          }
        )
      )
    | if . == {} then empty else . end
  ' \
  > "$TMP_DIR/index.json"

if [ ! -s "$TMP_DIR/index.json" ]; then
  echo "Erzeugtes JSON ist leer." >&2
  exit 1
fi

mv "$TMP_DIR/index.json" "$OUT"
md5sum "$OUT" | awk '{print $1}' > "${OUT}.md5"
