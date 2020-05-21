float x, y, size = 50;
boolean isUp = false;
long timer, pauseTime = 300;
//Code millis





long animBarSplitStart = 0, animSplitAnimationDuration = 250;    // Marlene: Variablen für die Animation der gesplitteten Bars
int animSplitIndex = -1, animNumBlocks = 0;

//int dirshift = 1;

boolean jumpOverGap = false;
boolean Gap = false;

int firstround;

int roundCount = 0;

boolean directionup = true;

int numCols = 12;
int numRows = 12;

float prob = 0.06;

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

void setup() {
  size(600, 600);
  sizeCanvas = width;
  cursorPos = sizeCanvas/numRows;
  blockWidth = sizeCanvas/numCols;
  blockHeight = sizeCanvas/numRows;
  setupPlayfield();
  setupBar();



  //Code millis
  x = width / 2;
  y = 2 * size;
  timer = millis();  // timer is the timestamp (store last time measured), millis() is now
  //Code millis
}
void draw() {
  background(0);

  renderPlayfield();
  cursorMove();
  renderBar();
  //millis
  //moveBarUp();

  moveBarUpMillis();
  //stopBar();

  //println(cursorPos);
}

void cursorMove() {
  noStroke();
  fill(255, 0, 0);
  // + 1 for the missing stroke
  rect(cursorPos, barRow * height/numRows + 1, 2, height/numRows - 1);
}


void nextRound() {
  setupBar();
  setupPlayfield();

  directionup =! directionup;
  println(" i changed the direction");

  roundCount++;
}

//millis

// (directionup == true)  is equal to writing (directionup)
// (directionup == false)  is equal to writing (!directionup)
void moveBarUpMillis() {
  if (millis() - timer >= pauseTime) {  // wait until 1 sec (pauseTime) is over
    println("tick " + millis()/1000.0);

    if (barRow == 0) {          //if it's on the top row
      nextRound();
      println(directionup);
      if (istheBarClear() == true) {
        barRow ++;  //go down
      }
    } 
    if (barRow == 11) {  //if it's on the bottom row
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
    } else if (barRow > 0 && barRow < 11) {
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
  stroke(0, 0, 0, 30);
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
  fill(0, 0, 0, 60);
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

//void stopBar() {
//  if (cursorPos <= 100) {
//    barRow++;
//  }
//}


/*

 //boolean isNextRowClear(int currentRow){
 //  for(each column){
 //    check col in currentRow
 //    if there is an obstacle (it's gray)
 //    return false
 //  }
 //  
 //  return true
 //}
 
 */

//boolean obstacle

boolean splitBar(int cursorPos, int numBlocks) {
  println(numBlocks);
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

      println("@" + i + " the bar's value is: " + bar[i]);
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


//store column index(es) for obstacle


/*
&& numRows-1
 */

// send to function the barRow, which is the current row of the bar
// and return true only when there is a square in previous row
/*

 
 boolean thereisSquareUp() {   
 for (int column = 0; column < cols; column++) {
 if (grid[column][barRow - 1 ] == 1) //if there is a square in position column and row = barRow-1)
 return  true;     
 }
 return false;
 
 }
 
 
 boolean thereisSquareUp() {   
 for (int column = 0; column < cols; column++) 
 for (int rows = 0; rows < rows; rows++) {
 if (grid[column][barRow - 1 ] == 1) //if there is a square in position column and row = barRow-1)
 return  true;     
 }
 return false;
 
 }
 
 
 if the column of bar ist 0 dann hoch
 ist die bar 0 dann not go up
 
 boolean askIfZero() {
 boolean returnVariable = false;
 for (int i = 0; i < cols; i++) {
 if (grid[i][barRow - 1] == 1 && grid[i][barRow] == 0 ) //if there is a square in pos (i,myrow-1)
 returnVariable = true;     
 }
 return returnVariable;
 }
 
 
 
 
 */
void mousePressed() {
  //boolean split = splitBar(5, 2);
  //if (split)
  //  barRow --;
  //barRow = (barRow+1)%numRows;
  //setupPlayfield();
}

/*
 void mousePressed() {
 boolean split = splitBar(5, 2);
 if (split)
 barRow --;
 //barRow = (barRow+1)%numRows;
 //setupPlayfield();
 }*/


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
}
