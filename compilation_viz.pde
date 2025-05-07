int head_index = 3;
String[] tokens_stream;
int tokens_stream_nb_spaces;

int token_slot_width = 50;


String[] compiler_stack = {"$"};

int[][] compiler_matrix = {
  // -2 = empty cell
  //  0 = word is accepted
  // -1 = pop from stack
  { 1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2},
  {-2, 2, 2, 2, -2, -2, -2, -2, -2, -2, -2},
  {-2, 4, 3, -2, -2, -2, -2, -2, -2, -2, -2},
  {-2, 6, 6, 5, -2, -2, -2, -2, -2, -2, -2},
  {-2, -2, -2, 7, -2, -2, -2, 7, -2, 7, -2},
  {-2, 9, 9, -2, -2, 8, -2, -2, 9, -2, -2},
  {-2, -2, -2, 10, -2, -2, -2, 10, -2, 10, -2},
  {-2, 12, 12, -2, -2, 12, 11, -2, 12, -2, -2},
  {-2, -2, -2, 14, -2, -2, -2, 13, -2, 15, -2},
  {-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 0},

  {-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2},
  {-2, -1, -2, -2, -2, -2, -2, -2, -2, -2, -2},
  {-2, -2, -1, -2, -2, -2, -2, -2, -2, -2, -2},
  {-2, -2, -2, -1, -2, -2, -2, -2, -2, -2, -2},
  {-2, -2, -2, -2, -1, -2, -2, -2, -2, -2, -2},
  {-2, -2, -2, -2, -2, -1, -2, -2, -2, -2, -2},
  {-2, -2, -2, -2, -2, -2, -1, -2, -2, -2, -2},
  {-2, -2, -2, -2, -2, -2, -2, -1, -2, -2, -2},
  {-2, -2, -2, -2, -2, -2, -2, -2, -1, -2, -2},
  {-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -2},
  {-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -1},
};

String[] compiler_matrix_cols = {
  "debut", "fin", ";", "id", ":=", "+", "*", "(", ")", "nb", "€"
};
String[] compiler_matrix_rows = {
  "P", "S", "R", "I", "E", "E'", "T", "T'", "F", "$",
  "debut", "fin", ";", "id", ":=", "+", "*", "(", ")", "nb"
};

String[][] grammar_rhs = {
  {"debut", "S", "fin"},
  {"I", "R"},
  {";", "I", "R"},
  {"€"},
  {"id", ":=", "E"},
  {"€"},
  {"F", "T'"},
  {"*", "F", "T'"},
  {"€"}, // € is for epsilon
  {"(", "E", ")"},
  {"id"}, // vars in the input
  {"nb"}
};

void setup() {
  size(600, 600);
  read_input("input.txt");
  frameRate(30);
}


void draw() {
  background(255);

  draw_tokens_stream();
  draw_compiler_stack();
}


void read_input(String filename) {
  String[] content = loadStrings(filename);
assert content.length == 1 :
  "Wrong input.";

  String[] stream = split(content[0], ' ');
  println("Tokens:___");
  for (int i=0; i < stream.length; i++) {
    println(stream[i]);
  }
  println("__________");

  tokens_stream = stream;
}

String sanitize_tokens_stream(String old_stream) {
  return old_stream;
}

void draw_tokens_stream() {
  int xoffset = 40;
  int yoffset = 40;
  int rect_width = tokens_stream.length * token_slot_width;
  int headxoffset = token_slot_width /2;

  fill(191);
  rect(xoffset, yoffset, rect_width, yoffset);
  noFill();

  for (int i=0; i < tokens_stream.length; i++) {
    fill(230);
    rect(xoffset + i * token_slot_width, yoffset, token_slot_width, yoffset);
    fill(0);
    text(tokens_stream[i], xoffset + i * token_slot_width + headxoffset/2, 1.6 * yoffset );
    noFill();
  }

assert head_index > 0 && head_index < tokens_stream.length:
  "Head index out of bounds";

  // draw the readhead
  int triangle_base_width = 10;
  fill(200, 0, 0);
  triangle(
    xoffset + head_index * 2*headxoffset+headxoffset - triangle_base_width,
    3 * yoffset,
    xoffset + head_index * 2*headxoffset+headxoffset - 0.1*triangle_base_width,
    2.5 * yoffset,
    xoffset + head_index * 2*headxoffset+headxoffset + triangle_base_width,
    3 * yoffset
    );
  noFill();
}


void draw_compiler_stack() {
  int xoffset = 40;
  int yoffset = 40;
  int rect_height = compiler_stack.length * token_slot_width;
  println("rect_height=", rect_height);
  println("tl=", xoffset, height - yoffset -rect_height);
  println("br=", xoffset+token_slot_width, height - yoffset);
  fill(191);
  rect( xoffset, height - 2*yoffset - rect_height, token_slot_width, height - 2*yoffset);
  noFill();
}
