use <../../braille_and_print.scad>;
sign_content(
  braille_lines = [
    "⠠⠗⠑⠉⠑⠏⠰⠝",
  ],
  print_lines = [
    "Reception",
  ],
  backing_thickness = 2,
  between_braille_and_print = 30,
  pad_x = 10,
  pad_y = 10,
  print_font = "Liberation Sans",
  print_line_spacing = 10,
  print_size = 20,
  print_spacing = 1.18,
  print_thickness = 1,
  radii = 10,
);