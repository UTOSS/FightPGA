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

	// Player registers:
	// State, position, activeframe
	reg [STATE_DEPTH-1:0] reg_p1_state;
	reg [STATE_DEPTH-1:0] reg_p2_state;
	reg [POSITION_DEPTH-1:0] reg_p1_position;
	reg [POSITION_DEPTH-1:0] reg_p2_position;
	reg [SPRITE_INDEX_DEPTH-1:0] reg_p1_sprite;
	reg [SPRITE_INDEX_DEPTH-1:0] reg_p2_sprite;
	
	assign p1_state = reg_p1_state;
	assign p2_state = reg_p2_state;
	assign p1_position = reg_p1_position;
	assign p2_position = reg_p2_position;
	assign p1_sprite = reg_p1_sprite;
	assign p2_sprite = reg_p2_sprite;
	
	

endmodule