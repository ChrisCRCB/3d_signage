use <sign.scad>;
use <../braille.scad/braille.scad>;

module sign(
  braille_lines,
  print_lines,
  print_thickness = 1,
  backing_thickness = 2,
  radii = 15,
  border = true,
  print_size = 20,
  print_font = "Liberation Sans",
  print_spacing = 1,
  print_line_spacing = 10,
  pad_x = 10,
  pad_y = 30
) {
  braille_width = get_longest_line(braille_lines);
  braille_height = get_braille_height(braille_lines);
  text_size = total_text_size(print_lines, size=print_size, font=print_font, spacing=print_spacing, line_spacing=print_line_spacing);
  x = pad_x + max([braille_width, text_size.x]) + pad_x;
  y = pad_y + max([braille_height, text_size.y]) + pad_y;

  module bounding_box() {
    square([x, y]);
  }

  union() {
    translate([radii, radii, 0])
      linear_extrude(backing_thickness)
        offset(radii)
          bounding_box();
    if (border) {
      translate([radii, radii, backing_thickness])
        difference() {
          linear_extrude(height=print_thickness)
            offset(radii)
              bounding_box();
          linear_extrude(height=print_thickness)
            bounding_box();
        }
    }
  }
  echo(x, y);
  union() {
    translate([radii + pad_x, radii + pad_y, backing_thickness])
      braille_lines(braille_lines);
    translate([radii + pad_x, radii + pad_y + braille_height, backing_thickness])
      linear_extrude(height=print_thickness)
        multiline_text(
          print_lines, size=print_size, font=print_font, spacing=print_spacing,
          line_spacing=print_line_spacing
        );
  }
}

sign(
  ["⠠⠁⠒⠑⠎⠎⠊⠃⠇⠑⠀⠠⠞⠕⠊⠇⠑⠞"],
  ["Accessible Toilet"]
);
