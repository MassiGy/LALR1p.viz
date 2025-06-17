/**
 @author: Massiles GHERNAOUT.
 */


int head_index = 0;
String[] tokens_stream;
int tokens_stream_nb_spaces;

float token_slot_width = 45;


boolean parsing_ended = false;
String[] LALR1p_stack = {"$", "P"};

int[][] LALR1p_matrix = {
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

String[] LALR1p_matrix_cols = {
  "debut", "fin", ";", "id", ":=", "+", "*", "(", ")", "nb", "€"
};
String[] LALR1p_matrix_rows = {
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
String LALR1p_error;
String LALR1p_hint;

void setup() {
  size(1366, 768);
  read_input("input2.txt");
  tokens_stream = push2strArr(tokens_stream, "€");

  // the visualization is almost completely static, so reduce fps to save up machine power
  frameRate(5);
}


void draw() {
  background(255);

  draw_tokens_stream();
  draw_LALR1p_stack();
  draw_stack_actions_history();
  draw_error();
  draw_hint();

  // freeze the screen, nothing to do anymore
  if (parsing_ended)
    noLoop();
}

void keyPressed() {
  if (key == CODED && keyCode == RIGHT && !parsing_ended) {
    // get token pointed by head;
    String target_token = tokens_stream[head_index];

    // get top of LALR1p stack
    String top_LALR1p_stack = LALR1p_stack[LALR1p_stack.length-1];


    if (top_LALR1p_stack.equals("€") && LALR1p_stack.length > 2) {
      LALR1p_stack = popFromStrArr(LALR1p_stack);
      return;
    }
    int next_action = get_next_action(top_LALR1p_stack, target_token);

    switch(next_action) {
    case 0: // word is accepted
      // push "Acc" to history stack
      stack_actions_history= push2strArr(stack_actions_history, "Acc");
      // end the parsing
      parsing_ended = true;

      break;
    case -1:
      // pop from the LALR1p stack
      LALR1p_stack = popFromStrArr(LALR1p_stack);
      // push "pop" to history stack
      stack_actions_history= push2strArr(stack_actions_history, "Pop");

      // move the head index to the right by 1;
      head_index++;


      break;
    case -2:


      // error occured
      LALR1p_error="No appropriate next rule found.\nPlease check if the input program follows the grammar accordingly.";

      // generate hint for the user;
      generate_hints(top_LALR1p_stack, target_token);

      // end the parsing
      parsing_ended = true;

      break;
    default:
      // pop the top of the LALR1p stack before updating it
      LALR1p_stack = popFromStrArr(LALR1p_stack);

      // update stack with next grammar rule
      for (int i=grammar_rhs[next_action-1].length-1; i >= 0; i--) {
        LALR1p_stack = push2strArr(LALR1p_stack, grammar_rhs[next_action-1][i]);
      }

      // push next_action to history stack
      stack_actions_history= push2strArr(stack_actions_history, ""+next_action);
    }
  }
}


void read_input(String filename) {
  String[] content = loadStrings(filename);
assert content.length == 1 :
  "Wrong input format. Please check out the readme.";

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
  int items_per_row = 10;
  float headxoffset = token_slot_width / 2;


  for (int i = 0; i < tokens_stream.length; i++) {
    int row = i / items_per_row;  // Determine which row the element belongs to.
    int col = i % items_per_row;  // Determine the column in the row.

    fill(230);
    rect(xoffset + col * token_slot_width, yoffset + row * yoffset, token_slot_width, yoffset);

    fill(0);
    text(tokens_stream[i], xoffset + col * token_slot_width + headxoffset / 2, yoffset + row *  yoffset + 0.6 * yoffset);
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


void draw_LALR1p_stack() {
  float slot_width = token_slot_width * 1.1;
  float slot_height = token_slot_width;
  float xoffset    = 40;
  float yoffset = height - slot_height - 80;


  for (int i = 0; i < LALR1p_stack.length; i++) {
    float y = yoffset - i * slot_height;
    stroke(0);
    noFill();
    rect(xoffset, y, slot_width, slot_height);
    fill(0);
    text(LALR1p_stack[i], xoffset + slot_width/2 - 10, y + slot_height/2);
  }

  yoffset = 80;
  textSize(18);
  fill(20);
  text("LALR1p stack "+(parsing_ended ? "(parsing_ended).": "(ongoing_parsing)."), xoffset, height-0.5*yoffset );
  text("> Hit Right-Arrow to move on the parsing.", xoffset, height - 0.25 * yoffset);
  noFill();
  textSize(12);
}

void draw_stack_actions_history() {
  float xoffset = width/2;
  float yoffset = 40;
  int items_per_row = 10;
  float headxoffset = token_slot_width / 2;


  for (int i = 0; i < stack_actions_history.length; i++) {
    int row = i / items_per_row;  // Determine which row the element belongs to.
    int col = i % items_per_row;  // Determine the column in the row.

    fill(230);
    rect(xoffset + col * token_slot_width, yoffset + row * yoffset, token_slot_width, yoffset);

    fill(0);
    text(stack_actions_history[i], xoffset + col * token_slot_width + headxoffset / 2, yoffset + row *  yoffset + 0.6 * yoffset);
    noFill();
  }

  textSize(18);
  fill(20);
  text("On stack actions history:", xoffset, 0.7* yoffset);
  noFill();
  textSize(12);
}


void draw_error() {
  float xoffset = width/2;

  float yoffset = 40;
  float headxoffset = token_slot_width /2;


  textSize(18);
  fill(200, 0, 0);
  text("Error: "+LALR1p_error, xoffset + headxoffset/2, height-yoffset);
  noFill();
  textSize(12);
}

void draw_hint() {
  if (LALR1p_hint == null)
    return;


  float xoffset = width/2;

  float yoffset = 100;
  float headxoffset = token_slot_width /2;


  textSize(18);
  fill(0, 0, 200);
  text("Hint: "+LALR1p_hint, xoffset + headxoffset/2, height-yoffset);
  noFill();
  textSize(12);
}

int get_rowindx_for_next_action(String top_LALR1p_stack) {
  // find row index corresponding to top_LALR1p_stack;
  int rowindx=-1;
  for (int i=0; i < LALR1p_matrix_rows.length; i++) {
    if (LALR1p_matrix_rows[i].equals(top_LALR1p_stack))
      rowindx = i;
  }
  return rowindx;
}

int get_colindx_for_next_action(String target_token) {

  // find col index corresponding to target token
  int colindx=-1;
  for (int i=0; i < LALR1p_matrix_cols.length; i++) {
    if (LALR1p_matrix_cols[i].equals(target_token))
      colindx = i;
  }
  return colindx;
}


int get_next_action(String top_LALR1p_stack, String target_token) {

  int rowindx= get_rowindx_for_next_action(top_LALR1p_stack);
  if (rowindx == -1) {
    return -2;
  }

  int colindx= get_colindx_for_next_action(target_token);
  if (colindx == -1) {
    return -2;
  }
  return LALR1p_matrix[rowindx][colindx];
}

void generate_hints(String top_LALR1p_stack, String target_token) {

  int rowindx= get_rowindx_for_next_action(top_LALR1p_stack);
  if (rowindx == -1) {
    LALR1p_hint = "Unkown next rule. The rule at the top of the LALR1p stack is not in the grammar.\n";
    return;
  }

  int colindx= get_colindx_for_next_action(target_token);
  if (colindx == -1) {
    LALR1p_hint = "Unkown next token. The token pointed by the head is not in the grammar.\n";
    return;
  }


  if (LALR1p_matrix[rowindx][colindx] == -2) {
    String hint = "Expected tokens { ";
    for (int i = 0; i < LALR1p_matrix[rowindx].length; i++) {
      if (LALR1p_matrix[rowindx][i] != -2) {
        // add this token to the expected tokens set
        hint+= LALR1p_matrix_cols[i];
        if (i < LALR1p_matrix[rowindx].length-1) {
          hint+="    ";
        }
      }
    }

    hint+= "}, but got: { " + (target_token.equals(" ") ? "<space>" : target_token )+" }.";
    LALR1p_hint = hint;
    return;
  }

  LALR1p_hint = "Please reverify the grammar of your input. \n(default hint, failed to generate a specific one).";
  return;
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
