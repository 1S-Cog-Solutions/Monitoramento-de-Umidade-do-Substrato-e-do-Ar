#include "DHT.h"

#define TIPO_SENSOR DHT11

const int PINO_SENSOR_DHT11 = 7;
const int PINO_SOLO = A0;

const int ValorAr   = 550;
const int ValorAgua = 230;

int valorUmidadeSolo = 0;
float umidadeSolo = 0;

DHT sensorDHT(PINO_SENSOR_DHT11, TIPO_SENSOR);

void setup() {
  Serial.begin(9600);
  sensorDHT.begin();
}

void loop() {
  valorUmidadeSolo = analogRead(PINO_SOLO);
  int faixa = ValorAr - ValorAgua;
  int distancia = ValorAr - valorUmidadeSolo;
  umidadeSolo = (float)distancia / faixa * 100.0;

  if (umidadeSolo < 0)   umidadeSolo = 0;
  if (umidadeSolo > 100) umidadeSolo = 100;

  float umidadeAr = sensorDHT.readHumidity();
  float temperatura = sensorDHT.readTemperature();

  if (isnan(temperatura) || isnan(umidadeAr)) {
    Serial.println("Erro ao ler os dados do sensor DHT!");
  } else {
    Serial.print(umidadeAr);
    Serial.print(";");
    Serial.print(umidadeSolo);
    Serial.print(";");
    Serial.println(temperatura);
  }

  delay(2000);
}