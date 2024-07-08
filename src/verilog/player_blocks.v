`include "params.vh"

module player_next_state_calc(
	input sys_clk,
	input frame_clk,
	input [INPUT_DEPTH-1:0] player_buttons,
	input [STATE_DEPTH-1:0] player_state,
	input [SPRITE_INDEX_DEPTH-1:0] player_sprite,
	input opponent_attack_connected,
	input player_attack_connected,
	output [STATE_DEPTH-1:0] next_state,
	output [SPRITE_INDEX_DEPTH-1:0] sprite_index
);

	reg [STATE_DEPTH-1:0] reg_next_state;
	reg new_frame;
	
	wire [STATE_DEPTH-1:0] state_from_buttons;
	wire player_actionable;
	wire new_action;

	
	// (IF AN ACTION HAS JUST FINISHED THEN THEY ARE ACTIONABLE THE NEXT FRAME)
	
	// LOGIC:
	// Did player win? If yes: win
	// Else: Did player lose? If yes: lose
	// Else: Is player in an actionable state? If no, return current state
	// Else: Action priority: KICK > BLOCK > GRAB > BACKWARDS > FORWARDS
	// TODO: NEED TO ADD LOGIC TO ONLY UPDATE ONCE PER FRAME CLOCK
	// TODO: NEED TO ADD BASIC PIPELINING - ACTION_TIMER NEEDS TO WAIT FOR REG_NEXT_STATE TO BE PROPERLY SET IN ORDER TO COMPUTE THE CORRECT ACTION TIMER
	// WILL LIKELY NEED TO ADD PIPELINING TO AVOID TIMING ISSUES
	
	gen_state_buttons g1 (
		.buttons(player_buttons),
		.state(player_state),
		.next_state(state_from_buttons)
	);
	
	gen_player_actionable g2 (
		.state(player_state),
		.action_timer(player_sprite),
		.actionable(player_actionable)
	);
	
	gen_action_timer g3(
		.state(player_state),
		.action_timer(player_state),
		.next_state(reg_next_state),
		.clk(sys_clk),
		.next_action_timer(sprite_index)
	);
	
	always@(posedge sys_clk) begin
		if(player_attack_connected == 1'b1)
			reg_next_state <= WIN;
		else if(opponent_attack_connected == 1'b1)
			reg_next_state <= LOSE;
		else if(player_actionable == 1'b1) begin
			reg_next_state <= state_from_buttons;
		end else begin
			reg_next_state <= player_state;
		end	
	end
	
/*	always@(posedge clk, negedge clk) begin
		if(clk==1'b0) begin
			reg_next_state <= NOTHING;
		end
		else begin
			if(player_attack_connected == 1'b1)
				reg_next_state <= WIN;
			else if(opponent_attack_connected == 1'b1)
				reg_next_state <= LOSE;
			else if(player_actionable == 1'b1) begin
				reg_next_state <= state_from_buttons;
			end else begin
				reg_next_state <= player_state;
			end
		end
	end*/
	assign next_state = reg_next_state;
	

endmodule

module gen_state_buttons(
	input [INPUT_DEPTH-1:0] buttons,
	input [STATE_DEPTH-1:0] state,
	output [STATE_DEPTH-1:0] next_state
);
	reg [STATE_DEPTH-1:0] reg_button_state;
	
	assign next_state = reg_button_state;
	
	always@(*) begin
		if(buttons[K_BUTTON] == 1'b1)
			reg_button_state <= KICK;
		else if(buttons[B_BUTTON] == 1'b1)
			reg_button_state <= BLOCK;
		else if(buttons[G_BUTTON] == 1'b1)
			reg_button_state <= GRAB;
		else if(buttons[WB_BUTTON] == 1'b1)
			reg_button_state <= WALK_BACKWARD;
		else if(buttons[WF_BUTTON] == 1'b1)
			reg_button_state <= WALK_FORWARD;
		else
			reg_button_state <= NOTHING;
	end
endmodule

module gen_player_actionable(
	input [STATE_DEPTH-1:0] state,
	input [SPRITE_INDEX_DEPTH-1:0] action_timer,
	output actionable
);
	assign actionable = reg_actionable;
	
	reg reg_actionable;
	
	always@(*) begin
		case(state)
			NOTHING, WALK_FORWARD, WALK_BACKWARD, BLOCK: reg_actionable <= 1'b1;
			KICK: reg_actionable <= (action_timer >= KICK_FRAMES-1 ? 1'b1 : 1'b0);
			GRAB: reg_actionable <= (action_timer >= GRAB_FRAMES-1 ? 1'b1 : 1'b0);
			default: reg_actionable <= 1'b0;
		endcase
	end
endmodule

module gen_action_timer(
	input [STATE_DEPTH-1:0] state,
	input [STATE_DEPTH-1:0] next_state,
	input [SPRITE_INDEX_DEPTH-1:0] action_timer,
	input clk,
	output [SPRITE_INDEX_DEPTH-1:0] next_action_timer
);
	reg [SPRITE_INDEX_DEPTH-1:0] curr_action_end_frame;
	reg [SPRITE_INDEX_DEPTH-1:0] next_action_timer_reg;
	
	always@(posedge clk) begin
		case(state)
			KICK: curr_action_end_frame <= KICK_FRAMES;
			GRAB: curr_action_end_frame <= GRAB_FRAMES;
			WALK_FORWARD: curr_action_end_frame <= F_WALK_FRAMES;
			WALK_BACKWARD: curr_action_end_frame <= B_WALK_FRAMES;
			default: curr_action_end_frame <= 1;
		endcase
		next_action_timer_reg <= (state == next_state) ? ( (action_timer >= curr_action_end_frame-1) ? 0 : action_timer+1) : 0;
	end
	
	assign next_action_timer = next_action_timer_reg;
endmodule