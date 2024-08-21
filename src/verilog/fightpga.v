`include "params.vh"

module fightpga(
	input ref_clk,
	input reset,
	input [4:0] p1_inputs,
	input [4:0] p2_inputs,
	output hsync,
	output vsync,
	output display_en,
	output vga_sync,
	output clk_out,
	output [7:0] vga_r,
	output [7:0] vga_g,
	output [7:0] vga_b,
	output pll_locked
);

	wire clk;
	wire reset_lock;
	wire pll_lock;
	assign pll_locked = pll_lock;
	assign reset_lock = pll_lock & reset;
	
	// vga phy wires
	wire [9:0] hcount;
	wire [9:0] vcount;
	wire [9:0] xcoord;
	wire [9:0] ycoord;
	wire active_region;
	wire [9:0] p1_position, p2_position;
	wire [STATE_DEPTH-1:0] wire_p1_state;
	wire [STATE_DEPTH-1:0] wire_p2_state;
	
	vga_pll pll0(
		.refclk(ref_clk),
		.rst(~reset),
		.outclk_0(clk),
		.locked(pll_lock)
	);
	
	vga_top vga0(
		.clk(clk),
		.reset(reset_lock),
		.hcount_out(hcount),
		.vcount_out(vcount),
		.hsync(hsync),
		.vsync(vsync),
		.xcoord(xcoord),
		.ycoord(ycoord),
		.display_en(active_region),
		.vga_sync(vga_sync)
	);
	
	sprite_draw s0(
		.clk(clk),
		.reset(reset_lock),
		.hcount(hcount),
		.vcount(vcount),
		.xcoord(xcoord),
		.ycoord(ycoord),
		.active(active_region),
		.sprite_position_p1(p1_position),
		.sprite_position_p2(p2_position),
		.vga_r(vga_r),
		.vga_g(vga_g),
		.vga_b(vga_b)
	);
	
	game_logic g0(
		.p1_inputs({3'b000,~p1_inputs[1:0]}),
		.p2_inputs({3'b000,~p2_inputs[1:0]}),
		.frame_clk(~vsync),
		.sys_clk(clk),
		.rst(reset_lock),
		.p1_position(p1_position),
		.p2_position(p2_position)
	);
	
	assign display_en = active_region;
	assign clk_out = clk;


endmodule