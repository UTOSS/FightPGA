//`include "params.vh"

module player_next_state_calc(
	input sys_clk,
	input frame_clk,
	input [INPUT_DEPTH-1:0] player_buttons,
	input [POSITION_DEPTH-1:0] other_player_position,
	input player_num,
	input opponent_attack_connected,
	input player_attack_connected,
	input reset,
	output [STATE_DEPTH-1:0] state,
	output [SPRITE_INDEX_DEPTH-1:0] index,
	output [POSITION_DEPTH-1:0] position,
	output done_gen
);

	parameter CYCLES_TO_FINISH = 4;
	// CURRENT STATES
	reg [POSITION_DEPTH-1:0] player_position;
	reg [STATE_DEPTH-1:0] player_state;
	reg [SPRITE_INDEX_DEPTH-1:0] player_sprite;
	
	// NEXT STATES
	wire [POSITION_DEPTH-1:0] next_position;
	wire [STATE_DEPTH-1:0] next_state;
	wire [SPRITE_INDEX_DEPTH-1:0] next_sprite;
	
	//INTERMEDIATE VALUES
	wire player_actionable;
	wire [STATE_DEPTH-1:0] state_from_buttons;
	reg [INPUT_DEPTH-1:0] buffered_inputs;
	reg frame_complete;
	wire sampled_frame_clk;
	reg[2:0] clk_count;
	
	always@(posedge sys_clk, negedge reset) begin
		if(reset==1'b0) begin
			player_position <= player_num ? P2_START : P1_START;
			player_sprite <= 0;
			player_state <= NOTHING;
		end else begin
			if(sampled_frame_clk) begin
				player_position <= next_position;
				player_sprite <= next_sprite;
				player_state <= next_state;
			end
		end
	end
	
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
		.next_action_timer(next_sprite),
		.reset(reset)
	);
	
	gen_player_position g4(
		.state(player_state),
		.current_position(player_position),
		.other_position(other_player_position),
		.player_num(player_num),
		.clk(sys_clk),
		.reset(reset),
		.next_position(next_position)
	);
	
	gen_player_state g5(
		.state(player_state),
		.state_from_inputs(state_from_buttons),
		.player_actionable(player_actionable),
		.got_hit(opponent_attack_connected),
		.attack_connected(player_attack_connected),
		.next_state(next_state)
	);
	
	rising_edge_detector red1(
		.clk(sys_clk),
		.d(frame_clk),
		.q(sampled_frame_clk)
	);
	
  	always@(posedge sys_clk, negedge frame_clk) begin
      	if(frame_clk == 1'b0) begin
        	clk_count <= 0;
        end else begin
    		clk_count <= clk_count == CYCLES_TO_FINISH ? clk_count : clk_count + 1;
        end
  	end
	
	always@(posedge frame_clk) begin
		buffered_inputs <= player_buttons;
	end
	
	assign done_gen = clk_count == CYCLES_TO_FINISH;
	
	assign position = player_position;
	assign index = player_sprite;
	assign state = player_state;

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
				curr_action_end_frame <= 1;
				next_action_timer_reg <= 0;
		end else begin 
			case(state)
				KICK: curr_action_end_frame <= KICK_FRAMES-1;
				GRAB: curr_action_end_frame <= GRAB_FRAMES-1;
				WALK_FORWARD: curr_action_end_frame <= F_WALK_FRAMES-1;
				WALK_BACKWARD: curr_action_end_frame <= B_WALK_FRAMES-1;
				WIN: curr_action_end_frame <= WIN_FRAMES-1;
				LOSE: curr_action_end_frame <= LOSE_FRAMES-1;
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
			next_position_no_collision <= invert_add ? (current_position <= walk_distance ? 0 : current_position - walk_distance) : (current_position + walk_distance > SCREEN_WIDTH - PLAYER_WIDTH ? SCREEN_WIDTH-PLAYER_WIDTH - 1: current_position + walk_distance);
		end
	end
	always@(*) begin
		if(player_num) begin
			next_position_reg = (next_position_no_collision < other_position + PLAYER_WIDTH) ? other_position + PLAYER_WIDTH : next_position_no_collision;
		end else begin
			next_position_reg = (next_position_no_collision + PLAYER_WIDTH > other_position) ? other_position - PLAYER_WIDTH: next_position_no_collision;
		end
	end
	
	assign next_position = next_position_reg;
endmodule

module gen_player_state(
	input [STATE_DEPTH-1:0] state,
	input [STATE_DEPTH-1:0] state_from_inputs,
	input player_actionable,
	input got_hit,
	input attack_connected,
	output [STATE_DEPTH-1:0] next_state
);

	assign next_state = got_hit ? LOSE : (attack_connected ? WIN : (player_actionable ? state_from_inputs : state));

endmodule

module rising_edge_detector(
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