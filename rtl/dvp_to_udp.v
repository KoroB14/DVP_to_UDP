`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Dmitry Koroteev
// korob14@gmail.com
//////////////////////////////////////////////////////////////////////////////////
//Included cam registers files
//OV2640_800p_30f.mif OV2640_1600p_15f.mif OV7670_640p_30f.mif
//OV5642_1920p_15f.mif OV5642_1920p_30f_gray_cam_processed.mif OV5642_1280p_30f.mif OV5642_1280p_60f_gray_cam_processed.mif
//OV5642_1280p_60f_RAW.mif
//For cam on-chip processing modes set FPGA_PROCESSING to 2 and COLOR_MODE to 1
//For RAW to RGB conversion set FPGA_PROCESSING to 3 and COLOR_MODE to 2
module dvp_to_udp
#(	parameter IM_X = 1920,
	parameter IM_Y = 1080,
	parameter COLOR_MODE = 1,		// 1 - Grayscale, 2 - RGB565	
	parameter CAMERA_ADDR = 8'h78,// 8'h60 - OV2640, 8'h42 - OV7670, 8'h78 - OV5642
	parameter MIF_FILE = "./rtl/cam_config/OV5642_1920p_30f_gray_cam_processed.mif", // Camera registers init file
	parameter ETH_FRAMES = 0,		// 0 - Jumbo Frames, 1 - ETH Frames: MTU < 1500,
	parameter FPGA_PROCESSING = 2, // 1 - Convert RGB565 -> 8-bit Grayscale, 2 - No processing, 3 - Convert RAW -> RGB565 
	parameter I2C_ADDR_16 = (CAMERA_ADDR == 8'h78),// Enable 16-bit I2C address
	parameter FAST_SIM = 0			// 1- Fast simulation mode
	
)
(					//reset and clock
					input				reset_n,                           
					input				fpga_gclk,
					//ETH
					output			e_reset,
               output			e_mdc,
					inout 			e_mdio,
		
            
					input				e_rxc,	//125Mhz ethernet gmii rx clock
					input				e_rxdv,	
					input				e_rxer,						
					input		[7:0] e_rxd,        

					input				e_txc,	//25Mhz ethernet mii tx clock         
					output			e_gtxc,	//125Mhz ethernet gmii tx clock  
					output			e_txen, 
					output			e_txer, 					
					output 	[7:0] e_txd,
					//Cam DVP & SCCB
					input		[7:0]	data_cam,
					input 			VSYNC_cam,
					input 			HREF_cam,
					input 			PCLK_cam,	
					output			XCLK_cam,
					output			res_cam,
					output			on_off_cam,	
					output			sioc,
					output			siod		
  
    );
                

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire 			main_pll_locked;
wire 			pix_clk;
wire 			hi_clk;
wire			conf_done;
wire 	[7:0] pixdata;
wire 			pixdata_valid;
wire			send;
wire			send_rdreq;
wire	[7:0] send_data;
wire			mii_clk;
wire 			mii_txen;
wire  [3:0] mii_txdata;
wire	[7:0] txdata;
wire			tx_fifo_empty;
wire 			in_ready;
wire			rst_d;
wire			rst_modules;
wire			gtx_clk;
//=======================================================
//  Structural coding
//=======================================================

assign e_gtxc = gtx_clk;
assign e_reset = rst_modules; 
assign e_txer = 0;
assign on_off_cam = 0;

//pll
main_pll	main_pll_inst (
	.areset ( ~reset_n ),
	.inclk0 ( fpga_gclk ),
	.c0 ( pix_clk ),
	.c1 (gtx_clk),
	.locked ( main_pll_locked )
	);
assign XCLK_cam = (CAMERA_ADDR == 8'h78) ? 1'bz : pix_clk;
//rst delay
rst_delay 
#(
	.FAST_SIM(FAST_SIM)
)
rst_delay (
	.clk(fpga_gclk),
	.rst_n(reset_n  & main_pll_locked ),
	.rst_modules(rst_modules),
	.rst_out(rst_d)
);

//camera config

assign res_cam = (CAMERA_ADDR == 8'h78) ? 0 : rst_modules;
camera_configure 
#(	
    .CLK_FREQ 	(	50000000		 ),
	 .CAMERA_ADDR (CAMERA_ADDR),
	 .MIF_FILE(MIF_FILE),
	 .I2C_ADDR_16(I2C_ADDR_16),
	 .FAST_SIM(FAST_SIM)
)
camera_configure_0
(
    .clk			 ( fpga_gclk ),	
	 .rst_n		 ( rst_d),
	 .sioc       ( sioc ),
    .siod       ( siod ),
	 .done       ( conf_done )
	
);

//cam capture

cam_capture 
#(
	.COLOR_MODE(FPGA_PROCESSING),
	.IM_X(IM_X),
	.IM_Y(IM_Y)
)
cam_capture_0
(
	.rst_n				  ( rst_d &conf_done),
	.data_cam           ( data_cam				),
	.VSYNC_cam          ( VSYNC_cam				),
	.HREF_cam           ( HREF_cam				),
	.PCLK_cam           ( PCLK_cam				),
	.gtx_clk				  ( gtx_clk ),
	.pixel				  ( pixdata ),
	.pixel_valid		  ( pixdata_valid ),
	.out_ready			  ( in_ready )

);

//udp packet gen

udp_pkt_gen 
#(
	.IM_X(IM_X),
	.IM_Y(IM_Y),
	.COLOR_MODE(COLOR_MODE),
	.ETH_FRAMES(ETH_FRAMES)
)
pkt_gen
(
	.clk(gtx_clk),
	.wrclk((FPGA_PROCESSING == 3) ? gtx_clk : PCLK_cam),
	.rst_n(rst_d),
	.in_valid(pixdata_valid),
	.in_data(pixdata),
	.in_ready(in_ready),
	.tx_en(e_txen),
	.send_byte(e_txd)
);
endmodule
