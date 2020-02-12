# Copyright (C) 2018  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details.



package require ::quartus::project

set_location_assignment PIN_L21 -to e_gtxc
set_location_assignment PIN_W22 -to e_mdc
set_location_assignment PIN_W21 -to e_mdio
set_location_assignment PIN_N22 -to e_reset
set_location_assignment PIN_F21 -to e_rxc
set_location_assignment PIN_J21 -to e_rxd[7]
set_location_assignment PIN_J22 -to e_rxd[6]
set_location_assignment PIN_H21 -to e_rxd[5]
set_location_assignment PIN_H22 -to e_rxd[4]
set_location_assignment PIN_F22 -to e_rxd[3]
set_location_assignment PIN_E21 -to e_rxd[2]
set_location_assignment PIN_E22 -to e_rxd[1]
set_location_assignment PIN_D21 -to e_rxd[0]
set_location_assignment PIN_D22 -to e_rxdv
set_location_assignment PIN_K22 -to e_rxer
set_location_assignment PIN_R22 -to e_txc
set_location_assignment PIN_V22 -to e_txd[7]
set_location_assignment PIN_U21 -to e_txd[6]
set_location_assignment PIN_U22 -to e_txd[5]
set_location_assignment PIN_R21 -to e_txd[4]
set_location_assignment PIN_P21 -to e_txd[3]
set_location_assignment PIN_P22 -to e_txd[2]
set_location_assignment PIN_N21 -to e_txd[1]
set_location_assignment PIN_M21 -to e_txd[0]
set_location_assignment PIN_M22 -to e_txen
set_location_assignment PIN_V21 -to e_txer
set_location_assignment PIN_T2 -to fpga_gclk
set_location_assignment PIN_J4 -to reset_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_gtxc
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_mdc
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_mdio
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_reset
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxc
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxd[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxd[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxd[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxd[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxd[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxd[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxd[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxd[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxdv
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_rxer
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txc
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txd[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txd[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txd[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txd[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txd[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txd[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txd[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txd[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txen
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to e_txer
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to fpga_gclk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HREF_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PCLK_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VSYNC_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to XCLK_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data_cam[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data_cam[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data_cam[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data_cam[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data_cam[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data_cam[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data_cam[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data_cam[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to on_off_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to res_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sioc
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to siod
set_location_assignment PIN_B8 -to sioc
set_location_assignment PIN_B7 -to siod
set_location_assignment PIN_A8 -to VSYNC_cam
set_location_assignment PIN_A7 -to HREF_cam
set_location_assignment PIN_B2 -to PCLK_cam
set_location_assignment PIN_C1 -to XCLK_cam
set_location_assignment PIN_B1 -to data_cam[7]
set_location_assignment PIN_B3 -to data_cam[6]
set_location_assignment PIN_A3 -to data_cam[5]
set_location_assignment PIN_B4 -to data_cam[4]
set_location_assignment PIN_A4 -to data_cam[3]
set_location_assignment PIN_B5 -to data_cam[2]
set_location_assignment PIN_A5 -to data_cam[1]
set_location_assignment PIN_B6 -to data_cam[0]
set_location_assignment PIN_A6 -to res_cam
set_location_assignment PIN_C2 -to on_off_cam
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to e_gtxc
set_instance_assignment -name SLEW_RATE 2 -to e_gtxc
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to siod
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sioc
