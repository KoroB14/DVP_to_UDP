# DVP_to_UDP
Uncompressed video over UDP using 1000BASE-T Ethernet on Cyclone IV FPGA. Videos:

[![Video - OV5642](http://img.youtube.com/vi/Rz6kp0QwiS8/0.jpg)](http://www.youtube.com/watch?v=Rz6kp0QwiS8)

[![Video - OV2640](http://img.youtube.com/vi/DarNFEHpn6I/0.jpg)](http://www.youtube.com/watch?v=DarNFEHpn6I)

# Description
This project contains camera capture module, camera config module and udp packet module.
![](https://habrastorage.org/webt/lz/nl/va/lznlvaijqqndsgeea-8puvztxeq.png)

# Top level module parameters
Top level module parameters define image resolution, color mode (grayscale or RGB565), camera I2C address, Ethernet frame type (Jumbo or ETHII).
| Parameter       | Description                                              							|
| ----------------| ------------------------------------------------------------------------------------|
| IM_X            | Image width                                              							|
| IM_Y            | Image height                                             							|
| COLOR_MODE      | 1 - Grayscale, 2 - RGB565                                							|
| CAMERA_ADDR     | Camera I2C address                                       							|
| MIF_FILE        | Camera registers memory init file                        							|
| ETH_FRAMES      | 0 - Jumbo Frames, 1 - ETH Frames                         							|
| FPGA_PROCESSING | 1 - Convert RGB565 -> 8-bit Grayscale, 2 - No processing, 3 - Convert RAW -> RGB565 |
| I2C_ADDR_16     | 0 - 8-bit I2C address, 1 - 16-bit I2C address            							|
| FAST_SIM        | 0 - Normal mode, 1 - Fast sim mode                       							|

# Camera config module
The camera configuration module initializes camera registers based on mif file and I2C address.

# Camera capture module
When configuration is done, the module waits for VSYNC falling edge and then captures pixel data from the camera by parallel DVP interface. If grayscale mode has been selected, the module converts RGB565 -> RGB888 -> 8-bit grayscale using simple pipeline. Otherwise, pixel data is written straight to the register. 

# RAW to RGB565 converter
Simple RAW to RGB converter. Only BG/GR pattern.

# UDP packet generation
Captured pixel data is written to the dual-clock FIFO. Sending UDP packet begins as far as entire image line is captured. On Jumbo frame selected, entire line fits single UDP packet. Otherwise, image line will be splited for two or four UDP packets, depending on image width. 
In this module you can configure IP and MAC parameters. 

UDP payload structure
                         
| Bytes | Description                                     |
| ------| ------------------------------------------------|
|  0    | PacketID: 0xAA - grayscale, 0xBB - RGB565       |
| 1-2   | IM_X: Image width                               |
| 3-4   | IM_Y: Image height                              |
| 5-6   | PAC_IN_FRAME: Number of packets in whole image  |
| 7-8   | PAC_CNT: Number of current packet               |
| 9-... | Pixel data                                      |

# Testbench
Testbench generates test video stream with defined parameters.

# Hardware
https://github.com/ChinaQMTECH/CYCLONE_IV_STARTER_KIT

# Software
Python-based client captures video stream from socket and shows it using OpenCV. Both Ethernet frame modes are supported. Requirements: Python 3.7+, Numba, NumPy, OpenCV. 