import time
import board
import adafruit_dht

dhtDevice = adafruit_dht.DHT22(board.D4)

try:
    temperature_c = dhtDevice.temperature
    humidity = dhtDevice.humidity
    #print("Temp: {:.1f} F / {:.1f} C Humidity: {}% ".format(temperature_f, temperature_c, humidity))
    print("{0:0.1f} {1:0.1f}".format(temperature_c, humidity))
except RuntimeError as error:
    print(error.args[0])

