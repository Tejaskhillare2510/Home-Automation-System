#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>
#include <string>
#include <Servo.h>

#ifndef APSSID
#define APSSID "ESP32_ACP"
#define APPSK "ece@123ece"
#endif

/* Declare the pins for the leds and their status var */
int ledPins[] = {D1, D2, D3, D4};
bool buttonOn[] = {false, false, false, false};

/* Set these to your desired credentials. */
const char *ssid = APSSID;
const char *password = APPSK;

ESP8266WebServer server(80);

/* Just a little test message.  Go to http://192.168.4.1 in a web browser
   connected to this access point to see it.
*/
void handleRoot()
{
    server.send(200, "text/html", "<h1>You are connected</h1>");
}

/*
  Function to control the led status
  Turns on and off individual leds based on the endpoint
*/
void toggleLed(int button)
{
    StaticJsonDocument<200> jsonDoc; // Adjust the size according to your needs

    if (button >= 0 && button < sizeof(ledPins) / sizeof(ledPins[0]))
    {
        digitalWrite(ledPins[button], !digitalRead(ledPins[button])); // Toggle the LED state

        // Build the JSON response
        jsonDoc["status"] = "success";
        jsonDoc["message"] = "LED state toggled";
        jsonDoc["ledStatus"] = digitalRead(ledPins[button]);

        // Convert the JSON document to a string
        String jsonResponse;
        serializeJson(jsonDoc, jsonResponse);

        // Send the JSON response
        server.send(200, "application/json", jsonResponse);
    }
    else
    {
        // Build the JSON response for an invalid button
        jsonDoc["status"] = "error";
        jsonDoc["message"] = "Invalid button";

        // Convert the JSON document to a string
        String jsonResponse;
        serializeJson(jsonDoc, jsonResponse);

        // Send the JSON response
        server.send(400, "application/json", jsonResponse);
    }
}

/*
  Setup function to initialize the initial state 
*/
void setup()
{
    // LED pin mode setup and initialization to LOW
    for (auto pin : ledPins)
    {
        pinMode(pin, OUTPUT);
        digitalWrite(pin, LOW);
    }

    delay(1000);
    Serial.begin(115200);
    Serial.println();
    Serial.print("Configuring access point...");
    /* You can remove the password parameter if you want the AP to be open. */
    WiFi.softAP(ssid, password);

    IPAddress myIP = WiFi.softAPIP();
    Serial.print("AP IP address: ");
    server.on("/", handleRoot);
    server.on("/led_1", []() { toggleLed(0); });
    server.on("/led_2", []() { toggleLed(1); });
    server.on("/led_3", []() { toggleLed(2); });
    server.on("/led_4", []() { toggleLed(3); });
    server.begin();
    Serial.println("HTTP server started");
}

void loop()
{
    server.handleClient();
}
