"""Traza el logo original (assets/brand/source/logo_original.jpg) a SVG en dos colores.

Uso: python3 tool/trace_logo.py assets/brand/source/logo_original.jpg assets/brand/symbol.svg
Requiere: pip install potracer pillow numpy
"""
import sys
import numpy as np
from PIL import Image, ImageFilter
import potrace

src, out = sys.argv[1], sys.argv[2]
im = Image.open(src).convert("RGB")
a = np.asarray(im).astype(int)
r, g, b = a[..., 0], a[..., 1], a[..., 2]
red = (r > 140) & (g < 110) & (b < 140) & (r - g > 70)
green = (g > 70) & (g - r > 25) & (g - b > 10) & (r < 120)
ys, xs = np.where(red | green)
x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
print("bounds", x0, x1, y0, y1)
S = 4  # escala para trazar con más detalle


def mask(m):
    crop = Image.fromarray((m[y0 - 4 : y1 + 5, x0 - 4 : x1 + 5] * 255).astype("uint8"))
    crop = crop.resize((crop.width * S, crop.height * S), Image.LANCZOS).filter(ImageFilter.GaussianBlur(2))
    return np.asarray(crop) > 127


def trace(m, color):
    bmp = potrace.Bitmap(~m)
    path = bmp.trace(turdsize=40, alphamax=1.0, opticurve=True, opttolerance=0.3)
    d = []
    for curve in path:
        sp = curve.start_point
        d.append(f"M{sp.x / S:.2f} {sp.y / S:.2f}")
        for seg in curve.segments:
            if seg.is_corner:
                d.append(f"L{seg.c.x / S:.2f} {seg.c.y / S:.2f}L{seg.end_point.x / S:.2f} {seg.end_point.y / S:.2f}")
            else:
                d.append(
                    f"C{seg.c1.x / S:.2f} {seg.c1.y / S:.2f} {seg.c2.x / S:.2f} {seg.c2.y / S:.2f} "
                    f"{seg.end_point.x / S:.2f} {seg.end_point.y / S:.2f}"
                )
        d.append("Z")
    return f'<path fill="{color}" fill-rule="evenodd" d="{"".join(d)}"/>'


w, h = (x1 - x0) + 9, (y1 - y0) + 9
body = trace(mask(green), "#2F6B3A") + "\n  " + trace(mask(red), "#C2185B")
open(out, "w").write(
    f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">\n  {body}\n</svg>\n'
)
print("size", w, h)
