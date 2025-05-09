int head_index = 0;
String[] tokens_stream;
int tokens_stream_nb_spaces;

float token_slot_width = 45;


boolean compilation_ended = false;
String[] compiler_stack = {"$", "P"};

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
  {"T", "E'"},
  {"+", "T", "E'"},
  {"€"},
  {"F", "T'"},
  {"*", "F", "T'"},
  {"€"}, // € is for epsilon
  {"(", "E", ")"},
  {"id"}, // vars in the input
  {"nb"}
};

String[] stack_actions_history = {};
String compiler_error;

void setup() {
  size(1366, 768);
  read_input("input.txt");
  tokens_stream = push2strArr(tokens_stream, "€");
  init_compiler_stack();
  println(get_next_action("P", "debut"));
  println(get_next_action("S", "fin"));
  println(get_next_action("T'", "fin"));
  println(get_next_action("F", "id"));
  println(get_next_action("$", "id"));
  // the visualization is almost completely static, so reduce fps to save up machine power
  frameRate(5);
}


void draw() {
  background(255);

  draw_tokens_stream();
  draw_compiler_stack();
  draw_stack_actions_history();
  draw_error();



  // freeze the screen, nothing to do anymore
  if (compilation_ended)
    noLoop();
}

void init_compiler_stack() {
};
void keyPressed() {
  if (key == CODED && keyCode == RIGHT && !compilation_ended) {
    // get token pointed by head;
    String target_token = tokens_stream[head_index];

    println("target_token="+target_token+";");

    // get top of compiler stack
    String top_compiler_stack = compiler_stack[compiler_stack.length-1];
    println("target_token="+target_token+";");
    println("top_compiler_stack="+top_compiler_stack+";");


    if (top_compiler_stack.equals("€") && compiler_stack.length > 2) {
      compiler_stack = popFromStrArr(compiler_stack);
      return;
    }
    int next_action = get_next_action(top_compiler_stack, target_token);

    switch(next_action) {
    case 0: // word is accepted
      // push "Acc" to history stack
      stack_actions_history= push2strArr(stack_actions_history, "Acc");
      // end the compilation
      compilation_ended = true;

      break;
    case -1:
      // pop from the compiler stack
      compiler_stack = popFromStrArr(compiler_stack);
      // push "pop" to history stack
      stack_actions_history= push2strArr(stack_actions_history, "Pop");

      // move the head index to the right by 1;
      head_index++;


      break;
    case -2:
      //println("rowindx=",rowindx, ";colindx=",colindx, ";next_action=", next_action);
      // error occured
      compiler_error="No appropriate next rule found.\n Please check if the input program follows the grammar accordingly.";
      // end the compilation
      compilation_ended = true;

      break;
    default:
      // pop the top of the compiler stack before updating it
      compiler_stack = popFromStrArr(compiler_stack);

      // update stack with next grammar rule
      for (int i=grammar_rhs[next_action-1].length-1; i >= 0; i--) {
        compiler_stack = push2strArr(compiler_stack, grammar_rhs[next_action-1][i]);
      }

      // push next_action to history stack
      stack_actions_history= push2strArr(stack_actions_history, ""+next_action);
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

assert head_index >= 0 && head_index < tokens_stream.length:
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
  text("Compiler stack "+(compilation_ended ? "(compilation_ended)": "(compilation_not_ended)"), xoffset, height-0.5*yoffset );
  noFill();
  textSize(12);
}

void draw_stack_actions_history() {
  float xoffset = 80 + tokens_stream.length * token_slot_width ;
  float yoffset = 40;
  float rect_width = stack_actions_history.length * token_slot_width;
  float headxoffset = token_slot_width /2;

  //fill(191);
  //rect(xoffset, yoffset, rect_width, yoffset);
  //noFill();

  int stagescount = stack_actions_history.length /10;

  for (int j=0; j < stagescount; j++) {

    for (int i=0; i < 10; i++) {
      fill(230);
      rect(xoffset + i * token_slot_width, yoffset, token_slot_width, yoffset  );
      fill(0);
      text(stack_actions_history[i+j*10], xoffset + i * token_slot_width + headxoffset/2, 1.6 * yoffset );
      noFill();
    }
    yoffset*=2;
  }

  int slots_count =  stack_actions_history.length;
  int i = 0;
  while (slots_count > 0) {
    for (; i < i+10; i++) {
      fill(230);
      rect(xoffset + i * token_slot_width, yoffset, token_slot_width, yoffset  );
      fill(0);
      text(stack_actions_history[i+j*10], xoffset + i * token_slot_width + headxoffset/2, 1.6 * yoffset );
      noFill();
    }
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



String[] push2strArr(String[] arr, String val) {
  String[] newArr = new String[arr.length+1];
  for (int i=0; i < arr.length; i++) {
    newArr[i] = arr[i];
  }
  newArr[arr.length]=val;
  return newArr;
}

String[] popFromStrArr(String[] arr) {
  String[] newArr = new String[arr.length-1];
  for (int i=0; i < arr.length-1; i++) {
    newArr[i] = arr[i];
  }
  return newArr;
}

int get_next_action(String top_compiler_stack, String target_token) {

  // find row index corresponding to top_compiler_stack;
  int rowindx=-1;
  for (int i=0; i < compiler_matrix_rows.length; i++) {
    if (compiler_matrix_rows[i].equals(top_compiler_stack))
      rowindx = i;
  }
assert rowindx!=-1 :
  "1";

  // find col index corresponding to target token
  int colindx=-1;
  for (int i=0; i < compiler_matrix_cols.length; i++) {
    if (compiler_matrix_cols[i].equals(target_token))
      colindx = i;
  }
assert colindx!=-1 :
  "2";


  return compiler_matrix[rowindx][colindx];
}
