`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2015 10:20:20 AM
// Design Name: 
// Module Name: camera_configure
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//source: https://github.com/westonb/OV7670-Verilog

module camera_configure
    #(
    parameter CLK_FREQ=24000000,
	 parameter CAMERA_ADDR = 8'h42,
	 parameter MIF_FILE = "./rtl/cam_config/ov5642_1280p_3_gray_60f.mif",
	 parameter I2C_ADDR_16 = 0,
	 parameter FAST_SIM = 0
    )
    (
    input wire clk,
	 input wire rst_n,
    output wire sioc,
    output wire siod,
	 output wire done
	 
    );
    wire start;
	 wire conf_done;
    wire [9:0] rom_addr;
    wire [15 + 8*I2C_ADDR_16:0] rom_dout;
    wire [7 + 8*I2C_ADDR_16:0] SCCB_addr;
    wire [7:0] SCCB_data;
    wire SCCB_start;
    wire SCCB_ready;
    wire SCCB_SIOC_oe;
    wire SCCB_SIOD_oe;
    
    assign sioc = SCCB_SIOC_oe ? 1'b0 : 1'bZ;
    assign siod = SCCB_SIOD_oe ? 1'b0 : 1'bZ;
	 assign done = FAST_SIM ? 1'b1 : conf_done;
	reg [15:0]	strt;	
	
	always @( posedge clk or negedge rst_n )
	if ( !rst_n ) begin
		strt	<= 0;
		
		end
	else
		
		if ( strt == 16'hffff) 
			strt	<= strt;
		else begin
			strt	<= strt + 1'b1;	
			 
			end
	
    assign start = (strt == 16'hfff0	);
	
		
    OV7670_config_rom # (.I2C_ADDR_16(I2C_ADDR_16),
								 .MIF_FILE(MIF_FILE))
	 rom1(
        .clk(clk),
        .addr(rom_addr),
        .dout(rom_dout)
        );
        
    OV7670_config #(.CLK_FREQ(CLK_FREQ),
						  .I2C_ADDR_16(I2C_ADDR_16)
	 ) 
	 config_1(
        .clk(clk),
        .SCCB_interface_ready(SCCB_ready),
        .rom_data(rom_dout),
        .start(start),
        .rom_addr(rom_addr),
        .done(conf_done),
        .SCCB_interface_addr(SCCB_addr),
        .SCCB_interface_data(SCCB_data),
        .SCCB_interface_start(SCCB_start)
        );
    
    SCCB_interface 
	 #( .CLK_FREQ(CLK_FREQ),
		 .CAMERA_ADDR(CAMERA_ADDR),
		 .I2C_ADDR_16(I2C_ADDR_16)
	 ) 
	 SCCB1(
        .clk(clk),
        .start(SCCB_start),
        .address(SCCB_addr),
        .data(SCCB_data),
        .ready(SCCB_ready),
        .SIOC_oe(SCCB_SIOC_oe),
        .SIOD_oe(SCCB_SIOD_oe)
        );
    
endmodule
