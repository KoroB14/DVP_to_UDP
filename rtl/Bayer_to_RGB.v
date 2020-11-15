//////////////////////////////////////////////////////////////////////////////////
// Dmitry Koroteev
// korob14@gmail.com
//////////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1 ps

module BayertoRGB
#(	parameter IM_X = 1280,
	parameter IM_Y = 720
)
(         
	input wire 					rst_n,
	input wire					clk,
	input wire		[7:0]		raw_data,
	input wire					data_valid,
	input wire 					out_ready,
	output wire 				in_ready,
	output reg 	[7:0]		R, G, B,
	output reg					pixel_valid
	
); 

localparam XBITS = $clog2(IM_X);
localparam YBITS = $clog2(IM_Y);

reg [XBITS - 1:0] cnt_x;
reg [YBITS - 1:0] cnt_y;
reg [15:0] firstline_px, secondline_px;
reg  even_line, second_byte, start_proc;
reg [7:0] Red, Blue;
reg [8:0] Green;

wire [XBITS - 1:0] usedw;
wire fifo_full, fifo_empty;
wire [7:0] fifo_data;


wire last_row = (cnt_y == IM_Y - 0);
wire rd_fifo;
reg rd_fifo_r;


assign in_ready = !fifo_full;

always @(posedge clk or negedge rst_n) 
if (!rst_n)
	cnt_x <= 0;
else if ((out_ready && data_valid) || last_row)
	cnt_x <= cnt_x + 1'b1;
else if (cnt_x == IM_X)
	cnt_x <= 0;

always @(posedge clk or negedge rst_n) 
if (!rst_n)
	cnt_y <= 0;
else if ((cnt_x == IM_X - 0) && !fifo_empty)
	cnt_y <= cnt_y + 1'b1;
else if ((cnt_y == IM_Y - 0) && (!rd_fifo_r))
	cnt_y <= 0;
	
//second line shift reg
always @(posedge clk or negedge rst_n) 
if (!rst_n)
	secondline_px <= 0;
else if (out_ready && data_valid) begin
	secondline_px[15:8] <= secondline_px[7:0];
	secondline_px[7:0] <= last_row ? 0 : raw_data;
end

//pix buffer
raw_data_fifo #(.ADDR_W(XBITS)) raw_data_fifo_inst
	
(
	.clk(clk),
	.rst_n(rst_n),
	.rdreq(rd_fifo),
	.wrreq(in_ready && out_ready && data_valid),
	.data_in(raw_data),
	.data_out(fifo_data),
	.empty(fifo_empty),
	.full(fifo_full),
	.usedw(usedw)
);

//first line shift reg
always @(posedge clk or negedge rst_n) 
if (!rst_n)
	firstline_px <= 0;
else if (rd_fifo_r) begin
	firstline_px[15:8] <= firstline_px[7:0];
	firstline_px[7:0] <=  fifo_data;
end

//read fifo 
assign rd_fifo = ((usedw == IM_X -1)  || (last_row && !fifo_empty));
always @(posedge clk or negedge rst_n)
if (!rst_n)
	rd_fifo_r <= 0;
else 
	rd_fifo_r <= rd_fifo;

//processing	
always @(posedge clk or negedge rst_n)
if (!rst_n)
	second_byte <= 0;
else if (start_proc)
	second_byte <= ~second_byte;

always @(posedge clk or negedge rst_n)
if (!rst_n)
	even_line <= 0;
else if (start_proc && ((cnt_x == IM_X - 0) || fifo_empty))
	even_line <= ~even_line;
	
always @(posedge clk or negedge rst_n)
if (!rst_n)
	start_proc <= 0;
else if ((cnt_x == 'd1) && (usedw == IM_X -1))
	start_proc <= 1'b1;
else if (!rd_fifo && !last_row)
	start_proc <= 0;

always @(*)
begin
	case ({even_line, second_byte})
		2'b00 : begin
					Blue = firstline_px[15:8];
					Green = firstline_px[7:0] + secondline_px[15:8];
					Red = secondline_px[7:0];
					
					end
		2'b01 : begin
					Blue = firstline_px[7:0];
					Green = firstline_px[15:8] + secondline_px[7:0];
					Red = secondline_px[15:8];
					
					end
		2'b10 : begin
					Blue = secondline_px[15:8];
					Green = firstline_px[15:8] + secondline_px[7:0];
					Red = firstline_px[7:0];
					
					end
		2'b11 : begin
					Blue = secondline_px[7:0];
					Green = firstline_px[7:0] + secondline_px[15:8];
					Red = firstline_px[15:8];
					
					end
		default : begin
					Blue = 0;
					Green = 0;
					Red = 0;
					
					end
	endcase
end

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	R <= 0;
	G <= 0;
	B <= 0;
	pixel_valid <= 0;
	end
else if (start_proc) begin
	B <= Blue;
	G <= Green[8:1];
	R <= Red;
	pixel_valid <= 1;
		end
else begin
	B <= 0;
	G <= 0;
	R <= 0;
	pixel_valid <= 0;
	end
reg [15:0] val_cnt_x;
always @(posedge clk or negedge rst_n)
if (!rst_n) 
	val_cnt_x <= 0;
else if (pixel_valid)
	val_cnt_x <= val_cnt_x + 1'b1;
else
	val_cnt_x <= 0;

reg [15:0] val_cnt_y;	
always @(posedge clk or negedge rst_n)
if (!rst_n) 
	val_cnt_y <= 0;
else if (val_cnt_x == IM_X - 1)
	val_cnt_y <= val_cnt_y + 1'b1;

endmodule
