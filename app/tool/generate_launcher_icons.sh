#!/usr/bin/env bash
# Genera los íconos de Android a partir de los SVG de assets/brand/.
# Requiere Python 3 y Node con Playwright (Chromium). Uso: bash tool/generate_launcher_icons.sh
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tool/brand_svgs.py
RES=android/app/src/main/res
declare -A DENS=([mdpi]=1 [hdpi]=1.5 [xhdpi]=2 [xxhdpi]=3 [xxxhdpi]=4)
for d in "${!DENS[@]}"; do
  f=${DENS[$d]}
  legacy=$(python3 -c "print(round(48*$f))")
  adaptive=$(python3 -c "print(round(108*$f))")
  mkdir -p "$RES/mipmap-$d" "$RES/drawable-$d"
  node tool/render_svg.js "$RES/mipmap-$d/ic_launcher.png" "$legacy" assets/brand/logo.svg
  node tool/render_svg.js "$RES/drawable-$d/ic_launcher_foreground.png" "$adaptive" assets/brand/launcher_foreground.svg
  node tool/render_svg.js "$RES/drawable-$d/ic_launcher_background.png" "$adaptive" assets/brand/launcher_background.svg
  node tool/render_svg.js "$RES/drawable-$d/ic_launcher_monochrome.png" "$adaptive" assets/brand/launcher_monochrome.svg
done
echo "Íconos generados en $RES"
