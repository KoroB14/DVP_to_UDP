module raw_data_fifo
#(
	parameter ADDR_W = 10
	
)
(
	input wire 						clk,
	input wire 						rst_n,
	input wire 						rdreq,
	input wire 						wrreq,
	input wire [7:0] 				data_in,
	output wire [7:0] 				data_out,
	output wire 					empty,
	output wire 					full,
	output wire [ADDR_W - 1 : 0]	usedw
);


scfifo	scfifo_component (
				.aclr (~rst_n),
				.data (data_in),
				.clock (clk),
				.rdreq (rdreq),
				.wrreq (wrreq),
				.q (data_out),
				.empty (empty),
				.usedw (usedw),
				.full (full)
				
				);
	defparam
		scfifo_component.intended_device_family = "Cyclone IV E",
		scfifo_component.lpm_numwords = 2**ADDR_W,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = 8,
		scfifo_component.lpm_widthu = ADDR_W,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";
		
		
		
	
endmodule
