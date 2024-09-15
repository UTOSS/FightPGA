//created by Joonseo Park

module M10K_Memory#(
	parameter audiofile = "bird_chirp_split_v2.hex"
)(
	
	input clock, re,
	input [31:0] r_addr,
	output reg [7:0] data_out
	//input [7:0] data_in
	
);

	//8 bit vector with depth of 1800 - infer M10K memory
	//where depth = memory locations
	reg [7:0] M10K [0:23489] /* synthesis ramstyle = M10K*/;
	initial begin
		$readmemh(audiofile, M10K);
	end
	
	//read and write logic
	always @(posedge clock) begin
				
			if (re) begin
				
				data_out <= M10K[r_addr]; 
			  
			end
	
	end
		 
endmodule
