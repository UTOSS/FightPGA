//enum {NOTHING, WALK_FORWARD, WALK_BACKWARD, KICK, GRAB, BLOCK, WIN, LOSE} p_states;
//enum {WF_BUTTON, WB_BUTTON, G_BUTTON, B_BUTTON, K_BUTTON} button_index;
`ifndef PARAMS_VH
`define PARAMS_VH

parameter NOTHING= 0;
parameter WALK_FORWARD= 1;
parameter WALK_BACKWARD= 2;
parameter KICK= 3;
parameter GRAB= 4;
parameter BLOCK= 5;
parameter WIN= 6;
parameter LOSE= 7;
parameter WF_BUTTON= 0;
parameter WB_BUTTON= 1;
parameter G_BUTTON= 2;
parameter B_BUTTON= 3;
parameter K_BUTTON= 4;
parameter FLOOR_HEIGHT = 40;

// DEPTH PARAMETERS
parameter STATE_DEPTH = 3;//$clog2(p_states.num); // depth of player state ports
parameter INPUT_DEPTH = 5; // depth of input ports (5 buttons)
parameter SCREEN_WIDTH = 640; // width of screen
parameter SCREEN_HEIGHT = 480; // height of screen
parameter POSITION_DEPTH = 10;//$clog2(SCREEN_WIDTH); // bit depth required to address pixels width-wise
parameter SPRITE_INDEX_DEPTH = 6;


// Game logic parameters
parameter F_WALK_SPEED = 5;
parameter B_WALK_SPEED = 4;
parameter P1_START = 50;
parameter P2_START = SCREEN_WIDTH - P1_START - PLAYER_WIDTH;
parameter PLAYER_WIDTH = 40;
parameter KICK_STARTUP = 15;
parameter KICK_ENDLAG = 20;
parameter GRAB_STARTUP = 5;
parameter GRAB_ENDLAG = 30;
parameter GRAB_FRAMES = GRAB_ENDLAG + GRAB_STARTUP;
parameter KICK_FRAMES = KICK_ENDLAG + KICK_STARTUP;
parameter KICK_RANGE = 80;
parameter GRAB_RANGE = 53; //$ceil(2*KICK_RANGE/3);
parameter KICK_EXTENSION = 60;
parameter GRAB_EXTENSION = 20;
parameter KICK_PULLBACK = 15;
parameter GRAB_PULLBACK = 10;
parameter F_WALK_FRAMES = 10;
parameter B_WALK_FRAMES = 12;

// VGA PARAMETERS
parameter H_FRONT_PORCH = 16;
parameter H_BACK_PORCH = 48;
parameter H_SYNC_WAIT = 96;
parameter V_FRONT_PORCH = 10;
parameter V_BACK_PORCH = 33;
parameter V_SYNC_WAIT = 2;
parameter LINE_WAIT = SCREEN_WIDTH + H_FRONT_PORCH + H_BACK_PORCH + H_SYNC_WAIT;
parameter V_LINES_WAIT = SCREEN_HEIGHT + V_FRONT_PORCH + V_BACK_PORCH + V_SYNC_WAIT;	
parameter FRAME_CYCLES = (LINE_WAIT * V_LINES_WAIT);

//COLOR
parameter COLOR_DEPTH = 2;
parameter COLOR_RED_CODE = 2;
parameter COLOR_BLUE_CODE = 3;
parameter COLOR_WHITE_CODE = 1;
parameter COLOR_BLACK_CODE = 0;
parameter COLOR_RED = 24'hff0000;
parameter COLOR_BLUE = 24'h0000ff;
parameter COLOR_WHITE = 24'hffffff;
parameter COLOR_BLACK = 24'h000000;

`endif