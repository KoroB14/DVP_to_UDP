//////////////////////////////////////////////////////////////////////////////////
// Dmitry Koroteev
// korob14@gmail.com
//////////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1 ps

module RAW_to_RGB565
#(	parameter IM_X = 1280,
	parameter IM_Y = 720
)
(         
	input wire 					rst_n,
	input wire					PCLK_cam,
	input wire					gtx_clk,
 	input wire		[7:0]		raw_data,
	input wire					data_valid,
	input wire 					out_ready,
	output wire 				in_ready,
	output wire 	[7:0]		pixel,
	output reg					pixel_valid
	
);
localparam XBITS = $clog2(IM_X);

wire [7:0] R, G, B;
wire RGB_valid;
wire wrfull, rdempty, rdreq;

assign rdreq = out_ready & !rdempty;

always @(posedge gtx_clk or negedge rst_n) 
if (!rst_n)
	pixel_valid <= 0;
else
	pixel_valid <= rdreq;
	
BayertoRGB #(.IM_X(IM_X), .IM_Y(IM_Y)) BayertoRGB_inst
(
	.rst_n(rst_n),
	.clk(PCLK_cam),
	.raw_data(raw_data),
	.data_valid(data_valid),
	.out_ready(1'b1),
	.in_ready(in_ready),
	.R(R), 
	.G(G), 
	.B(B),
	.pixel_valid(RGB_valid)
);

dcfifo_mixed_widths	RGB_BUF (
				.aclr (~rst_n),
				.data ({G[4:2], B[7:3], R[7:3], G[7:5]}),
				.rdclk (gtx_clk),
				.rdreq (rdreq),
				.wrclk (PCLK_cam),
				.wrreq (RGB_valid),
				.q (pixel),
				.rdempty (rdempty),
				.rdusedw (),
				.wrfull (wrfull),
				.eccstatus (),
				.rdfull (),
				.wrempty (),
				.wrusedw ());
	defparam
		RGB_BUF.intended_device_family = "Cyclone IV E",
		RGB_BUF.lpm_numwords = 2**(XBITS-1),
		RGB_BUF.lpm_showahead = "OFF",
		RGB_BUF.lpm_type = "dcfifo",
		RGB_BUF.lpm_width = 16,
		RGB_BUF.lpm_widthu = XBITS-1,
		RGB_BUF.lpm_width_r = 8,
		RGB_BUF.lpm_widthu_r = XBITS,
		RGB_BUF.overflow_checking = "ON",
		RGB_BUF.rdsync_delaypipe = 4,
		RGB_BUF.read_aclr_synch = "OFF",
		RGB_BUF.underflow_checking = "ON",
		RGB_BUF.use_eab = "ON",
		RGB_BUF.write_aclr_synch = "OFF",
		RGB_BUF.wrsync_delaypipe = 4;


endmodule
