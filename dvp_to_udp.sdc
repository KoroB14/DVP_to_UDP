#########################################################
## Dmitry Koroteev
## korob14@gmail.com
#########################################################
set_time_format -unit ns -decimal_places 3
#OV7670
#set PCLK_FREQ "24MHz"
#OV2640 800x600x30
#set PCLK_FREQ "48MHz"
#OV2640 1600x1200x15
#set PCLK_FREQ "72MHz"
#OV5642
set PCLK_FREQ "96MHz"

#set CAM_DATA_DELAY 5.000
set CAM_DATA_DELAY 2.500
# Clock constraints
create_clock -name "e_rxc" -period 8.000ns [get_ports {e_rxc}] -waveform {0.000 4.000}
create_clock -period 20.000 -waveform {0.000 10.000} -name fpga_gclk [get_ports {fpga_gclk}]
create_clock -name {PCLK_cam} -period $PCLK_FREQ [get_ports {PCLK_cam}]
create_clock -name {virt_clk} -period $PCLK_FREQ

# Create Generated Clock
create_generated_clock -source {main_pll_inst|altpll_component|auto_generated|pll1|inclk[0]} -divide_by 25 -multiply_by 3 -duty_cycle 50.00 -name {pix_clk} {main_pll_inst|altpll_component|auto_generated|pll1|clk[0]}
create_generated_clock -source {main_pll_inst|altpll_component|auto_generated|pll1|inclk[0]} -divide_by 2 -multiply_by 5 -duty_cycle 50.00 -name {gtx_clk} {main_pll_inst|altpll_component|auto_generated|pll1|clk[1]}
create_generated_clock -name {e_gtxc} -source [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  [get_ports {e_gtxc}]

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

#false pathes
set_false_path -from [get_ports {reset_n}] -to {*}
set_false_path -from [get_registers {rst_delay:rst_delay|rst_modules}] -to {*}
set_false_path -to [get_ports {on_off_cam}]
set_false_path -to [get_ports {res_cam}]
set_false_path -to [get_ports {sioc}]
set_false_path -to [get_ports {siod}]

# Set Clock Groups
set_clock_groups -exclusive -group [get_clocks {PCLK_cam virt_clk}] 
set_clock_groups -asynchronous -group [get_clocks {PCLK_cam}] -group [get_clocks {gtx_clk}] 
set_clock_groups -asynchronous -group [get_clocks {fpga_gclk}] -group [get_clocks {gtx_clk}] 
#create the input delay referencing the virtual clock
#specify the maximum external clock delay from the external
#device
set CLKAs_max 0.0
#specify the minimum external clock delay from the external
#device
set CLKAs_min 0.0
#specify the maximum external clock delay to the FPGA
set CLKAd_max [expr 50*0.007]
#specify the minimum external clock delay to the FPGA
set CLKAd_min [expr 50*0.007]
#specify the maximum clock-to-out of the external device
set tCOa_max $CAM_DATA_DELAY
#specify the minimum clock-to-out of the external device
set tCOa_min 0
#specify the maximum board delay
set BDa_max [expr 50*0.007]
#specify the minimum board delay
set BDa_min [expr 50*0.007]

set_input_delay -add_delay -min -clock_fall -clock [get_clocks {virt_clk}]  [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {HREF_cam}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {virt_clk}]  [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {VSYNC_cam}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {virt_clk}]  [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {data_cam[*]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {virt_clk}]  [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {HREF_cam}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {virt_clk}]  [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {VSYNC_cam}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {virt_clk}]  [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {data_cam[*]}]


# Output delay
#specify the maximum external clock delay to the external device
set CLKd_max [expr 50*0.007]
#specify the minimum external clock delay to the external device
set CLKd_min [expr 50*0.007]
#specify the maximum setup time of the external device
set tSU 2.0
#specify the hold time of the external device
set tH 0.0
#specify the maximum board delay
set BD_max [expr 50*0.007]
#specify the minimum board delay
set BD_min [expr 50*0.007]

set_output_delay -clock [get_clocks {e_gtxc}] -max [expr $BD_max + $tSU - $CLKd_min] [get_ports {e_txen}] 
set_output_delay -clock [get_clocks {e_gtxc}] -max [expr $BD_max + $tSU - $CLKd_min] [get_ports {e_txd[*]}] 
set_output_delay -clock [get_clocks {e_gtxc}] -min [expr $BD_min - $tH - $CLKd_max] [get_ports {e_txen}] 
set_output_delay -clock [get_clocks {e_gtxc}] -min [expr $BD_min - $tH - $CLKd_max] [get_ports {e_txd[*]}] 

# tpd constraints

set_max_delay 5.000ns -from [get_clocks {pix_clk}] -to [get_ports {XCLK_cam}]
set_min_delay 0.000ns -from [get_clocks {pix_clk}] -to [get_ports {XCLK_cam}]

