import controlP5.*;
import java.io.FileWriter;

int rposx = 4;
int gposx = 4;
int bposx = 4;
int rval = 0;
int gval = 0;
int bval = 0;
int output = 0;
int serialPort = 0;
PFont fontA;
import processing.serial.*;
import java.util.Random;
Serial port;
ControlP5 controlP5;
Textfield redNumberField;
Textfield greenNumberField;
Textfield blueNumberField;
int numberOfColors = 90;
Textfield numberOfColorsField;
Textlabel errorText;
Button exportPaletteButton;
Button importPaletteButton;
DropdownList serialPortList;

int selectedColorButton = 0;
ArrayList<Color> palette = new ArrayList<Color>();
ArrayList<ColorButton> colorButtons = new ArrayList<ColorButton>();

boolean paletteNeedsUpdated = true;



/* PALETTE CONFIGURATION */
int rows = 6;
int cols = 15;
int colors = rows*cols;
int padding = 2;



/* File IO */


void fileSelected(File selection) {
  if (selection == null) {
    displayError("User cancelled save operation");
  } else {
    try {
      String filename = selection.getAbsolutePath();
      if (filename.indexOf(".") == -1) {
        filename = split(filename, ".")[0] + ".json";
      } else {
        filename = filename + ".json";
      }
      File file = new File(filename);
      file.createNewFile();
      FileWriter writer = new FileWriter(file); 
      JSONObject obj = paletteColorArrayToJSON(getPaletteColorArray());
      writer.write(obj.toString()+"\r\n");
      writer.flush();
      writer.close();
      displayError("Exported palette to " + filename);
    } catch (Exception except) {
      displayError("Error saving to " + selection.getAbsolutePath());
    }
  }
}

void fileImport(File selection) {
  if (selection == null) {
    displayError("User cancelled save operation");
  } else {
    try {
      resetPalette();
      String filename = selection.getAbsolutePath();
      JSONObject obj = loadJSONObject(filename);
      JSONArray colors = obj.getJSONArray("colors");
      for (int i=0;i<colors.size();i++) {
        palette.set(i, new Color(colors.getJSONArray(i).getInt(0), colors.getJSONArray(i).getInt(1), colors.getJSONArray(i).getInt(2)));
      }
    } catch (Exception except) {
      displayError("Error saving to " + selection.getAbsolutePath());
    }
  }
}


/* GENERIC CLASSES */

class Color {
  public int[] rgb;
  public String hex;
  public Color(int red, int green, int blue) {
    rgb = new int[]{red,green,blue};
    hex = String.format("#%02x%02x%02x", red, green, blue);
  }
}


class Point {
  public int x;
  public int y;
  public Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
}

class Size {
  public int width;
  public int height;
  public Size(int width, int height) {
    this.width = width;
    this.height = height;
  }
}

class ColorButton {
  public Point position;
  public Size size;
  public Color Color;
  public ColorButton(Color theColor, boolean highlighted, int padding, Point position, Size size) {
    fill(theColor.rgb[0], theColor.rgb[1], theColor.rgb[2]);
    if (highlighted) {
      stroke(255,0,0);
    } else {
      stroke(0);
    }
    strokeWeight(padding);
    rect(position.x, position.y, size.width, size.height);
    this.position = position;
    this.size = size;
    this.Color = theColor;
  }
}



/* PALETTE CONTROLS */

void resetPalette() {
  palette = new ArrayList<Color>();
  for (int i=0;i<colors;i++) {
    Color theColor = new Color(255,255,255);
    palette.add(theColor);
  }
}

void drawPalette() {
  colorButtons = new ArrayList<ColorButton>();
  if (paletteNeedsUpdated) {
    resetPalette();
    paletteNeedsUpdated = false;
  }
  for (int row=0;row<rows;row++) {
    for (int col=0;col<cols;col++) {
      boolean highlighted = false;
      if (selectedColorButton == ((cols*row)+col)) {
        highlighted = true;
      }
      ColorButton paletteColorButton = new ColorButton(palette.get(((cols*row)+col)),
        highlighted,
        padding,
        new Point(0+(32*col), 210+(32*row)),
        new Size(32, 32));
      colorButtons.add(paletteColorButton);
    }
  }
}



/* ARRAY CONVERSION FUNCTIONS */

public ArrayList<int[]> truncateColorArray(ArrayList<int[]> colorArray) {
  ArrayList<int[]> tmpArray = new ArrayList<int[]>();
  boolean flagged = false;
  for (int i=0;i<colorArray.size();i++) {
    if (colorArray.get(i)[0] == 255 && colorArray.get(i)[1] == 255 && colorArray.get(i)[2] == 255) {
      if (flagged) {
        return tmpArray;
      } else {
        flagged = true;
      }
    } else {
      if (flagged) {
        tmpArray.add(colorArray.get(i-1));
        flagged = false;
      }
      tmpArray.add(colorArray.get(i));
    }
  }
  return tmpArray;
}

public ArrayList<int[]> getPaletteColorArray() {
  ArrayList<int[]> colorList = new ArrayList<int[]>();
  for (int i=0;i<palette.size();i++) {
    colorList.add(palette.get(i).rgb);
  }
  return truncateColorArray(colorList);
}

public JSONObject paletteColorArrayToJSON(ArrayList<int[]> colorArray) {
  JSONObject obj = new JSONObject();
  JSONArray colors = new JSONArray();
  for(int i = 0 ; i < colorArray.size() ; i++){
    JSONArray tmpColor = new JSONArray();
    tmpColor.setInt(0, colorArray.get(i)[0]);
    tmpColor.setInt(1, colorArray.get(i)[1]);
    tmpColor.setInt(2, colorArray.get(i)[2]);
    colors.setJSONArray(i, tmpColor);
  }
  obj.setJSONArray("colors", colors);
  return obj;
}


/* IMPORT/EXPORT Functions */

void exportJSON() {
  selectOutput("Select a file to write to:", "fileSelected");
}

void importJSON() {
  selectInput("Select a file to import:", "fileImport");
}



/* UPDATE SLIDERS BASED ON RGB INT VALUES */

void updateSliders() {
  rposx = int(redNumberField.getText());
  rval = rposx-5;
  gposx = int(greenNumberField.getText());
  gval = gposx-5;
  bposx = int(blueNumberField.getText());
  bval = bposx-5;
}



/* ERROR DISPLAY UTILITY */

void displayError(String error) {
  errorText.setText(error);
}



/* SETUP THE VIEW */

void setup() {
  size(481, 450);
  controlP5 = new ControlP5(this);
  stroke(255);
  fill(255);
  rect(4, 4, 257, 52);
  rect(4, 64, 257, 52);
  rect(4, 124, 257, 52);
  fontA = createFont("Verdana", 26);
  textFont(fontA);
  textAlign(CENTER);

  surface.setTitle("MFWProgrammingTool");


  PFont font = createFont("arial", 18);
  PFont errorFont = createFont("arial", 12);
  redNumberField = controlP5.addTextfield("RED")
    .setPosition(275, 15)
    .setSize(40, 30)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255, 255, 255));

  greenNumberField = controlP5.addTextfield("GREEN")
    .setPosition(275, 80)
    .setSize(40, 30)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255, 255, 255));

  blueNumberField = controlP5.addTextfield("BLUE")
    .setPosition(275, 135)
    .setSize(40, 30)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255, 255, 255));

  serialPortList = controlP5.addDropdownList("Serial")
    .setPosition(350, 10)
    ;


  errorText = controlP5.addTextlabel("errorText", "", 2, 183)
    .setFont(errorFont)
    .setColor(color(255, 0, 0));
    
    
  exportPaletteButton = controlP5.addButton("Export Palette", 1.0, 375, 415, 100, 30);
  importPaletteButton = controlP5.addButton("Import Palette", 1.0, 265, 415, 100, 30);
  
  numberOfColorsField = controlP5.addTextfield("Colors in Palette")
    .setPosition(360, 150)
    .setSize(60, 30)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255, 255, 255))
    .setText(str(numberOfColors));

  customize(serialPortList); // customize the first list


  // this will allow for serial port communication with the arduino
  println("Available serial ports:");
  println(Serial.list());
  //selects the first port in the Serial.list() for use and speed of 115200
  port = new Serial(this, Serial.list()[serialPort], 115200);
  
}


/* Wrap the dropdown in a visually pleasing style */
void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  for (int i=1; i<Serial.list().length; i++) {
    ddl.addItem(Serial.list()[i], i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}


/* DRAW THE CANVAS */

void draw() {
  background(0);
  // this draws a circle wich displayed the mixed color that is being output to the Arduino
  fill(rval, gval, bval);
  ellipse(390, 90, 100, 100);

  // these draw the red, green, and blue gradient lines, as well as a verticle bar in each one to denote what amt of that color is
  // being selected
  for (int i = 0; i<256; i++) {
    stroke(i, 0, 0);
    line(i+5, 5, i+5, 55);
  }
  stroke(255);
  line(rposx, 5, rposx, 55);
  for (int i = 0; i<256; i++) {
    stroke(0, i, 0);
    line(i+5, 65, i+5, 115);
  }
  stroke(255);
  line(gposx, 65, gposx, 115);

  for (int i = 0; i<256; i++) {
    stroke(0, 0, i);
    line(i+5, 125, i+5, 175);
  }
  stroke(255);
  line(bposx, 125, bposx, 175);
  
  drawPalette();
}



/* MOUSE EVENTS */

void mouseReleased() {
  serialPort = int(serialPortList.getValue()); 
  try {
    port = new Serial(this, Serial.list()[serialPort], 115200);
  } 
  catch (Exception e) {
    String error = "Failed to connect to " + Serial.list()[serialPort];
    displayError(error);
  }
  
  for (int i=0;i<colorButtons.size();i++) {
    ColorButton button = colorButtons.get(i);
    if (mouseX>button.position.x && mouseX<button.position.x+button.size.width &&
        mouseY>button.position.y && mouseY<button.position.y+button.size.height) {
      selectedColorButton = i;
      redNumberField.setText(str(palette.get(selectedColorButton).rgb[0]));
      greenNumberField.setText(str(palette.get(selectedColorButton).rgb[1]));
      blueNumberField.setText(str(palette.get(selectedColorButton).rgb[2]));
      updateSliders();
    }
  }
  
  if (mouseX>exportPaletteButton.getPosition()[0] && mouseX<exportPaletteButton.getPosition()[0]+100 &&
        mouseY>exportPaletteButton.getPosition()[1] && mouseY<exportPaletteButton.getPosition()[1]+30) {
          exportJSON();
  }
  
  if (mouseX>importPaletteButton.getPosition()[0] && mouseX<importPaletteButton.getPosition()[0]+100 &&
        mouseY>importPaletteButton.getPosition()[1] && mouseY<importPaletteButton.getPosition()[1]+30) {
          importJSON();
  }
}

void mouseDragged() {
  // this allows you to drag the bar in the gradient to select the color, by determining if the mouse is inside one of the gradient
  // bars and which gradient bar you are in. 
  if (mouseX < 260 && mouseX > 5 && mouseY > 5 && mouseY < 55) {
    rposx = mouseX;
    rval = rposx-5;
    redNumberField.setValue(str(rval));
    float rout;
    // for rout,gout,bout rather than sending out the 0-255 value for each i remapped the values to 0-85 for red,86-170 for green,
    // and 171-255 for blue. this allowed me to only send a single serial port message from the computer to the arduino each time the
    // color is changed
    rout = map(rval, 0, 255, 0, 85);
    int routp = int(rout);
    //    println(routp);
    port.write(routp);
  } 
  if (mouseX < 260 && mouseX > 5 && mouseY > 65 && mouseY < 115) {
    gposx = mouseX;
    gval = mouseX-5;
    greenNumberField.setValue(str(gval));
    float gout;
    gout = map(gval, 0, 255, 86, 170);
    int goutp = int(gout);
    //    println(goutp);
    port.write(goutp);
  }
  if (mouseX < 260 && mouseX > 5 && mouseY > 125 && mouseY < 175) {
    bposx = mouseX;
    bval = mouseX-5;
    blueNumberField.setValue(str(bval));
    float bout;
    bout = map(bval, 0, 255, 171, 255);
    int boutp = int(bout);
    //    println(boutp);
    port.write(boutp);
  }
  palette.set(selectedColorButton, new Color(rval, gval, bval));
}

/* KEYBOARD EVENTS */

void keyReleased() {
  updateSliders();
}