import re
import sys
import subprocess
from pathlib import Path
from dataclasses import dataclass
from typing import Any
from json import load


@dataclass
class SignSettings:
    """The settings for a sign."""

    braille_lines: list[str]
    print_lines: list[str]
    between_braille_and_print: object
    print_thickness: object
    backing_thickness: object
    radii: object
    border: bool
    print_size: object
    print_font: str
    print_spacing: object
    print_line_spacing: object
    pad_x: object
    pad_y: object
    screw_holes_radii: object

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> "SignSettings":
        return cls(
            braille_lines=data["braille_lines"],
            print_lines=data["print_lines"],
            between_braille_and_print=data["between_braille_and_print"],
            print_thickness=data["print_thickness"],
            backing_thickness=data["backing_thickness"],
            radii=data["radii"],
            border=data["border"],
            print_size=data["print_size"],
            print_font=data["print_font"],
            print_spacing=data["print_spacing"],
            print_line_spacing=data["print_line_spacing"],
            pad_x=data["pad_x"],
            pad_y=data["pad_y"],
            screw_holes_radii=data["screw_holes_radii"],
        )


def generate_arguments(settings: SignSettings) -> list[str]:
    """Returns a list of arguments from `settings`."""
    arguments: list[str] = ["  braille_lines = ["]
    for line in settings.braille_lines:
        arguments.append(f'    "{line}",')
    arguments.append("  ],")
    arguments.append("  print_lines = [")
    for line in settings.print_lines:
        arguments.append(f'    "{line}",')
    arguments.append("  ],")

    for name in sorted(dir(settings)):
        if name in ["from_json", "braille_lines", "print_lines"] or name.startswith(
            "_"
        ):
            continue
        value = getattr(settings, name)
        value_str: str
        if isinstance(value, bool):
            value_str = "true" if value else "false"
        elif isinstance(value, str):
            value_str = f'"{value}"'
        else:
            value_str = str(value)
        arguments.append(f"  {name} = {value_str},")
    return arguments


def main(filename: Path) -> None:
    """Generate code from the code in `constants_filename`."""
    settings: SignSettings
    with open(filename, "r", encoding="utf-8") as f:
        json = load(f)
        settings = SignSettings.from_json(json)
    arguments = generate_arguments(settings)
    top_import = "use <../braille_and_print.scad>;"
    directory = filename.parent
    backing_filename = "backing"
    content_filename = "content"
    backing_code: list[str] = [top_import, "sign_backing("] + arguments + [");"]
    content_code: list[str] = (
        [top_import, "sign_content("]
        + [
            x
            for x in arguments
            if not x.startswith("  screw_holes_radii") and not x.startswith("  border")
        ]
        + [");"]
    )
    sign_code: list[str] = [top_import, "sign("] + arguments + [");"]

    basename = filename.stem
    backing_scad = directory / f"{basename}_{backing_filename}.scad"
    with open(backing_scad, "w", encoding="utf-8") as f:
        f.write("\n".join(backing_code))

    content_scad = directory / f"{basename}_{content_filename}.scad"
    with open(content_scad, "w", encoding="utf-8") as f:
        f.write("\n".join(content_code))

    sign_scad = directory / f"{basename}_sign.scad"
    with open(sign_scad, "w", encoding="utf-8") as f:
        f.write("\n".join(sign_code))

    backing_stl = directory / f"{basename}_{backing_filename}.stl"
    content_stl = directory / f"{basename}_{content_filename}.stl"
    sign_stl = directory / f"{basename}_sign.stl"
    for scad, stl in [
        (backing_scad, backing_stl),
        (content_scad, content_stl),
        (sign_scad, sign_stl),
    ]:
        result = subprocess.run(
            ["openscad", "--enable", "all", scad, "-o", stl],
            check=True,
            capture_output=True,
            text=True,
        )
        for line in result.stderr.split("\n"):
            match = re.match(r"ECHO:\s*([0-9.]+),\s*([0-9.]+)", line)
            if match is not None:
                x = float(match.group(1))
                y = float(match.group(2))
                print(f"{basename}: {x} x {y}")


if __name__ == "__main__":
    for filename in sys.argv[1:]:
        main(Path(filename))
