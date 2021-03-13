/**
 * (./) udp.pde - how to use UDP library as unicast connection
 * (cc) 2006, Cousot stephane for The Atelier Hypermedia
 * (->) http://hypermedia.loeil.org/processing/
 *
 * Create a communication between Processing<->Pure Data @ http://puredata.info/
 * This program also requires to run a small program on Pd to exchange data  
 * (hum!!! for a complete experimentation), you can find the related Pd patch
 * at http://hypermedia.loeil.org/processing/udp.pd
 * 
 * -- note that all Pd input/output messages are completed with the characters 
 * ";\n". Don't refer to this notation for a normal use. --
 */

// import UDP library
import processing.opengl.*;
import hypermedia.net.*;
import java.io.FileWriter;
//import java.io.IOException; 
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

float roll1, pitch1,yaw1, roll2, pitch2,yaw2, roll3, pitch3,yaw3;
static int i=0;

//Set ip and port for Devices but remember only specific ip and port should be set for every device!
String setIP1= "192.168.43.181";   //Set ip and port for Device1, Muneeb
int setPort1= 4110;
//--------------------------------------------------------------------------------
String setIP2= "192.168.43.119";  //Set ip and port for Device2, Shaoor
int setPort2= 4210;
//--------------------------------------------------------------------------------
String setIP3= "192.168.43.217";  //Set ip and port for Device3, Pasha
int setPort3= 4310;


UDP udp1,udp2,udp3;  // define the UDP object

void setup() {
  size (1366 , 768, OPENGL);    //I used OPENGL for rendering you can also use P3D
    
  // create a new datagram connection on port
  // and wait for incomming message
   udp1 = new UDP( this, setPort1 );
  //udp1.log( true );     // <-- printout the connection activity
   udp1.listen( true );
  
  //----------------------------------------
   udp2 = new UDP( this, setPort2 );
  //udp2.log( true );     // <-- printout the connection activity
   udp2.listen( true );
  //----------------------------------------
   udp3 = new UDP( this, setPort3 );
  //udp3.log( true );     // <-- printout the connection activity
   udp3.listen( true );

loop();
}

void setupCylinder(){        //Setting up cylinder values
//background(0, 128, 255);
    lights();
    
    
     fill(137, 95, 4);
    pushMatrix();    
    translate( -1015, 0, 0 );
//    rotateX( PI/2 );
//    rotateY( radians( frameCount ) );
//    rotateZ( radians( frameCount ) );
    drawCylinder( 30, 50, 240 );
    popMatrix();
}
void drawCylinder(int sides, float r, float h)      //Drawing cylinder
{

    float angle = 360 / sides;
    float halfHeight = h / 2;

    // draw top of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, -halfHeight);
    }
    endShape(CLOSE);

    // draw bottom of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, halfHeight);
    }
    endShape(CLOSE);
    
    // draw sides and connect bwtween two circles
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < sides + 1; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, halfHeight);
        vertex( x, y, -halfHeight);    
    }
    endShape(CLOSE);

}


void board1(){            //Function for board1
  
translate(300, 380 , -500);


  textSize(28);
  fill(137, 95, 4);
  text("Roll: " + int(roll1) + ", Pitch: " + int(pitch1) + ", Yaw: " + int(yaw1), -100, 265);
  //Rotate the object
  rotateX(radians(pitch1));
  rotateZ(radians(roll1));
  rotateY(radians(yaw1));
  
  // 3D 0bject
  textSize(30);  
  fill(193, 150, 41);
  box (386, 40, 200); // Draw box
  
  textSize(25);
  fill(255, 255, 255);
  //text("Model 1", -183, 10, 101);

}

void board2(){  //Function for board2
  translate(390, 0 , 0);
  textSize(28);
  fill(137, 95, 4);
  text("Roll: " + int(roll2) + ", Pitch: " + int(pitch2) + ", Yaw: " + int(yaw2), -100, 265);
  //Rotate the object
  rotateX(radians(pitch2));
  rotateZ(radians(roll2));
  rotateY(radians(yaw2));
  
  // 3D 0bject
  textSize(30);  
  fill(193, 150, 41);
  box (386, 40, 200); // Draw box
  
  textSize(25);
  fill(255, 255, 255);
  //text("Model 2", -183, 10, 101);
  
}

void board3(){  //Function for board3
 translate(387, 0 , 0);
  
  textSize(28);
  fill(137, 95, 4);
 text("Roll: " + int(roll3) + ", Pitch: " + int(pitch3) + ", Yaw: " + int(yaw3), -100, 265);
  //Rotate the object
  rotateX(radians(pitch3));
  rotateZ(radians(roll3));
  rotateY(radians(yaw3));
//  
  // 3D 0bject
  textSize(30);  
  fill(193, 150, 41);
  box (386, 40, 200); // Draw box
  
  textSize(25);
  fill(255, 255, 255);
  //text("Model 3", -183, 10, 101);
  
}

  

//process events
void draw() {
//camera(-1000.0, -1200.0, -600.0, 50.0, 50.0, 0.0, 0.0, 1.0, 0.0);

  background(25);
  
 // board1();
  //board2();
  board3();
  setupCylinder(); 
 }
//-------------------------------------------------------------------------------------
void ipFunction1()  //Set ip for device 1
{

  String ip1       = setIP1;  // the remote IP address, set it accourding to your device 1
  int port1        = setPort1;    // the destination port
  
  // formats the message for Pd
  String message1 = "This is simple Message from Computer using device 1.";
  // send the message
  udp1.send( message1, ip1, port1 );   
}

void ipFunction2()  //Set ip for device 2
{

  String ip2       = setIP2;  // the remote IP address, set it accourding to your device 1
  int port2        = setPort2;    // the destination port
  
  // formats the message for Pd
  String message2 = "This is simple Message from Computer using device 2.";
  // send the message
  udp2.send( message2, ip2, port2 );   
}

void ipFunction3()  //Set ip for device 3
{

  String ip3       = setIP3;  // the remote IP address, set it accourding to your device 1
  int port3        = setPort3;    // the destination port
  
  // formats the message for Pd 
  String message3 = "This is simple Message from Computer using device 3.";
  // send the message
  udp3.send( message3, ip3, port3 );   
}

void loop() {
  ipFunction1();
   ipFunction2();
    ipFunction3();
}

//-------------------------------------------------------------------------------------------------------
//Receiving data packets from Arduino IDE

void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  
  if(port == setPort1){
    
     data = subset(data, 0, data.length-2);          
     String message1 = new String( data );
      String items1[] = split(message1, ',');    //Sending Pitch,Roll and Yaw value for board 1, Device 1
    if (items1.length > 1) {
      //--- Roll,Pitch in degrees
      roll1 = float(items1[0]);
     // println("roll: " + roll);
      pitch1 = float(items1[1]);
      //println("pitch: " + pitch);
      yaw1 = float(items1[2]);
      //println("Yaw: " + yaw);
    }
    
     println( "Device 1 receive: \""+message1+"\" from "+ip+" on port "+port );  //Receiving data packets from device1
  }
  else if(port == setPort2){
    
    data = subset(data, 0, data.length-2);          
    String message2 = new String( data );
    String items2[] = split(message2, ',');     //Sending Pitch,Roll and Yaw value for board 2, Device 2
    if (items2.length > 1) {
      //--- Roll,Pitch in degrees
      roll2 = float(items2[0]);
     // println("roll: " + roll);
      pitch2 = float(items2[1]);
      //println("pitch: " + pitch);
      yaw2 = float(items2[2]);
      //println("Yaw: " + yaw);
    }
    
    println( "Device 2 receive: \""+message2+"\" from "+ip+" on port "+port );   //Receiving data packets from device2
  }
  
  else if(port == setPort3){
    
  data = subset(data, 0, data.length-2);          
  String message3 = new String( data );
  
  String items3[] = split(message3, ',');    //Sending Pitch,Roll and Yaw value for board 3, Device 3
    if (items3.length > 1) {
      //--- Roll,Pitch in degrees
      roll3 = float(items3[0]);
     // println("roll: " + roll);
      pitch3 = float(items3[1]);
      //println("pitch: " + pitch);
      yaw3 = float(items3[2]);
      //println("Yaw: " + yaw);
    }
    
      println( "Device 3 receive: \""+message3+"\" from "+ip+" on port "+port );   //Receiving data packets from device3

  }
  
  else{
       println("Error \"");
  }
  
  loop();
 
    
       try { 
             
            // Open given file in append mode. 
            BufferedWriter out = new BufferedWriter(new FileWriter("data_store_sensor.txt", true)); 
             // println(" ");     
            out.write("   No:" + i);
            i++;
            out.write("  Device1 Roll: \n" + roll1);
            out.write( " Device1 Pitch:\n " + pitch1);
            out.write("  Device1 Yaw: \n" + yaw1);
            out.write("  Device2 Roll: \n" + roll2);
            out.write( " Device2 Pitch:\n " + pitch2);
            out.write("  Device2 Yaw: \n" + yaw2);
              out.write("  Device3 Roll: \n" + roll3);
            out.write( " Device3 Pitch:\n " + pitch3);
            out.write("  Device3 Yaw: \n" + yaw3);
            out.newLine();
            
            out.close(); 
        } 
        catch (IOException e) { 
            System.out.println("exception occoured" + e); 
        } 
}
