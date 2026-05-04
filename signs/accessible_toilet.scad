use <../braille_and_print.scad>;

// The braille of the sign.
braille_lines = ["⠠⠁⠒⠑⠎⠎⠊⠃⠇⠑⠀⠠⠞⠕⠊⠇⠑⠞"];

// The print of the sign.
print_lines = ["Accessible Toilet"];

// Uncomment the appropriate line below.
//
// Uncomment the individual calls to `sign_backing` and `sign_content` for rendering to separate STL files.

// sign_backing(braille_lines, print_lines);
// sign_content(braille_lines, print_lines);
sign(braille_lines=braille_lines, print_lines=print_lines);
