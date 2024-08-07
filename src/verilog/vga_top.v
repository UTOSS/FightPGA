module vga_top#(
	parameter WIDTH = 640, //10 bit line select, 10 bit counter including porches/waits
	parameter HEIGHT = 480, //9 bit column select, 10 bit counter including porches/waits
	parameter H_FRONT_PORCH = 16,
	parameter H_BACK_PORCH = 48,
	parameter H_SYNC_WAIT = 96,
	parameter V_FRONT_PORCH = 10,
	parameter V_BACK_PORCH = 33,
	parameter V_SYNC_WAIT = 2,
	parameter LINE_WAIT = WIDTH + H_FRONT_PORCH + H_BACK_PORCH + H_SYNC_WAIT,
	parameter V_LINES_WAIT = HEIGHT + V_FRONT_PORCH + V_BACK_PORCH + V_SYNC_WAIT	
)(
	input ref_clk,
	input reset,
	output [7:0] vga_r,
	output [7:0] vga_b,
	output [7:0] vga_g,
	output [9:0] x_coord,
	output [9:0] y_coord,
	output hsync,
	output vsync,
	output display_en, // blank
	output clk_out,
	output pll_lock_out,
	output vga_sync
);

	reg [9:0] hcount;
	reg [9:0] vcount;
	reg hsync_reg;
	reg vsync_reg;
	wire vcount_enable;
	
	
	wire active_region;
	//reg active_region;
	wire clk;
	wire lock;
	wire reset_lock;
	assign vga_sync = ~active_region;
	assign clk_out = clk;
	
	assign pll_lock_out = lock;	
	assign reset_lock = lock & reset;
	
	assign active_region = (hcount >= H_SYNC_WAIT + H_BACK_PORCH-1) & (vcount >= V_SYNC_WAIT+V_BACK_PORCH-1) & (hcount < H_SYNC_WAIT + H_BACK_PORCH + WIDTH -1) & (vcount < V_SYNC_WAIT+V_BACK_PORCH + HEIGHT-1);
	
	always@(posedge clk, negedge reset_lock) begin
		if(reset_lock == 1'b0) begin
			hcount <= 0;
			vcount <= 0;
			hsync_reg <= 1'b1;
			vsync_reg <= 1'b1;
			//active_region <= 1'b0;
		end else begin
			hcount <= (hcount >= LINE_WAIT - 1) ? 0 : hcount + 1;
			if(vcount_enable == 1'b1) begin
				vcount <= (vcount >= V_LINES_WAIT - 1) ? 0 : vcount + 1;
			end
			hsync_reg <= ~(hcount <= H_SYNC_WAIT - 1);
			vsync_reg <= ~(vcount <= V_SYNC_WAIT - 1);
			//active_region <= (hcount < WIDTH + H_BACK_PORCH-1) & (vcount < HEIGHT+V_BACK_PORCH-1) & (hcount >= H_BACK_PORCH-1) & (vcount >= V_BACK_PORCH-1);
		end
	end
	assign vcount_enable = hcount >= LINE_WAIT-1;
	assign hsync = hsync_reg;
	assign vsync = vsync_reg;
	assign display_en = active_region;
	assign x_coord = active_region ? hcount - (H_SYNC_WAIT + H_BACK_PORCH - 1) : 0;
	assign y_coord = active_region ? vcount - (V_SYNC_WAIT + V_BACK_PORCH - 1) : 0;
	
endmodule