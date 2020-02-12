//////////////////////////////////////////////////////////////////////////////////
// Dmitry Koroteev
// korob14@gmail.com
//////////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1 ps

module cam_capture
#(	parameter COLOR_MODE = 1
)
(         
	input wire 					rst_n,
	input wire		[7:0]		data_cam,
	input wire					VSYNC_cam,
	input wire					HREF_cam,
	input wire					PCLK_cam,	
	input wire 					out_ready,
	output wire 	[7:0]		pixel,
	output wire					pixel_valid
	
);
reg 						second_byte;	
reg 						pixdata_valid;
reg 						RGB_valid;
reg						pixel_valid_r;
reg						start;
reg 		[15:0] 		pixdata;	
reg 		[7: 0] 		R, G, B;
reg 		[7: 0]		pixel_r;
wire 						vsync_fall;
//Vsync falling edge detector
detect_falling_edge detect_vsync_fedge
(
	.clk(PCLK_cam),
	.rst_n(rst_n),
	.signal(VSYNC_cam),
	.out(vsync_fall)
);


// Start signal
always @ (posedge PCLK_cam or negedge rst_n)
	if (!rst_n)
		start <= 0;
	else if (vsync_fall & out_ready)
		start <= 1'b1;

//Generate pipeline or reg
generate

if (COLOR_MODE == 1) begin: Generate_Grayscale		
always @( posedge PCLK_cam or negedge rst_n )
		if (!rst_n)
			second_byte		<= 1'h0;
		else
			if (HREF_cam & start)
				second_byte	<= ~second_byte;
			else
				second_byte	<= 1'h0;	
//Capture two bytes			
always @( posedge PCLK_cam or negedge rst_n )
	if (!rst_n) begin
		pixdata	<= 0;
		pixdata_valid <= 0;
		end
	else if (start)
		if (second_byte) begin
				pixdata[7:0]  <= data_cam;
				pixdata_valid <= 1'b1;
				end
		else begin
				pixdata[15:8] <= data_cam;
				pixdata_valid <= 0;
				end
	else 
		pixdata_valid <= 0;
//Convert to RGB888	
always @ (posedge PCLK_cam)
if (!pixdata_valid) begin
	R	<= 0;
	G	<= 0;
	B	<= 0;
	RGB_valid <= 0;
	end
else begin
	R	<= {pixdata[ 15: 11], pixdata[15:13]};
	G	<= {pixdata[10: 5], pixdata[10:9]};
	B	<= {pixdata[ 4: 0], pixdata[4:2]};
	RGB_valid <= 1'b1;
	end
//Convert to grayscale
always @( posedge PCLK_cam)
if (!RGB_valid) begin
	pixel_r <= 0;
	pixel_valid_r <= 0;
	end
else begin
	pixel_r <= (R>>2)+(R>>5)+(G>>1)+(G>>4)+(B>>4)+(B>>5);
	pixel_valid_r <= out_ready;
	end	

end
// Reg for RGB
else if (COLOR_MODE == 2) begin: Generate_RGB
always @( posedge PCLK_cam or negedge rst_n )
	if (!rst_n) begin
		pixel_r <= 0;
		pixel_valid_r <= 0;
		end
	else begin
		pixel_r <= data_cam;
		pixel_valid_r <= HREF_cam & start & out_ready;
		end

end
endgenerate

assign pixel = pixel_r;
assign pixel_valid = pixel_valid_r;	

endmodule


