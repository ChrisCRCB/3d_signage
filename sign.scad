$fn = 100;

// Make `string` fit into `size`, using `textmetrics`.
module resize_text(string, target, size = 20, font = "Liberation Sans") {
  halign = "left";
  valign = "bottom";
  m = textmetrics(string, size=size, font=font);

  scale_factor = min(target[0] / m.size[0], target[1] / m.size[1]);
  echo(scale_factor);

  scale([scale_factor, scale_factor])
    text(string, size=size, font=font, halign=halign, valign=valign);
}

// Get the size of some text.
function text_size(line, size, font, spacing) =
  textmetrics(
    text=line,
    size=size,
    font=font,
    spacing=spacing
  ).size;

// Width of the widest line.
function total_text_width(lines, size, font, spacing) =
  len(lines) == 0 ? 0
  : max([for (line = lines) text_size(line, size, font, spacing).x]);

// Height of all lines stacked vertically.
// line_spacing is the gap between lines, in mm.
function total_text_height(lines, size, font, spacing, line_spacing) =
  len(lines) == 0 ? 0
  : sum([for (line = lines) text_size(line, size, font, spacing).y]) + line_spacing * (len(lines) - 1);

// Full bounding size: [width, height]
function total_text_size(lines, size = 18, font = "Liberation Sans", spacing = 1, line_spacing = 3) =
  [
    total_text_width(lines, size, font, spacing),
    total_text_height(lines, size, font, spacing, line_spacing),
  ];

// Recursive sum helper.
function sum(values, i = 0, total = 0) =
  i >= len(values) ? total
  : sum(values, i + 1, total + values[i]);

function reverse_list(v) =
  [for (i = [len(v) - 1:-1:0]) v[i]];

module multiline_text(
  lines,
  size,
  font,
  spacing,
  line_spacing,
) {
  halign = "left";
  valign = "bottom";
  reversed_lines = reverse_list(lines);

  for (i = [0:len(lines) - 1]) {
    y = sum(
      [
        for (j = [0:i - 1]) textmetrics(
          text=lines[j],
          size=size,
          font=font,
          spacing=spacing,
        ).size.y + line_spacing,
      ]
    );

    line = reversed_lines[i];
    echo(line, text_size(line));

    translate([0, y, 0])
      text(
        text=line,
        size=size,
        font=font,
        spacing=spacing,
        halign=halign,
        valign=valign
      );
  }
}

// A sign with a backing.
module sign(lines, text_thickness = 1, backing_thickness = 2, radii = 10, border = true, size = 18, font = "Liberation Sans", spacing = 1, line_spacing = 3, pad_x = 10, pad_y = 10) {
  target = total_text_size(lines, size=size, font=font, spacing=spacing, line_spacing=line_spacing);
  echo([radii + pad_x + target.x + pad_x + radii, radii + pad_y + target.y + pad_y + radii]);
  backing_size = [pad_x + target.x + pad_x, pad_y + target.y + pad_y];
  translate([radii, radii, 0])
    linear_extrude(height=backing_thickness)
      offset(radii)
        square(backing_size);
  if (border) {
    translate([radii, radii, backing_thickness])
      difference() {
        linear_extrude(height=text_thickness)
          offset(radii)
            square(backing_size);
        linear_extrude(height=text_thickness)
          square(backing_size);
      }
  }
  translate([radii + pad_x, radii + pad_y, backing_thickness])
    linear_extrude(height=text_thickness)
      multiline_text(
        lines,
        size=size,
        font=font,
        spacing=spacing,
        line_spacing=line_spacing,
      );
}

module keyring(lines, text_thickness = 1, backing_thickness = 2, radii = 15, border = true, size = 8, font = "Liberation Sans", spacing = 1, line_spacing = 1, pad_x = 3, pad_y = 3, hole_base = 5, hole_size = 2) {
  sign(lines=lines, text_thickness=text_thickness, backing_thickness=backing_thickness, radii=radii, border=border, size=size, font=font, spacing=spacing, line_spacing=line_spacing, pad_x=pad_x, pad_y=pad_y);
  target = total_text_size(lines, size=size, font=font, spacing=spacing, line_spacing=line_spacing);
  overall = [radii + pad_x + target.x + pad_x + radii, radii + pad_y + target.y + pad_y + radii];
  hole_centre = [overall.x + hole_base, overall.y / 2];
  echo("hole", hole_centre);
  translate(hole_centre) {
    difference() {
      cylinder(h=backing_thickness, r=hole_base);
      cylinder(h=backing_thickness, r=hole_size);
    }
  }
}

// Produce a sign.
keyring(["Coventry Comets", "Showdown Club"]);
