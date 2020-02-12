//////////////////////////////////////////////////////////////////////////////////
// Dmitry Koroteev
// korob14@gmail.com
//////////////////////////////////////////////////////////////////////////////////
module rst_delay
#(
	parameter FAST_SIM = 0
)
(
	input clk,
	input rst_n,
	output reg rst_modules,
	output reg rst_out
);
reg [22:0] rst_cnt;

always @ (posedge clk or negedge rst_n)
if (!rst_n)
	rst_cnt <= 0;
else if (rst_cnt != 23'h7FFFFF)
	rst_cnt <= rst_cnt + 1'b1;

always @ (posedge clk or negedge rst_n)
if (!rst_n) begin
	rst_modules <= 0;
	rst_out <= 0;
	end
else begin
	rst_modules <= FAST_SIM ? rst_n : (rst_cnt >= 23'h1FFFFF);	
	rst_out <= FAST_SIM ? rst_n : (rst_cnt == 23'h7FFFFF);
	end

endmodule
 