`include "params.vh"

module fightpga(
	input ref_clk,
	input reset,
	input [4:0] p1_inputs,
	input [4:0] p2_inputs,
	input [1:0] palette_select,
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
	wire win_reset;
	assign pll_locked = pll_lock;
	assign reset_lock = pll_lock & reset & win_reset;
	
	// vga phy wires
	wire [9:0] hcount;
	wire [9:0] vcount;
	wire [9:0] xcoord;
	wire [9:0] ycoord;
	wire active_region;
	wire [9:0] p1_position, p2_position;
	wire [STATE_DEPTH-1:0] state_p1, state_p2;
	wire [SPRITE_INDEX_DEPTH-1:0] action_timer_p1, action_timer_p2;
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
		.action_timer_p1(action_timer_p1),
		.action_timer_p2(action_timer_p2),
		.state_p1(state_p1),
		.state_p2(state_p2),
		.palette_select(palette_select),
		.vga_r(vga_r),
		.vga_g(vga_g),
		.vga_b(vga_b)
	);
	
	game_logic g0(
		.p1_inputs(~p1_inputs),
		.p2_inputs(~p2_inputs),
		.frame_clk(~vsync),
		.sys_clk(clk),
		.rst(reset_lock),
		.p1_state(state_p1),
		.p2_state(state_p2),
		.p1_sprite(action_timer_p1),
		.p2_sprite(action_timer_p2),
		.p1_position(p1_position),
		.p2_position(p2_position),
		.win_reset(win_reset)
	);
	
	assign display_en = active_region;
	assign clk_out = clk;


endmodule