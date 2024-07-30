`include "params.vh"

module player_next_state_calc(
	input sys_clk,
	input frame_clk,
	input [INPUT_DEPTH-1:0] player_buttons,
	input [STATE_DEPTH-1:0] player_state,
	input [SPRITE_INDEX_DEPTH-1:0] player_sprite,
	input [POSITION_DEPTH-1:0] player_position,
	input [POSITION_DEPTH-1:0] other_player_position,
	input player_num,
	input opponent_attack_connected,
	input player_attack_connected,
	input reset,
	output [STATE_DEPTH-1:0] next_state,
	output [SPRITE_INDEX_DEPTH-1:0] sprite_index,
	output [POSITION_DEPTH-1:0] next_position,
	output done_gen
);

	parameter CYCLES_TO_FINISH = 4;

	reg [STATE_DEPTH-1:0] reg_next_state;
	reg [SPRITE_INDEX_DEPTH-1:0] reg_sprite_index;
	reg [POSITION_DEPTH-1:0] reg_next_position;
	
	reg [INPUT_DEPTH-1:0] buffered_inputs;
	reg [2:0] clk_count;
	
	wire [STATE_DEPTH-1:0] state_from_buttons;
	wire player_actionable;
	wire [SPRITE_INDEX_DEPTH-1:0] wire_sprite_index;
	wire [POSITION_DEPTH-1:0] wire_next_position;
	

	
	// (IF AN ACTION HAS JUST FINISHED THEN THEY ARE ACTIONABLE THE NEXT FRAME)
	
	// LOGIC:
	// Did player win? If yes: win
	// Else: Did player lose? If yes: lose
	// Else: Is player in an actionable state? If no, return current state
	// Else: Action priority: KICK > BLOCK > GRAB > BACKWARDS > FORWARDS
	// TODO: NEED TO ADD LOGIC TO ONLY UPDATE ONCE PER FRAME CLOCK
	// TODO: NEED TO ADD BASIC PIPELINING - ACTION_TIMER NEEDS TO WAIT FOR REG_NEXT_STATE TO BE PROPERLY SET IN ORDER TO COMPUTE THE CORRECT ACTION TIMER
	// WILL LIKELY NEED TO ADD PIPELINING TO AVOID TIMING ISSUES
	// ACTIVE-LOW ASYNC RESET
	
	gen_state_buttons g1 (
		.buttons(buffered_inputs),
		.next_state(state_from_buttons)
	);
	
	gen_player_actionable g2 (
		.state(player_state),
		.action_timer(player_sprite),
		.actionable(player_actionable)
	);
	
	gen_action_timer g3(
		.state(player_state),
      	.action_timer(player_sprite),
		.clk(sys_clk),
		.next_action_timer(wire_sprite_index),
		.reset(reset)
	);
	
	gen_player_position g4(
		.state(player_state),
		.current_position(player_position),
		.other_position(other_player_position),
		.player_num(player_num),
		.clk(sys_clk),
		.reset(reset),
		.next_position(wire_next_position)
	); 
	
	always@(posedge sys_clk, negedge reset) begin
		if(reset==1'b0) begin
			reg_next_state <= 0;
			reg_next_position <= 0;
			reg_sprite_index <= 0;
		end else begin
			if(player_attack_connected == 1'b1)
				reg_next_state <= WIN;
			else if(opponent_attack_connected == 1'b1)
				reg_next_state <= LOSE;
			else if(player_actionable == 1'b1) begin
				reg_next_state <= state_from_buttons;
			end else begin
				reg_next_state <= player_state;
			end	
			reg_sprite_index <= wire_sprite_index;
			reg_next_position <= wire_next_position;
			//clk_count <= clk_count == CYCLES_TO_FINISH ? clk_count : clk_count + 1;
		end
	end
	
	always@(posedge frame_clk, negedge reset) begin
		if(reset==1'b0) begin
			buffered_inputs <= 0;
		end else begin
			buffered_inputs <= player_buttons;
		end
	end
  	
  	wire sampled_frame_clk;
 	high_detector h1(.clk(sys_clk), .d(frame_clk), .q(sampled_frame_clk));
  	always@(posedge sys_clk, negedge sampled_frame_clk) begin
      	if(sampled_frame_clk == 1'b0) begin
        	clk_count <= 0;
        end else begin
    		clk_count <= clk_count == CYCLES_TO_FINISH ? clk_count : clk_count + 1;
        end
  	end
  
	assign next_state = reg_next_state;
	assign sprite_index = reg_sprite_index;
	assign next_position = reg_next_position;
	assign done_gen = clk_count == CYCLES_TO_FINISH;

endmodule

module gen_state_buttons(
	input [INPUT_DEPTH-1:0] buttons,
	output [STATE_DEPTH-1:0] next_state
);
	reg [STATE_DEPTH-1:0] reg_button_state;
	
	assign next_state = reg_button_state;
	
	always@(*) begin
		if(buttons[K_BUTTON] == 1'b1)
			reg_button_state = KICK;
		else if(buttons[B_BUTTON] == 1'b1)
			reg_button_state = BLOCK;
		else if(buttons[G_BUTTON] == 1'b1)
			reg_button_state = GRAB;
		else if(buttons[WB_BUTTON] == 1'b1)
			reg_button_state = WALK_BACKWARD;
		else if(buttons[WF_BUTTON] == 1'b1)
			reg_button_state = WALK_FORWARD;
		else
			reg_button_state = NOTHING;
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
			NOTHING, WALK_FORWARD, WALK_BACKWARD, BLOCK: reg_actionable = 1'b1;
			KICK: reg_actionable = (action_timer >= KICK_FRAMES-1 ? 1'b1 : 1'b0);
			GRAB: reg_actionable = (action_timer >= GRAB_FRAMES-1 ? 1'b1 : 1'b0);
			default: reg_actionable = 1'b0;
		endcase
	end
endmodule

module gen_action_timer(
	input [STATE_DEPTH-1:0] state,
	input [SPRITE_INDEX_DEPTH-1:0] action_timer,
	input clk,
  	input reset,
	output [SPRITE_INDEX_DEPTH-1:0] next_action_timer
);
	reg [SPRITE_INDEX_DEPTH-1:0] curr_action_end_frame;
	reg [SPRITE_INDEX_DEPTH-1:0] next_action_timer_reg;
	
	always@(posedge clk, negedge reset) begin
		if(reset == 1'b0) begin
				curr_action_end_frame <= 1'b0;
				next_action_timer_reg <= NOTHING;
		end else begin 
			case(state)
				KICK: curr_action_end_frame <= KICK_FRAMES;
				GRAB: curr_action_end_frame <= GRAB_FRAMES;
				WALK_FORWARD: curr_action_end_frame <= F_WALK_FRAMES;
				WALK_BACKWARD: curr_action_end_frame <= B_WALK_FRAMES;
				default: curr_action_end_frame <= 1;
			endcase
		//next_action_timer_reg <= (state == next_state) ? ( (action_timer >= curr_action_end_frame-1) ? 0 : action_timer+1) : 0;
		next_action_timer_reg <= (action_timer >= curr_action_end_frame-1) ? 0 : action_timer + 1;
		end
	end
	
	assign next_action_timer = next_action_timer_reg;
endmodule

module gen_player_position(
	input [STATE_DEPTH-1:0] state,
	input [POSITION_DEPTH-1:0] current_position,
	input [POSITION_DEPTH-1:0] other_position,
	input player_num, // set to 0 for player 1, 1 for player 2
	input clk,
	input reset,
	output [POSITION_DEPTH-1:0] next_position
);
	wire [3:0] walk_distance;
  	wire invert_add;
	reg [POSITION_DEPTH-1:0] next_position_no_collision; 
	reg [POSITION_DEPTH-1:0] next_position_reg;
  	assign invert_add = (state==WALK_BACKWARD & ~player_num) | (state==WALK_FORWARD & player_num);
	assign walk_distance = (state == WALK_FORWARD) ? F_WALK_SPEED : (state == WALK_BACKWARD ? B_WALK_SPEED : 0);
	always@(posedge clk, negedge reset) begin
		if(reset == 1'b0) begin
			next_position_no_collision <= 0;
		end else begin
			next_position_no_collision <= invert_add ? current_position - walk_distance : current_position + walk_distance;
		end
	end
	always@(*) begin
		if(player_num) begin
			reg_next_position = (next_position_no_collision < other_position + PLAYER_WIDTH) ? other_position + PLAYER_WIDTH : next_position_no_collision;
		end else begin
			reg_next_position = (next_position_no_collision+PLAYER_WIDTH > other_position) ? other_position-PLAYER_WIDTH : next_position_no_collision;
		end
	end
	
	assign next_position = reg_next_position;
endmodule

module high_detector(
	input clk,
  	input d,
  	output q
);
  	reg q_reg;
  	always@(posedge clk) begin
    	q_reg <= d;
  	end
  	assign q = d & ~q_reg;
endmodule