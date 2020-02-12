//////////////////////////////////////////////////////////////////////////////////
// Dmitry Koroteev
// korob14@gmail.com
//////////////////////////////////////////////////////////////////////////////////
module udp_pkt_gen
#(
	// "IP source" - put an unused IP 
	parameter IPsource_1 = 192,
	parameter IPsource_2 = 168,
	parameter IPsource_3 = 1,
	parameter IPsource_4 = 100,
	parameter SourcePort = 1024,
	// "IP destination" - put the IP of the PC you want to send to
	parameter IPdestination_1 = 192,
	parameter IPdestination_2 = 168,
	parameter IPdestination_3 = 1,
	parameter IPdestination_4 = 1,
	parameter DestinationPort = 1024,
	// "Physical Address" - put the address of the PC you want to send to - default broadcast
	parameter PhysicalAddress_1 = 8'hff,
	parameter PhysicalAddress_2 = 8'hff,
	parameter PhysicalAddress_3 = 8'hff,
	parameter PhysicalAddress_4 = 8'hff,
	parameter PhysicalAddress_5 = 8'hff,
	parameter PhysicalAddress_6 = 8'hff,
	//FPGA Physical address
	parameter MyAddress_1 = 8'haa,
	parameter MyAddress_2 = 8'hde,
	parameter MyAddress_3 = 8'had,
	parameter MyAddress_4 = 8'hbe,
	parameter MyAddress_5 = 8'hef,
	parameter MyAddress_6 = 8'haa,
	//Frame type
	parameter ETH_FRAMES = 1,
	//Image params
	parameter IM_X = 640,
	parameter IM_Y = 480,
	parameter COLOR_MODE = 1
)
(
	input wire 			clk,
	input wire 			wrclk,
	input wire 			rst_n,
	input wire			in_valid,
	input wire	[7:0]	in_data,
	output wire		in_ready,
	output reg			send,
	output wire			tx_en,
	output reg [7:0]	send_byte,
	
	output reg [31:0] crc32_2
);
`include "CRC32_functions.vh"

localparam XBITS = $clog2(IM_X * COLOR_MODE);
localparam PacketID = (COLOR_MODE == 1) ? 8'hAA : ((COLOR_MODE == 2) ? 8'hBB : 0);
localparam PAC_IN_LINE = (ETH_FRAMES == 1) ? ((IM_X * COLOR_MODE > 2800) ? (4) : 
															((IM_X * COLOR_MODE > 1400) ? (2) : (1))) : 
															(1);
															
//Packet length
localparam header_plus_info = 59;
localparam PAC_IN_FRAME = IM_Y * PAC_IN_LINE;
localparam payload_length = ((IM_X * COLOR_MODE) / PAC_IN_LINE) + 9;
localparam udp_length = payload_length + 8;
localparam IP_length = udp_length + 20;
localparam IP_Length_1 = IP_length[15:8];
localparam IP_Length_2 = IP_length[7:0];
localparam cnt_max = payload_length + 50 + 4;
localparam IFG = 12;
// calculate the IP checksum, big-endian style
localparam IPchecksum1 = 32'h0000C511 + (IP_Length_1 <<8) + IP_Length_2 + (IPsource_1<<8)+IPsource_2+(IPsource_3<<8)+IPsource_4+
                                                                (IPdestination_1<<8)+IPdestination_2+(IPdestination_3<<8)+(IPdestination_4);
localparam IPchecksum2 =  ((IPchecksum1&32'h0000FFFF)+(IPchecksum1>>16));
localparam IPchecksum3 = ~((IPchecksum2&32'h0000FFFF)+(IPchecksum2>>16));
//////////////////////////////////////////////////////////////////////
//State control params
localparam Idle		 =		4'b0000;
localparam SendHeader = 	4'b0001;
localparam SendFifoData = 	4'b0010;
localparam SendCRC 		= 	4'b0100;
localparam SendIFG 		= 	4'b1000;
/////////////////////////////////////////////////////////////////////
reg [3:0] SenderState;
reg [3:0] IFG_count;
reg send_b;
wire send_t;
reg [7:0] send_byte_t;
reg [XBITS-1:0] rdaddress;
reg [7:0] pkt_data;
reg [15:0] pac_cnt;
wire fifo_full, fifo_empty;
wire [7:0] fifo_data;
wire [XBITS-1:0] rdusedw;
reg [3:0]sbyte_cnt;
reg rd_fifo;
assign tx_en = send;


//////////////////////////////////////////////////////////////////////



//Packet data
always @(posedge clk)
case(rdaddress)
// Ethernet preamble
  7'h00: pkt_data <= 8'h55;
  7'h01: pkt_data <= 8'h55;
  7'h02: pkt_data <= 8'h55;
  7'h03: pkt_data <= 8'h55;
  7'h04: pkt_data <= 8'h55;
  7'h05: pkt_data <= 8'h55;
  7'h06: pkt_data <= 8'h55;
  7'h07: pkt_data <= 8'hD5;
// Ethernet header
  7'h08: pkt_data <= PhysicalAddress_1;
  7'h09: pkt_data <= PhysicalAddress_2;
  7'h0A: pkt_data <= PhysicalAddress_3;
  7'h0B: pkt_data <= PhysicalAddress_4;
  7'h0C: pkt_data <= PhysicalAddress_5;
  7'h0D: pkt_data <= PhysicalAddress_6;
  7'h0E: pkt_data <= MyAddress_1;
  7'h0F: pkt_data <= MyAddress_2;
  7'h10: pkt_data <= MyAddress_3;
  7'h11: pkt_data <= MyAddress_4;
  7'h12: pkt_data <= MyAddress_5;
  7'h13: pkt_data <= MyAddress_6;
// IP header
  7'h14: pkt_data <= 8'h08;//0x0800 - IPv4 
  7'h15: pkt_data <= 8'h00;
  7'h16: pkt_data <= 8'h45;
  7'h17: pkt_data <= 8'h00;
  7'h18: pkt_data <= IP_Length_1;
  7'h19: pkt_data <= IP_Length_2;
  7'h1A: pkt_data <= 8'h00;
  7'h1B: pkt_data <= 8'h00;
  7'h1C: pkt_data <= 8'h00;
  7'h1D: pkt_data <= 8'h00;
  7'h1E: pkt_data <= 8'h80;
  7'h1F: pkt_data <= 8'h11;
  7'h20: pkt_data <= IPchecksum3[15:8];
  7'h21: pkt_data <= IPchecksum3[ 7:0];
  7'h22: pkt_data <= IPsource_1;
  7'h23: pkt_data <= IPsource_2;
  7'h24: pkt_data <= IPsource_3;
  7'h25: pkt_data <= IPsource_4;
  7'h26: pkt_data <= IPdestination_1;
  7'h27: pkt_data <= IPdestination_2;
  7'h28: pkt_data <= IPdestination_3;
  7'h29: pkt_data <= IPdestination_4;
// UDP header
  7'h2A: pkt_data <= SourcePort >> 8;
  7'h2B: pkt_data <= SourcePort;
  7'h2C: pkt_data <= DestinationPort >> 8;
  7'h2D: pkt_data <= DestinationPort;
  7'h2E: pkt_data <= udp_length >> 8;
  7'h2F: pkt_data <= udp_length;
  7'h30: pkt_data <= 8'h00;
  7'h31: pkt_data <= 8'h00; 
// payload
  7'h32: pkt_data <= PacketID; // Packet ID
  7'h33: pkt_data <= IM_X ; // IM_X
  7'h34: pkt_data <= IM_X>> 8; // IM_X
  7'h35: pkt_data <= IM_Y ; // IM_Y
  7'h36: pkt_data <= IM_Y>> 8; // IM_Y
  7'h37: pkt_data <= PAC_IN_FRAME ; // Packets in full frame
  7'h38: pkt_data <= PAC_IN_FRAME>> 8; // Packets in full frame
  7'h39: pkt_data <= pac_cnt[7:0]; // Packet number
  7'h3A: pkt_data <= pac_cnt[15:8]; // Packet number

  default: pkt_data <= 8'h00;
endcase

//////////////////////////////////////////////////////////////////////
// Packet counter
always @(posedge clk or negedge rst_n)
if (!rst_n )
	pac_cnt <= 0;
else if (pac_cnt == PAC_IN_FRAME )
	pac_cnt <= 0;
else if ((rdaddress == cnt_max)  )
	pac_cnt <= pac_cnt + 1'b1;
//Pack in line counter
reg [1:0]  pack_in_line_cnt = 0;
generate
if (PAC_IN_LINE > 1) begin: Generate_Pack_in_line_counter
	
	always @(posedge clk or negedge rst_n)
		if (!rst_n)
			pack_in_line_cnt <= 0;
		else if (pack_in_line_cnt == PAC_IN_LINE )
			pack_in_line_cnt <= 0;
		else if (rdaddress == cnt_max)
			pack_in_line_cnt <= pack_in_line_cnt + 1'b1;
end
endgenerate	
//Address
always @(posedge clk or negedge rst_n) 
if (!rst_n)
	rdaddress <= 0;
else if (rdaddress == cnt_max)
	rdaddress <= 0;
else if ((SenderState != Idle) && (SenderState != SendIFG))
	rdaddress <= rdaddress + 1'b1;

//Pixel data fifo
pixel_data_fifo #(XBITS) pixel_data_fifo 
(	
	.rdclk(clk),
	.wrclk(wrclk),
	.rst_n(rst_n),
	.rdreq((SenderState == SendFifoData)  && !fifo_empty),
	.wrreq(in_valid),
	.data_in(in_data),
	.data_out(fifo_data),
	.rdempty(fifo_empty),
	.wrfull(fifo_full),
	.rdusedw(rdusedw)
);
//input ready signal
assign in_ready = ~fifo_full;
//FSM
always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	SenderState <= Idle;
	
	end
else begin: StateControl
	case(SenderState)
		Idle: 			
							begin
								if (PAC_IN_LINE == 1) begin: Generate_One_Packet 
									if (rdusedw >= IM_X * COLOR_MODE)
											SenderState <= SendHeader;
									end
								else if (PAC_IN_LINE == 2) begin: Generate_Two_Packets
									if ((rdusedw >= IM_X * COLOR_MODE && pack_in_line_cnt == 0) || 
										(rdusedw >= (IM_X * COLOR_MODE) / 2 && pack_in_line_cnt == 1))
											SenderState <= SendHeader;
									end
								else if (PAC_IN_LINE == 4) begin: Generate_Four_Packets
									if ((rdusedw >= IM_X * COLOR_MODE && pack_in_line_cnt == 0) || 
										(rdusedw >= (IM_X * COLOR_MODE) *3 / 4 && pack_in_line_cnt == 1) ||
										(rdusedw >= (IM_X * COLOR_MODE) *1 / 2 && pack_in_line_cnt == 2) ||
										(rdusedw >= (IM_X * COLOR_MODE) *1 / 4 && pack_in_line_cnt == 3))
											SenderState <= SendHeader;
									end
							end
							
		SendHeader: 	begin
								if (rdaddress == header_plus_info )
										SenderState <= SendFifoData;
																
							end
		SendFifoData:	begin
								if (rdaddress == header_plus_info + (IM_X * COLOR_MODE) / PAC_IN_LINE)
										SenderState <= SendCRC;
																
							end
		SendCRC:			begin
								if (rdaddress == cnt_max )
										SenderState <= SendIFG;
																
							end
		SendIFG:			begin
								if (IFG_count == IFG -1)
										SenderState <= Idle;
																
							end
		default:			SenderState <= Idle;
						
	endcase
	end

//IFG counter

always @ (posedge clk or negedge rst_n)
if (!rst_n)
	IFG_count <= 0;
else if (SenderState == SendIFG)
	IFG_count <= IFG_count + 1'b1;
else 
	IFG_count <= 0;


assign  send_t = (SenderState != SendIFG) & (SenderState != Idle);
  
//Data Mux
always @ (*) begin: DataMux
case (SenderState)
	Idle: 			send_byte_t = 0;
	SendHeader:		send_byte_t = pkt_data;
	SendFifoData:	send_byte_t = fifo_data;
	SendCRC:			
						begin
						case(rdaddress)
							(cnt_max - 3) : send_byte_t = crc32_2[7:0];
							(cnt_max - 2) : send_byte_t = crc32_2[15:8];
							(cnt_max - 1) : send_byte_t = crc32_2[23:16];
							(cnt_max)     : send_byte_t = crc32_2[31:24];
							default 		  : send_byte_t = 0;
						endcase
					   end
	SendIFG:			send_byte_t = 0;	
	default:			send_byte_t = 0;
endcase
end

//Register output
always @ (posedge clk or negedge rst_n) 
if (!rst_n) begin
	send <= 0;
	send_byte <= 0;
	end
else begin
	send <= send_t;
	send_byte <= send_byte_t;
	end

//count number of bytes sent (to skip crc calc for preamble)

always @(posedge clk or negedge rst_n)
	if(!rst_n)
		sbyte_cnt <= 0;
	else if(send && sbyte_cnt<8)
		sbyte_cnt <= sbyte_cnt + 1;
	else if ((rdaddress == 0) && !send )
		sbyte_cnt <= 0;
	
//Calculate CRC32	
reg [31:0]crc32_;
always @(posedge clk or negedge rst_n)
if (!rst_n)
	crc32_ <= 0;
else
	if((SenderState != Idle) && (sbyte_cnt==8) &&  (rdaddress < cnt_max - 3))
	begin
		crc32_ <= nextCRC32_D8( 
				{
				send_byte_t[0], send_byte_t[1], send_byte_t[2], send_byte_t[3], 
				send_byte_t[4], send_byte_t[5], send_byte_t[6], send_byte_t[7] }
				, crc32_ );
		
	end
	else if (!send && rdaddress == 0)
		crc32_ <= 32'hFFFFFFFF;

//reverse bits and inverse of CRC32

always @(*)
	crc32_2 <= InverseCRC32(crc32_);


endmodule
