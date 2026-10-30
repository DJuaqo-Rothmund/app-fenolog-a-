#!/usr/bin/env bash
# Publica el contenido de un archivo como anotaciones de error de GitHub Actions
# (bloques de 40 líneas, hasta 9), para leer los errores sin descargar los registros.
# Uso: annotate.sh <archivo> <título>
file="$1"; title="$2"
[ -s "$file" ] || exit 0
split -l 40 -d -a 2 "$file" /tmp/annot_
n=0
for part in /tmp/annot_*; do
  n=$((n + 1))
  [ "$n" -gt 9 ] && break
  body=$(sed -e 's/%/%25/g' -e 's/\r/%0D/g' "$part" | awk 'BEGIN{ORS="%0A"} {print}')
  echo "::error title=${title} (${n})::${body}"
done
rm -f /tmp/annot_*
