`ifndef PARAMS_VH
`define PARAMS_VH
enum {NOTHING, WALK_FORWARD, WALK_BACKWARD, KICK, GRAB, BLOCK, WIN, LOSE} p_states;
parameter STATE_DEPTH = $clog2(p_states.num); // depth of player state ports
parameter INPUT_DEPTH = 5; // depth of input ports (5 buttons)
parameter SCREEN_WIDTH = 640; // width of screen
parameter SCREEN_HEIGHT = 480; // height of screen
parameter POSITION_DEPTH = $clog2(SCREEN_WIDTH); // bit depth required to address pixels width-wise
`endif