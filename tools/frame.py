"""Frame raw simulator captures as App Store screenshots in the Mltply look: the app icon's orange dots and yellow and
lime bars, floating on warm white.

Reads screenshots/raw/<screen>.png (6.3" iPhone) and screenshots/raw/ipad/<screen>.png (13" iPad), writes
screenshots/appstore/<size>/NN-<screen>.png for each display size App Store Connect accepts. Each device family's
layout is designed at one size and scaled to the others. Run by tools/screenshots.sh.
"""
import base64
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW, OUT, BUILD = ROOT / "screenshots/raw", ROOT / "screenshots/appstore", ROOT / "build"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
LAYOUTS = {
    "iphone": dict(raw="", design=(1320, 2868), sizes={"6.9": (1320, 2868), "6.5": (1242, 2688), "6.3": (1206, 2622)},
                   h1=120, sub=50, text_top=190, sub_top=480, device_top=760, device_w=1010, radius=118, shape=1),
    "ipad": dict(raw="ipad", design=(2064, 2752), sizes={"ipad-13": (2064, 2752), "ipad-12.9": (2048, 2732)},
                 h1=140, sub=58, text_top=190, sub_top=540, device_top=820, device_w=1640, radius=64, shape=1.4),
}

# (screen, caption with the key words in <b>, small line under it)
SLIDES = [
    ("chat", "Maths, but<br><b>it’s a chat</b>", "Buddy asks, your child answers, one message at a time"),
    ("timed", "Beat<br><b>the clock</b>", "Two minutes on the timer, or keep going as long as you like"),
    ("settings", "Pick the<br><b>numbers</b>", "Times tables, adding, taking away and dividing, at their pace"),
    ("achievements", "Earn<br><b>achievements</b>", "Streaks and milestones that celebrate every right answer"),
    ("scoreboard", "Watch them<br><b>improve</b>", "Every round on the scoreboard, with a personal best to beat"),
]

INK, ORANGE, YELLOW, LIME, PAPER = "#2b2622", "#ff8d28", "#ffcc00", "#b8ff50", "#fbf8f2"
FONT = '<link href="https://fonts.googleapis.com/css2?family=Nunito:wght@600;900&display=block" rel="stylesheet">'


def uri(path):
    return f"data:image/png;base64,{base64.b64encode(Path(path).read_bytes()).decode()}"


def shapes(scale, W):
    """The icon's pieces: two orange dots, a yellow bar and a lime bar, half off the edges."""
    s = scale
    return f"""<div class="dot" style="width:{230 * s}px;height:{230 * s}px;right:{-60 * s}px;top:{120 * s}px"></div>
<div class="bar" style="background:{YELLOW};width:{520 * s}px;height:{150 * s}px;right:{-230 * s}px;top:{420 * s}px;transform:rotate(-8deg)"></div>
<div class="bar" style="background:{LIME};width:{150 * s}px;height:{560 * s}px;left:{-70 * s}px;bottom:{260 * s}px;transform:rotate(24deg)"></div>
<div class="dot" style="width:{170 * s}px;height:{170 * s}px;left:{90 * s}px;bottom:{90 * s}px"></div>"""


def page(L, screen, caption, sub, width):
    W, H = L["design"]
    return f"""<!doctype html><html><head><meta charset="utf-8">{FONT}
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
html{{background:{PAPER}}}
body{{width:{W}px;height:{H}px;overflow:hidden;position:relative;font-family:Nunito,sans-serif;zoom:{width / W};background:{PAPER}}}
.dot{{position:absolute;border-radius:50%;background:{ORANGE};opacity:.85}}
.bar{{position:absolute;border-radius:{24 * L["shape"]}px;opacity:.85}}
h1{{position:absolute;left:110px;right:300px;top:{L["text_top"]}px;font:900 {L["h1"]}px/1.04 Nunito,sans-serif;letter-spacing:-.02em;color:{INK}}}
h1 b{{color:{ORANGE};font-weight:900}}
p{{position:absolute;left:114px;right:320px;top:{L["sub_top"]}px;font-size:{L["sub"]}px;font-weight:600;line-height:1.32;color:#6b625a}}
.phone{{position:absolute;left:50%;top:{L["device_top"]}px;width:{L["device_w"]}px;transform:translateX(-50%);border-radius:{L["radius"]}px;
  padding:22px;background:#1c1c1e;box-shadow:0 0 0 4px #2c2c2e, 0 60px 140px rgba(80,50,20,.28)}}
.phone img{{display:block;width:100%;border-radius:{L["radius"] - 20}px}}
</style></head><body>{shapes(L["shape"], W)}
<h1>{caption}</h1><p>{sub}</p>
<div class="phone"><img src="{uri(RAW / L["raw"] / f'{screen}.png')}"></div></body></html>"""


def shoot(html, png, size):
    BUILD.mkdir(exist_ok=True)
    tmp = BUILD / "frame.html"
    tmp.write_text(html)
    subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                    f"--window-size={size[0]},{size[1]}", "--virtual-time-budget=4000", f"--screenshot={png}", tmp.as_uri()],
                   check=True, capture_output=True)
    tmp.unlink()


def main():
    for L in LAYOUTS.values():
        for name, size in L["sizes"].items():
            (OUT / name).mkdir(parents=True, exist_ok=True)
            for n, (screen, caption, sub) in enumerate(SLIDES, 1):
                if not (RAW / L["raw"] / f"{screen}.png").exists():
                    print(f"skip {name} {screen}: no capture")
                    continue
                out = OUT / name / f"{n:02d}-{screen}.png"
                shoot(page(L, screen, caption, sub, size[0]), out, size)
                print(f"framed {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
