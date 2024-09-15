//The Memory Controller will take in read/write enable signals from the design's overarching control unit
//The start address will be pre-defined 
//The start address will continuously be incremented at each positive clock edge
//samples will be output at each rising clock edge untill all samples are read out
//Have a set number of samples that will be read out
//Have a sample ready signal when we are not at the max # of samples
//done bit updated to 1 when we reach final address
//created by Joonseo Park

`include "audioparams.vh"

module Memory_Controller(
	input sysclock,
	input read_enable,
	//input [32:0] read_address,
	//input [7:0] input_data, 
	output reg [7:0] output_data,
	//output reg reading_on,
	//output reg reading_finished,
	input sysreset
);


//internal register holding current address
reg [31:0] present_address = 0;
wire [7:0] output_wire;
reg donereading = 1'b0;


	M10K_Memory testmemory (
									.clock(sysclock),
									//.we(write_enable),
									.re(read_enable),
									//.w_addr(write_address),
									.r_addr(present_address),
									//.data_in(input_data),
									.data_out(output_wire));
									
									
	always@(posedge sysclock) begin
	
		if (read_enable == 1'b1 && sysreset != 1) begin
			
			if (present_address < 32'h00011340 && donereading == 0) begin //if we are still reading from memory
			
				//reading_on <= 1'b1;
				//reading_finished <= 1'b0;
				output_data <= output_wire;
				present_address <= present_address + 1;
				
			end
			
			else if (present_address >= 32'h00011340 && donereading == 0) begin //we are done reading the entire memory block, and need to indicate we are done reading
			
				donereading <= 1'b1;
				output_data <= 0;
			
			end
			
			else begin //reset donereading to 0 on this clock cycle so that we can read from memory again
			
				//reading_on <= 1'b0;
				//reading_finished <= 1'b1;
				present_address <= 0;
				donereading <= 1'b0;
			
			end
			
		end		
	
	end
	

endmodule
