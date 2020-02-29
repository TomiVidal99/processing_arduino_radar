#include <Servo.h>

int rotationSpeed = 1;

int led_rojo = 10;
int led_azul = 11;

int servoPin = 3;
Servo servo;
int currentAngle;
boolean isClockWise;

boolean isOn = false;

int maxAngle = 180;
int minAngle = 0;

int echo = 7;
int trig = 8;

long duration, cm;

bool shouldClear = false;

long distancia_actual() {

  // enviar puslo por 10ms
  digitalWrite(trig, LOW);
  delayMicroseconds(5);
  digitalWrite(trig, HIGH);
  delayMicroseconds(10);
  digitalWrite(trig, LOW);

  // escuchar el pulso recibido
  pinMode(echo, INPUT);
  duration = pulseIn(echo, HIGH);

  // definir las variables iniciales en base a los datos recibidos
  cm = (duration / 2) / 29.1;
  
    
}

void setup() {

  Serial.begin(9600);
  pinMode(led_rojo, OUTPUT);
  pinMode(led_azul, OUTPUT);
  pinMode(trig, OUTPUT);
  pinMode(echo, INPUT);
  servo.attach(servoPin);

  delay(500);

  servo.write(minAngle);
  currentAngle = minAngle;
  isClockWise = true;
  
}

void loop() {

  while( Serial.available() > 0) {
    char message = Serial.read();
    if (message == 'b') {
      isOn = true;
    } else if (message == 's') {
      rotationSpeed = 1;
    } else if (message == 'm') {
      rotationSpeed = 3;
    } else if (message == 'f') {
      rotationSpeed = 6;
    }
  }
  
 while ( isOn == true ) {
  
    if (currentAngle < maxAngle && currentAngle >= minAngle && isClockWise == true) {
      currentAngle += rotationSpeed;
      shouldClear = false;
    } else if (currentAngle <= maxAngle && currentAngle > minAngle && isClockWise == false) {
      currentAngle -= rotationSpeed;
      shouldClear = false;
    } else if (currentAngle >= maxAngle && isClockWise == true) {
      isClockWise = false;
      shouldClear = true;
    } else if (currentAngle <= minAngle && isClockWise == false) {
      isClockWise = true;
      shouldClear = true;
    }
  
    distancia_actual();
      
    Serial.print(cm);
    Serial.print("&");
    if (shouldClear == true) {
      Serial.print("c");
      Serial.print("&");
    }
    Serial.println(currentAngle);
  
    servo.write(currentAngle);
  
    delay(20);
  }
}
