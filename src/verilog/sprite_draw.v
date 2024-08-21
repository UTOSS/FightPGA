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
	output [7:0] vga_r,
	output [7:0] vga_g,
	output [7:0] vga_b
);

	wire [COLOR_DEPTH-1:0] p1_color, p2_color, color_vga;
	wire p1_active, p2_active;
	wire [COLOR_DEPTH-1:0] default_color;
	wire choose_default;
	
	sprite_renderer #(
		.filename("ryu_base.hex")
	) sp1 (
		.clk(clk),
		.reset(reset_lock),
		.hcount(hcount),
		.vcount(vcount),
		.xcoord(xcoord),
		.ycoord(ycoord),
		.active(active_region),
		.sprite_position(sprite_position_p1),
		.color_out(p1_color),
		.player_active(p1_active)
	);

	
	sprite_renderer #(
		.filename("ken_base.hex")
	) sp2 (
		.clk(clk),
		.reset(reset_lock),
		.hcount(hcount),
		.vcount(vcount),
		.xcoord(xcoord),
		.ycoord(ycoord),
		.active(active_region),
		.sprite_position(sprite_position_p2),
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