"""Genera las ilustraciones de la guía de fotos (dibujos originales, estilo plano).

Uso: python3 tool/guide_svgs.py   (escribe en assets/guide/)
"""
import math
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "assets" / "guide"

LEAF = "#2F6B3A"
LEAF2 = "#4E8A57"
LEAF3 = "#7DB46C"
PALE = "#CFE8C8"
BERRY = "#C2185B"
BERRY_D = "#8E1243"
BERRY_L = "#E8618C"
PINK = "#F29BB5"
GREENFRUIT = "#A8C97A"
GREENFRUIT_D = "#7FA352"
CREAM = "#FFF8EC"
SKY = "#E4F1E6"
SOIL = "#9B7B5B"
SOIL_D = "#7A5E44"
CANE = "#8A6A4A"
SUN = "#F6C445"
SKIN = "#E9B38C"
SKIN_D = "#D19570"
SHIRT = "#3E6E8E"
PANTS = "#3B4752"
PHONE = "#263238"
WHITE = "#FFFFFF"
GREY = "#9AA5A0"
YELLOW = "#E9C46A"
BROWN = "#B07A43"


def svg(w, h, body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">\n{body}\n</svg>\n'


def leaf(cx, cy, length, angle, color=LEAF2, vein=True):
    """Hoja en forma de lanza, centrada en su base (cx, cy), girada `angle` grados."""
    l, w = length, length * 0.42
    d = f"M0 0 C{w} {-l * 0.25} {w * 0.8} {-l * 0.8} 0 {-l} C{-w * 0.8} {-l * 0.8} {-w} {-l * 0.25} 0 0Z"
    v = f'<path d="M0 0 L0 {-l * 0.85}" stroke="{PALE}" stroke-width="{max(0.8, l * 0.05):.1f}" fill="none" opacity="0.8"/>' if vein else ""
    return f'<g transform="translate({cx:.1f} {cy:.1f}) rotate({angle})"><path d="{d}" fill="{color}"/>{v}</g>'


def berry(cx, cy, r, color=BERRY, dark=BERRY_D, light=BERRY_L, calyx=True):
    """Frambuesa pequeña de drupéolas."""
    out = [f'<ellipse cx="{cx}" cy="{cy + r * 0.1}" rx="{r * 1.05}" ry="{r * 1.2}" fill="{dark}"/>']
    d = r * 0.36
    rows = [(-0.75, 2), (-0.25, 3), (0.25, 3), (0.75, 2)]
    for fy, n in rows:
        for j in range(n):
            x = cx + (j - (n - 1) / 2) * d * 1.75
            y = cy + fy * r * 1.15
            out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{d:.1f}" fill="{color}"/>')
            out.append(f'<circle cx="{x - d * 0.3:.1f}" cy="{y - d * 0.3:.1f}" r="{d * 0.32:.1f}" fill="{light}"/>')
    if calyx:
        for a in (-60, -20, 20, 60):
            out.append(leaf(cx, cy - r * 1.15, r * 0.7, a, LEAF3, vein=False))
    return "".join(out)


def plant(x, ground, h, flip=False, fruits=True):
    """Planta de frambueso en hilera: cañas con hojas y algunos frutos."""
    out = []
    s = -1 if flip else 1
    for i, (dx, hh, lean) in enumerate([(-10, 1.0, -8), (0, 0.92, 4), (10, 0.98, 10)]):
        top = ground - h * hh
        bx = x + dx
        tx = bx + lean * s
        out.append(f'<path d="M{bx} {ground} Q{bx + lean * 0.3 * s} {(ground + top) / 2} {tx} {top}" stroke="{CANE}" stroke-width="2.4" fill="none" stroke-linecap="round"/>')
        for k in range(6):
            t = 0.25 + k * 0.13
            px = bx + (tx - bx) * t
            py = ground + (top - ground) * t
            out.append(leaf(px, py, h * 0.17, (-55 if k % 2 else 55) + lean, [LEAF, LEAF2, LEAF3][(k + i) % 3]))
        if fruits:
            out.append(berry(bx + (tx - bx) * 0.55 + 6 * s, ground + (top - ground) * 0.55 + 6, h * 0.035))
    return "".join(out)


def person(x, ground, facing=1):
    """Persona sencilla sosteniendo un teléfono a la altura del pecho."""
    f = facing
    return (
        f'<rect x="{x - 9}" y="{ground - 46}" width="8" height="46" rx="4" fill="{PANTS}"/>'
        f'<rect x="{x + 1}" y="{ground - 46}" width="8" height="46" rx="4" fill="{PANTS}"/>'
        f'<rect x="{x - 13}" y="{ground - 92}" width="26" height="50" rx="11" fill="{SHIRT}"/>'
        f'<circle cx="{x}" cy="{ground - 104}" r="12" fill="{SKIN}"/>'
        f'<path d="M{x - 12} {ground - 108} q12 -14 24 0" fill="{SOIL_D}"/>'
        f'<path d="M{x + 6 * f} {ground - 82} L{x + 24 * f} {ground - 74}" stroke="{SHIRT}" stroke-width="8" stroke-linecap="round"/>'
        f'<circle cx="{x + 26 * f}" cy="{ground - 74}" r="4.5" fill="{SKIN}"/>'
        f'<rect x="{x + 26 * f - 3}" y="{ground - 86}" width="6" height="14" rx="1.5" fill="{PHONE}"/>'
    )


def sun(cx, cy, r):
    rays = "".join(
        f'<path d="M{cx + math.cos(a) * r * 1.35:.1f} {cy + math.sin(a) * r * 1.35:.1f} L{cx + math.cos(a) * r * 1.8:.1f} {cy + math.sin(a) * r * 1.8:.1f}" stroke="{SUN}" stroke-width="3" stroke-linecap="round"/>'
        for a in [i * math.pi / 4 for i in range(8)]
    )
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{SUN}"/>{rays}'


def dim(x1, x2, y, label):
    """Cota con flechas. El texto (`label`) lo pone la app encima: el lector de SVG
    de Flutter no dibuja texto."""
    return (
        f'<path d="M{x1} {y} L{x2} {y}" stroke="{LEAF}" stroke-width="2" stroke-dasharray="5 4"/>'
        f'<path d="M{x1 + 7} {y - 5} L{x1} {y} L{x1 + 7} {y + 5}" stroke="{LEAF}" stroke-width="2" fill="none" stroke-linecap="round"/>'
        f'<path d="M{x2 - 7} {y - 5} L{x2} {y} L{x2 - 7} {y + 5}" stroke="{LEAF}" stroke-width="2" fill="none" stroke-linecap="round"/>'
    )


def screen(w, h, body, bg=SKY):
    """Pantalla de teléfono (para los ejemplos Bien / Evitar)."""
    return (
        f'<rect x="2" y="2" width="{w - 4}" height="{h - 4}" rx="14" fill="{PHONE}"/>'
        f'<clipPath id="c"><rect x="8" y="8" width="{w - 16}" height="{h - 16}" rx="9"/></clipPath>'
        f'<g clip-path="url(#c)"><rect x="8" y="8" width="{w - 16}" height="{h - 16}" fill="{bg}"/>{body}</g>'
    )


def stake(x, ground, h=46):
    return (
        f'<rect x="{x - 3}" y="{ground - h}" width="6" height="{h}" fill="{CANE}"/>'
        f'<rect x="{x - 12}" y="{ground - h - 4}" width="24" height="14" rx="3" fill="{WHITE}" stroke="{LEAF}" stroke-width="1.5"/>'
        f'<path d="M{x - 7} {ground - h + 3} h14" stroke="{LEAF}" stroke-width="1.5"/>'
    )


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    files = {}

    # ---------------- Escena: foto general -----------------
    g = 168
    files["general_scene"] = svg(
        340,
        210,
        f'<rect width="340" height="210" rx="20" fill="{SKY}"/>'
        f'{sun(40, 40, 16)}'
        f'<rect y="{g}" width="340" height="42" fill="{SOIL}"/><rect y="{g}" width="340" height="5" fill="{SOIL_D}"/>'
        f'<path d="M205 {g - 112} H330" stroke="{GREY}" stroke-width="1.5"/>'
        f'{plant(232, g, 118)}{plant(272, g, 112)}{plant(310, g, 120)}'
        f'{stake(200, g)}'
        f'{person(78, g)}'
        f'<path d="M108 92 L200 70 M108 92 L200 150" stroke="{LEAF}" stroke-width="1.2" stroke-dasharray="3 4" opacity="0.7"/>'
        f'{dim(92, 205, 196, "2–3 m")}',
    )

    # ---------------- Escena: foto de detalle -----------------
    lat = (
        f'<path d="M330 30 Q250 70 180 118" stroke="{CANE}" stroke-width="5" fill="none" stroke-linecap="round"/>'
        + leaf(300, 46, 40, -40)
        + leaf(262, 66, 44, 200, LEAF)
        + leaf(226, 90, 38, -30, LEAF3)
    )
    files["detail_scene"] = svg(
        340,
        210,
        f'<rect width="340" height="210" rx="20" fill="{SKY}"/>'
        # mano detrás del racimo
        f'<g transform="translate(170 118) rotate(-12)">'
        f'<rect x="-34" y="-36" width="64" height="80" rx="26" fill="{SKIN}"/>'
        + "".join(f'<rect x="{-32 + i * 15}" y="-74" width="13" height="50" rx="6.5" fill="{SKIN}"/>' for i in range(4))
        + f'<rect x="26" y="-6" width="40" height="13" rx="6.5" transform="rotate(-35 26 0)" fill="{SKIN_D}"/></g>'
        f'{lat}{berry(176, 122, 15)}{berry(150, 108, 11, GREENFRUIT, GREENFRUIT_D, PALE)}'
        # teléfono con recuadro de enfoque
        f'<g transform="translate(26 54) rotate(-6)"><rect width="66" height="122" rx="10" fill="{PHONE}"/>'
        f'<rect x="5" y="9" width="56" height="102" rx="6" fill="{CREAM}"/>'
        f'{berry(33, 60, 13)}'
        f'<path d="M15 40 v-7 h7 M44 33 h7 v7 M51 80 v7 h-7 M22 87 h-7 v-7" stroke="{SUN}" stroke-width="2.5" fill="none" stroke-linecap="round"/></g>'
        f'{dim(92, 168, 196, "10–20 cm")}',
    )

    # ---------------- Bien / Evitar (pantallas 160 x 120) -----------------
    W, H = 160, 120
    files["frame_ok"] = svg(W, H, screen(W, H, f'<rect x="8" y="98" width="{W}" height="20" fill="{SOIL}"/>{plant(80, 100, 82)}'))
    files["frame_bad"] = svg(W, H, screen(W, H, f'<rect x="8" y="98" width="{W}" height="20" fill="{SOIL}"/>{plant(80, 150, 180)}'))
    files["organ_ok"] = svg(W, H, screen(W, H, f'{leaf(40, 108, 50, 30)}{leaf(126, 110, 48, -35, LEAF3)}{berry(80, 64, 26)}', CREAM))
    files["organ_bad"] = svg(
        W,
        H,
        screen(
            W,
            H,
            "".join(leaf(20 + (i % 6) * 26, 30 + (i // 6) * 34, 30, (i * 47) % 360, [LEAF, LEAF2, LEAF3][i % 3]) for i in range(24))
            + berry(118, 86, 6),
            LEAF3,
        ),
    )
    files["background_ok"] = svg(
        W,
        H,
        screen(
            W,
            H,
            f'<rect x="40" y="18" width="80" height="110" rx="28" fill="{SKIN}"/>{berry(80, 66, 22)}{leaf(52, 40, 30, -50, LEAF3, False)}',
            SKY,
        ),
    )
    files["background_bad"] = svg(
        W,
        H,
        screen(
            W,
            H,
            "".join(leaf(10 + (i % 7) * 24, 20 + (i // 7) * 30, 36, (i * 61) % 360, [LEAF, LEAF2, LEAF3, LEAF][i % 4]) for i in range(28))
            + berry(80, 64, 18),
            LEAF2,
        ),
    )
    files["light_ok"] = svg(W, H, screen(W, H, f'<rect x="8" y="98" width="{W}" height="20" fill="{SOIL}"/>{plant(80, 100, 82)}'))
    files["light_bad"] = svg(
        W,
        H,
        screen(
            W,
            H,
            f'<rect x="8" y="8" width="{W}" height="{H}" fill="#FFF3C4"/>{sun(110, 34, 18)}'
            f'<rect x="8" y="98" width="{W}" height="20" fill="#5B4A3A"/>'
            f'<g opacity="0.9" fill="#2B3A2E">'
            + plant(70, 100, 82, fruits=False).replace(LEAF2, "#2B3A2E").replace(LEAF3, "#2B3A2E").replace(LEAF, "#2B3A2E").replace(CANE, "#2B3A2E")
            + "</g>",
            "#FFF3C4",
        ),
    )

    # ---------------- Etapas (100 x 100) -----------------
    def card(body, bg=CREAM):
        return svg(100, 100, f'<rect width="100" height="100" rx="18" fill="{bg}"/>{body}')

    cane = f'<path d="M50 100 L50 0" stroke="{CANE}" stroke-width="7"/>'
    files["stage_0"] = card(
        cane + f'<path d="M52 58 q22 -8 22 -34 q-22 6 -22 34z" fill="{BROWN}"/><path d="M66 32 q4 -8 9 -11" stroke="{LEAF3}" stroke-width="4" stroke-linecap="round"/>'
        f'<path d="M48 86 q-18 -6 -18 -26 q17 5 18 26z" fill="{BROWN}"/>'
    )
    files["stage_1"] = card(
        cane + f'<path d="M50 60 Q62 46 66 30" stroke="{LEAF2}" stroke-width="3" fill="none"/>'
        + leaf(58, 50, 22, 50, LEAF3)
        + leaf(62, 40, 18, -40, LEAF2)
        + leaf(66, 32, 12, 20, LEAF3, False)
    )
    files["stage_3"] = card(
        cane + f'<path d="M50 72 Q74 54 92 18" stroke="{LEAF2}" stroke-width="3.5" fill="none"/>'
        + "".join(leaf(50 + t * 42, 72 - t * 54, 18, (55 if i % 2 else -35), [LEAF, LEAF2, LEAF3][i % 3]) for i, t in enumerate([0.2, 0.4, 0.6, 0.8]))
    )
    buds = "".join(
        f'<circle cx="{x}" cy="{y}" r="6" fill="{GREENFRUIT}"/>' + leaf(x, y - 3, 7, -30, LEAF2, False) + leaf(x, y - 3, 7, 30, LEAF2, False)
        for x, y in [(52, 34), (66, 26), (40, 24), (58, 14), (72, 42)]
    )
    files["stage_5"] = card(
        f'<path d="M20 100 Q40 70 54 40 M54 40 L66 26 M54 40 L40 24 M54 40 L58 14 M54 40 L72 42" stroke="{LEAF2}" stroke-width="3" fill="none"/>'
        + leaf(30, 80, 22, -60)
        + buds
    )
    petals = "".join(
        f'<ellipse cx="{50 + math.cos(a) * 15:.1f}" cy="{48 + math.sin(a) * 15:.1f}" rx="11" ry="8" transform="rotate({math.degrees(a):.0f} {50 + math.cos(a) * 15:.1f} {48 + math.sin(a) * 15:.1f})" fill="{WHITE}" stroke="#E7E1D3"/>'
        for a in [i * 2 * math.pi / 5 - math.pi / 2 for i in range(5)]
    )
    files["stage_6"] = card(
        f'<path d="M50 100 L50 60" stroke="{LEAF2}" stroke-width="3"/>' + leaf(50, 86, 22, -55) + petals
        + f'<circle cx="50" cy="48" r="9" fill="{GREENFRUIT}"/>'
        + "".join(f'<circle cx="{50 + math.cos(a) * 9:.1f}" cy="{48 + math.sin(a) * 9:.1f}" r="1.6" fill="{YELLOW}"/>' for a in [i * math.pi / 5 for i in range(10)]),
        SKY,
    )
    files["stage_7"] = card(
        f'<path d="M50 100 L50 62" stroke="{LEAF2}" stroke-width="3"/>' + leaf(50, 88, 22, 55) + berry(50, 46, 20, GREENFRUIT, GREENFRUIT_D, PALE)
    )
    files["stage_8"] = card(
        f'<path d="M30 0 Q40 30 36 44 M30 0 Q60 30 66 52" stroke="{LEAF2}" stroke-width="3" fill="none"/>'
        + berry(36, 58, 15, PINK, BERRY_L, WHITE)
        + berry(66, 66, 17)
    )
    files["stage_9"] = card(
        cane
        + leaf(62, 40, 26, 60, YELLOW)
        + leaf(38, 62, 24, -60, BROWN)
        + leaf(76, 82, 18, 120, "#D9A441", False)
        + f'<path d="M50 30 q8 -4 9 -14 q-8 3 -9 14z" fill="{BROWN}"/>'
    )

    for name, content in files.items():
        (OUT / f"{name}.svg").write_text(content)
    print(f"{len(files)} ilustraciones en {OUT}")


if __name__ == "__main__":
    main()
