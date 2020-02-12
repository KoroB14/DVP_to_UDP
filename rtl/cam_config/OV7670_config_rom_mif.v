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

module OV7670_config_rom(
    input wire clk,
    input wire [7:0] addr,
    output reg [15:0] dout
    );
    //Included files
	 //OV2640_800p_30f.mif OV2640_1600p_15f.mif OV7670_640p_30f.mif
	reg [15:0] rom [255:0] /* synthesis ram_init_file = "./rtl/cam_config/OV2640_800p_30f.mif" */;
	
	always @ (posedge clk)
	begin
		dout <= rom[addr];
	end

endmodule
