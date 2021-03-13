#include <Wire.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <String.h>
#include <stdio.h> 
#include <MadgwickAHRS.h>

const char* ssid = "Jazz";
const char* password = "mogambo123";

WiFiUDP Udp;
unsigned int localUdpPort = 4310;  // local port to listen on
char incomingPacket[255];  // buffer for incoming packets
char  replyPacket1[] = "ggg ggg gggggg";


int ledPin = 13;

Madgwick filter;
unsigned long microsPerReading, microsPrevious;
float accelScale, gyroScale;

//initializations

float accAngleX, accAngleY, gyroAngleX, gyroAngleY, gyroAngleZ;
float roll, pitch, yaw;
float AccErrorX, AccErrorY, GyroErrorX, GyroErrorY, GyroErrorZ;
float elapsedTime, currentTime, previousTime;
int c = 0;

// MPU9250 Slave Device Address
const uint8_t MPU9250SlaveAddress = 0x68;

// Pins for serial data
const uint8_t scl = D6;
const uint8_t sda = D7;

// sensitivity scale factor of accelerometer and gyroscope 
const uint16_t AccelScaleFactor = 16384;
const uint16_t GyroScaleFactor = 131;

// MPU9250 few configuration register addresses
const uint8_t MPU9250_REGISTER_SMPLRT_DIV   =  0x19;
const uint8_t MPU9250_REGISTER_USER_CTRL    =  0x6A;
const uint8_t MPU9250_REGISTER_PWR_MGMT_1   =  0x6B;
const uint8_t MPU9250_REGISTER_PWR_MGMT_2   =  0x6C;
const uint8_t MPU9250_REGISTER_CONFIG       =  0x1A;
const uint8_t MPU9250_REGISTER_GYRO_CONFIG  =  0x1B;
const uint8_t MPU9250_REGISTER_ACCEL_CONFIG =  0x1C;
const uint8_t MPU9250_REGISTER_FIFO_EN      =  0x23;
const uint8_t MPU9250_REGISTER_INT_ENABLE   =  0x38;
const uint8_t MPU9250_REGISTER_ACCEL_XOUT_H =  0x3B;
const uint8_t MPU9250_REGISTER_SIGNAL_PATH_RESET  = 0x68;

int16_t AccelX, AccelY, AccelZ, Temperature, GyroX, GyroY, GyroZ;

void setup() {
  Serial.begin(9600);
  Wire.begin(sda, scl);
  MPU9250_Init();

  filter.begin(25);
  // initialize variables to pace updates to correct rate
  microsPerReading = 1000000 / 25;
  microsPrevious = micros();

 // Serial.begin(115200);
  Serial.println();

  Serial.printf("Connecting to %s ", ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println(" connected");

  Udp.begin(localUdpPort);
  Serial.printf("Now listening at IP %s, UDP port %d\n", WiFi.localIP().toString().c_str(), localUdpPort);
  
}



void I2C_Write(uint8_t deviceAddress, uint8_t regAddress, uint8_t data){
  Wire.beginTransmission(deviceAddress);
  Wire.write(regAddress);
  Wire.write(data);
  Wire.endTransmission();
}

// read all 14 register
void Read_RawValue(uint8_t deviceAddress, uint8_t regAddress){
  Wire.beginTransmission(deviceAddress);
  Wire.write(regAddress);
  Wire.endTransmission();
  Wire.requestFrom(deviceAddress, (uint8_t)14);
  AccelX = (((int16_t)Wire.read()<<8) | Wire.read());
  AccelY = (((int16_t)Wire.read()<<8) | Wire.read());
  AccelZ = (((int16_t)Wire.read()<<8) | Wire.read());
  Temperature = (((int16_t)Wire.read()<<8) | Wire.read());
  GyroX = (((int16_t)Wire.read()<<8) | Wire.read());
  GyroY = (((int16_t)Wire.read()<<8) | Wire.read());
  GyroZ = (((int16_t)Wire.read()<<8) | Wire.read());
}

//configure MPU9250
void MPU9250_Init(){
  delay(150);
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_SMPLRT_DIV, 0x07);
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_PWR_MGMT_1, 0x01);
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_PWR_MGMT_2, 0x00);
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_CONFIG, 0x00);
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_GYRO_CONFIG, 0x00);//set +/-250 degree/second full scale
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_ACCEL_CONFIG, 0x00);// set +/- 2g full scale
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_FIFO_EN, 0x00);
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_INT_ENABLE, 0x01);
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_SIGNAL_PATH_RESET, 0x00);
  I2C_Write(MPU9250SlaveAddress, MPU9250_REGISTER_USER_CTRL, 0x00);
}
void loop() {
  float Ax, Ay, Az, T, Gx, Gy, Gz;
  unsigned long microsNow;
  
  Read_RawValue(MPU9250SlaveAddress, MPU9250_REGISTER_ACCEL_XOUT_H);
  
  //divide each with their sensitivity scale factor
  Ax = (float)AccelX/AccelScaleFactor;
  Ay = (float)AccelY/AccelScaleFactor;
  Az = (float)AccelZ/AccelScaleFactor;
  T = (float)Temperature/340+36.53; //temperature formula
  Gx = (float)GyroX/GyroScaleFactor;
  Gy = (float)GyroY/GyroScaleFactor;
  Gz = (float)GyroZ/GyroScaleFactor;

   microsNow = micros();
  if (microsNow - microsPrevious >= microsPerReading) {
    // update the filter, which computes orientation
    filter.updateIMU(Gx, Gy, Gz, Ax, Ay, Az);

    // print the heading, pitch and roll
    roll = filter.getRoll();
    pitch = filter.getPitch();
    yaw = filter.getYaw();

  Serial.print(roll);
  Serial.print("/");
  Serial.print(pitch);
  Serial.print("/");
  Serial.println(yaw);

     // increment previous time, so we keep proper pace
    microsPrevious = microsPrevious + microsPerReading;
    // Print the values on the serial monitor
 
  }
  
//// Calculating the Roll and the Pitch from the accelerometer data
//  accAngleX = (atan(Ay / sqrt(pow(Ax, 2) + pow(Az, 2))) * 180 / PI) - 0.58; // AccErrorX ~(0.58)
//  accAngleY = (atan(-1 * Ax / sqrt(pow(Ay, 2) + pow(Az, 2))) * 180 / PI) + 1.58; // AccErrorY ~(-1.58)
//
////reading gyroscope data
//  previousTime = currentTime;        // The Previous time is stored before the actual time read
//  currentTime = millis();            // Current time
//  elapsedTime = (currentTime - previousTime) / 1000; // Dividing by 1000 to get seconds
//
//// Correcting the outputs with the calculated error values
//  Gx = Gx - 1.94; // GyroErrorX ~(1.94)
//  Gy = Gy ; // GyroErrorY ~
//  Gz = Gz ; // GyroErrorZ ~ 
//
//// Currently the raw values are in degrees per seconds, deg/s, so we need to multiply by seconds to get the angle in degrees
//  gyroAngleX = gyroAngleX + Gx * elapsedTime; // deg/s * s = deg
//  gyroAngleY = gyroAngleY + Gy * elapsedTime;
//  yaw =  yaw + Gz * elapsedTime;    ////////////////////////////////////////////////////////
//// Complementary filter - combining the acceleromter and gyro angle values
//  roll = 0.96 * gyroAngleX + 0.04 * accAngleX;    //////////////////////////////////////////
//  pitch = 0.96 * gyroAngleY + 0.04 * accAngleY;   //////////////////////////////////////////
  
    
  Serial.println("Roll!");
  char replyPacket[30];
  gcvt(roll, 30, replyPacket);
  Serial.println(replyPacket);
  Serial.println("Pitch!"); 
  char replyPacket2[30]; 
  gcvt(pitch, 30, replyPacket2);
  Serial.println(replyPacket2);
  
  
  Serial.println("Yaw!");
  char replyPacket3[30];
  gcvt(yaw, 15, replyPacket3);
  Serial.println(replyPacket3);
  Udp.beginPacket("192.168.43.28", 4210);
   //Serial.println("Roll1");
   Udp.write(replyPacket);
  // Serial.println("Pitch1!");
   Udp.write(replyPacket2);
   //Serial.println("Yaw1!");
   Udp.write(replyPacket3);
   Udp.endPacket();
  
  int packetSize = Udp.parsePacket();
  
  if (packetSize)
  {
    // receive incoming UDP packets
    Serial.printf("Received %d bytes from %s, port %d\n", packetSize, Udp.remoteIP().toString().c_str(), Udp.remotePort());
    int len = Udp.read(incomingPacket, 255);
    if (len > 0)
    {
      incomingPacket[len] = 0;
    }
    Serial.printf("UDP packet contents: %s\n", incomingPacket);

    // send back a reply, to the IP address and port we got the packet from
    Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
    Udp.write(replyPacket);
    Udp.write(",");
    Udp.write(replyPacket2);
    Udp.write(",");
    Udp.write(replyPacket3);
    Udp.endPacket();
  }


  delay(10);
}
