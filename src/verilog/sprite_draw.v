`include "params.vh"

module sprite_draw(
	input reset,
	input clk,
	input [2:0] sprite_select,
	input active,
	input [9:0] hcount,
	input [9:0] vcount,
	input [9:0] xcoord,
	input [9:0] ycoord,
	input [9:0] sprite_position_p1,
	input [9:0] sprite_position_p2,
	input [STATE_DEPTH-1:0] state_p1,
	input [STATE_DEPTH-1:0] state_p2,
	input [SPRITE_INDEX_DEPTH-1:0] action_timer_p1,
	input [SPRITE_INDEX_DEPTH-1:0] action_timer_p2,
	output [7:0] vga_r,
	output [7:0] vga_g,
	output [7:0] vga_b
);

	wire [COLOR_DEPTH-1:0] p1_color, p2_color, color_vga;
	wire p1_active, p2_active;
	wire [COLOR_DEPTH-1:0] default_color;
	wire choose_default;
	wire [SPRITE_ADDR_DEPTH-1:0] p1_offset, p2_offset;
	
	sprite_offset_gen sog1(
		.state(state_p1),
		.index(action_timer_p1),
		.offset(p1_offset)
	);
	
	sprite_offset_gen sog2(
		.state(state_p2),
		.index(action_timer_p2),
		.offset(p2_offset)
	);
	
	sprite_renderer #(
		.filename("ryu.hex")
	) sp1 (
		.clk(clk),
		.reset(reset),
		.hcount(hcount),
		.vcount(vcount),
		.xcoord(xcoord),
		.ycoord(ycoord),
		.active(active),
		.sprite_position(sprite_position_p1),
		.addr_offset(p1_offset),
		.color_out(p1_color),
		.player_active(p1_active)
	);

	
	sprite_renderer #(
		.filename("ken.hex")
	) sp2 (
		.clk(clk),
		.reset(reset),
		.hcount(hcount),
		.vcount(vcount),
		.xcoord(xcoord),
		.ycoord(ycoord),
		.active(active),
		.sprite_position(sprite_position_p2),
		.addr_offset(p2_offset),
		.color_out(p2_color),
		.player_active(p2_active)
	);
	
	
	assign choose_default = ~(p1_active | p2_active);
	assign default_color = (ycoord >= SCREEN_HEIGHT - FLOOR_HEIGHT) ? COLOR_BLACK_CODE : COLOR_WHITE_CODE;
	assign color_vga = choose_default ? default_color : ((p1_color != COLOR_BLUE_CODE) & p1_active) ? p1_color: (((p2_color != COLOR_RED_CODE) & p2_active) ? p2_color : COLOR_WHITE_CODE);
	
	color_select c0(
		.pix(color_vga),
		.r(vga_r),
		.g(vga_g),
		.b(vga_b)
	);
endmodule

module color_select(
	input [COLOR_DEPTH-1:0] pix,
	output [7:0] r,
	output [7:0] g,
	output [7:0] b
);

	reg [23:0] rgb;
	always@(*) begin
		case(pix)
			COLOR_BLACK_CODE: rgb <= COLOR_BLACK;
			COLOR_RED_CODE: rgb <= COLOR_RED;
			COLOR_BLUE_CODE: rgb <= COLOR_BLUE;
			COLOR_WHITE_CODE: rgb <= COLOR_WHITE;
		endcase
	end
	
	assign r = rgb[23:16];
	assign g = rgb[15:8];
	assign b = rgb[7:0];
endmodule

module sprite_offset_gen(
	input [STATE_DEPTH-1:0] state,
	input [SPRITE_INDEX_DEPTH-1:0] index,
	output [SPRITE_ADDR_DEPTH-1:0] offset
);

	reg [SPRITE_ADDR_DEPTH-1:0] offset_reg;
	always@(*) begin
		case(state)
			NOTHING: offset_reg <= BASE_OFFSET;
			WALK_FORWARD: begin
				if(index <= F_WALK_FRAME0)
					offset_reg <= BASE_OFFSET;
				else if(index <= F_WALK_FRAME1)
					offset_reg <= WF0_OFFSET;
				else
					offset_reg <= WF1_OFFSET;
			end
			WALK_BACKWARD: begin
				if(index <= B_WALK_FRAME0)
					offset_reg <= BASE_OFFSET;
				else if(index <= B_WALK_FRAME1)
					offset_reg <= WB0_OFFSET;
				else
					offset_reg <= WB1_OFFSET;
			end
			GRAB: begin
				if(index <= GRAB_STARTUP)
					offset_reg <= GRAB_WHIFF_OFFSET;
				else if(index <= GRAB_PULLBACK_FRAME)
					offset_reg <= GRAB_ACTIVE_OFFSET;
				else
					offset_reg <= GRAB_WHIFF_OFFSET;
			end
			KICK: begin
				if(index <= KICK_STARTUP)
					offset_reg <= KICK_WHIFF_OFFSET;
				else if(index <= KICK_PULLBACK_FRAME)
					offset_reg <= KICK_ACTIVE_OFFSET;
				else
					offset_reg <= KICK_WHIFF_OFFSET;
			end
			WIN: offset_reg <= (index > WIN_FRAME0) ? WIN1_OFFSET : WIN0_OFFSET;
			LOSE: offset_reg <= LOSE_OFFSET;
			default: offset_reg <= BASE_OFFSET;
		endcase
	end
	assign offset = offset_reg;

endmodule