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

	parameter SPRITE_HEIGHT = 16;
	parameter SPRITE_WIDTH = 32;
	parameter ADDR_WIDTH = 10;
	parameter SPRITE_PIXELS = SPRITE_HEIGHT*SPRITE_WIDTH;
	
	wire line_active;
	wire sprite_active;
	
	wire [COLOR_DEPTH-1:0] default_color;
	wire [COLOR_DEPTH-1:0] color_code;
	wire [COLOR_DEPTH-1:0] color_draw;
	
	assign default_color = (ycoord >= SCREEN_HEIGHT - FLOOR_HEIGHT) ? COLOR_BLACK_CODE : COLOR_WHITE_CODE;
	
	assign line_active = (ycoord >= SCREEN_HEIGHT - FLOOR_HEIGHT - SPRITE_HEIGHT) & (ycoord < SCREEN_HEIGHT-FLOOR_HEIGHT);
	assign sprite_active = (hcount >= sprite_position+H_SYNC_WAIT + H_BACK_PORCH) & (hcount < sprite_position + SPRITE_WIDTH+H_SYNC_WAIT + H_BACK_PORCH);//(xcoord >= sprite_position) & (xcoord < sprite_position + SPRITE_WIDTH); //(hcount >= sprite_position+H_SYNC_WAIT + H_BACK_PORCH) & (hcount < sprite_position + SPRITE_WIDTH+H_SYNC_WAIT + H_BACK_PORCH);
	wire choose_default;
	assign choose_default = ~(line_active & sprite_active);
	assign color_draw = choose_default ? default_color : color_code;
	
	reg [2**ADDR_WIDTH-1:0] pixel_select;

	always@(posedge clk, negedge reset) begin
		if(reset == 1'b0) begin
			pixel_select <= 0;
		end else begin
			pixel_select <= (line_active & sprite_active) ? pixel_select + 1 : (pixel_select >= SPRITE_PIXELS - 1 ? 0 : pixel_select);
		end
	end
	
	// Variable sprite widths
	// Option: Pad all sprites to a particular length
	// Have custom "animation width" for each sprite (replaces the SPRITE_WIDTH parameter) where it just stops drawing
	// Player 1 sprites get priority: add a mux which checks if player 1 is active in that area - if they are, draw their sprites (unless it's an empty pixel - then draw player 2)
	
	parameter ACCESS_OFFSET = 2;
	
	sprite_rom r0(
		.clk(clk),
		.addr((ycoord-(SCREEN_HEIGHT-FLOOR_HEIGHT-SPRITE_HEIGHT))* SPRITE_WIDTH + (xcoord-sprite_position + ACCESS_OFFSET)), //pixel_select
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

module sprite_rom#(
	parameter ADDR_WIDTH = 10
)(
	input clk,
	input [ADDR_WIDTH-1:0] addr,
	output [COLOR_DEPTH-1:0] pixel
);

	reg [COLOR_DEPTH-1:0] spr [0:(2**ADDR_WIDTH)-1] /* synthesis ramstyle = M10K*/;
	initial begin
		$readmemh("sprite_rom.hex", spr);
	end

	reg [COLOR_DEPTH-1:0] pixel_reg;
	reg [ADDR_WIDTH-1:0] addr_reg;
	
	always@(posedge clk) begin
		pixel_reg <= spr[addr];
		//addr_reg <= addr;
	end
	assign pixel = pixel_reg;
	
endmodule