import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MFWProgrammingTool extends PApplet {



int rposx = 4;
int gposx = 4;
int bposx = 4;
int rval = 0;
int gval = 0;
int bval = 0;
int output = 0;
PFont fontA;

Serial port;
ControlP5 controlP5;
Textfield redNumberField;
Textfield greenNumberField;
Textfield blueNumberField;

public void setup() {
size(480,180);
controlP5 = new ControlP5(this);
background(0);
stroke(255);
fill(255);
rect(4,4,257,52);
rect(4,64,257,52);
rect(4,124,257,52);
fontA = createFont("Verdana",26);
textFont(fontA);
textAlign(CENTER);

frame.setTitle("MFWProgrammingTool");


PFont font = createFont("arial",18);
redNumberField = controlP5.addTextfield("RED")
     .setPosition(275,15)
     .setSize(40,30)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,255,255));
     
greenNumberField = controlP5.addTextfield("GREEN")
     .setPosition(275,80)
     .setSize(40,30)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,255,255));
     
blueNumberField = controlP5.addTextfield("BLUE")
     .setPosition(275,135)
     .setSize(40,30)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,255,255));


// this will allow for serial port communication with the arduino
println("Available serial ports:");
println(Serial.list());
//selects the first port in the Serial.list() for use and speed of 115200
port = new Serial(this, Serial.list()[1],115200);
}

public void draw() {
// this draws a circle wich displayed the mixed color that is being output to the Arduino
  fill(rval,gval,bval);
  ellipse(390,90,100,100);

// these draw the red, green, and blue gradient lines, as well as a verticle bar in each one to denote what amt of that color is
// being selected
    for (int i = 0; i<256; i++) {
    stroke(i,0,0);
    line(i+5,5,i+5,55);
  }
  stroke(255);
  line(rposx,5,rposx,55);
  for (int i = 0; i<256; i++) {
    stroke(0,i,0);
    line(i+5,65,i+5,115);
  }
  stroke(255);
  line(gposx,65,gposx,115);
 
  for (int i = 0; i<256; i++) {
    stroke(0,0,i);
    line(i+5,125,i+5,175);
  }
  stroke(255);
  line(bposx,125,bposx,175); 
}

public void updateSliders() {
}

public void mouseDragged() {
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
    int routp = PApplet.parseInt(rout);
//    println(routp);
    port.write(routp);      
  } 
  if (mouseX < 260 && mouseX > 5 && mouseY > 65 && mouseY < 115) {
    gposx = mouseX;
    gval = mouseX-5;
    greenNumberField.setValue(str(gval));
    float gout;
    gout = map(gval, 0, 255, 86, 170);
    int goutp = PApplet.parseInt(gout);
//    println(goutp);
    port.write(goutp);
  }
  if (mouseX < 260 && mouseX > 5 && mouseY > 125 && mouseY < 175) {
    bposx = mouseX;
    bval = mouseX-5;
    blueNumberField.setValue(str(bval));
    float bout;
    bout = map(bval, 0, 255, 171, 255);
    int boutp = PApplet.parseInt(bout);
//    println(boutp);
    port.write(boutp);
  }
}

public void keyReleased() {
  rposx = PApplet.parseInt(redNumberField.getText());
  rval = rposx-5;
  gposx = PApplet.parseInt(greenNumberField.getText());
  gval = gposx-5;
  bposx = PApplet.parseInt(blueNumberField.getText());
  bval = bposx-5;
  //updateSliders();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MFWProgrammingTool" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
