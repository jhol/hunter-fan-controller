
module top(input ref_12mhz, output ant, output test1, output test2);

	wire ref_10mhz, lo_350mhz;
	wire lock0, lock1;

	SB_PLL40_CORE #(.FEEDBACK_PATH("SIMPLE"),
		.PLLOUT_SELECT("GENCLK"),
		.DIVR(2),
		.DIVF(39),
		.DIVQ(4),
		.FILTER_RANGE(3'b001),
	) uut0 (
		.REFERENCECLK(ref_12mhz),
		.PLLOUTCORE(ref_10mhz),
		.LOCK(lock0),
		.RESETB(1'b1),
		.BYPASS(1'b0)
	);

	SB_PLL40_CORE #(.FEEDBACK_PATH("SIMPLE"),
		.PLLOUT_SELECT("GENCLK"),
		.DIVR(0),
		.DIVF(34),
		.DIVQ(0),
		.FILTER_RANGE(3'b001),
	) uut1 (
		.REFERENCECLK(ref_10mhz),
		.PLLOUTCORE(lo_350mhz),
		.LOCK(lock1),
		.RESETB(1'b1),
		.BYPASS(1'b0)
	);

	assign ant = lo_350mhz && ook;

	reg [17:0] packet_timer;

	reg ready = 0;
	reg reset;

	wire start_packet = (packet_timer == 0);

	wire ook;

	packet_generator packet_generator (
		ook, ref_10mhz, reset, start_packet);

	always @(posedge ref_10mhz) begin
		if (!ready) begin
			ready <= 1;
			reset <= 1;
		end else
			reset = 0;

		if (reset) begin
			packet_timer <= 0;
		end else begin
			packet_timer <= packet_timer + 1;
		end
	end

	assign test1 = 0;
	assign test2 = 0;
endmodule
