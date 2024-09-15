	// I2C programmer
	// This file initalizes the I2C registers
	//created by James Kim
	
	module i2c_initialization (
		i2c_clk, reset, i2c_scl, byte_done, ack_bit, ack_en, i2c_data_reg

	);
	
	input i2c_clk; // 27 MHz DE1-SoC clock
	input reset; // 2 MHz enable clock

	output i2c_scl; // 40KHz I2C clock 
	output byte_done; // Data transaction complete
	output ack_bit; // Slave device acknowledge 
	output ack_en; // Timing of ack_bit
	
	inout i2c_data_reg; // Bit-directional serial data line
	
	reg [15:0] i2c_clk_divider; 
	reg [23:0] shift_i2c_data;
	reg [6:0] shift_count;
	
	reg output_clk;
	reg sclk;
	reg byte_done;
	reg data_reg_out;
	reg clock;
	
	//Load values to video, audio register
	
	//i2c_fsm code instantiation
	
	i2c_fsm u0 (
		.clk(output_clk),
		.reset(reset),
		.mend(data_reg),    
		.mack(ack_bit),
		.mgo(GO),
		.SCLK(sclk),
		.mstep(step_out),
		.i2c_data(data_reg)
	);
	
	wire i2c_scl = (byte_done == 1'b0) ? sclk : 1'b1;

	wire i2c_data_rega = (ack_en == 1'b1) ? data_reg_out : 1'bz;

	reg ack_en;
	reg ack_bit_1, ack_bit_2, ack_bit_3;
	wire ack_bit = ack_bit_1 | ack_bit_2 | ack_bit_3;
	wire [23:0] data_reg;
	wire GO;
	wire [3:0] step_out;
	
	parameter clk_freq = 50000000; //50 MHz
	parameter i2c_freq = 40000; //40 kHz
	
	// Divide input clock to create control for I2C

	always @(posedge i2c_clk or negedge reset) 
	begin
		if (!reset)
		begin
			i2c_clk_divider <= 0;
			output_clk <= 0;
		end 
		
		else 
		begin
			if (output_clk < (clk_freq/i2c_freq)) 
				output_clk <= i2c_clk_divider + 1;
			else 
			begin
				i2c_clk_divider <= 0;
				output_clk <= ~output_clk;
			end
		end
	end

	always @(posedge clock or negedge reset) 
	begin
		if (!reset)
			shift_count = 7'b1111111;
		else 
		begin
			if (GO == 0)
				shift_count = 7'b0;
			else 
				if ((shift_count < 7'b1110111) & (byte_done == 0)) 
					shift_count = shift_count + 1;
		end
	end

	// Shift bits into I2C data register
	always @(posedge clock or negedge reset) 
	begin
		if (!reset)
		begin 
			ack_bit_1 = 0;
			ack_bit_2 = 0;
			ack_bit_3 = 0;
			byte_done = 0;
			data_reg_out = 1;
			sclk = 1;
			ack_en = 1;
		end 
		else 
			case (shift_count)
			
				7'd0:
				begin
					ack_bit_1 = 0;
					ack_bit_2 = 0;
					ack_bit_3 = 0;
					byte_done = 0;
					data_reg_out = 1;
					sclk = 1;
					ack_en = 1;
				end
				
				7'd1:
				begin
					shift_i2c_data = (data_reg); 
					data_reg_out = 0;
				end
				
				// begin load
				// slave address
				7'd2 : begin data_reg_out = data_reg[23]; sclk = 0; end
				7'd3 : begin data_reg_out = data_reg[23]; sclk = 1; end
				7'd4 : begin data_reg_out = data_reg[23]; sclk = 1; end
				7'd5 : begin data_reg_out = data_reg[23]; sclk = 0; end
				
				7'd6 : begin data_reg_out = data_reg[22]; sclk = 0; end
				7'd7 : begin data_reg_out = data_reg[22]; sclk = 1; end
				7'd8 : begin data_reg_out = data_reg[22]; sclk = 1; end
				7'd9 : begin data_reg_out = data_reg[22]; sclk = 0; end
				
				7'd10 : begin data_reg_out = data_reg[21]; sclk = 0; end
				7'd11 : begin data_reg_out = data_reg[21]; sclk = 1; end
				7'd12 : begin data_reg_out = data_reg[21]; sclk = 1; end
				7'd13 : begin data_reg_out = data_reg[21]; sclk = 0; end
				
				7'd14 : begin data_reg_out = data_reg[20]; sclk = 0; end
				7'd15 : begin data_reg_out = data_reg[20]; sclk = 1; end
				7'd16 : begin data_reg_out = data_reg[20]; sclk = 1; end
				7'd17 : begin data_reg_out = data_reg[20]; sclk = 0; end
				
				7'd18 : begin data_reg_out = data_reg[19]; sclk = 0; end
				7'd19 : begin data_reg_out = data_reg[19]; sclk = 1; end
				7'd20 : begin data_reg_out = data_reg[19]; sclk = 1; end
				7'd21 : begin data_reg_out = data_reg[19]; sclk = 0; end
				
				7'd22 : begin data_reg_out = data_reg[18]; sclk = 0; end
				7'd23 : begin data_reg_out = data_reg[18]; sclk = 1; end
				7'd24 : begin data_reg_out = data_reg[18]; sclk = 1; end
				7'd25 : begin data_reg_out = data_reg[18]; sclk = 0; end

				// acknowledge cycle begin
				7'd26 : begin data_reg_out = data_reg[17]; sclk = 0; end
				7'd27 : begin data_reg_out = data_reg[17]; sclk = 1; end
				7'd28 : begin data_reg_out = data_reg[17]; sclk = 1; end
				7'd29 : begin data_reg_out = data_reg[17]; sclk = 0; end
				
				7'd30 : begin data_reg_out = data_reg[16]; sclk = 0; end
				7'd31 : begin data_reg_out = data_reg[16]; sclk = 1; end
				7'd32 : begin data_reg_out = data_reg[16]; sclk = 1; end
				7'd33 : begin data_reg_out = data_reg[16]; sclk = 0; end
				
				// acknowledge cycle begin
				7'd34 : begin data_reg_out = 0; sclk = 0; end
				7'd35 : begin data_reg_out = 0; sclk = 1; end
				7'd36 : begin data_reg_out = 0; sclk = 1; end
				7'd37 : begin ack_bit_1 = i2c_data_reg; sclk = 0; ack_en = 0; end
				7'd38 : begin ack_bit_1 = i2c_data_reg; sclk = 0; ack_en = 0; end
				7'd39 : begin data_reg_out = 0; sclk = 0; ack_en = 1; end
				
				7'd40 : begin data_reg_out = data_reg[15]; sclk = 0; end
				7'd41 : begin data_reg_out = data_reg[15]; sclk = 1; end
				7'd42 : begin data_reg_out = data_reg[15]; sclk = 1; end
				7'd43 : begin data_reg_out = data_reg[15]; sclk = 0; end
				
				7'd44 : begin data_reg_out = data_reg[14]; sclk = 0; end
				7'd45 : begin data_reg_out = data_reg[14]; sclk = 1; end
				7'd46 : begin data_reg_out = data_reg[14]; sclk = 1; end
				7'd47 : begin data_reg_out = data_reg[14]; sclk = 0; end
				
				7'd48 : begin data_reg_out = data_reg[13]; sclk = 0; end
				7'd49 : begin data_reg_out = data_reg[13]; sclk = 1; end
				7'd50 : begin data_reg_out = data_reg[13]; sclk = 1; end
				7'd51 : begin data_reg_out = data_reg[13]; sclk = 0; end
				
				7'd52 : begin data_reg_out = data_reg[12]; sclk = 0; end
				7'd53 : begin data_reg_out = data_reg[12]; sclk = 1; end
				7'd54 : begin data_reg_out = data_reg[12]; sclk = 1; end
				7'd55 : begin data_reg_out = data_reg[12]; sclk = 0; end
				
				7'd56 : begin data_reg_out = data_reg[11]; sclk = 0; end
				7'd57 : begin data_reg_out = data_reg[11]; sclk = 1; end
				7'd58 : begin data_reg_out = data_reg[11]; sclk = 1; end
				7'd59 : begin data_reg_out = data_reg[11]; sclk = 0; end
				
				7'd60 : begin data_reg_out = data_reg[10]; sclk = 0; end
				7'd61 : begin data_reg_out = data_reg[10]; sclk = 1; end
				7'd62 : begin data_reg_out = data_reg[10]; sclk = 1; end
				7'd63 : begin data_reg_out = data_reg[10]; sclk = 0; end
				
				7'd64 : begin data_reg_out = data_reg[9]; sclk = 0; end
				7'd65 : begin data_reg_out = data_reg[9]; sclk = 1; end
				7'd66 : begin data_reg_out = data_reg[9]; sclk = 1; end
				7'd67 : begin data_reg_out = data_reg[9]; sclk = 0; end
				
				7'd68 : begin data_reg_out = data_reg[8]; sclk = 0; end
				7'd69 : begin data_reg_out = data_reg[8]; sclk = 1; end
				7'd70 : begin data_reg_out = data_reg[8]; sclk = 1; end
				7'd71 : begin data_reg_out = data_reg[8]; sclk = 0; end

				// acknowledge cycle begin
				7'd72 : begin data_reg_out = 0; sclk = 0; end
				7'd73 : begin data_reg_out = 0; sclk = 1; end
				7'd74 : begin data_reg_out = 0; sclk = 1; end
				7'd75 : begin ack_bit_1 = i2c_data_reg; sclk = 0; ack_en = 0; end
				7'd76 : begin ack_bit_1 = i2c_data_reg; sclk = 0; ack_en = 0; end
				7'd77 : begin data_reg_out = 0; sclk = 0; ack_en = 1; end
				
				7'd78 : begin data_reg_out = data_reg[7]; sclk = 0; end
				7'd79 : begin data_reg_out = data_reg[7]; sclk = 1; end
				7'd80 : begin data_reg_out = data_reg[7]; sclk = 1; end
				7'd81 : begin data_reg_out = data_reg[7]; sclk = 0; end
				
				7'd82 : begin data_reg_out = data_reg[6]; sclk = 0; end
				7'd83 : begin data_reg_out = data_reg[6]; sclk = 1; end
				7'd84 : begin data_reg_out = data_reg[6]; sclk = 1; end
				7'd85 : begin data_reg_out = data_reg[6]; sclk = 0; end
				
				7'd86 : begin data_reg_out = data_reg[5]; sclk = 0; end
				7'd87 : begin data_reg_out = data_reg[5]; sclk = 1; end
				7'd88 : begin data_reg_out = data_reg[5]; sclk = 1; end
				7'd89 : begin data_reg_out = data_reg[5]; sclk = 0; end
				
				7'd90 : begin data_reg_out = data_reg[4]; sclk = 0; end
				7'd91 : begin data_reg_out = data_reg[4]; sclk = 1; end
				7'd92 : begin data_reg_out = data_reg[4]; sclk = 1; end
				7'd93 : begin data_reg_out = data_reg[4]; sclk = 0; end
				
				7'd94 : begin data_reg_out = data_reg[3]; sclk = 0; end
				7'd95 : begin data_reg_out = data_reg[3]; sclk = 1; end
				7'd96 : begin data_reg_out = data_reg[3]; sclk = 1; end
				7'd97 : begin data_reg_out = data_reg[3]; sclk = 0; end
				
				7'd98 : begin data_reg_out = data_reg[2]; sclk = 0; end
				7'd99 : begin data_reg_out = data_reg[2]; sclk = 1; end
				7'd100 : begin data_reg_out = data_reg[2]; sclk = 1; end
				7'd101 : begin data_reg_out = data_reg[2]; sclk = 0; end
				
				7'd102 : begin data_reg_out = data_reg[1]; sclk = 0; end
				7'd103 : begin data_reg_out = data_reg[1]; sclk = 1; end
				7'd104 : begin data_reg_out = data_reg[1]; sclk = 1; end
				7'd105 : begin data_reg_out = data_reg[1]; sclk = 0; end
				
				7'd106 : begin data_reg_out = data_reg[0]; sclk = 0; end
				7'd107 : begin data_reg_out = data_reg[0]; sclk = 1; end
				7'd108 : begin data_reg_out = data_reg[0]; sclk = 1; end
				7'd109 : begin data_reg_out = data_reg[0]; sclk = 0; end

				// acknowledge cycle begin
				7'd110 : begin data_reg_out = 0; sclk = 0; end
				7'd111 : begin data_reg_out = 0; sclk = 1; end
				7'd112 : begin data_reg_out = 0; sclk = 1; end
				7'd113 : begin ack_bit_1 = i2c_data_reg; sclk = 0; ack_en = 0; end
				7'd114 : begin ack_bit_1 = i2c_data_reg; sclk = 0; ack_en = 0; end
				7'd115 : begin data_reg_out = 0; sclk = 0; ack_en = 1; end

				// stop
				7'd116 : begin sclk = 1'b0; data_reg_out = 1'b0; end
				7'd117 : begin sclk = 1'b1; end
				7'd118 : begin data_reg_out = 1'b1; byte_done = 1'b1; end

			endcase 
		end
		
	// Direct signals to GPIO pins
	always @(*)
	begin
		clock <= output_clk;
	end

endmodule
			 