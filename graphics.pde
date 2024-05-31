import processing.serial.*;

int twoDMode = 0;

Serial myPort; // The serial port
String val;
String massPos;
String handlePos;
float wallPos = 0;
float prevWallPos = 0;
float userPos = 0;
float prevUserPos = 0;
float anchorPos = 0.005;
float pixelWallLoc = 0;
float pixelAnchorPos = 0;
float pixelBallWidth = 20;
float pixelUserPos = 0;
String[] list;
int keyPressed = 0;
int charPositionX = 300; // Character position in pixels, x coordinate
int charPositionY = 300; // Character position in pixels, y coordinate
float charTheta = 0; // Character facing direction, horizontal is 0
int pixelStrideLength = 4; // Character speed controller, sets the number of strides the character moves every loop
float thetaStrideLength = 0.02 * PI;
static int screenSizeX = 600;
static int screenSizeY = 600;
int numWalls = 16;
int wallWidth = floor(screenSizeX / numWalls); // Wall width
boolean orbNotGenerated = true;
boolean win = false;
int orbPositionX = 0;
int orbPositionY = 0;
int orbDistanceX; // Distance to orb in x direction
int orbDistanceY; // Distance to orb in y direction
int orbDistance; // Manhattan distance to orb

int[][] wallArray = {
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1},
  {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1},
  {1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
};

void settings() {
  size(screenSizeX, screenSizeY);
}

void setup() {
  // Set the window size
  // List all the available serial ports
  // println(Serial.list());
  
  // Check the listed serial ports in your machine
  // and use the correct index number in Serial.list()[]
  // myPort = new Serial(this, Serial.list()[0], 230400); // make sure baud rate matches Arduino
  
  // A serialEvent() is generated when a newline character is received
  // myPort.bufferUntil('\n');
  background(0); // Set initial background
  hint(ENABLE_STROKE_PURE);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      keyPressed = 1;
    } else if (keyCode == DOWN) {
      keyPressed = 2;
    } else if (keyCode == LEFT) {
      keyPressed = 3;
    } else if (keyCode == RIGHT) {
      keyPressed = 4;
    }
  }
}

void draw() {
  // Everything happens in the serialEvent()
  background(0); // Uncomment if you want to control a ball
  stroke(127, 34, 255); // Stroke color
  strokeWeight(2); // Stroke width

  print(" key pressed: ");
  print(keyPressed);
  print(" theta :");
  print(charTheta);
  print(" position x:");
  print(charPositionX);
  print(" position y:");
  print(charPositionY);
  print("\n");

  // Generate the point where the orb is
  floor(random(0, numWalls));

  while (orbNotGenerated == true) {
    orbPositionX = floor(random(0, numWalls));
    orbPositionY = floor(random(0, numWalls));
    // Check for walls
    if (wallArray[orbPositionY][orbPositionX] == 0) {
      orbNotGenerated = false;
    }
  }

  println(orbPositionX);
  println(orbPositionY);

  // Set position before checking for collisions
  int tempPositionX = charPositionX;
  int tempPositionY = charPositionY;

  if (keyPressed == 1) {
    tempPositionX = charPositionX + floor(pixelStrideLength * cos(charTheta));
    tempPositionY = charPositionY + floor(pixelStrideLength * sin(charTheta));
  } else if (keyPressed == 2) {
    tempPositionX = charPositionX - floor(pixelStrideLength * cos(charTheta));
    tempPositionY = charPositionY - floor(pixelStrideLength * sin(charTheta));
  } else if (keyPressed == 3) {
    charTheta = charTheta - thetaStrideLength;
  } else if (keyPressed == 4) {
    charTheta = charTheta + thetaStrideLength;
  }

  // Check for collisions with the walls
  int collisionFlag = 0;
  for (int i = 0; i < numWalls; i++) {
    for (int j = 0; j < numWalls; j++) {
      if (wallArray[i][j] == 1) {
        if ((tempPositionX >= j * wallWidth) && (tempPositionX <= (j + 1) * wallWidth)) {
          if ((tempPositionY >= i * wallWidth) && (tempPositionY <= (i + 1) * wallWidth))
            collisionFlag = 1;
        }
      }
    }
  }

  if (collisionFlag == 0) {
    charPositionX = tempPositionX;
    charPositionY = tempPositionY;
  }

  // Check for outer boundary collisions
  if (charPositionX > screenSizeX) {
    charPositionX = screenSizeX;
  } else if (charPositionX < 0) {
    charPositionX = 0;
  } else if (charPositionY > screenSizeY) {
    charPositionY = screenSizeY;
  } else if (charPositionY < 0) {
    charPositionY = 0;
  }

  int gridX = floor(charPositionX / wallWidth); // Which cell is the player in the X direction?
  int gridY = floor(charPositionY / wallWidth); // Which cell is the player in the Y direction?

  // Check win
  if ((gridX - orbPositionX == 0) && (gridY - orbPositionY == 0)) {
    win = true;
  }

  if (win == true) {
    println("You've found the orb!");
  }

  // Distance
  orbDistanceX = abs(gridX - orbPositionX);
  orbDistanceY = abs(gridY - orbPositionY);
  orbDistance = orbDistanceX + orbDistanceY;

  print("\nOrb distance x :");
  print(orbDistanceX);
  print("\tOrb distance y :");
  print(orbDistanceY);

  // Add random object position setting code here
  // Calculate position from object to the character goes here

  if (twoDMode == 1) {
    // Draw the character in 2D
    ellipse(charPositionX, charPositionY, 10, 10);

    // Draw the walls in 2D
    for (int i = 0; i < numWalls; i++) {
      for (int j = 0; j < numWalls; j++) {
        if (wallArray[i][j] == 1) {
          square(j * wallWidth, i * wallWidth, wallWidth);
        }
      }
    }
  }

  if (twoDMode == 0) {
    // Define camera plane vector and direction vector, set field of view
    float FOVMod = 0.66;
    float dVectorX = cos(charTheta);
    float dVectorY = sin(charTheta);
    float camPlaneX = -FOVMod * sin(charTheta);
    float camPlaneY = FOVMod * cos(charTheta);

    stroke(150, 150, 150);
    square(0, 0, 600);
    stroke(50, 50, 50);
    square(0, 0, 600);

    for (int x = 0; x < screenSizeX; x++) {
      float XFloat = x;
      float camX = 2 * XFloat / screenSizeX - 1; // Camera space X coordinate
      float rayDirX = dVectorX + camPlaneX * camX;
      float rayDirY = dVectorY + camPlaneY * camX;

      int mapX = floor(charPositionX / wallWidth); // Which cell is the player in the X direction?
      int mapY = floor(charPositionY / wallWidth); // Which cell is the player in the Y direction?

      float sideDistX = 0; // Distance to nearest X side
      float sideDistY = 0; // Distance to nearest Y side

      float deltaDistX = 0;
      float deltaDistY = 0;

      // Calculate the stepping distance
      if (rayDirX == 0) {
        deltaDistX = 1e30;
      } else {
        deltaDistX = abs(1 / rayDirX);
      }

      if (rayDirY == 0) {
        deltaDistY = 1e30;
      } else {
        deltaDistY = abs(1 / rayDirY);
      }

      float perpWallDist; // Distance to the wall perpendicular to the camera plane

      // Which direction to step in (+-1)
      int stepX = 1;
      int stepY = 1;

      int hit = 0; // Wall hit check flag
      int side = 0; // Which orientation wall, vertical or horizontal

      // Calculate initial distance to side
      if (rayDirX < 0) {
        stepX = -1;
        sideDistX = (charPositionX - mapX * wallWidth) * deltaDistX;
      } else {
        stepX = 1;
        sideDistX = ((mapX + 1) * wallWidth - charPositionX) * deltaDistX;
     
        if (rayDirY < 0) {
          stepY = -1;
          sideDistY = (charPositionY - mapY * wallWidth) * deltaDistY;
        } else {
          stepY = 1;
          sideDistY = ((mapY + 1) * wallWidth - charPositionY) * deltaDistY;
        }
  
        // DDA
        while (hit == 0) {
          // Advance the ray
          if (sideDistX < sideDistY) {
            sideDistX += deltaDistX * wallWidth;
            mapX += stepX;
            side = 0;
          } else {
            sideDistY += deltaDistY * wallWidth;
            mapY += stepY;
            side = 1;
          }
          if (wallArray[mapY][mapX] > 0)
            hit = 1;
        }
  
        // Calculate perpendicular distance to the wall
        if (side == 0) {
          perpWallDist = (sideDistX - deltaDistX * wallWidth);
        } else {
          perpWallDist = (sideDistY - deltaDistY * wallWidth);
        }
  
        perpWallDist = perpWallDist / (screenSizeX / 2);
  
        int lineHeight = floor(screenSizeY / (perpWallDist * 10));
        int drawStart = -lineHeight / 2 + screenSizeY / 2;
  
        if (drawStart < 0)
          drawStart = 0;
  
        int drawEnd = lineHeight / 2 + screenSizeY / 2;
  
        if (drawEnd > screenSizeY)
          drawEnd = screenSizeY;
  
        if (side == 1) {
          stroke(220, 220, 220); // Stroke color for vertical walls
        } else {
          stroke(110, 110, 110); // Stroke color for horizontal walls
        }
  
        line(x, drawStart, x, drawEnd);
      }
    }
  }

  keyPressed = 0;
}

void serialEvent(Serial myPort) {
  //logic for communicating to arduino goes here
}
