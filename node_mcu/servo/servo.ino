#include <ESP32Servo.h>

Servo myservo;

void setup(){

  myservo.attach(15);
  Serial.begin(115200);
  myservo.write(0);
}

void loop(){
  myservo.write(0);
  delay(500);
  myservo.write(60);
  delay(500);
  myservo.write(120);
  delay(500);
  myservo.write(180);
    delay(500);
  myservo.write(120);
  delay(500);
  myservo.write(60);
  delay(500);

}