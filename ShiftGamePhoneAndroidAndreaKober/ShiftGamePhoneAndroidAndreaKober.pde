boolean firstPress = false;
int timePressed;
int timeSoFar;
long timer, pauseTime = 300;


float startX;
float lengthDragged;


float w ;
float h = 10;
float expand = 1;


float x, y, size = 50;
boolean isUp = false;
//Code millis

long animBarSplitStart = 0, animSplitAnimationDuration = 250;    // Marlene: Variablen für die Animation der gesplitteten Bars
int animSplitIndex = -1, animNumBlocks = 0;

//int dirshift = 1;

boolean jumpOverGap = false;
boolean Gap = false;

int firstround;

int roundCount = 0;

boolean directionup = true;

int numCols = 9;
int numRows = 7;
int bottomRow = 6; // to avoid aout of bounds

float prob = 0.05;

int[][] grid = new int[numCols][numRows];
//int[][] squares = new int[numCols][numRows];

int[] bar = new int[numCols];

// Number of columns and rows in the grid
int cols = numCols;
int rows = numRows;

int blockWidth = 0 ;
int blockHeight = 0;

int barRow = numRows-1;
int sizeCanvas = 0;

int cursorPos = 0;
float cursorPosHeight = barRow;
int cursorWidth = 2;
int increaseCursorWidth = 1;

boolean stoppedPressing = false;


void setup() {

  size (600, 300);
  //textSize(14);

  //orientation(LANDSCAPE);     //for phone
  sizeCanvas = width;
  cursorPos = sizeCanvas/numRows; //Here changes CursorPos
  blockWidth = sizeCanvas/numCols;
  blockHeight = sizeCanvas/numRows;
  setupPlayfield();
  setupBar();

  //Code millis
  x = width / 2;
  y = 2 * size;
  //timer = millis();  // timer is the timestamp (store last time measured), millis() is now
  //Code millis
}
void draw() {
  background(255);
  println("barRow " + barRow);



  if (mousePressed) {
    stoppedPressing = false;
    if (!firstPress) {
      timePressed = millis();
      firstPress  = true;
    }

    cursorWidth += increaseCursorWidth;
    //println(timePressed);
  }
  // once when the mouse is released
  else if (stoppedPressing) {
    println("Stopped pressing");
    stoppedPressing = false;
    firstPress = false;

    // use timePressed to claculate how many blocks to remove
    timeSoFar = millis() - timePressed;
    float timeSoFarSecs = timeSoFar/1000.0;
    timeSoFarSecs = constrain(timeSoFarSecs, 1, 3);
    int howManyBlocks = ceil(timeSoFarSecs); // round up
    println("Blocks to remove " + howManyBlocks);


    // time to split
    int xMousePos = floor(map(mouseX, 0, width, 0, numCols));
    //SplitBar( Postion, Blocks);
    splitBar(xMousePos, howManyBlocks);
  }


  renderPlayfield();
  renderBar();

  cursorMove();
  //millis
  //moveBarUp();

  moveBarUpMillis();
  //stopBar();

  //println(cursorPos);
}

///
///
///
///

void cursorMove() {
  noStroke();
  fill(255, 0, 0);
  // + 1 for the missing stroke
  rect(mouseX, barRow * height/numRows - 1, cursorWidth, height/numRows +2);
}


void nextRound() {
  setupBar();
  setupPlayfield();

  directionup =! directionup;
  //println(" i changed the direction");

  roundCount++;
}

//millis

// (directionup == true)  is equal to writing (directionup)
// (directionup == false)  is equal to writing (!directionup)
void moveBarUpMillis() {
  if (millis() - timer >= pauseTime) {  // wait until 1 sec (pauseTime) is over
    //println("tick " + millis()/1000.0);

    if (barRow == 0) {          //if it's on the top row
      nextRound();
      //println(directionup);
      if (istheBarClear() == true) {
        barRow ++;  //go down
      }
    } 
    if (barRow == bottomRow) {  //if it's on the bottom row
      nextRound();
      directionup = true;

      if (firstround == 1 ) {
        nextRound();
        firstround ++;
        if (istheBarClear() == true) {
          barRow ++;  //go down
        }
      } 

      if (istheBarClear() == true) {
        barRow --; // go up
      }
    } else if (barRow > 0 && barRow < bottomRow) {
      if (istheBarClear() == true) {      //if there isn't an obstacle in the next row
        if (directionup == true ) {
          barRow --;
        } else {
          barRow ++;
        }
      }
    }

    timer = millis();    // store last time reacted on
  }
}


//millis

void setupPlayfield() {
  // 1 in cols leave the 1st and last col empty
  for (int i = 1; i < cols - 1; i++) {
    for (int j = 2; j < rows - 2; j++) {
      // Initialize each object
      if (random(1) < prob) 
        grid[i][j] = 1;
      else 
      grid[i][j] = 0;
    }
  }
}

void renderPlayfield() {
  stroke(0, 0, 0, 40);
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {

      if (grid[i][j] == 1) 
        fill(128);
      else 
      fill(255);
      rect(i*width/numCols, j*height/numRows, width/numCols, height/numRows);
    }
  }
}


void setupBar() {
  for (int i = 0; i < cols; i++) 
    bar[i] = 1;
}


void renderBar() {
  noStroke();
  fill(0, 0, 0, 40);
  for (int i = 0; i < cols; i++) {
    long animProgress = millis() - animBarSplitStart;
    if (animSplitIndex >= 0 && i >= animSplitIndex+animNumBlocks &&      // Marlene: gültiger split index und aktueller Block rechts vom split index 
      animProgress < animSplitAnimationDuration * animNumBlocks ) {    // Marlene: Animationsdauer ist im Bereich           
      float animX = map(animProgress, 0, animSplitAnimationDuration * animNumBlocks, (i-animNumBlocks)*width/numCols, (i)*width/numCols);
      rect(animX, barRow * height/numRows, width/numCols, height/numRows);
    } else if (bar[i] == 1) {
      rect(i*width/numCols, barRow * height/numRows, width/numCols, height/numRows);
    }
  }
}

//boolean obstacle

boolean splitBar(int cursorPos, int numBlocks) {
  println("Number of Blocks: " + numBlocks);
  if (cursorPos > 0 && cursorPos < numCols && bar[cursorPos] == 1 && bar[cursorPos-1] == 1 &&
    numBlocks > 0 && numBlocks <= 3) {
    for (int i = numCols -1; i >= cursorPos; i--) {
      if (i-numBlocks >= 0) 
        bar[i] = bar[i-(numBlocks)];
    }

    for (int i = cursorPos; i < cursorPos + numBlocks; i++)
      bar[i] = 0;

    // Marlene: setzte Animationsvariablen auf gültige Werte um mit Anim. zu beginnen 
    animBarSplitStart = millis();
    animSplitIndex = cursorPos;
    animNumBlocks = numBlocks;

    return true;
  }

  // Marlene: setzte Animationsvariablen auf ungültige Werte um nicht mehr zu animieren 
  animBarSplitStart = 0;
  animSplitIndex = -1;
  numBlocks = 0;

  return false;
}

boolean istheBarClear() { 
  boolean isClear = true;

  int dirVal = 0;

  if (directionup == true) {
    dirVal = -1;
  } else {
    dirVal = 1;
  }

  for (int i = 0; i < cols; i++) {
    if (grid[i][barRow + (dirVal)] == 1) { //if there is a square in pos (i,myrow-1)
      // if (grid[i][barRow] == 1){
      // }
      // here stop the bar when its on top
      // take it to the next level

      //println("@" + i + " the bar's value is: " + bar[i]);
      if (bar[i] == 0) {
        isClear = true;
      } else {
        isClear = false;
        break;
      }
    }
  }

  return isClear;
}


void mouseReleased() {
  println("mouseReleased() " + mouseX + " " + mouseY);
  //timeSoFar = millis() - timePressed;
  stoppedPressing = true;

  cursorWidth = 2;

  timeSoFar = 0;
  println(timeSoFar);
  splitBar(mouseX, 1);
}

/*
void keyPressed() {
 if (keyCode == RIGHT) {
 cursorPos += width/numRows;
 if (cursorPos >= width/numRows * numCols) {
 cursorPos -= width/numRows;
 }
 }
 
 
 //wenn ich bei 50 cursorPos mit 2 Einheiten trenne darf cursor nicht auf 100 springen 
 //sondern auf cursor pos + width/numRows + (50);
 
 if (keyCode == LEFT) {
 cursorPos -= width/numRows;
 if (cursorPos <= width/numRows - numRows) {
 cursorPos += width/numRows;
 }
 }
 
 if ((keyCode == UP) && (istheBarClear() == true) && (barRow > 0)) {
 barRow --;
 }
 
 
 if ((keyCode == DOWN) && (istheBarClear() == true) && (barRow < numRows)) {
 barRow ++;
 }
 
 //Split the bar
 if (key == '1' && cursorPos % 50 == 0) {
 splitBar(cursorPos/50, 1);
 }
 
 
 
 if (key == '2' && cursorPos % 50 == 0) {
 splitBar(cursorPos/50, 2);
 }
 
 if (key == '3' && cursorPos % 50 == 0) {
 splitBar(cursorPos/50, 3);
 }
 
 if (key == '4' && cursorPos % 50 == 0) {
 splitBar(cursorPos/50, 2);
 }
 
 if (key == 't') {
 setupPlayfield();
 }
 
 //println("mousePressed() " + mouseX + " " + mouseY);
 startX = mouseX;
 timePressed = millis();
 }
 */
