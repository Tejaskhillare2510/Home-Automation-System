import machine
import network
from umqtt.simple import MQTTClient
from machine import Pin

# Set up LED pins
led_pins = [2, 4, 5, 16]  # GPIO pin numbers for ESP8266
led_states = [False] * len(led_pins)

# Set up access point
ap_ssid = "ESP32_ACP"
ap_password = "ece@123ece"
ap = network.WLAN(network.AP_IF)
ap.active(True)
ap.config(essid=ap_ssid, password=ap_password)

# Set up web server
server = MQTTClient("esp8266", "192.168.4.1")

# Handle root endpoint
def handle_root(topic, msg):
    print("Received message on {}: {}".format(topic, msg));server.publish(topic, "You are connected")

# Handle LED toggle endpoints
def toggle_led(topic, msg):
    try:
        led_index = int(topic.split("_")[-1]) - 1
        if 0 <= led_index < len(led_pins):
            led_states[led_index] = not led_states[led_index]
            pin = Pin(led_pins[led_index], Pin.OUT)
            pin.value(led_states[led_index])
            server.publish(topic, "LED state toggled")
        else:
            server.publish(topic, "Invalid button")
    except ValueError:
        server.publish(topic, "Invalid button")

# Subscribe to topics
server.set_callback(handle_root)
server.subscribe(b"/")
for i in range(1, len(led_pins) + 1):
    server.set_callback(toggle_led)
    server.subscribe("/led_{}".format(i))

# Main loop
while True:
    server.check_msg()
