`ifndef PARAMS_VH
`define PARAMS_VH
enum {NOTHING, WALK_FORWARD, WALK_BACKWARD, KICK, GRAB, BLOCK, WIN, LOSE} p_states;
enum {WF_BUTTON, WB_BUTTON, G_BUTTON, B_BUTTON, K_BUTTON} button_index;
parameter STATE_DEPTH = $clog2(p_states.num); // depth of player state ports
parameter INPUT_DEPTH = 5; // depth of input ports (5 buttons)
parameter SCREEN_WIDTH = 640; // width of screen
parameter SCREEN_HEIGHT = 480; // height of screen
parameter POSITION_DEPTH = $clog2(SCREEN_WIDTH); // bit depth required to address pixels width-wise
parameter SPRITE_INDEX_DEPTH = 6;


// Game logic parameters
parameter F_WALK_SPEED = 5;
parameter B_WALK_SPEED = 4;
parameter P1_START = 50;
parameter P2_START = SCREEN_WIDTH - P1_START;
parameter PLAYER_WIDTH = 40;
parameter KICK_STARTUP = 15;
parameter KICK_ENDLAG = 20;
parameter GRAB_STARTUP = 5;
parameter GRAB_ENDLAG = 30;
parameter GRAB_FRAMES = GRAB_ENDLAG + GRAB_STARTUP;
parameter KICK_FRAMES = KICK_ENDLAG + KICK_STARTUP;
parameter KICK_RANGE = 80;
parameter GRAB_RANGE = 53; //$ceil(2*KICK_RANGE/3);
parameter KICK_PULLBACK = 15;
parameter GRAB_PULLBACK = 10;
parameter F_WALK_FRAMES = 10;
parameter B_WALK_FRAMES = 12;
`endif