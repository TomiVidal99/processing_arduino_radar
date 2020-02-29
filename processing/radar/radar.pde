// importo librerias para trabajar con los puertos y 
// la consola de JAVA
import processing.serial.*;
import static javax.swing.JOptionPane.*;

// este es mi puerto serial tipo COM1 o COM3
Serial myPort;
int portBaudRate = 9600;
final boolean debug = true;
String COMx, COMlist = "";

float angle = 0;
boolean clockWise = true;

float laserLongitud = 900;
int laserLong;

String startVelocity = "f"; // 's' slow 'm' medium 'f' fast

FloatList coordenatesList = new FloatList();

void portSelection() {
  // esta funcion es para poder seleccionar el puerto COM
  try {
    if (debug) printArray(Serial.list());
    int i = Serial.list().length;
    if (i != 0) {
      if (i >= 2) {
        // need to check which port the inst uses -
        // for now we'll just let the user decide
        for (int j = 0; j < i; ) {
          COMlist += char(j+'a') + " = " + Serial.list()[j];
          if (++j < i) COMlist += ",  ";
        }
        COMx = showInputDialog("Seleccione el puerto? (a,b,..):\n"+COMlist);
        if (COMx == null) exit();
        if (COMx.isEmpty()) exit();
        i = int(COMx.toLowerCase().charAt(0) - 'a') + 1;
      }
      String portName = Serial.list()[i-1];
      if (debug) println(portName);
      myPort = new Serial(this, portName, portBaudRate); // change baud rate to your liking
      myPort.bufferUntil('\n'); // buffer until CR/LF appears, but not required..
    } else {
      showMessageDialog(frame, "No hay ningún dispositivo conectado a la PC");
      exit();
    }
  }
  catch (Exception e)
  { //Print the type of error
    showMessageDialog(frame, "El puerto COM no está disponible (capas lo tenés usado por otro proceso)");
    println("Error:", e);
    exit();
  }
}

void writeToPort(String message) {
  //println("You tried to write: '" + message + "'r to the port: " + COMx);
  myPort.write(message);
}

float[] getCoordenate(float rad, float ang) {

  float arr[] = new float[4];
  float doubleWidth = width*2;

  //println("angle: ", ang, " radio: ", rad);

  if (ang > 0 && ang < PI/2) {

    // cuando estoy en los primeros 90 grados
    arr[0] = -rad*cos(ang); // esta es mi x
    arr[1] = -rad*sin(ang); // esta es mi y
    // defino punto terminal de la linea
    arr[2] = -(doubleWidth)*cos(ang); // esta es mi y
    arr[3] = -(doubleWidth)*sin(ang); // esta es mi x
  } else if (ang > PI/2 && ang < PI) {

    // cuando estoy entre 90 y 180 grados
    float newAng = PI - ang;
    arr[0] = rad*cos(newAng); // esta es mi x
    arr[1] = -rad*sin(newAng); // esta es my y
    // defino el punto terminal de la linea
    arr[2] = (doubleWidth)*cos(newAng); // esta es mi x
    arr[3] = -(doubleWidth)*sin(newAng); // esta es mi y
  }
  return(arr);
}

void drawRadarGrid() {
  // dibujar las lineas del radar
  push();
  noFill();
  line(0, 0, width/2, height);
  line(width, 0, width/2, height);
  line(width/2, 0, width/2, height);
  line(0, height/2, width/2, height);
  line(width, height/2, width/2, height);

  circle(width/2, height, height*2);
  circle(width/2, height, height);
  circle(width/2, height, height/2);

  textAlign(CENTER);
  textSize(12);
  fill(255);
  text("50cm", (width/2), 12);
  text("25cm", (width/2), (height/2) + 12);
  text("13cm", (width/2), (3*height/4) + 12);

  pop();
}

void radarDetector(float ang, float ll) {
  push();
  // primero dibujo la linea y luego la roto con un angulo ang
  stroke(42, 176, 84);
  strokeWeight(5);
  translate(width/2, height);
  rotate(ang);
  //rotate(PI/3);
  line(0, 0, -ll, 0);
  // ahora dibujo un punto en el inicio de la linea como decoracion
  fill(0);
  circle(width/2, height, 10);
  pop();
} 

void setup() {

  size(
    600, 
    600
    );

  // iniciar la consola para seleccionar el puerto COM
  portSelection();

  myPort.write("0");

  delay(5000);
  println("Started");
  myPort.write(startVelocity);
  delay(500);
  myPort.write("b");
      
    
}

void draw() {

  if ( myPort.available() > 0) { 
    String val = myPort.readStringUntil('\n');
    if (val != null) {
      try {
        String[] splitted = split(val, "&");
        if (splitted.length == 2) {
          laserLong = Integer.parseInt(splitted[0]);
          angle = float(splitted[1])*(PI/180);;
        } else if (splitted.length == 3) {
          coordenatesList.clear();
          laserLong = Integer.parseInt(splitted[0]);
          angle = float(splitted[2])*(PI/180);;
        }
      }
      catch (NumberFormatException e) {
        println("ERROR ", e);
      }
    }
  }

  background(28, 117, 56);
  drawRadarGrid(); 

  if (laserLong > 0 && laserLong < 100) {
    float mappedLong = map(laserLong, 1, 50, 1, height);
    //radarDetector(angle, mappedLong);
    radarDetector(angle, width*2);
    float[] coords = getCoordenate(mappedLong, angle);
    //println("Coordenada: ", coords[0], coords[1], coords[2], coords[3]);
    coordenatesList.append(coords[0]);
    coordenatesList.append(coords[1]);
    coordenatesList.append(coords[2]);
    coordenatesList.append(coords[3]);
  } else {
    radarDetector(angle, 2*width);
  }

  float[] arr = coordenatesList.array();

  for (int i = 0; i < arr.length; i += 4) {
    //println("Coords: ", arr[i], ", ", arr[i+1]); 
    push();
    translate(width/2, height);
    stroke(255, 0, 0);
    strokeWeight(3);
    line(arr[i], arr[i+1], arr[i+2], arr[i+3]);
    pop();
  }


  delay(2);
}
