use <sign.scad>;
use <../braille.scad/braille.scad>;

function sign_dimensions(
  braille_lines,
  print_lines,
  between_braille_and_print = 30,
  print_size = 20,
  print_font = "Liberation Sans",
  print_spacing = 1,
  print_line_spacing = 10,
  pad_x = 10,
  pad_y = 10
) =
  let (
    braille_width = get_longest_line(braille_lines),
    braille_height = get_braille_height(braille_lines),
    text_size = total_text_size(print_lines, size=print_size, font=print_font, spacing=print_spacing, line_spacing=print_line_spacing)
  ) [
      pad_x + max([braille_width, text_size.x]) + pad_x,
      pad_y + braille_height + between_braille_and_print + text_size.y + pad_y,
      braille_height,
      text_size.x,
      text_size.y,
  ];

module sign_backing(
  braille_lines,
  print_lines,
  between_braille_and_print = 30,
  print_thickness = 1,
  backing_thickness = 2,
  radii = 10,
  border = true,
  print_size = 20,
  print_font = "Liberation Sans",
  print_spacing = 1,
  print_line_spacing = 10,
  pad_x = 10,
  pad_y = 10,
  screw_holes_radii = 2.2,
) {
  dims = sign_dimensions(
    braille_lines,
    print_lines,
    between_braille_and_print,
    print_size,
    print_font,
    print_spacing,
    print_line_spacing,
    pad_x,
    pad_y
  );
  x = dims[0];
  y = dims[1];

  module bounding_box() {
    square([x, y]);
  }

  module screw_hole() {
    cylinder(
      h=1 + backing_thickness + print_thickness + 1, r=screw_holes_radii, $fn=64,
    );
  }

  difference() {
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

    screw_hole_offset = radii / 2;
    translate([screw_hole_offset, radii, -1])
      screw_hole();
    translate([radii + x + screw_hole_offset, radii, -1])
      screw_hole();
    translate([screw_hole_offset, radii + y, -1])
      screw_hole();
    translate([radii + x + screw_hole_offset, radii + y, -1])
      screw_hole();
  }
}

module sign_content(
  braille_lines,
  print_lines,
  between_braille_and_print = 30,
  print_thickness = 1,
  backing_thickness = 2,
  radii = 10,
  print_size = 20,
  print_font = "Liberation Sans",
  print_spacing = 1,
  print_line_spacing = 10,
  pad_x = 10,
  pad_y = 10
) {
  braille_height = get_braille_height(braille_lines);

  union() {
    translate([radii + pad_x, radii + pad_y, backing_thickness])
      braille_lines(braille_lines);
    translate([radii + pad_x, radii + pad_y + braille_height + between_braille_and_print, backing_thickness])
      linear_extrude(height=print_thickness)
        multiline_text(
          print_lines, size=print_size, font=print_font, spacing=print_spacing,
          line_spacing=print_line_spacing
        );
  }
}

module sign(
  braille_lines,
  print_lines,
  between_braille_and_print = 30,
  print_thickness = 1,
  backing_thickness = 2,
  radii = 10,
  border = true,
  print_size = 20,
  print_font = "Liberation Sans",
  print_spacing = 1,
  print_line_spacing = 10,
  pad_x = 10,
  pad_y = 10,
  screw_holes_radii = 2.2,
) {
  dims = sign_dimensions(
    braille_lines,
    print_lines,
    between_braille_and_print,
    print_size,
    print_font,
    print_spacing,
    print_line_spacing,
    pad_x,
    pad_y
  );
  echo(radii + dims[0] + radii, radii + dims[1] + radii);
  sign_backing(
    braille_lines,
    print_lines,
    between_braille_and_print,
    print_thickness,
    backing_thickness,
    radii,
    border,
    print_size,
    print_font,
    print_spacing,
    print_line_spacing,
    pad_x,
    pad_y,
    screw_holes_radii=screw_holes_radii,
  );
  sign_content(
    braille_lines,
    print_lines,
    between_braille_and_print=between_braille_and_print,
    print_thickness=print_thickness,
    backing_thickness=backing_thickness,
    radii=radii,
    print_size=print_size,
    print_font=print_font,
    print_spacing=print_spacing,
    print_line_spacing=print_line_spacing,
    pad_x=pad_x,
    pad_y=pad_y
  );
}

// The braille of the sign.
braille_lines = [
  "⠠⠁⠉⠞⠊⠧⠊⠞⠊⠑⠎⠀⠯⠀⠠⠧⠕⠇⠥⠝⠞⠑⠻⠎",
  "⠠⠍⠁⠝⠁⠛⠻",
];

// The print of the sign.
print_lines = ["Activities and", "Volunteers Manager"];

// Uncomment the appropriate line below.
//
// Uncomment the individual calls to `sign_backing` and `sign_content` for rendering to separate STL files.

// sign_backing(braille_lines, print_lines);
// sign_content(braille_lines, print_lines);
sign(braille_lines=braille_lines, print_lines=print_lines, print_size=16);
