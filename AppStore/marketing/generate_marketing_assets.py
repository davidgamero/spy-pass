from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import textwrap


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = Path(__file__).resolve().parent
IPHONE_SOURCE = ROOT / "AppStore/screenshots/iphone-6.3-required"
IPAD_SOURCE = ROOT / "AppStore/screenshots/ipad-13"
ICON_SOURCE = ROOT / "SpyPass/SpyPass/Assets.xcassets/AppIcon.appiconset/AppIcon.png"

INK = "#0E1116"
PANEL = "#171C23"
LINE = "#2A313B"
PAPER = "#ECE6D8"
MUTED = "#A4ABB4"
RED = "#E2402B"

DISPLAY_FONT = "/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf"
BODY_FONT = "/System/Library/Fonts/SFNS.ttf"

SLIDES = [
    ("01-setup.png", "PLAY OFFLINE ON ONE PHONE", "#FF7A66"),
    ("02-hidden-card.png", "PASS THE PHONE", "#5DB7FF"),
    ("03-secret-name.png", "REMEMBER THE NAME", "#B5E04A"),
    ("04-spy-role.png", "ONE PLAYER IS THE SPY", "#FFB938"),
    ("05-start-talking.png", "GIVE CLUES AND FIND THE SPY", RED),
]


def rounded_image(image: Image.Image, size: tuple[int, int], radius: int) -> Image.Image:
    image = image.convert("RGB").resize(size, Image.Resampling.LANCZOS)
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    image.putalpha(mask)
    return image


def place_with_shadow(
    canvas: Image.Image,
    image: Image.Image,
    position: tuple[int, int],
    radius: int,
    shadow_offset: int,
) -> None:
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_mask = image.getchannel("A")
    shadow_color = Image.new("RGBA", image.size, (0, 0, 0, 150))
    shadow_color.putalpha(shadow_mask)
    shadow.paste(
        shadow_color,
        (position[0], position[1] + shadow_offset),
        shadow_color,
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius))
    canvas.paste(shadow, (0, 0), shadow)
    canvas.paste(image, position, image)


def fit_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    max_width: int,
    max_height: int,
    starting_size: int,
    minimum_size: int,
    spacing: int,
) -> tuple[str, ImageFont.FreeTypeFont]:
    for size in range(starting_size, minimum_size - 1, -2):
        font = ImageFont.truetype(DISPLAY_FONT, size)
        words = text.split()
        lines: list[str] = []
        line = ""
        for word in words:
            candidate = f"{line} {word}".strip()
            if draw.textbbox((0, 0), candidate, font=font)[2] <= max_width:
                line = candidate
            else:
                if line:
                    lines.append(line)
                line = word
        if line:
            lines.append(line)
        wrapped = "\n".join(lines)
        box = draw.multiline_textbbox((0, 0), wrapped, font=font, spacing=spacing)
        if box[2] <= max_width and box[3] <= max_height:
            return wrapped, font
    return text, ImageFont.truetype(DISPLAY_FONT, minimum_size)


def create_store_slide(
    source: Path,
    destination: Path,
    headline: str,
    accent: str,
    canvas_size: tuple[int, int],
    screenshot_width: int,
    screenshot_y: int,
    headline_size: int,
) -> None:
    canvas = Image.new("RGB", canvas_size, INK)
    draw = ImageDraw.Draw(canvas)
    margin = max(64, canvas_size[0] // 18)
    wrapped, font = fit_text(
        draw,
        headline,
        canvas_size[0] - margin * 2,
        screenshot_y - 120,
        headline_size,
        int(headline_size * 0.62),
        int(headline_size * 0.06),
    )
    box = draw.multiline_textbbox((0, 0), wrapped, font=font, spacing=int(font.size * 0.06))
    text_width = box[2] - box[0]
    text_height = box[3] - box[1]
    text_x = (canvas_size[0] - text_width) // 2
    text_y = max(54, (screenshot_y - text_height - 34) // 2)
    draw.multiline_text(
        (text_x, text_y),
        wrapped,
        font=font,
        fill=PAPER,
        spacing=int(font.size * 0.06),
        align="center",
    )
    bar_width = max(120, canvas_size[0] // 8)
    bar_y = screenshot_y - 34
    draw.rounded_rectangle(
        (
            (canvas_size[0] - bar_width) // 2,
            bar_y,
            (canvas_size[0] + bar_width) // 2,
            bar_y + 10,
        ),
        radius=5,
        fill=accent,
    )

    with Image.open(source) as screenshot:
        ratio = screenshot.height / screenshot.width
        screenshot_size = (screenshot_width, round(screenshot_width * ratio))
        framed = rounded_image(screenshot, screenshot_size, radius=max(36, screenshot_width // 22))
    x = (canvas_size[0] - screenshot_width) // 2
    place_with_shadow(canvas, framed, (x, screenshot_y), radius=26, shadow_offset=20)
    draw.rounded_rectangle(
        (x, screenshot_y, x + screenshot_size[0], screenshot_y + screenshot_size[1]),
        radius=max(36, screenshot_width // 22),
        outline=LINE,
        width=4,
    )
    canvas.save(destination, "PNG", optimize=True)


def create_header(destination: Path, size: tuple[int, int]) -> None:
    canvas = Image.new("RGB", size, INK)
    draw = ImageDraw.Draw(canvas)
    if size[0] > size[1] * 1.5:
        title_font = ImageFont.truetype(DISPLAY_FONT, round(size[1] * 0.19))
        tagline_font = ImageFont.truetype(BODY_FONT, round(size[1] * 0.06))
        draw.text((size[0] * 0.07, size[1] * 0.20), "SPY PASS.", font=title_font, fill=PAPER)
        draw.text(
            (size[0] * 0.075, size[1] * 0.52),
            "One phone. No internet. Find the spy.",
            font=tagline_font,
            fill=MUTED,
        )
        draw.rounded_rectangle(
            (size[0] * 0.075, size[1] * 0.64, size[0] * 0.24, size[1] * 0.655),
            radius=10,
            fill=RED,
        )
        with Image.open(ICON_SOURCE) as icon:
            icon_size = round(size[1] * 0.66)
            icon = rounded_image(icon, (icon_size, icon_size), radius=round(icon_size * 0.22))
        icon_x = round(size[0] * 0.66)
        icon_y = (size[1] - icon_size) // 2
        place_with_shadow(canvas, icon, (icon_x, icon_y), radius=30, shadow_offset=20)
    else:
        title_font = ImageFont.truetype(DISPLAY_FONT, round(size[1] * 0.13))
        tagline_font = ImageFont.truetype(BODY_FONT, round(size[1] * 0.045))
        title = "SPY PASS."
        title_box = draw.textbbox((0, 0), title, font=title_font)
        draw.text(((size[0] - title_box[2]) / 2, size[1] * 0.08), title, font=title_font, fill=PAPER)
        with Image.open(ICON_SOURCE) as icon:
            icon_size = round(size[1] * 0.55)
            icon = rounded_image(icon, (icon_size, icon_size), radius=round(icon_size * 0.22))
        icon_x = (size[0] - icon_size) // 2
        icon_y = round(size[1] * 0.25)
        place_with_shadow(canvas, icon, (icon_x, icon_y), radius=26, shadow_offset=18)
        tagline = "One phone. No internet. Find the spy."
        tagline_box = draw.textbbox((0, 0), tagline, font=tagline_font)
        draw.text(
            ((size[0] - tagline_box[2]) / 2, size[1] * 0.86),
            tagline,
            font=tagline_font,
            fill=MUTED,
        )
        draw.rounded_rectangle(
            (size[0] * 0.40, size[1] * 0.94, size[0] * 0.60, size[1] * 0.952),
            radius=8,
            fill=RED,
        )
    canvas.save(destination, "PNG", optimize=True)


def main() -> None:
    iphone_output = OUTPUT / "app-store-iphone-6.3"
    ipad_output = OUTPUT / "app-store-ipad-13"
    iphone_output.mkdir(parents=True, exist_ok=True)
    ipad_output.mkdir(parents=True, exist_ok=True)

    for filename, headline, accent in SLIDES:
        create_store_slide(
            IPHONE_SOURCE / filename,
            iphone_output / filename,
            headline,
            accent,
            canvas_size=(1206, 2622),
            screenshot_width=940,
            screenshot_y=430,
            headline_size=92,
        )
        create_store_slide(
            IPAD_SOURCE / filename,
            ipad_output / filename,
            headline,
            accent,
            canvas_size=(2064, 2752),
            screenshot_width=1600,
            screenshot_y=550,
            headline_size=128,
        )

    create_header(OUTPUT / "spy-pass-header-2400x1200.png", (2400, 1200))
    create_header(OUTPUT / "spy-pass-social-1200x1200.png", (1200, 1200))


if __name__ == "__main__":
    main()
