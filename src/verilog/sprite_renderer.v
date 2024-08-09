//`include "C:/Users/reece/OneDrive/Desktop/UTOSS/UTOSS_summer_2t4/src/verilog/params_dummy.vh"

module sprite_renderer(
	input reset,
	input clk,
	input [2:0] sprite_select,
	input active,
	input [9:0] hcount,
	input [9:0] vcount,
	input [9:0] xcoord,
	input [9:0] ycoord,
	input [9:0] sprite_position,
	output [7:0] vga_r,
	output [7:0] vga_g,
	output [7:0] vga_b
);

	parameter SPRITE_HEIGHT = 8;
	parameter SPRITE_WIDTH = 8;
	parameter ADDR_WIDTH = 6;
	parameter SPRITE_PIXELS = SPRITE_HEIGHT*SPRITE_WIDTH;
	
	wire line_active;
	
	wire [COLOR_DEPTH-1:0] default_color;
	wire [COLOR_DEPTH-1:0] color_code;
	wire [COLOR_DEPTH-1:0] color_draw;
	
	reg [9:0] xcoord_reg;
	reg [9:0] ycoord_reg;
	
	assign color_draw = choose_default ? default_color : color_code;
	
	assign default_color = (ycoord >= SCREEN_HEIGHT - FLOOR_HEIGHT) ? COLOR_BLACK_CODE : COLOR_WHITE_CODE;
	
	assign line_active = (ycoord >= SCREEN_HEIGHT - FLOOR_HEIGHT - SPRITE_HEIGHT) & (ycoord < SCREEN_HEIGHT-FLOOR_HEIGHT);
	assign sprite_active = (xcoord >= sprite_position) & (xcoord < sprite_position + SPRITE_WIDTH);
	wire choose_default;
	assign choose_default = ~(line_active & sprite_active);
	
	reg [2**ADDR_WIDTH-1:0] pixel_select;

	always@(posedge clk, negedge reset) begin
		if(reset == 1'b0) begin
			pixel_select <= 0;
			xcoord_reg <= 0;
			ycoord_reg <= 0;
		end else begin
			pixel_select <= (line_active & sprite_active) ? pixel_select + 1 : (pixel_select >= SPRITE_PIXELS - 1 ? 0 : pixel_select);
			xcoord_reg <= line_active ? xcoord : 0;
			ycoord_reg <= ycoord;
		end
	end
	
	// sprite drawing algorithm
	// At the start of each line (hcount = 0), check if the sprite is on this line (ycoord)
	// If not, skip (draw default colour/floor)
	// Otherwise, 
	
	sprite_rom r0(
		.clk(clk),
		.addr(pixel_select),
		.pixel(color_code)
	);
	
	color_select c0(
		.pix(color_draw),
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
			COLOR_WHITE_CODE: rgb <= COLOR_WHITE;
			COLOR_BLACK_CODE: rgb <= COLOR_BLACK;
			COLOR_RED_CODE: rgb <= COLOR_RED;
			COLOR_BLUE_CODE: rgb <= COLOR_BLUE;
		endcase
	end
	
	assign r = rgb[23:16];
	assign g = rgb[15:8];
	assign b = rgb[7:0];
endmodule

module sprite_rom#(
	parameter ADDR_WIDTH = 6,
	parameter NUM_PIXELS = 8*8
)(
	input clk,
	input [ADDR_WIDTH-1:0] addr,
	output [COLOR_DEPTH-1:0] pixel
);

	reg [COLOR_DEPTH-1:0] spr [0:NUM_PIXELS-1];
	initial begin
		$readmemh("sprite_rom.hex", spr);
	end

	reg [COLOR_DEPTH-1:0] pixel_reg;
	
	/*always@(posedge clk) begin
		pixel_reg <= spr[addr];
	end*/
	assign pixel = spr[addr];//pixel_reg;
	
endmodule