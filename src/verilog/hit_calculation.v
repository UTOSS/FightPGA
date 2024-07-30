`include "params.vh"

module hit_calculator(
	input [STATE_DEPTH-1:0] p1_state,
	input [STATE_DEPTH-1:0] p2_state,
	input [POSITION_DEPTH-1:0] p1_position,
	input [POSITION_DEPTH-1:0] p2_position,
	input [SPRITE_INDEX_DEPTH-1:0] p1_frame,
	input [SPRITE_INDEX_DEPTH-1:0] p2_frame,
	input clk,
	output p1_connects,
	output p2_connects
);

	wire p1_kicking;
	wire p2_kicking;
	wire p1_grabbing;
	wire p2_grabbing;
	wire p1_kick_active;
	wire p1_grab_active;
	wire p2_kick_active;
	wire p2_grab_active;
	
	assign p1_kicking = p1_state == KICK;
	assign p2_kicking = p2_state == KICK;
	assign p1_grabbing = p1_state == GRAB;
	assign p2_grabbing = p2_state == GRAB;
	assign p1_kick_active = p1_sprite == KICK_STARTUP-1;
	assign p1_grab_active = p1_sprite == GRAB_STARTUP-1;
	assign p2_kick_active = p2_sprite == KICK_STARTUP-1;
	assign p2_grab_active = p2_sprite == GRAB_STARTUP-1;
	
	reg [POSITION_DEPTH-1:0] p1_effective_hurtbox;
	reg [POSITION_DEPTH-1:0] p2_effective_hurtbox;
	reg [POSITION_DEPTH-1:0] p1_hurtbox_shift;
	reg [POSITION_DEPTH-1:0] p2_hurtbox_shift;
	reg p1_kick_connected;
	reg p1_grab_connected;
	reg p2_kick_connected;
	reg p2_grab_connected;
	
	//cycle 1: calculate hurtbox shift
	//cycle 2: calculate effective hurtbox
	//cycle 3: kick connect or grab connect
	always@(posedge clk, negedge reset) begin
		if(reset == 1'b0) begin
			p1_hurtbox_shift <= 0;
			p2_hurtbox_shift <= 0;

			p1_effective_hurtbox <= 0;
			p2_effective_hurtbox <= 0;
			
			p1_kick_connected <= 0;
			p1_grab_connected <= 0;
			p2_kick_connected <= 0;
			p2_grab_connected <= 0;
		end else begin
			p1_hurtbox_shift <= p1_kicking ? KICK_EXTENSION : (p1_grabbing ? GRAB_EXTENSION : 0);
			p2_hurtbox_shift <= p2_kicking ? KICK_EXTENSION : (p2_grabbing ? GRAB_EXTENSION : 0);

			p1_effective_hurtbox <= p1_position + PLAYER_WIDTH + p1_hurtbox_shift;
			p2_effective_hurtbox <= p2_position - p2_hurtbox_shift;
			
			p1_kick_connected <= p1_kick_active & (p1_position + KICK_RANGE >= p2_effective_hurtbox);
			p1_grab_connected <= p1_grab_active & (p1_position + GRAB_RANGE >= p2_effective_hurtbox);
			p2_kick_connected <= p2_kick_active & (p2_position - KICK_RANGE <= p1_effective_hurtbox);
			p2_grab_connected <= p2_grab_active & (p2_position - GRAB_RANGE <= p1_effective_hurtbox);
		end
	end
	
	assign p1_attack_connected = p1_kick_connected | p1_grab_connected;
	assign p2_attack_connected = p2_kick_connected | p2_grab_connected;
	
endmodule