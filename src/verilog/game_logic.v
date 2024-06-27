`include "params.vh"

module game_logic(
	input [INPUT_DEPTH-1:0] p1_inputs,
	input [INPUT_DEPTH-1:0] p2_inputs,
	input pixel_clk,
	input sys_clk,
	input rst,
	output [STATE_DEPTH-1:0] p1_state,
	output [STATE_DEPTH-1:0] p2_state,
	output [POSITION_DEPTH-1:0] p1_position,
	output [POSITION_DEPTH-1:0] p2_position,
	output [SPRITE_INDEX_DEPTH-1:0] p1_sprite,
	output [SPRITE_INDEX_DEPTH-1:0] p2_sprite
);

endmodule