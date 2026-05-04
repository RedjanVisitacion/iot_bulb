#include <WiFi.h>
#include <WebSocketsClient.h> // Library must be installed first!

const char* ssid = "OROSWIFI_2.4G"; 
const char* password = "Oros2025";
const char* ws_server = "192.168.101.6"; 
const int ws_port = 8000;

const int RELAY_PIN = 26;
const int LED_PIN = 2; // Internal Green LED

WebSocketsClient webSocket;

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_CONNECTED:
      Serial.println("Connected to FastAPI!");
      digitalWrite(LED_PIN, HIGH); // Green Light ON when connected
      break;
    case WStype_DISCONNECTED:
      Serial.println("Disconnected!");
      digitalWrite(LED_PIN, LOW);
      break;
    case WStype_TEXT:
      String msg = String((char*)payload);
      if(msg == "ON") {
        digitalWrite(RELAY_PIN, LOW);  // Click!
        digitalWrite(LED_PIN, HIGH);
      } else if(msg == "OFF") {
        digitalWrite(RELAY_PIN, HIGH); // Click!
        digitalWrite(LED_PIN, LOW);
      }
      break;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(RELAY_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH); // Start OFF
  
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) { delay(500); }

  // Connect to the /ws/esp32 endpoint we made in FastAPI
  webSocket.begin(ws_server, ws_port, "/ws/esp32");
  webSocket.onEvent(webSocketEvent);
  webSocket.setReconnectInterval(5000);
}

void loop() {
  webSocket.loop();
}

