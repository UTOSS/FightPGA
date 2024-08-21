//`include "C:/Users/reece/OneDrive/Desktop/UTOSS/UTOSS_summer_2t4/src/verilog/params_dummy.vh"

module sprite_renderer #(
	parameter SPRITE_HEIGHT = 76,
	parameter SPRITE_WIDTH = 64,
	parameter ADDR_WIDTH = 10,
	parameter SPRITE_PIXELS = SPRITE_HEIGHT*SPRITE_WIDTH,
	parameter filename="ryu_base"
) (
	input reset,
	input clk,
	input [2:0] sprite_select,
	input active,
	input [9:0] hcount,
	input [9:0] vcount,
	input [9:0] xcoord,
	input [9:0] ycoord,
	input [9:0] sprite_position,
	/*output [7:0] vga_r,
	output [7:0] vga_g,
	output [7:0] vga_b*/
	output [COLOR_DEPTH-1:0] color_out,
	output player_active
);
	
	wire line_active;
	wire [COLOR_DEPTH-1:0] color_draw;
	
	assign line_active = (ycoord >= SCREEN_HEIGHT - FLOOR_HEIGHT - SPRITE_HEIGHT) & (ycoord < SCREEN_HEIGHT-FLOOR_HEIGHT);
	assign sprite_active = (hcount >= sprite_position+H_SYNC_WAIT + H_BACK_PORCH) & (hcount < sprite_position + SPRITE_WIDTH+H_SYNC_WAIT + H_BACK_PORCH);//(xcoord >= sprite_position) & (xcoord < sprite_position + SPRITE_WIDTH); //(hcount >= sprite_position+H_SYNC_WAIT + H_BACK_PORCH) & (hcount < sprite_position + SPRITE_WIDTH+H_SYNC_WAIT + H_BACK_PORCH);
	
	reg [2**ADDR_WIDTH-1:0] pixel_select;

	always@(posedge clk, negedge reset) begin
		if(reset == 1'b0) begin
			pixel_select <= 0;
		end else begin
			pixel_select <= (line_active & sprite_active) ? pixel_select + 1 : (pixel_select >= SPRITE_PIXELS - 1 ? 0 : pixel_select);
		end
	end
	
	// Current issue: Due to clocked ROM, the first pixel gets duplicated twice
	// Since at the first pixel, xcoord is 0
	// Solution 1: register the address instead of the output?
	// Solution 2: line_active goes early one x coordinate earlier?
	
	parameter ACCESS_OFFSET = 2;
	
	sprite_rom #(
		.filename(filename)
	) r0
	(
		.clk(clk),
		.addr((ycoord-(SCREEN_HEIGHT-FLOOR_HEIGHT-SPRITE_HEIGHT))* SPRITE_WIDTH + (xcoord-sprite_position + ACCESS_OFFSET)), //pixel_select
		.pixel(color_draw)
	);
	
	assign player_active = line_active & sprite_active;
	assign color_out = color_draw;
	
endmodule

module sprite_rom#(
	parameter ADDR_WIDTH = 13,
	parameter filename="ryu_base.hex"
)(
	input clk,
	input [ADDR_WIDTH-1:0] addr,
	output [COLOR_DEPTH-1:0] pixel
);

	reg [COLOR_DEPTH-1:0] spr [0:(2**ADDR_WIDTH)-1] /* synthesis ramstyle = M10K*/;
	initial begin
		$readmemh(filename, spr);
	end

	reg [COLOR_DEPTH-1:0] pixel_reg;
	reg [ADDR_WIDTH-1:0] addr_reg;
	
	always@(posedge clk) begin
		pixel_reg <= spr[addr];
		//addr_reg <= addr;
	end
	assign pixel = pixel_reg;
	
endmodule