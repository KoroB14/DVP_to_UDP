`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2015 02:41:55 PM
// Design Name: 
// Module Name: OV7670_config_rom
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

module OV7670_config_rom
	#(parameter I2C_ADDR_16 = 0,
	  parameter MIF_FILE = "./rtl/cam_config/ov5642_1280p_3_gray_60f.mif")
	(
    input wire clk,
    input wire [9:0] addr,
    output reg [15 + 8*I2C_ADDR_16:0] dout
    );
    
	(* ram_init_file = MIF_FILE *) reg [15 + 8*I2C_ADDR_16:0] rom [1023:0];
	
	always @ (posedge clk)
	begin
		dout <= rom[addr];
	end

endmodule
