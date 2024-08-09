module vga_top(
	input clk,
	input reset,
	output [9:0] hcount_out,
	output [9:0] vcount_out,
	output [9:0] xcoord,
	output [9:0] ycoord,
	output hsync,
	output vsync,
	output display_en, // blank
	output vga_sync
);

	reg [9:0] hcount;
	reg [9:0] vcount;
	reg hsync_reg;
	reg vsync_reg;
	wire vcount_enable;
	wire active_region;
	
	assign vga_sync = ~active_region;
	
	assign active_region = (hcount >= H_SYNC_WAIT + H_BACK_PORCH-1) & (vcount >= V_SYNC_WAIT+V_BACK_PORCH-1) & (hcount < H_SYNC_WAIT + H_BACK_PORCH + SCREEN_WIDTH -1) & (vcount < V_SYNC_WAIT+V_BACK_PORCH + SCREEN_HEIGHT-1);
	
	always@(posedge clk, negedge reset) begin
		if(reset == 1'b0) begin
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
	
	assign vcount_enable = hcount == LINE_WAIT-1;
	assign hsync = hsync_reg;
	assign vsync = vsync_reg;
	assign display_en = active_region;
	assign xcoord = active_region ? hcount - (H_SYNC_WAIT + H_BACK_PORCH - 1) : 0;
	assign ycoord = active_region ? vcount - (V_SYNC_WAIT + V_BACK_PORCH - 1) : 0;
	assign hcount_out = hcount;
	assign vcount_out = vcount;
	
endmodule