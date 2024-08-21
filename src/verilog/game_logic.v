//`include "params.vh"

module game_logic(
	input [INPUT_DEPTH-1:0] p1_inputs,
	input [INPUT_DEPTH-1:0] p2_inputs,
	input frame_clk,
	input sys_clk,
	input rst,
	output [STATE_DEPTH-1:0] p1_state,
	output [STATE_DEPTH-1:0] p2_state,
	output [POSITION_DEPTH-1:0] p1_position,
	output [POSITION_DEPTH-1:0] p2_position,
	output [SPRITE_INDEX_DEPTH-1:0] p1_sprite,
	output [SPRITE_INDEX_DEPTH-1:0] p2_sprite,
	output done_gen
);
	// Player registers:
	// State, position, activeframe
	wire [STATE_DEPTH-1:0] wire_p1_state;
	wire [STATE_DEPTH-1:0] wire_p2_state;
	wire [POSITION_DEPTH-1:0] wire_p1_position;
	wire [POSITION_DEPTH-1:0] wire_p2_position;
	wire [SPRITE_INDEX_DEPTH-1:0] wire_p1_sprite;
	wire [SPRITE_INDEX_DEPTH-1:0] wire_p2_sprite;
	wire p1_done;
	wire p2_done;
	wire p1_attack_connected;
	wire p2_attack_connected;
	
	player_next_state_calc p1(
		.sys_clk(sys_clk),
		.frame_clk(frame_clk),
		.reset(rst),
		.player_buttons(p1_inputs),
		.other_player_position(wire_p2_position),
		.player_num(1'b0),
		.opponent_attack_connected(p2_attack_connected),
		.player_attack_connected(p1_attack_connected),
		.state(wire_p1_state),
		.index(wire_p1_sprite),
		.position(wire_p1_position),
		.done_gen(p1_done)
	);
	
	player_next_state_calc p2(
		.sys_clk(sys_clk),
		.frame_clk(frame_clk),
		.reset(rst),
		.player_buttons(p2_inputs),
		.other_player_position(wire_p1_position),
		.player_num(1'b1),
		.opponent_attack_connected(p1_attack_connected),
		.player_attack_connected(p2_attack_connected),
		.state(wire_p2_state),
		.index(wire_p2_sprite),
		.position(wire_p2_position),
		.done_gen(p2_done)
	);
	
	hit_calculator h(
		.p1_state(wire_p1_state),
		.p2_state(wire_p2_state),
		.p1_position(wire_p1_position),
		.p2_position(wire_p2_position),
		.p1_frame(wire_p1_sprite),
		.p2_frame(wire_p2_sprite),
		.clk(sys_clk),
		.reset(rst),
		.p1_connects(p1_attack_connected),
		.p2_connects(p2_attack_connected)
	);
	
	assign p1_state = wire_p1_state;
	assign p2_state = wire_p2_state;
	assign p1_position = wire_p1_position;
	assign p2_position = wire_p2_position;
	assign p1_sprite = wire_p1_sprite;
	assign p2_sprite = wire_p2_sprite;
	assign done_gen = p1_done & p2_done;

endmodule