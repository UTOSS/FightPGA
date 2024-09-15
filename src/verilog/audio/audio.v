//created by James Kim
//Edited for integration by Joonseo Park

module audio (
aud_xclk	, // clock 12. MHz?
bclk 		, // bit stream clock
adclrck	, // left right clock ADC
adcdat	, // data stream ADC
daclrck	, // left right clock DAC
dacdat	, // data stream DAC
sclk		, // serial clock I2C
sdat		, // serail data I2C
swt		,
clk		,
//read_enable,
read_address,
gpio);     // 40 pin header

//output aud_xclk;
input adcdat;
input swt;
input clk;
input bclk;

input adclrck;
input daclrck;
inout sdat;
//input read_enable;
input[14:0] read_address;
wire[7:0] audio_out;

output aud_xclk;
output sclk;
output dacdat;
output[7:0] gpio;

wire [7:0] output_datatop;
wire reading_on;
wire reading_finished;

//use temporarily, for isolated audio testing
reg read_enable = 1;

i2c_initialization u1(
	.i2c_clk(clk),			//  50 Mhz clk from DE1-SoC
	.reset(swt),			//  clock enable 
	.i2c_scl(sclk),		// I2C clock 40K
	.byte_done(TRN_END),
	.ack_bit(ACK),
	.ack_en(ACK_enable),
	.i2c_data_reg(sdat)		// bi directional serial data 
 );


Memory_Controller u2 (
	.sysclock(clk),            // Connect system clock
	.read_enable(read_enable), // Connect read enable control signal
	//.read_address(read_address), // Connect read address input
	.output_data(output_datatop), // Connect data output to internal signal
	//.reading_on(reading_on),   // Connect reading_on signal to internal signal
	//.reading_finished(reading_finished), // Connect reading_finished signal
	.sysreset(reset)           // Connect system reset
);

assign audio_out = output_datatop;

serial_dac u3 (
 
	.serial_dac(dacdat),		// 32 bit serial in data
	.sda_left(serial_lf),
	.sda_right(serial_rt), 
	.dac_input_en(daclrck),
	.data_in(output_datatop),
	.clk(clk),				// 50 KHz clock
	.enable(swt)			// master reset

);

 parameter clk_freq = 50000000;  // 50 Mhz
 parameter i2c_freq = 12288000;  // 12.288 Mhz

 wire[32:0] serial_lf;
 wire[32:0] serial_rt;
	
  always @ (posedge clk or negedge swt)
  begin
		if (!swt)
		begin
			clk_div <= 0;
			ctrl_clk <= 0;
		end
		
		else
		
		begin
		
			if (clk_div <  (clk_freq/i2c_freq) )  // keeps dividing until reaches desired frequency
			clk_div <= clk_div + 1;
			
			else
			begin 
					clk_div <= 0;
					ctrl_clk <= ~ctrl_clk;
			end
		end
	end
 
 wire sclk; 
 wire sdat; 

//internal signals

 wire ACK ;
 wire ACK_enable;
 wire [23:0] data_23;
 wire TRN_END;
 reg ctrl_clk;
 reg [15:0] clk_div;  // clock divider

 assign aud_xclk = ctrl_clk; 
 
 assign gpio[0] = ctrl_clk;
 assign gpio[1] = bclk;
 assign gpio[2] = dacdat;
 assign gpio[3] = daclrck;
 assign gpio[4] = adcdat;
 assign gpio[5] = adclrck;
 assign gpio[6] = sclk;
 assign gpio[7] = sdat;
 

endmodule
