
module top(input ref_12mhz, output ant);

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

	assign ant = lo_350mhz;
endmodule
