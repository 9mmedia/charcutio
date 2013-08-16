#include <OneWire.h> 
#include <DHT22.h>

// pins
int thermometerPin = 2;
int freezerPin = 13;
int hygrometerPin = 7;

// targets
float targetTemperature = 27.0; // 18.3;
float targetHumidity = 65.0;

OneWire thermometer(thermometerPin);
DHT22 hygrometer(hygrometerPin);

void setup(void) {
  Serial.begin(9600);
  pinMode(freezerPin, OUTPUT);
}

void loop(void) {
  delay(2000); // necessary for the hygrometer

  float temperature = getTemperature();
  float humidity = getHumidity();

  Serial.println(temperature);
  Serial.println(humidity);

  updateTemperature(temperature);
  updateHumidity(humidity);
}

void updateTemperature(float currentTemperature) {
  if (currentTemperature >= targetTemperature + 0.5) {
    digitalWrite(freezerPin, HIGH);
  } else if (currentTemperature < targetTemperature) {
    digitalWrite(freezerPin, LOW);
  }
}

void updateHumidity(float currentHumidity) {
  // TODO implement!
}

float getTemperature(){
  // returns the temperature from one DS18S20 in DEG Celsius
  byte data[12];
  byte addr[8];

  if(!thermometer.search(addr)) {
    // no more sensors on chain, reset search
    thermometer.reset_search();
    return -1000;
  }

  if(OneWire::crc8(addr, 7) != addr[7]) {
    Serial.println("CRC is not valid!");
    return -1000;
  }

  if(addr[0] != 0x10 && addr[0] != 0x28) {
    Serial.print("Device is not recognized");
    return -1000;
  }

  thermometer.reset();
  thermometer.select(addr);
  thermometer.write(0x44, 1); // start conversion, with parasite power on at the end

  byte present = thermometer.reset();
  thermometer.select(addr);  
  thermometer.write(0xBE); // Read Scratchpad

  for(int i = 0; i < 9; i++) { // we need 9 bytes
    data[i] = thermometer.read();
  }

  thermometer.reset_search();

  byte MSB = data[1];
  byte LSB = data[0];

  float tempRead = ((MSB << 8) | LSB); // using two's compliment
  float temperatureSum = tempRead / 16;

  return temperatureSum;
}

float getHumidity() {
  DHT22_ERROR_t errorCode;
  errorCode = hygrometer.readData();
  
  float result = -1.0;

  switch(errorCode) {
    case DHT_ERROR_NONE:
      result = hygrometer.getHumidity();
      break;
    case DHT_ERROR_CHECKSUM:
      Serial.print("check sum error ");
      Serial.print(hygrometer.getTemperatureC());
      Serial.print("C ");
      Serial.print(hygrometer.getHumidity());
      Serial.println("%");
      break;
    case DHT_BUS_HUNG:
      Serial.println("BUS Hung ");
      break;
    case DHT_ERROR_NOT_PRESENT:
      Serial.println("Not Present ");
      break;
    case DHT_ERROR_ACK_TOO_LONG:
      Serial.println("ACK time out ");
      break;
    case DHT_ERROR_SYNC_TIMEOUT:
      Serial.println("Sync Timeout ");
      break;
    case DHT_ERROR_DATA_TIMEOUT:
      Serial.println("Data Timeout ");
      break;
    case DHT_ERROR_TOOQUICK:
      Serial.println("Polled too quick ");
      break;
  }

  return result;
}
