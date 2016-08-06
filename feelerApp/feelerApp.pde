boolean debug = true;
boolean simulateMindSet = true;
boolean simulateBoxes = true;

float countDownStartMeditate = .1;
float countDownStartStudy = .2;

import processing.net.*; 
import controlP5.*;
import java.util.*; 
import java.awt.Robot; 
import java.awt.AWTException;
import java.awt.Rectangle;

import java.util.Timer;
import java.util.TimerTask;
import java.text.DecimalFormat;

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException;
import java.nio.*;

import processing.serial.*;
import pt.citar.diablu.processing.mindset.*;

import feelerSerial.*;

feelerSerial feelerS;
boolean boxInit = false;

ControlP5 cp5;

JSONObject json;

String currentPage = "home";

//User session stuff
String encodedAuth = "";
Client client;
String loginData;
String host;
int port;
String loginAddress;
String newUserAddress;

boolean isLoggedIn = false;
boolean isWrongPassword = false;
String currentUser = "";
String currentSession = "";
int currentItem;
String currentPassword = "";
Textfield username;
Textfield password;

boolean isNewUser = false;

final static int TIMER = 100;
static boolean isEnabled = true;

CountDown sw = new CountDown();
CountUp cu = new CountUp();
boolean recording = false; 

//UI variables
PImage logo;
OverallAvgs eegAvg, personalAssSesion, personalAvg;
LineChart trends, eegAct, personalExperience;
int headerHeight = 100;
int padding = 20;
int userTabsX;
int buttonWidth = 70;
int buttonHeight = 20;
int visBarWidth = 300;
int visBarHeight = 120;
int visX;
int visY;
int visWidth;
int visHeight;
int dotSize = 20;
float e = 0;
float containerPosX;
float containerPosY;
int videoWidth = 640;
int videoHeight = 480;
int recControlersWidth = 300;

PImage homeImg;

boolean assess3Toggle1 = true;
boolean assess3Toggle2 = true;
int assessQuestion = 0;
FeelingRadio feelingRadioMeditation, feelingRadioStudy, feelingRadioPlay;
String feelingAssessMeditation, feelingAssessStudy, feelingAssessPlay;
int assessRelaxationMeditation = 0;
int assessRelaxationStudy = 0;
int assessRelaxationPlay = 0;
int assessAttentionMeditation = 0;
int assessAttentionStudy = 0;
int assessAttentionPlay = 0;

PVector hoverUpLeft, hoverDownRight;

PImage screenshotModal;
PImage close;
boolean modal = false;
float modalWidth;
float modalHeight;

//Color
color graphBgColor = color(240);
color textDarkColor = color(100);
color textLightColor = color(180);
color attentionColor = color(234, 79, 51);
color relaxationColor = color(167, 196, 58);

// files handling
int listSize;
float[] attentionAverageList;
float[] relaxationAverageList;
float assessmentAttAvgs = 0;
float assessmentRlxAvgs = 0;

boolean loading = false;
String[] fileName;
String[] fileNames;
String filePath;
String sessionPath;
String[] sessionFolders;
String userFolder;
float attentionAverage = 0;
float relaxationAverage = 0;
String[] assessmentData;
File assessmentFolder;
String[] screenshotsArray;

String userDataFolder = "user-data";
String absolutePath;
FloatTable data;
String filenameString;
String[] fileArray;
String[] fileAssessmentArray;
File directory2;

float dataMin, dataMax;
int deltaMax, deltaMin, thetaMax, thetaMin, lowAlphaMax, lowAlphaMin, highAlphaMax, highAlphaMin, lowBetaMax, lowBetaMin, highBetaMax, highBetaMin, lowGammaMax, lowGammaMin, midGammaMax, midGammaMin, blinkStMax, blinkStMin, attentionMin, attentionMax, meditationMin, meditationMax; 
float plotX1, plotY1;
float plotX2, plotY2;

int rowCount, rowCount1, rowCount2, rowCount3;
long state1start, state2start, state3start;
int columnCount;
int currentColumn = 0; 
char[] filenameCharArray = new char[20];
/////////////////////////

// screen capture
PImage screenshot;
/////////////////

int boxState = 0;

//MindSet stuff
MindSet mindSet;
boolean mindSetOK = false;
Serial mindSetPort;
int mindSetId;

public void setup() {
  smooth();
  
  homeImg = loadImage("home.png");
  close = loadImage("close.png");
  
  trends = new LineChart();
  eegAct = new LineChart();
  personalExperience = new LineChart();
  
  hoverUpLeft = new PVector(0,0);
  hoverDownRight = new PVector(0,0);
  
  //size(1200, 850);
  //size(1000, 700);
  size(displayWidth, displayHeight);
  
  //fullScreen();
  surface.setResizable(true);
//double width = screenSize.getWidth();
//double height = screenSize.getHeight();
  //println((int)screenSize.getWidth());
  
  
  
  noStroke();
  textSize(12);

  userTabsX = width/2;

  visX = (width/3)/2;
  visY = headerHeight + padding + 60;
  visWidth = width - width/3;
  visHeight = 300;

  json = loadJSONObject("config.json");
  host = json.getString("host");
  port = json.getInt("port");
  loginAddress = json.getString("login-address");
  newUserAddress = json.getString("new-user-address");

  cp5 = new ControlP5(this);

  eegAvg = new OverallAvgs("eeg", "Values based on your EEG data");
  personalAssSesion = new OverallAvgs("assessment", "Values based on your personal experience");
  personalAvg = new OverallAvgs("eeg", "On average");

  eegAvg.setup(visWidth, visHeight);
  personalAssSesion.setup(visWidth, visHeight);

  //Create UI elements
  containerPosX = width/2 - videoWidth/2;
  containerPosY = height/2 - videoHeight/2;
  
  logo = loadImage("feeler-logo.png");
  
  feelingRadioMeditation = new FeelingRadio(20, 300, "Mediatation");
  feelingRadioStudy = new FeelingRadio(20, 300 + 50 + padding*2, "Study");
  feelingRadioPlay = new FeelingRadio(20, 300 + 50*2 + padding*4, "Play");
  
  //Make a new feelerSerial
  feelerS = new feelerSerial(this); 
  
  thread("updateBoxData");

  // Feeler Serial stuff
  //debug mode
  //feelerS.debug();

  //Set the settings you want to send.
  //The settings are speeds(seconds) for the 3 different boxes.
  //first number speed for ledfade in box 1
  feelerS.setSettings(10000, 2000, 3000); //remove this line to use default settings.
  
  
  
  
  //PImage[] imgs = {loadImage("feeler-logo.png"), loadImage("feeler-logo.png"), loadImage("feeler-logo.png")};
  
  //cp5.addButton("homeBt")
  //  .setBroadcast(false)
  //  .setPosition(20, 20)
  //  .setSize(241, 63)
  //  .setLabel("Feeler")
  //  .setImages(imgs)
  //  .setValue(1)
  //  .setBroadcast(true)
  //  .getCaptionLabel().align(CENTER, CENTER)
  //  ;
  //cp5.getController("homeBt").moveTo("global");

  cp5.getTab("default")
    .activateEvent(true)
    .setLabel("home")
    .setId(1)
    ;
    
  cp5.getWindow().setPositionOfTabs(0, -200);

  cp5.addTab("login");
  cp5.getTab("login")
   .activateEvent(true)
   .setId(2)
   ;

  username = cp5.addTextfield("username")
    .setPosition(width/2 - 100, height/2 - 40)
    .setSize(200, 20)
    .setLabel("username")
    .setFocus(true)
    ;
  username.setAutoClear(true);
  cp5.getController("username").moveTo("login");

  password = cp5.addTextfield("password")
    .setPosition(width/2 - 100, height/2)
    .setSize(200, 20)
    .setPasswordMode(true)
    .setLabel("password")
    ;
  password.setAutoClear(true);
  cp5.getController("password").moveTo("login");

  cp5.addButton("submit")
    .setBroadcast(false)
    .setLabel("login")
    .setPosition(width/2 - 100, height/2 + 40)
    .setSize(200, 40)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("submit").moveTo("login");

  cp5.addButton("signup")
    .setBroadcast(false)
    .setLabel("signup")
    .setPosition(width/2 - 100, height/2 + 90)
    .setSize(200, 40)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("signup").moveTo("login");

  cp5.addButton("loginBt")
    .setBroadcast(false)
    .setLabel("login")
    .setPosition(width - 100, 20)
    .setSize(80, 40)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("loginBt").moveTo("default");

  cp5.addButton("logoutBt")
    .setBroadcast(false)
    .setLabel("Logout")
    .setPosition(width - 80, 10)
    .setSize(70, 20)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("logoutBt").moveTo("global");
  cp5.getController("logoutBt").hide();

  //Session
  cp5.addButton("startSession")
    .setBroadcast(false)
    .setLabel("Record")
    .setPosition(padding, headerHeight + padding * 7)
    .setSize(200, 80)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("startSession").moveTo("global");
  cp5.getController("startSession").hide();

  cp5.addButton("playPauseBt")
    .setBroadcast(false)
    .setLabel("Pause")
    .setPosition(width/2 - 50, containerPosY + padding * 2)
    .setSize(50, 50)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("playPauseBt").moveTo("global");
  cp5.getController("playPauseBt").hide();
  
  cp5.addButton("stopBt")
    .setBroadcast(false)
    .setLabel("Stop")
    .setPosition(width/2, containerPosY + padding * 2)
    .setSize(50, 50)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("stopBt").moveTo("global");
  cp5.getController("stopBt").hide();
  
  
  cp5.addButton("endGame")
  .setBroadcast(false)
  .setLabel("End game")
  .setPosition(padding, headerHeight + padding * 4)
  .setSize(70, 20)
  //.setValue(1)
  .setBroadcast(true)
  .getCaptionLabel().align(CENTER, CENTER)
  ;
  cp5.getController("endGame").moveTo("global");
  cp5.getController("endGame").hide();
  
  // assessment 1/3
  cp5.addButton("assess1Bt")
    .setBroadcast(false)
    .setLabel("Next")
    .setPosition(padding, headerHeight + padding * 6)
    .setSize(70, 20)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("assess1Bt").moveTo("global");
  cp5.getController("assess1Bt").hide();
  
  // assessment 2/3
  cp5.addSlider("assessRelaxationMeditation")
    .setLabel("Meditation")
    .setColorLabel(textDarkColor)
    .setPosition(padding, headerHeight + padding * 3)
    .setRange(0, 100)
    ;
  cp5.getController("assessRelaxationMeditation").moveTo("global");
  cp5.getController("assessRelaxationMeditation").hide();
  
  cp5.addSlider("assessRelaxationStudy")
    .setLabel("Study")
    .setColorLabel(textDarkColor)
    .setPosition(padding, headerHeight + padding * 4)
    .setRange(0, 100)
    ;
  cp5.getController("assessRelaxationStudy").moveTo("global");
  cp5.getController("assessRelaxationStudy").hide();
  
  cp5.addSlider("assessRelaxationPlay")
    .setLabel("Play")
    .setColorLabel(textDarkColor)
    .setPosition(padding, headerHeight + padding * 5)
    .setRange(0, 100)
    ;
  cp5.getController("assessRelaxationPlay").moveTo("global");
  cp5.getController("assessRelaxationPlay").hide();

  cp5.addButton("assess22Bt")
    .setBroadcast(false)
    .setLabel("Previous")
    .setPosition(padding, headerHeight + padding * 6)
    .setSize(70, 20)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("assess22Bt").moveTo("global");
  cp5.getController("assess22Bt").hide();
  
  cp5.addButton("assess2Bt")
    .setBroadcast(false)
    .setLabel("Next")
    .setPosition(padding + 80, headerHeight + padding * 6)
    .setSize(70, 20)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("assess2Bt").moveTo("global");
  cp5.getController("assess2Bt").hide();
  
  // assessment 3/3
  cp5.addSlider("assessAttentionMeditation")
    .setLabel("Meditation")
    .setColorLabel(textDarkColor)
    .setPosition(padding, headerHeight + padding * 3)
    .setRange(0, 100)
    ;
  cp5.getController("assessAttentionMeditation").moveTo("global");
  cp5.getController("assessAttentionMeditation").hide();
  
  cp5.addSlider("assessAttentionStudy")
    .setLabel("Study")
    .setColorLabel(textDarkColor)
    .setPosition(padding, headerHeight + padding * 4)
    .setRange(0, 100)
    ;
  cp5.getController("assessAttentionStudy").moveTo("global");
  cp5.getController("assessAttentionStudy").hide();
  
  cp5.addSlider("assessAttentionPlay")
    .setLabel("Play")
    .setColorLabel(textDarkColor)
    .setPosition(padding, headerHeight + padding * 5)
    .setRange(0, 100)
    ;
  cp5.getController("assessAttentionPlay").moveTo("global");
  cp5.getController("assessAttentionPlay").hide();

  cp5.addToggle("assess3Toggle1")
    .setColorLabel(color(0))
    .setLabel("yes/no")
    .setPosition(277, 150)
    .setSize(70, 20)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    ;
  cp5.getController("assess3Toggle1").moveTo("global");
  cp5.getController("assess3Toggle1").hide();

  cp5.addToggle("assess3Toggle2")
    .setColorLabel(color(0))
    .setLabel("yes/no")
    .setPosition(181, 185)
    .setSize(70, 20)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    ;
  cp5.getController("assess3Toggle2").moveTo("global");
  cp5.getController("assess3Toggle2").hide();
  
  
  cp5.addButton("assess33Bt")
  .setBroadcast(false)
  .setLabel("Previous")
  .setPosition(padding, headerHeight + padding * 6)
  .setSize(70, 20)
  //.setValue(1)
  .setBroadcast(true)
  .getCaptionLabel().align(CENTER, CENTER)
  ;
  cp5.getController("assess33Bt").moveTo("global");
  cp5.getController("assess33Bt").hide();
  
  cp5.addButton("assess3Bt")
  .setBroadcast(false)
  .setLabel("Submit")
  .setPosition(padding + 80, headerHeight + padding * 6)
  .setSize(70, 20)
  //.setValue(1)
  .setBroadcast(true)
  .getCaptionLabel().align(CENTER, CENTER)
  ;
  cp5.getController("assess3Bt").moveTo("global");
  cp5.getController("assess3Bt").hide();
  
  /////////////////////////////////

}

public void draw() {
  background(255);
  fill(0);
  image(logo, 20, 20);
  
  if ( millis() % 100 == 0) {
    //feelerS.sendValues();
    try {
      feelerS.get();
    } catch (NullPointerException e) {
    }
    
  }
  
  if(
    mouseX > hoverUpLeft.x &&
    mouseX < hoverDownRight.x
    &&
    mouseY > hoverUpLeft.y &&
    mouseY < hoverDownRight.y
  ){
    cursor(HAND);
  } else {
    cursor(ARROW);
  }
  

  if (isLoggedIn) {
    textAlign(RIGHT);
    text("Hello, " + currentUser, width - 10, 50);
  }

  if (isWrongPassword) {
    textAlign(CENTER);
    text("Wrong username or password", width/2, height/2 - 60);
  }


  //Visualisation
  switch(currentPage) {
  case "home":
    if (!loading) {
      home();
    }
    break;
  case "overall":
    trends.display();
    break;
  case "singleSession":
    singleVisPage();
    break;
  case "eegActivity":
    //eegActivity();
    eegAct.display();
    break;
  case "assessmentActivity":
    //println("assessmentActivity");
    assessmentActivity();
    break;
  case "assessAct":
    break;
  case "newSession":
    newSession();
    break;
  }

  if (debug) {
    textAlign(LEFT);

    fill(0, 20);
    rect(0, height-100, width, 100);

    String s = "Press 'L' to log in" +
      "\nPress 'C' after logging in to capture screen." +
      "\nCurrent user:" + currentUser +
      "\nIs logged in:" + isLoggedIn +
      "\nPress 'M' to toggle MindSet simulation"
      ;

    fill(50);
    text(s, padding, height-90, width/3, height-90);
    
    if(userFolder != null){
      text(userFolder, padding, height-110);
    }
    
    if (simulateMindSet) {
      text("generating simulated data", padding, height-130);
      simulate();
    }


    if (currentPage == "newSession") {
      String s2 = "Box state: " + boxState +
        "\nPress 'S' to study" +
        "\nPress 'A' to assess"
        ;
      text(s2, width/3 + padding*2, height-90, width/2, height-90);

      String s3 = "\nAssessment question 3a: " + assess3Toggle1 +
        "\nAssessment question 3b: " + assess3Toggle2
        ;
      text(s3, (width/3)*2 + padding*2, height-90, width/2, height-90);
    }
  }

  textAlign(CENTER);
  if (loading) {
    text("Loading...", width/2, height/2);
  }
  
  if(modal){
    fill(230);
    rect(modalWidth/4 - padding, modalHeight/4 - padding, modalWidth + padding*2, modalHeight + padding*2);
    image(screenshotModal, modalWidth/4, modalHeight/4, modalWidth, modalHeight);
    image(close,modalWidth/4 - padding - 10, modalHeight/4 - padding - 10);
  }
}

public void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isTab()) {
    println("got an event from tab : "+theControlEvent.getTab().getName()+" with id "+theControlEvent.getTab().getId());
  }

  switch(theControlEvent.getName()) {
  case "overall":
    println("overall page");
    currentPage = "overall";
    cp5.getController("session").hide();
    personalAssSesion.setup(visWidth, visHeight);
    personalAvg.setup(visWidth, visHeight);
    break;
  case "newSession":
    if(!simulateBoxes){
      try{
        feelerS.init("/dev/tty.Feeler-RNI-SPP");
      } catch (NullPointerException e){
      }
    }
    println("newSession page");
    currentPage = "newSession";
    cp5.getController("connectBox").show();
    boxState = 0;
    break;
  case "startSession":
    feelerS.play();
    feelerS.setBox2LedSpeed(2000);
    println("startSession");
    sw.start();
    sessionPath = userFolder + "/" + nf(year(), 4)+"-"+nf(month(), 2)+"-"+nf(day(), 2)+"-"+nf(hour(), 2)+"-"+nf(minute(), 2)+"-"+nf(second(), 2);

    //create user folder
    File sessionFolder = new File(dataPath(sessionPath));
    sessionFolder.mkdir();
    File sessionImgFolder = new File(dataPath(sessionPath + "/screenshots"));
    sessionImgFolder.mkdir();
    String[] tempAssessment = {"", "", "", "50", "50", "50"};
    saveStrings(sessionPath + "/assessment.txt", tempAssessment);

    //filePath = absolutePath + "/user-data/" + currentUser + "/" + "assessment/"+nf(year(),4)+"."+nf(month(),2)+"."+nf(day(),2)+" "+nf(hour(),2)+"."+nf(minute(),2)+"."+nf(second(),2);
    //filename = absolutePath + "/user-data/" + currentUser + "/" + "log/"+nf(year(),4)+"."+nf(month(),2)+"."+nf(day(),2)+" "+nf(hour(),2)+"."+nf(minute(),2)+"."+nf(second(),2) + ".tsv";

    filename = sessionPath + "/brain-activity.tsv";

    output = createWriter(filename);
    output.println("time" + TAB + "delta" + TAB + "theta" + TAB + "lowAlpha" + TAB + "highAlpha" + TAB + "lowBeta" + TAB + "highBeta" + TAB + "lowGamma" + TAB + "midGamma" + TAB + "blinkSt" + TAB + "attention" + TAB + "meditation" + TAB + "timeline");
    datetimestr0 = minute()*60+second();   
    break;
  case "singleSession":
    println("singleSession page");
    currentPage = "singleSession";
    break;
  case "eegActivity":
    println("eegActivity page");
    currentPage = "eegActivity";
    break;
  }

  //clean up interface on logout
  if (theControlEvent.getLabel() == "Logout") {
    cp5.getController("logoutBt").hide();
    isLoggedIn = false;
    currentUser = "";
    cp5.getTab("default").bringToFront();
    currentPage = "home";
    cp5.getController("newSession").hide();
    cp5.getController("overall").hide();
  }

  if (theControlEvent.isAssignableFrom(Textfield.class)) {
    Textfield t = (Textfield)theControlEvent.getController();

    if (t.getName() == "username") {
      currentUser = t.getStringValue();
    }
    if (t.getName() == "password") {
      currentPassword = t.getStringValue();
    }

    //https://forum.processing.org/two/discussion/10423/working-with-client-connection-to-api-with-authentication
    // post request
    client = new Client(this, host, port);


    if (isNewUser) {
      client.write("POST "+newUserAddress+" HTTP/1.0\r\n");
    } else {
      client.write("POST "+loginAddress+" HTTP/1.0\r\n");
    }


    client.write("Accept: application/xml\r\n");
    client.write("Accept-Charset: utf-8;q=0.7,*;q=0.7\r\n");
    client.write("Content-Type: application/x-www-form-urlencoded\r\n");
    String contentLength = nf(23+currentUser.length()+currentPassword.length()); 
    client.write("Content-Length: "+contentLength+"\r\n\r\n");

    client.write("username="+currentUser+"&password="+currentPassword+"&\r\n");
    client.write("\r\n");

    println("controlEvent: accessing a string from controller '"
      +t.getName()+"': "+t.getStringValue()
      );

    print("controlEvent: trying to setText, ");

    t.setText("controlEvent: changing text.");
    if (t.isAutoClear()==false) {
      println(" success!");
    } else {
      println(" but Textfield.isAutoClear() is false, could not setText here.");
    }
    ///////////////////////////////////
  }
}

public void homeBt(int theValue) {
  currentPage = "home";
  //cp5.getTab("default").bringToFront();
  if (isLoggedIn) {
    cp5.getController("loginBt").hide();
  }
}

public void connectBox(int theValue) {
  
  if(!feelerS.checkConnection()){
    try{
      feelerS.init("/dev/tty.Feeler-RNI-SPP");
    } catch (NullPointerException e){
    }
  }
}


public void logoutBt(int theValue) {
  //cp5.getTab("default").bringToFront();
  cp5.getController("loginBt").show();
  currentUser = "";
  isLoggedIn = false;
  isEnabled = true;
  isWrongPassword = false;
}

public void loginBt(int theValue) {
  cp5.getTab("login").bringToFront();
  currentPage = "login";
}

public void newSession(int theValue) {
  cp5.getTab("newSession").bringToFront();

  String lastLogin = String.valueOf(year()) + "-" + String.valueOf(month()) + "-" + String.valueOf(day()) + "-" + String.valueOf(hour()) + "-" + String.valueOf(minute()) + "-" + String.valueOf(second()) + ".txt";
  String[] userLoglist = split(lastLogin, ' ');
  saveStrings(userDataFolder + "/" +currentUser + "/last-login.txt", userLoglist);
}

public void overall(int theValue) {
  cp5.getTab("overall").bringToFront();
}


public void session(int theValue) {
  println("this session: " + currentSession);
  cp5.getController("session").hide();
  
  if(currentSession != ""){
    currentPage = "singleSession";
    cp5.getTab("singleSession").bringToFront();
    currentSession = sessionFolders[currentItem];
  }
  //currentItem = i;
  //trends.onClick();
  //eegAct.onClick();
}

public void export(int theValue) {
  selectFolder("Select a folder to save your data:", "folderSelected");
}

public void startSession(int theValue) {
  //currentPage = "meditate";
  boxState = 100;
}

public void playPauseBt(int theValue){
  sw.playPause();
  println(recording);
  if(recording){
    cp5.getController("playPauseBt").setLabel("Pause");
  } else {
    cp5.getController("playPauseBt").setLabel("Play");
  }
}

public void stopBt(int theValue){
  boxState = 0;
  sw.stop();
}

public void endGame(int theValue){
  println("end game");
  assessQuestion = 1;
  boxState = 400;
  sw.stop();
  cp5.getController("endGame").hide();
  cp5.getController("assess1Bt").show();
}


public void assess1Bt(int theValue) {
  assessQuestion = 2;
  
  cp5.getController("assessRelaxationMeditation").show();
  cp5.getController("assessRelaxationStudy").show();
  cp5.getController("assessRelaxationPlay").show();
  
  cp5.getController("assess1Bt").hide();
  cp5.getController("assess2Bt").show();
  cp5.getController("assess22Bt").show();
}

public void assess22Bt(int theValue) {
  cp5.getController("assessRelaxationMeditation").hide();
  cp5.getController("assessRelaxationStudy").hide();
  cp5.getController("assessRelaxationPlay").hide();
  cp5.getController("assess22Bt").hide();
  cp5.getController("assess2Bt").hide();

  boxState = 400;
  assessQuestion = 1;
  cp5.getController("assess1Bt").show();
}

public void assess2Bt(int theValue) {
  assessQuestion = 3;
  
  cp5.getController("assessRelaxationMeditation").hide();
  cp5.getController("assessRelaxationStudy").hide();
  cp5.getController("assessRelaxationPlay").hide();
  
  cp5.getController("assessAttentionMeditation").show();
  cp5.getController("assessAttentionStudy").show();
  cp5.getController("assessAttentionPlay").show();
  
  cp5.getController("assess2Bt").hide();
  cp5.getController("assess22Bt").hide();
  cp5.getController("assess33Bt").show();
  cp5.getController("assess3Bt").show();
}

public void assess33Bt(int theValue) {
  assessQuestion = 2;
  
  cp5.getController("assessRelaxationMeditation").show();
  cp5.getController("assessRelaxationStudy").show();
  cp5.getController("assessRelaxationPlay").show();
  
  cp5.getController("assessAttentionMeditation").hide();
  cp5.getController("assessAttentionStudy").hide();
  cp5.getController("assessAttentionPlay").hide();
  
  cp5.getController("assess2Bt").show();
  cp5.getController("assess22Bt").show();
  cp5.getController("assess3Bt").hide();
  cp5.getController("assess33Bt").hide();
}

public void assess3Bt(int theValue) {
  assessQuestion = 4;

  cp5.getController("assessAttentionMeditation").hide();
  cp5.getController("assessAttentionStudy").hide();
  cp5.getController("assessAttentionPlay").hide();
  
  cp5.getController("assess3Bt").hide();
  cp5.getController("assess3Toggle1").hide();
  cp5.getController("assess3Toggle2").hide();
  cp5.getController("assess33Bt").hide();
  
  output.flush();
  output.close();
  
  String[] assessment = {feelingAssessMeditation, feelingAssessStudy, feelingAssessPlay, str(assessRelaxationMeditation), str(assessRelaxationStudy), str(assessRelaxationPlay), str(assessAttentionMeditation), str(assessAttentionStudy), str(assessAttentionPlay)};
  // Writes the strings to a file, each on a separate line
  saveStrings(sessionPath + "/assessment.txt", assessment);

  isRecordingMind = false;
  loadFiles();
}


void assess3Toggle1(boolean theFlag) {
  assess3Toggle1 = theFlag;
}

void assess3Toggle2(boolean theFlag) {
  assess3Toggle2 = theFlag;
}

public void submit(int theValue) {
  // use callback instead
  isEnabled = true;
  isNewUser = false;
  username.submit();
  password.submit();
  thread("timer"); // from forum.processing.org/two/discussion/110/trigger-an-event
}

public void signup(int theValue) {
  // use callback instead
  isEnabled = true;
  isNewUser = true;
  username.submit();
  password.submit();
  thread("timer"); // from forum.processing.org/two/discussion/110/trigger-an-event
}

public void loginCheck() {
  println("logincheck");

  if (debug) {
    println(currentUser);
    if (currentUser == "") {
      currentUser = "someuser";
    }

    cp5.getTab("overall").bringToFront();
    isLoggedIn = true;

    isWrongPassword = false;
    cp5.getController("logoutBt").show();

    addUserAreaControllers();
  } else {
    if (client.available() > 0) {
      loginData = client.readString();
      println(loginData);
      String[] m = match(loginData, "<logintest>(.*?)</logintest>");
      if (m[1].equals("success")) {
        cp5.getTab("overall").bringToFront();
        isLoggedIn = true;
        isWrongPassword = false;
        cp5.getController("logoutBt").show();
        addUserAreaControllers();
      } else if (m[1].equals("registered")) {
        cp5.getTab("login").bringToFront();
      } else {
        println("wrong password");
        isLoggedIn = false;
        isWrongPassword = true;
      }
    }
  }

  currentPage = "overall";
  loadFiles();
  loading = false;
}

public void addUserAreaControllers() {

  cp5.addTab("newSession");
  cp5.getTab("newSession")
    .activateEvent(true)
    .setId(3)
    ;

  cp5.addTab("overall");
  cp5.getTab("overall")
    .activateEvent(true)
    .setId(4)
    ;

  cp5.addTab("singleSession");
  cp5.getTab("singleSession")
    .activateEvent(true)
    .setId(5)
    ;

  cp5.addTab("eegActivity");
  cp5.getTab("eegActivity")
    .activateEvent(true)
    .setId(6)
    ;

  //other controllers
  cp5.addButton("newSession")
    .setBroadcast(false)
    .setLabel("start a session")
    .setPosition(width - 160, 10)
    .setSize(buttonWidth, buttonHeight)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("newSession").moveTo("global");

  cp5.addButton("connectBox")
    .setBroadcast(false)
    .setLabel("Connect Box")
    .setPosition(width - 170 - buttonWidth, 10)
    .setSize(buttonWidth, buttonHeight)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("connectBox").moveTo("global");
  cp5.getController("connectBox").hide();

  cp5.addButton("overall")
    .setBroadcast(false)
    .setLabel("overall")
    .setPosition(width/2 - buttonWidth/2 - 1, padding)
    .setSize(buttonWidth, buttonHeight)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("overall").moveTo("global");
  
  cp5.addButton("session")
    .setBroadcast(false)
    .setLabel("current session")
    .setPosition(width/2 + buttonWidth/2 + 1, padding)
    .setSize(buttonWidth, buttonHeight)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("session").moveTo("global");
  cp5.getController("session").hide();
  
  cp5.addButton("export")
    .setBroadcast(false)
    .setLabel("export data")
    .setPosition(width - 160, 50)
    .setSize(buttonWidth, buttonHeight)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
  cp5.getController("export").moveTo("singleSession");
}

public void timer() {
  while (isEnabled) {
    loading = true;
    delay(TIMER);
    isEnabled = false;
    loginCheck();
  }
}


public void deleteFile(int theValue) {
  String fileName = dataPath("test.json");
  //File f = new File(fileName);
  File f = new File(directory2 + "/" + filenameString);
  //println(fileName);
  //println("data: " + directory2 + "/" + filenameString);

  if (f.exists()) {
    f.delete();
    println("deletou");
    loginCheck();
  } else {
    println("n\u00e3o existe");
  }
}

public void loadFilesList(int n) {
  /* request the selected item based on index n */
  println(n, cp5.get(ScrollableList.class, "loadFilesList").getItem(n));
  CColor c = new CColor();
  c.setBackground(color(0));
  cp5.get(ScrollableList.class, "loadFilesList").getItem(n).put("color", c);

  loadFile(n);
}

public void mousePressed() {
  
  switch(currentPage) {
    case "singleSession":
      eegAvg.onClick(mouseX, mouseY);
      personalAssSesion.onClick(mouseX, mouseY);
      //personalAssSesion.setup(visWidth/2, visHeight/3);
      //personalAvg.setup(visWidth/2, visHeight/3);
      cp5.getController("session").show();
      loadFile(currentItem);
      break;
    case "overall":
      trends.onClick();
      eegAct.onClick();
      break;
    case "eegActivity":
      trends.onClick();
      eegAct.onClick();
      break;
  }
  
  feelingRadioMeditation.click();
  feelingRadioStudy.click();
  feelingRadioPlay.click();
  
  if(modal){
    if(
        mouseX >= modalWidth/4 - padding - 10 &&
        mouseX <= modalWidth/4 - padding - 10 + 30 &&
        mouseY >= modalHeight/4 - padding - 10 &&
        mouseY <= modalHeight/4 - padding - 10 + 30
    ){
      modal = false;
    }
  }
}

void mouseWheel(MouseEvent event) {
  e = event.getCount();
} 

public void keyPressed() {
  if (debug) {
    switch(key) {
    case 'c':
      screenshot();
      PImage newImage = createImage(100, 100, RGB);
      newImage = screenshot.get();
      newImage.save(
        absolutePath + "/user-data/" + currentUser + "/" +
        String.valueOf(year()) + "-" + String.valueOf(month()) + "-" + String.valueOf(day()) + "-" + String.valueOf(hour()) + "-" + String.valueOf(minute()) + "-" + String.valueOf(second()) +
        "-screenshot.png"
        );
      break;
    case 'l':
      thread("timer"); // from forum.processing.org/two/discussion/110/trigger-an-event
      break;
    case 's':
      sw.start();
      boxState = 200;
      break;
    case 'p':
      sw.stop();
      cp5.getController("playPauseBt").show();
      cp5.getController("stopBt").show();
      boxState = 300;
      break;
    case 'a':
      cp5.getController("playPauseBt").hide();
      sw.stop();
      
      if (currentPage == "newSession") {
        boxState = 400;
        assessQuestion = 1;
        if (assessQuestion == 1) {
          cp5.getController("assess1Bt").show();
        }
      }
      break;
    case 'm':
      simulateMindSet = !simulateMindSet;
    case 'q':
      sw.stop();
      cp5.getController("playPauseBt").hide();
      break;
    case 'w':
      sw.start();
      break;
    case 'e':
      sw.playPause();
      break;
    }
  }
}

public void screenshot() {
  try {
    Robot robot_Screenshot = new Robot();
    screenshot = new PImage(robot_Screenshot.createScreenCapture
      (new Rectangle(0, 0, displayWidth, displayHeight)));
  }
  catch (AWTException e) {
    println(e);
  }
  frame.setLocation(0, 0);
}


void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
      
    //save brain activity
    File fin = new File(userFolder + "/" + sessionFolders[currentItem] + "/brain-activity.tsv");
    File fout = new File(savePath(selection.getAbsolutePath() + "/" + currentUser + "/" + sessionFolders[currentItem] + "/brain-activity.tsv"));
    
    try {
      FileInputStream fis  = new FileInputStream(fin);
      FileOutputStream fos = new FileOutputStream(fout);
        
      byte[] buf = new byte[1024];
      int i = 0;
      while((i=fis.read(buf))!=-1) {
        fos.write(buf, 0, i);
      }
      fis.close();
      fos.close();
    } catch (Exception e) {
      println( "Error occured at ... " );
      e.printStackTrace();
    } finally {
      // what to do when finished trying and catching ...               
    }

    //save assessment
    File fin2 = new File(userFolder + "/" + sessionFolders[currentItem] + "/assessment.txt");
    File fout2 = new File(savePath(selection.getAbsolutePath() + "/" + currentUser + "/" + sessionFolders[currentItem] + "/assessment.txt"));

    try {
      FileInputStream fis  = new FileInputStream(fin2);
      FileOutputStream fos = new FileOutputStream(fout2);
        
      byte[] buf = new byte[1024];
      int i = 0;
      while((i=fis.read(buf))!=-1) {
        fos.write(buf, 0, i);
      }
      fis.close();
      fos.close();
    } catch (Exception e) {
      println( "Error occured at ... " );
      e.printStackTrace();
    } finally {
      // what to do when finished trying and catching ...
    }
    
  }
}

void openModal(String img){
  screenshotModal = loadImage(img);
  modalWidth = screenshotModal.width/1.5;
  modalHeight = screenshotModal.height/1.5;
}


void updateBoxData(){
  while(true){
    if ( millis() % 500 == 0) {
      
      try{
        feelerS.sendValues();
      } catch (Exception e) {}
      
      try{
        feelerS.get();
      } catch (Exception e) {}
    }
  }
}

void exit() {
  println("exiting");
  if(!simulateMindSet){
    mindSet.quit();
  }

  println("closeWindow");
  super.exit();  
}