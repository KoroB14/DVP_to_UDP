//////////////////////////////////////////////////////////////////////////////////
// Dmitry Koroteev
// korob14@gmail.com
//////////////////////////////////////////////////////////////////////////////////
module detect_falling_edge
(
	input wire clk,
	input wire rst_n,
	input wire signal,
	output reg out
);

reg signal_delayed;

always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	signal_delayed <= 0;
	out <= 0;
	end
else begin
	signal_delayed	<= signal;
	out <= ~signal & signal_delayed;
	end
endmodule
