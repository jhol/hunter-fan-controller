module test;
	reg reset = 0;
	reg start = 0;
	initial begin
		$dumpfile("packet_generator.vcd");
		$dumpvars(0, test);

		# 3 reset = 1;
		# 2 reset = 0;
		# 10 start = 1;
		# 2 start = 0;
		# 500000 $finish;
	end

	reg clk = 0;
	always #1 clk = !clk;

	reg [2:0] cmd = 0;

	wire value, sending;
	packet_generator g1 (value, sending, clk, reset, cmd, start);
endmodule
