"""Genera los SVG de la marca FramBitácora a partir del símbolo del logo.

El símbolo (`assets/brand/symbol.svg`) es el logo elegido por el dueño: una frambuesa
cuyas drupéolas se convierten en circuitos, con hojas verdes. Se obtiene trazando la
imagen original con `tool/trace_logo.py`.

Uso: python3 tool/brand_svgs.py   (escribe en assets/brand/)
"""
import re
from pathlib import Path

BRAND = Path(__file__).resolve().parent.parent / "assets" / "brand"

LEAF = "#2F6B3A"
LEAF_PALE = "#A9D8A6"
CREAM = "#FFF8EC"


def symbol(mono=None):
    """Contenido del símbolo y su tamaño (ancho, alto). mono = un solo color."""
    text = (BRAND / "symbol.svg").read_text()
    w, h = (float(v) for v in re.search(r'viewBox="0 0 ([\d.]+) ([\d.]+)"', text).groups())
    paths = re.findall(r"<path[^>]*/>", text)
    if mono:
        paths = [re.sub(r'fill="#[0-9A-Fa-f]{6}"', f'fill="{mono}"', p) for p in paths]
    return "\n  ".join(paths), w, h


def placed(cx, cy, box, mono=None):
    """El símbolo centrado en (cx, cy), cabiendo en un cuadrado de lado `box`."""
    body, w, h = symbol(mono)
    s = box / max(w, h)
    return f'<g transform="translate({cx - w * s / 2:.3f} {cy - h * s / 2:.3f}) scale({s:.5f})">\n  {body}\n  </g>'


def svg(view, body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view}">\n  {body}\n</svg>\n'


def main():
    # Ícono adaptable de Android: lienzo de 108 con zona segura central (círculo de 66).
    (BRAND / "launcher_background.svg").write_text(svg("0 0 108 108", f'<rect width="108" height="108" fill="{CREAM}"/>'))
    (BRAND / "launcher_foreground.svg").write_text(svg("0 0 108 108", placed(54, 54, 50)))
    (BRAND / "launcher_monochrome.svg").write_text(svg("0 0 108 108", placed(54, 54, 50, mono="#000000")))
    # Ícono clásico (Android antiguo) y logo para documentos: recuadro crema redondeado.
    logo = (
        f'<rect x="4" y="4" width="100" height="100" rx="24" fill="{CREAM}" stroke="{LEAF_PALE}" stroke-width="1.5"/>\n'
        f"  {placed(54, 54, 78)}"
    )
    (BRAND / "logo.svg").write_text(svg("0 0 108 108", logo))
    # Ilustración para la pantalla sin proyectos: libreta de campo con el símbolo.
    rings = "\n  ".join(
        f'<rect x="38" y="{46 + i * 22}" width="16" height="7" rx="3.5" fill="{LEAF}"/>' for i in range(6)
    )
    lines = "\n  ".join(
        f'<path d="M66 {70 + i * 18}h{70 if i % 2 else 92}" stroke="{LEAF_PALE}" stroke-width="5" stroke-linecap="round"/>'
        for i in range(6)
    )
    empty = (
        f'<circle cx="100" cy="100" r="92" fill="{LEAF_PALE}" opacity="0.35"/>\n'
        f'  <rect x="44" y="30" width="112" height="146" rx="14" fill="{CREAM}" stroke="{LEAF}" stroke-width="4"/>\n'
        f"  {rings}\n  {lines}\n  {placed(146, 138, 76)}"
    )
    (BRAND / "empty_projects.svg").write_text(svg("0 0 200 200", empty))


if __name__ == "__main__":
    main()
