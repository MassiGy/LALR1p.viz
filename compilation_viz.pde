int head_index = 3;
String[] tokens_stream;
int tokens_stream_nb_spaces;

float token_slot_width = 45;



String[] compiler_stack = {"$", "F", "T"};

int[][] compiler_matrix = {
  // -2 = empty cell (error case)
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

String[] stack_actions_history = {"1", "pop", "acc"};
String compiler_error;

void setup() {
  size(1366, 768);
  read_input("input.txt");
  init_compiler_stack();
  frameRate(30);
}


void draw() {
  background(255);

  draw_tokens_stream();
  draw_compiler_stack();
  draw_stack_actions_history();
  draw_error();
}
void init_compiler_stack() {
};
void keyPressed() {
  if (key == CODED && keyCode == RIGHT) {
    // get token pointed by head;
    String target_token = tokens_stream[head_index];

    // get top of compiler stack
    String top_compiler_stack = compiler_stack[compiler_stack.length-1];

    // find row index corresponding to top_compiler_stack;
    int rowindx=-1;
    for (int i=0; i < compiler_matrix_rows.length; i++) {
      if (compiler_matrix_rows[i] == top_compiler_stack)
        rowindx = i;
    }
    assert rowindx!=-1;

    // find col index corresponding to target token
    int colindx=-1;
    for (int i=0; i < compiler_matrix_cols.length; i++) {
      if (compiler_matrix_cols[i] == target_token)
        colindx = i;
    }
    assert colindx!=-1;


    int next_action = compiler_matrix[rowindx][colindx];
    switch(next_action) {
    case 0: // word is accepted
      
      break;
    case -1: // pop from the stack
      
      break;
    case -2: // error occured
      
      break;
    default: // update stack with next grammar rule
      
      
    }
  }
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

void draw_tokens_stream() {
  float xoffset = 40;
  float yoffset = 40;
  float rect_width = tokens_stream.length * token_slot_width;
  float headxoffset = token_slot_width /2;

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

  textSize(18);
  fill(20);
  text("Tokens stream:", xoffset, 0.7*yoffset );
  noFill();
  textSize(12);

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
  float cellW = token_slot_width;
  float cellH = token_slot_width;
  float xoffset    = 40;
  float yoffset = 80;

  float startY = height - yoffset - cellH;

  for (int i = 0; i < compiler_stack.length; i++) {
    float y = startY - i * cellH;
    stroke(0);
    noFill();
    rect(xoffset, y, cellW, cellH);
    fill(0);
    text(compiler_stack[i], xoffset + cellW/2, y + cellH/2);
  }
  textSize(18);
  fill(20);
  text("Compiler stack", xoffset, height-0.5*yoffset );
  noFill();
  textSize(12);
}

void draw_stack_actions_history() {
  float xoffset = 80 + tokens_stream.length * token_slot_width ;
  float yoffset = 40;
  float rect_width = stack_actions_history.length * token_slot_width;
  float headxoffset = token_slot_width /2;

  fill(191);
  rect(xoffset, yoffset, rect_width, yoffset);
  noFill();

  for (int i=0; i < stack_actions_history.length; i++) {
    fill(230);
    rect(xoffset + i * token_slot_width, yoffset, token_slot_width, yoffset);
    fill(0);
    text(stack_actions_history[i], xoffset + i * token_slot_width + headxoffset/2, 1.6 * yoffset );
    noFill();
  }
  textSize(18);
  fill(20);
  text("On stack actions history:", xoffset, 0.7*yoffset );
  noFill();
  textSize(12);
}

void draw_error() {
  float xoffset = 90 + tokens_stream.length * token_slot_width ;
  float yoffset = 40;
  float headxoffset = token_slot_width /2;

  textSize(18);
  fill(200, 0, 0);
  text("Error:"+compiler_error, xoffset + headxoffset/2, height-yoffset);
  noFill();
  textSize(12);
}
