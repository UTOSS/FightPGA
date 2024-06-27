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
	reg frame_calculated = 1'b0;
	
	wire [STATE_DEPTH-1:0] state_from_buttons; // TODO: WRITE A PLAYER BUTTON PROCESSING BLOCK THAT DETERMINES THE STATE IF THE PLAYER IS ACTIONABLE AND A BUTTON IS PRESSED
	wire player_actionable; // TODO: WRITE A PLAYER_ACTIONABLE PROCESSING BLOCK THAT DETERMINES IF THE PLAYER IS CURRENTLY ACTIONABLE BASED ON THEIR CURRENT STATE AND THEIR ANIMATION FRAME
	// (IF AN ACTION HAS JUST FINISHED THEN THEY ARE ACTIONABLE THE NEXT FRAME)
	
	// LOGIC:
	// Did player win? If yes: win
	// Else: Did player lose? If yes: lose
	// Else: Is player in an actionable state? If no, return current state
	// Else: Action priority: KICK > BLOCK > GRAB > BACKWARDS > FORWARDS
	
	always@(posedge clk, negedge clk) begin
		if(clk==1'b0) begin
			reg_next_state <= NOTHING;
			frame_calculated <= 1'b0;
		end
		else begin
			if(player_attack_connected == 1'b1)
				reg_next_state <= WIN;
			else if(opponent_attack_connected == 1'b1)
				reg_next_state <= LOSE;
			else if(player_actionable == 1'b1)
				reg_next_state <= state_from_buttons;
			else begin
				reg_next_state <= player_state;
				// UPDATE PLAYER SPRITE INDEX
			end
		end
	end

endmodule