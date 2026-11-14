"""Genera los SVG de la marca FramBitácora (logo e ilustraciones).

Dibujo original: una frambuesa formada por drupéolas, con cáliz y una hoja.
Uso: python3 tool/brand_svgs.py   (escribe en assets/brand/)
"""
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "assets" / "brand"

LEAF = "#2F6B3A"       # verde hoja (color principal de la app)
LEAF_LIGHT = "#5FA36A"
LEAF_PALE = "#A9D8A6"
BERRY = "#C2185B"
BERRY_DARK = "#8E1243"
BERRY_LIGHT = "#E8618C"
CREAM = "#FFF8EC"


def drupelets(cx, cy, r, rows):
    """Centros de las drupéolas: filas de distinta cantidad, bien juntas."""
    out = []
    for i, n in enumerate(rows):
        y = cy + (i - (len(rows) - 1) / 2) * r * 1.42
        for j in range(n):
            x = cx + (j - (n - 1) / 2) * r * 1.68
            out.append((x, y))
    return out


def berry(cx, cy, r, mono=None):
    """Frambuesa (forma de dedal redondeado) con cáliz estrellado, tallo y hoja.

    mono = un solo color (ícono temático de Android 13).
    """
    import math

    parts = []
    rows = [4, 5, 6, 6, 5, 4, 2]
    pts = drupelets(cx, cy, r, rows)
    half_h = (len(rows) - 1) / 2 * r * 1.42
    # Silueta de fondo para que no queden huecos entre drupéolas.
    body = mono or BERRY_DARK
    parts.append(
        f'<ellipse cx="{cx:.2f}" cy="{cy + r * 0.2:.2f}" rx="{r * 4.6:.2f}" ry="{half_h + r * 0.6:.2f}" fill="{body}"/>'
    )
    for (x, y) in pts:
        if mono:
            parts.append(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="{r:.2f}" fill="{mono}"/>')
        else:
            parts.append(
                f'<circle cx="{x:.2f}" cy="{y:.2f}" r="{r * 0.95:.2f}" fill="{BERRY}" '
                f'stroke="{BERRY_DARK}" stroke-width="{r * 0.16:.2f}"/>'
            )
            parts.append(f'<circle cx="{x - r * 0.3:.2f}" cy="{y - r * 0.32:.2f}" r="{r * 0.3:.2f}" fill="{BERRY_LIGHT}"/>')
    top = cy - half_h - r * 0.4
    green = mono or LEAF_LIGHT
    dark = mono or LEAF
    # Cáliz: sépalos puntiagudos en estrella, abiertos sobre la fruta.
    s = r * 1.1
    for ang in (-170, -125, -90, -55, -10):
        a = math.radians(ang)
        length = s * (3.4 if ang in (-170, -10) else 2.8)
        tx, ty = cx + math.cos(a) * length, top + 0.6 * s + math.sin(a) * length * 0.7
        nx, ny = -math.sin(a) * s * 0.75, math.cos(a) * s * 0.75
        mx, my = (cx + tx) / 2, (top + ty) / 2
        parts.append(
            f'<path d="M{cx:.2f} {top:.2f} Q{mx + nx:.2f} {my + ny:.2f} {tx:.2f} {ty:.2f} '
            f'Q{mx - nx:.2f} {my - ny:.2f} {cx:.2f} {top:.2f}Z" fill="{green}"/>'
        )
    parts.append(f'<circle cx="{cx:.2f}" cy="{top - s * 0.1:.2f}" r="{s * 0.6:.2f}" fill="{dark}"/>')
    # Tallo y hoja.
    stem_top = top - s * 2.3
    parts.append(
        f'<path d="M{cx:.2f} {top - s * 0.3:.2f} C{cx - s * 0.1:.2f} {top - s * 1.2:.2f} {cx + s * 0.2:.2f} {stem_top + s * 0.5:.2f} '
        f'{cx + s * 0.4:.2f} {stem_top:.2f}" stroke="{dark}" stroke-width="{r * 0.6:.2f}" stroke-linecap="round" fill="none"/>'
    )
    lx, ly = cx + s * 0.3, stem_top + s * 0.7
    parts.append(
        f'<path d="M{lx:.2f} {ly:.2f} C{lx + s * 1.0:.2f} {ly - s * 1.7:.2f} {lx + s * 3.0:.2f} {ly - s * 1.5:.2f} {lx + s * 3.6:.2f} {ly - s * 1.0:.2f} '
        f'C{lx + s * 2.7:.2f} {ly + s * 0.5:.2f} {lx + s * 1.0:.2f} {ly + s * 0.6:.2f} {lx:.2f} {ly:.2f}Z" fill="{dark}"/>'
    )
    if not mono:
        parts.append(
            f'<path d="M{lx + s * 0.3:.2f} {ly - s * 0.1:.2f} Q{lx + s * 1.9:.2f} {ly - s * 1.0:.2f} {lx + s * 3.1:.2f} {ly - s * 1.0:.2f}" '
            f'stroke="{LEAF_PALE}" stroke-width="{r * 0.22:.2f}" stroke-linecap="round" fill="none"/>'
        )
    return "\n  ".join(parts)


def svg(view, body, size=None):
    w = f' width="{size}" height="{size}"' if size else ""
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view}"{w}>\n  {body}\n</svg>\n'


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    # Ícono adaptable de Android: lienzo de 108 con zona segura central de 66.
    fg = berry(54, 60, 3.1)
    (OUT / "launcher_foreground.svg").write_text(svg("0 0 108 108", fg))
    (OUT / "launcher_monochrome.svg").write_text(svg("0 0 108 108", berry(54, 60, 3.1, mono="#000000")))
    bg = f'<rect width="108" height="108" fill="{LEAF}"/>\n  <circle cx="54" cy="55" r="30" fill="{CREAM}"/>'
    (OUT / "launcher_background.svg").write_text(svg("0 0 108 108", bg))
    # Ícono clásico (Android antiguo) y logo para la app: recuadro redondeado.
    legacy = (
        f'<rect x="4" y="4" width="100" height="100" rx="24" fill="{LEAF}"/>\n'
        f'  <circle cx="54" cy="56" r="36" fill="{CREAM}"/>\n  {berry(54, 61, 3.9)}'
    )
    (OUT / "logo.svg").write_text(svg("0 0 108 108", legacy))
    # Ilustración para la pantalla sin proyectos: libreta de campo con frambuesa.
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
        f'  {rings}\n  {lines}\n'
        f'  <g transform="translate(82 64) scale(1.15)">{berry(54, 60, 4.4)}</g>'
    )
    (OUT / "empty_projects.svg").write_text(svg("0 0 200 200", empty))


if __name__ == "__main__":
    main()
