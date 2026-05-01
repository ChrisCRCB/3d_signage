// Make `string` fit into `size`, using `textmetrics`.
module resize_text(string, target, size = 20, font = "Liberation Sans") {
  halign = "left";
  valign = "bottom";
  m = textmetrics(string, size=size, font=font);

  scale_factor = min(target[0] / m.size[0], target[1] / m.size[1]);
  echo(scale_factor);

  scale([scale_factor, scale_factor])
    text(string, size=size, font=font);
}

// A sign with a backing.
module sign(string, target, text_thickness = 1, backing_thickness = 2, radii = 3, border = true) {
  union() {
    translate([radii, radii, 0])
      linear_extrude(height=backing_thickness)
        offset(radii)
          square(target);
    if (border) {
      difference() {
        translate([radii, radii, backing_thickness])
          linear_extrude(height=text_thickness)
            offset(radii)
              square(target);
        translate([radii, radii, backing_thickness])
          linear_extrude(height=text_thickness)
            square(target);
      }
    }
    translate([radii, radii, backing_thickness])
      linear_extrude(height=text_thickness)
        resize_text(string=string, target=target);
  }
}
