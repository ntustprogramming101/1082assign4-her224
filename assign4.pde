PImage title, gameover, startNormal, startHovered, restartNormal, restartHovered;
PImage groundhogIdle, groundhogLeft, groundhogRight, groundhogDown, groundhogDisplay;
PImage bg, life, cabbage, stone1, stone2, soilEmpty;
PImage soldier;
PImage[][] soils, stones;

final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2;
int gameState = 0;

final int GRASS_HEIGHT = 15;
final int SOIL_COL_COUNT = 8;
final int SOIL_ROW_COUNT = 24;
final int SOIL_SIZE = 80;

int[][] soilHealth;
int[] soilEmptyPosition;
int areaIndex, soilState = 0, stoneGrayState = 0, stoneBlueState = 0;
boolean stoneGrayExist, stoneBlueExist;

final int START_BUTTON_WIDTH = 144;
final int START_BUTTON_HEIGHT = 60;
final int START_BUTTON_X = 248;
final int START_BUTTON_Y = 360;

float[] cabbageX, cabbageY, soldierX, soldierY;

float soldierSpeed = 2f;

float playerX, playerY;
int playerCol, playerRow;
final float PLAYER_INIT_X = 4 * SOIL_SIZE;
final float PLAYER_INIT_Y = - SOIL_SIZE;
boolean leftState = false;
boolean rightState = false;
boolean downState = false;
int playerHealth = 2;
final int PLAYER_MAX_HEALTH = 5;
int playerMoveDirection = 0;
int playerMoveTimer = 0;
int playerMoveDuration = 15;

boolean demoMode = false;

void setup() {
	size(640, 480, P2D);
	bg = loadImage("img/bg.jpg");
	title = loadImage("img/title.jpg");
	gameover = loadImage("img/gameover.jpg");
	startNormal = loadImage("img/startNormal.png");
	startHovered = loadImage("img/startHovered.png");
	restartNormal = loadImage("img/restartNormal.png");
	restartHovered = loadImage("img/restartHovered.png");
	groundhogIdle = loadImage("img/groundhogIdle.png");
	groundhogLeft = loadImage("img/groundhogLeft.png");
	groundhogRight = loadImage("img/groundhogRight.png");
	groundhogDown = loadImage("img/groundhogDown.png");
	life = loadImage("img/life.png");
	soldier = loadImage("img/soldier.png");
	cabbage = loadImage("img/cabbage.png");
	soilEmpty = loadImage("img/soils/soilEmpty.png");
  
	// Load PImage[][] soils
	soils = new PImage[6][5];
	for(int i = 0; i < soils.length; i++){
		for(int j = 0; j < soils[i].length; j++){
			soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
		}
	}

	// Load PImage[][] stones
	stones = new PImage[2][5];
	for(int i = 0; i < stones.length; i++){
		for(int j = 0; j < stones[i].length; j++){
			stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
		}
	}

	// Initialize player
	playerX = PLAYER_INIT_X;
	playerY = PLAYER_INIT_Y;
	playerCol = (int) (playerX / SOIL_SIZE);
	playerRow = (int) (playerY / SOIL_SIZE);
	playerMoveTimer = 0;
	playerHealth = 2;

	// Initialize soilHealth
  soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];
	initialSoilHealth();

	// Initialize soidiers and their position
  soldierX = new float[6];
  soldierY = new float[6];
  initialSoldier();
  
	// Initialize cabbages and their position
  cabbageX = new float[6];
  cabbageY = new float[6];
  initialCabbage();
}

void draw() {

	switch (gameState) {

		case GAME_START: // Start Screen.
		image(title, 0, 0);
		if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
	    && START_BUTTON_X < mouseX
	    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
	    && START_BUTTON_Y < mouseY) {

			image(startHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;
			}
		}else{
			image(startNormal, START_BUTTON_X, START_BUTTON_Y);
		}
		break;

		case GAME_RUN: // In-Game.
    // Background.
		drawBG();
	  // Transform coordinate.
		pushMatrix();
		translate(0, max(SOIL_SIZE * -18, SOIL_SIZE * 1 - playerY));
		// Ground
    drawGround();
		// Soil
		drawSoil();
		// Cabbages
    drawCabbage();
		// Soldiers
    drawSoldier();
    // Groundhog
    drawGH();

		// Demo mode: Show the value of soilHealth on each soil
		// (DO NOT CHANGE THE CODE HERE!)
		if(demoMode){	

			fill(255);
			textSize(26);
			textAlign(LEFT, TOP);

			for(int i = 0; i < soilHealth.length; i++){
				for(int j = 0; j < soilHealth[i].length; j++){
					text(soilHealth[i][j], i * SOIL_SIZE, j * SOIL_SIZE);
				}
			}
		}

		popMatrix();

		// Health UI
    drawLife();
    
    // Switch to game over if health equal zero.
    if(playerHealth == 0){
      gameState = GAME_OVER;
    }
    
		break;

		case GAME_OVER: // Gameover Screen
		image(gameover, 0, 0);
		
		if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
	    && START_BUTTON_X < mouseX
	    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
	    && START_BUTTON_Y < mouseY) {

			image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;

				// Initialize player
				playerX = PLAYER_INIT_X;
				playerY = PLAYER_INIT_Y;
				playerCol = (int) (playerX / SOIL_SIZE);
				playerRow = (int) (playerY / SOIL_SIZE);
				playerMoveTimer = 0;
				playerHealth = 2;

				// Initialize soilHealth
        initialSoilHealth();				
				// Initialize soidiers and their position
        initialSoldier();
				// Initialize cabbages and their position
				initialCabbage();
			}

		}else{
			image(restartNormal, START_BUTTON_X, START_BUTTON_Y);
		}
		break;
		
	}
}

void initialSoilHealth(){
  for(int j = 0; j < SOIL_ROW_COUNT; j++){
    // Set empty soil number.
    int soilEmptyNumber = ceil(random(0,2));
    
    // Except first layer.
    if(j == 0){
      soilEmptyNumber = 0;
    }
    
    // Set empty soil position.
    soilEmptyPosition = new int[soilEmptyNumber];
    
    for(int k = 0; k < soilEmptyNumber; k++){
      soilEmptyPosition[k] = floor(random(0,8));
    }
    
    for (int i = 0; i < SOIL_COL_COUNT; i++) {
      // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
      soilHealth[i][j] = 15;
      areaIndex = floor(j / 4);
      
      // Detect stone and soil state.
      if(areaIndex < 2){ // First and second layer.
        // Rule : follow diagonal line.
        if(i == j){
          soilHealth[i][j] = 30;
        }
      }else if(areaIndex < 4){ // Third and fourth layer.
        // Rule : follow diagonal line and use the difference between i and j as tag to check.
        if(abs((j - 8) - i) == 1 || abs((j - 8) - i) == 5){
        // This diagonal line begin with a stone and follow with a blank.
          if((i + j) % 4 == 1){
            soilHealth[i][j] = 30; 
          }
        }else if(abs((j - 8) - i) == 2 || abs((j - 8) - i) == 6){ // This diagonal line full of stone.
          soilHealth[i][j] = 30;
        }else if(abs((j - 8) - i) == 3){ // This diagonal line begin with a blank and follow with a stone.
          if((i + j) % 4 == 1){
            soilHealth[i][j] = 30;
          }
        }
      }else{ // Fifth and sixth layer.
        // Rule : follow anti-diagonal line.
        if(!((j - 16 + i) == 0 || (j - 16 + i) == 3 || (j - 16 + i) == 6 || (j - 16 + i) == 9 || (j - 16 + i) == 12)){ 
          soilHealth[i][j] = 30;
        }
        // Rule : follow anti-diagonal line.
        if((j - 16 + i) == 2 || (j - 16 + i) == 5 || (j - 16 + i) == 8 || (j - 16 + i) == 11 || (j - 16 + i) == 14){ 
          soilHealth[i][j] = 45;
        }
      }
      
      // Set empty soil's health equal to zero.
      for(int count = 0; count < soilEmptyNumber; count++){
        if(i == soilEmptyPosition[count]){
          soilHealth[i][j] = 0;
        }
      }
    }
  }
}

void initialCabbage(){
  // Initialize cabbage in random position, x and y coordinate should be in block.
  // Four rows as one region, pick one row of every region as y coordinate.
  for(int i = 0; i < 6; i++){
    cabbageX[i] = floor(random(0, 8)) * SOIL_SIZE;
    cabbageY[i] = floor(random(i * 4, (i + 1) * 4)) * SOIL_SIZE;
  }
}

void initialSoldier(){
  // Initial soldier in random position, x can be any position in range of width, y should be in block.
  // Four rows as one region, pick one row of every region as y coordinate.
  for(int i = 0; i < 6; i++){
    soldierX[i] = random(0, width);
    soldierY[i] = floor(random(i * 4, (i + 1) * 4)) * SOIL_SIZE;
  }
}

void drawBG(){
  // Background
  image(bg, 0, 0);
  // Sun
  stroke(255,255,0);
  strokeWeight(5);
  fill(253,184,19);
  ellipse(590,50,120,120);
}

void drawGround(){
  fill(124, 204, 25);
  noStroke();
  rect(0, -GRASS_HEIGHT, width, GRASS_HEIGHT);
}

void drawSoil(){
  for(int i = 0; i < soilHealth.length; i++){
    for (int j = 0; j < soilHealth[i].length; j++){
      areaIndex = floor(j / 4);
      stoneGrayExist = false;
      stoneBlueExist = false;
      
      // Detect stone and soil state.
      if(areaIndex < 2){ // First and second layer.
        // Rule : follow diagonal line.
        if(i == j){
          stoneGrayExist = true;
        }
      }else if(areaIndex < 4){ // Third and fourth layer.
        // Rule : follow diagonal line and use the difference between i and j as tag to check.
        if(abs((j - 8) - i) == 1 || abs((j - 8) - i) == 5){
          // This diagonal line begin with a stone and follow with a blank.
          if((i + j) % 4 == 1){
            stoneGrayExist = true; 
          }
        }else if(abs((j - 8) - i) == 2 || abs((j - 8) - i) == 6){ // This diagonal line full of stone.
          stoneGrayExist = true;
        }else if(abs((j - 8) - i) == 3){ // This diagonal line begin with a blank and follow with a stone.
          if((i + j) % 4 == 1){
            stoneGrayExist = true;
          }
        }
      }else{ // Fifth and sixth layer.
        // Rule : follow anti-diagonal line.
        if(!((j - 16 + i) == 0 || (j - 16 + i) == 3 || (j - 16 + i) == 6 || (j - 16 + i) == 9 || (j - 16 + i) == 12)){ 
          stoneGrayExist = true;
        }
        
        // Rule : follow anti-diagonal line.
        if((j - 16 + i) == 2 || (j - 16 + i) == 5 || (j - 16 + i) == 8 || (j - 16 + i) == 11 || (j - 16 + i) == 14){ 
          stoneBlueExist = true;
        }
      }
      
      // Cauculate health
      // Check soil.
      if(soilHealth[i][j] > 12){
        soilState = 4;
      }else if(soilHealth[i][j] > 0){
        soilState = (soilHealth[i][j] - 1) / 3;
      }else{
        soilState = 0;
      }
      
      // Check gray stone.
      if((soilHealth[i][j] - 16) > 11){
        stoneGrayState = 4;
      }else if((soilHealth[i][j] - 16) >= 0){
        stoneGrayState = (soilHealth[i][j] - 16) / 3;
      }else{
        stoneGrayExist = false;
      }
      
      // Check blue stone.
      if((soilHealth[i][j] - 31) > 11){
        stoneBlueState = 4;
      }else if((soilHealth[i][j] - 31) >= 0){
        stoneBlueState = (soilHealth[i][j] - 31) / 3;
      }else{
        stoneBlueExist = false;
      }
        
      // Draw soil.
      image(soils[areaIndex][soilState], i * SOIL_SIZE, j * SOIL_SIZE);
      
      // Draw gray stone.
      if(stoneGrayExist){
        image(stones[0][stoneGrayState], i * SOIL_SIZE, j * SOIL_SIZE);
      }
      
      // Draw blue stone.
      if(stoneBlueExist){
        image(stones[1][stoneBlueState], i * SOIL_SIZE, j * SOIL_SIZE);
      }
      
      // Draw empty soil.
      if(soilHealth[i][j] == 0){
        image(soilEmpty, i * SOIL_SIZE, j * SOIL_SIZE);
      }
    }
  }
}

void drawLife(){
  // Draw different number and position of life.
  for(int i = 0; i < playerHealth; ++i){
    image(life, i * (life.width+20)+10, 10);
  }
}

void drawCabbage(){
  for(int i = 0; i < 6; i++){
    image(cabbage, cabbageX[i], cabbageY[i]);
    
    // Detect collision between cabbage and groundhog.
    if( cabbageX[i] < (playerX + SOIL_SIZE) && (cabbageX[i] + SOIL_SIZE) > playerX && cabbageY[i] < (playerY + SOIL_SIZE) && (cabbageY[i] + SOIL_SIZE) > playerY ){
      
      // If player's health over five, cabbage won't be ate.
      if(playerHealth < 5){
        cabbageX[i] = width;
        cabbageY[i] = height;
        playerHealth++; // Earn life.
      }
    }
  }
}

void drawSoldier(){
  for(int i = 0; i < 6; i++){
    image(soldier, soldierX[i], soldierY[i]);
    soldierX[i] += soldierSpeed;
    
    // Detect if soldier is out of boundary.
    if(soldierX[i] > width){soldierX[i] = -SOIL_SIZE;}
    
    // Detect collision between soldier and grounhog.
    if( soldierX[i] < (playerX + SOIL_SIZE) && (soldierX[i] + SOIL_SIZE) > playerX && soldierY[i] < (playerY + SOIL_SIZE) && (soldierY[i] + SOIL_SIZE) > playerY ){
      playerHealth--; //lose life.
      // Initial groundhog's position and moving state.
      playerX = PLAYER_INIT_X;
      playerY = PLAYER_INIT_Y;
      playerCol = (int) (playerX / SOIL_SIZE);
      playerRow = (int) (playerY / SOIL_SIZE);
      playerMoveTimer = 0;
      soilHealth[playerCol][playerRow+1] = 15;
      leftState = false;
      rightState = false;
      downState = false;
    }
  }
}

void drawGH(){ 
  
    groundhogDisplay = groundhogIdle;
    // If player is not moving, we have to decide what player has to do next
    if(playerMoveTimer == 0){
      // If the soil under player is empty, player should fall automatically and can't move left or right.
      if((playerRow < SOIL_ROW_COUNT - 1) && (soilHealth[playerCol][playerRow + 1] == 0)){
        playerMoveDirection = DOWN;
        playerMoveTimer = playerMoveDuration;
        leftState = false;
        rightState = false;        
      }

      if(leftState){

        groundhogDisplay = groundhogLeft;

        // Check left boundary
        if(playerCol > 0){
          // Player is under ground and left side soil isn't empty.
          if((playerRow >= 0) && (soilHealth[playerCol - 1][playerRow] > 0)){
            soilHealth[playerCol - 1][playerRow]--;
          }else{
            playerMoveDirection = LEFT;
            playerMoveTimer = playerMoveDuration;
          }
        }

      }else if(rightState){

        groundhogDisplay = groundhogRight;

        // Check right boundary
        if(playerCol < SOIL_COL_COUNT - 1){
          // Player is under ground and right side soil isn't empty.
          if((playerRow >= 0) && (soilHealth[playerCol + 1][playerRow] > 0)){
            soilHealth[playerCol + 1][playerRow]--;
          }else{
            playerMoveDirection = RIGHT;
            playerMoveTimer = playerMoveDuration;
          }
        }

      }else if(downState){

        groundhogDisplay = groundhogDown;

        // Check bottom boundary
        if(playerRow < SOIL_ROW_COUNT - 1){
          // Player can dig even if it's on the ground and down side soil isn't empty.
          if((playerRow >= -1) && (soilHealth[playerCol][playerRow + 1] > 0)){
            soilHealth[playerCol][playerRow + 1]--;
          }else{
            playerMoveDirection = DOWN;
            playerMoveTimer = playerMoveDuration;
          }
        }
      }
    }
    // Make groundhog move smoothly
    if(playerMoveTimer > 0){
      playerMoveTimer --;
      switch(playerMoveDirection){

        case LEFT:
        groundhogDisplay = groundhogLeft;
        if(playerMoveTimer == 0){
          playerCol--;
          playerX = SOIL_SIZE * playerCol;
        }else{
          playerX = (float(playerMoveTimer) / playerMoveDuration + playerCol - 1) * SOIL_SIZE;
        }
        break;

        case RIGHT:
        groundhogDisplay = groundhogRight;
        if(playerMoveTimer == 0){
          playerCol++;
          playerX = SOIL_SIZE * playerCol;
        }else{
          playerX = (1f - float(playerMoveTimer) / playerMoveDuration + playerCol) * SOIL_SIZE;
        }
        break;

        case DOWN:
        groundhogDisplay = groundhogDown;
        if(playerMoveTimer == 0){
          playerRow++;
          playerY = SOIL_SIZE * playerRow;
        }else{
          playerY = (1f - float(playerMoveTimer) / playerMoveDuration + playerRow) * SOIL_SIZE;
        }
        break;
      }
    }
    image(groundhogDisplay, playerX, playerY);
}

void keyPressed(){
	if(key==CODED){
		switch(keyCode){
			case LEFT:
			leftState = true;
			break;
			case RIGHT:
			rightState = true;
			break;
			case DOWN:
			downState = true;
			break;
		}
	}else{
		if(key=='b'){
			// Press B to toggle demo mode
			demoMode = !demoMode;
		}
	}
}

void keyReleased(){
	if(key==CODED){
		switch(keyCode){
			case LEFT:
			leftState = false;
			break;
			case RIGHT:
			rightState = false;
			break;
			case DOWN:
			downState = false;
			break;
		}
	}
}
