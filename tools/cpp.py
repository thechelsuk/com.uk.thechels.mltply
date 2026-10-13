"""Render artwork for the App Store's custom product pages, in the same look as the screenshots.

Each page gets a header (in both sizes App Store Connect takes), with the headline beside the screen the page is
about, and its own 6.3" iPhone and 13" iPad screenshots, led by that screen; the default page gets a header only.
There's no search results image: without one, search shows the page's first screenshots, which suits a portrait app
better. The copy for each page (promotional text, keywords) is in custom-product-pages.md.

    screenshots/raw/<screen>.png  ->  screenshots/cpp/<page>/{header-5244x2950,header-3840x1646}.png
                                  ->  screenshots/cpp/<page>/{iphone-6.3,ipad-13}-NN-<screen>.png

Needs the raw captures from tools/screenshots.sh.
"""
from frame import FONT, INK, LAYOUTS, LIME, ORANGE, PAPER, RAW, ROOT, YELLOW, page, shoot, uri

OUT = ROOT / "screenshots/cpp"
SCREENS = {"iphone-6.3": ("iphone", (1206, 2622)), "ipad-13": ("ipad", (2064, 2752))}

# name: (width, height, safe area as left, top, right, bottom in pixels). The 3840 × 1646 is the "Art Safe Area" from
# Apple's header template. The 5244 × 2950 is the box iPhone shows of a header: about 1.08 times as wide as the image
# is tall, centred, below the Dynamic Island and buttons (the top fifth) and above the app's name (the bottom 28%).
HEADERS = {
    "header-5244x2950": (5244, 2950, (1224, 590, 4020, 2124)),
    "header-3840x1646": (3840, 1646, (1097, 493, 2743, 1154)),
}

# page: (header screen, headline with the key words in <b>, screenshots as (screen, headline, line under it))
PAGES = {
    "default": ("chat", "Maths that feels<br><b>like a chat</b>", []),
    "times-tables": ("chat", "Times tables,<br><b>one text at a time</b>", [
        ("chat", "Times tables,<br><b>by text</b>", "Buddy asks, your child answers, and every right answer gets a cheer"),
        ("settings", "Choose<br><b>the tables</b>", "Practise any numbers from 1 to 12, in order or mixed up"),
        ("achievements", "Earn<br><b>achievements</b>", "Streaks and milestones that celebrate every right answer"),
        ("scoreboard", "Watch them<br><b>improve</b>", "Every round on the scoreboard, with a personal best to beat"),
    ]),
    "practice": ("settings", "Daily maths,<br><b>no distractions</b>", [
        ("settings", "Pick the<br><b>numbers</b>", "Adding, taking away, times and dividing, at their pace"),
        ("chat", "Maths, but<br><b>it’s a chat</b>", "Buddy asks, your child answers, one message at a time"),
        ("scoreboard", "Watch them<br><b>improve</b>", "Every round on the scoreboard, with a personal best to beat"),
        ("achievements", "Earn<br><b>achievements</b>", "Streaks and milestones that celebrate every right answer"),
    ]),
    "challenge": ("timed", "Beat<br><b>the clock</b>", [
        ("timed", "Beat<br><b>the clock</b>", "Two minutes to answer as many as they can"),
        ("scoreboard", "Beat your<br><b>personal best</b>", "Every round on the scoreboard, best first"),
        ("achievements", "Keep<br><b>the streak</b>", "Five in a row, ten, twenty, and on up to a hundred"),
        ("settings", "Up to<br><b>GOAT level</b>", "Starter, Explorer, Champion and GOAT, with numbers up to 9,999"),
    ]),
}


def header(screen, caption, W, H, safe):
    """The headline on the left of the safe area and the phone on its right, running off its bottom edge, with the
    icon's dots and bars around them."""
    x0, y0, x1, y1 = safe
    w = x1 - x0
    piece = lambda colour, left, top, width, height, turn, round_: (
        f'<div style="position:absolute;background:{colour};opacity:.85;left:{left}px;top:{top}px;width:{width}px;'
        f'height:{height}px;border-radius:{round_};transform:rotate({turn}deg)"></div>')
    shapes = (piece(ORANGE, x0 + w * .52, y0 - w * .02, w * .1, w * .1, 0, "50%")
              + piece(YELLOW, x1 + w * .02, y0 + w * .06, w * .32, w * .09, -8, f"{w * .015}px")
              + piece(LIME, x0 - w * .2, y0 + w * .12, w * .09, w * .34, 24, f"{w * .015}px")
              + piece(ORANGE, x0 - w * .02, y1 + w * .02, w * .07, w * .07, 0, "50%"))
    return f"""<!doctype html><html><head><meta charset="utf-8">{FONT}
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{width:{W}px;height:{H}px;overflow:hidden;position:relative;background:{PAPER}}}
h1{{position:absolute;left:{x0}px;width:{w * .62}px;top:{(y0 + y1) / 2}px;transform:translateY(-50%);
  font:900 {w * .074}px/1.04 Nunito,sans-serif;letter-spacing:-.02em;color:{INK}}}
h1 b{{color:{ORANGE};font-weight:900}}
.phone{{position:absolute;left:{x0 + w * .67}px;top:{y0 + (y1 - y0) * .02}px;width:{w * .3}px;transform:rotate(-5deg);
  border-radius:{w * .045}px;padding:{w * .009}px;background:#1c1c1e;
  box-shadow:0 0 0 {w * .002}px #2c2c2e, 0 {w * .028}px {w * .065}px rgba(80,50,20,.28)}}
.phone img{{display:block;width:100%;border-radius:{w * .037}px}}
</style></head><body>{shapes}
<h1>{caption}</h1>
<div class="phone"><img src="{uri(RAW / f'{screen}.png')}"></div></body></html>"""


def main():
    for name, (screen, caption, slides) in PAGES.items():
        out = OUT / name
        out.mkdir(parents=True, exist_ok=True)
        for size, (W, H, safe) in HEADERS.items():
            shoot(header(screen, caption, W, H, safe), out / f"{size}.png", (W, H))
        for size, (layout, dims) in SCREENS.items():
            for n, (shot, title, sub) in enumerate(slides, 1):
                shoot(page(LAYOUTS[layout], shot, title, sub, dims[0]), out / f"{size}-{n:02d}-{shot}.png", dims)
        print(f"made {name}")


if __name__ == "__main__":
    main()
