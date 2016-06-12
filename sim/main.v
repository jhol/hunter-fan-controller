module test;
	reg reset = 0;
	initial begin
		$dumpfile("protocol.vcd");
		$dumpvars(0, test);

		# 3 reset = 1;
		# 1 reset = 0;
		# 513 $finish;
	end

	reg clk = 0;
	always #1 clk = !clk;

	wire value;
	packet_generator g1 (value, clk, reset);
endmodule
