
module top(input ref_12mhz, input rxd, output ant_p, output ant_n, output test1,
	output test2, output [7:0] leds, input [3:0] b);

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

	wire [3:0] b_din;

	SB_IO #( .PIN_TYPE(6'b0000_01), .PULLUP(1'b1)) b1_config (
		.PACKAGE_PIN(b[0]), .D_IN_0(b_din[0]));
	SB_IO #( .PIN_TYPE(6'b0000_01), .PULLUP(1'b1)) b2_config (
		.PACKAGE_PIN(b[1]), .D_IN_0(b_din[1]));
	SB_IO #( .PIN_TYPE(6'b0000_01), .PULLUP(1'b1)) b3_config (
		.PACKAGE_PIN(b[2]), .D_IN_0(b_din[2]));
	SB_IO #( .PIN_TYPE(6'b0000_01), .PULLUP(1'b1)) b4_config (
		.PACKAGE_PIN(b[3]), .D_IN_0(b_din[3]));

	assign ant_p = lo_350mhz && ook;
	assign ant_n = !ant_p;

	reg ready = 0;
	reg reset;

	wire start_burst;
	wire start_packet;
	wire [2:0] cmd;
	wire ook;
	wire sending;

	packet_generator packet_generator (
		ook, sending, ref_12mhz, reset, cmd, start_packet);
	controller controller (.start_packet(start_packet), .cmd(cmd),
		.ref_clk(ref_12mhz), .reset(reset), .rxd(rxd), .b_din(b_din));
		
	always @(posedge ref_12mhz) begin
		if (!ready) begin
			ready <= 1;
			reset <= 1;
		end else
			reset = 0;
	end

	assign test1 = 0;
	assign test2 = 0;

	assign leds[0] = (cmd == 0);
	assign leds[1] = (cmd == 1);
	assign leds[2] = (cmd == 2);
	assign leds[3] = (cmd == 3);
	assign leds[4] = (cmd == 4);
	assign leds[5] = 0;
	assign leds[6] = 0;
	assign leds[7] = sending;
endmodule
