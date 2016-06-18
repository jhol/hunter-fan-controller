
module top(input ref_12mhz, input rxd, output ant_p, output ant_n, output test1,
	output test2, output led0, output led1, output led2, output led3,
	output led4, output led5, output led6, output led7);

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

	assign ant_p = lo_350mhz && ook;
	assign ant_n = !ant_p;

	reg [17:0] packet_timer;
	reg [7:0] packet_counter;

	reg ready = 0;
	reg reset;
	reg start_packet;

	reg [2:0] cmd;

	wire ook;

	packet_generator packet_generator (
		ook, ref_12mhz, reset, cmd, start_packet);

	wire rxd_data_ready;
	wire [7:0] rxd_data;
	async_receiver rx (
		.clk(ref_12mhz), .RxD(rxd), .RxD_data_ready(rxd_data_ready),
		.RxD_data(rxd_data));

	always @(posedge ref_12mhz) begin
		if (!ready) begin
			ready <= 1;
			reset <= 1;
		end else
			reset = 0;

		if (reset) begin
			packet_timer <= 0;
			packet_counter <= 0;
			cmd <= 7;
		end else begin
			packet_timer <= packet_timer - 1;

			if (packet_timer == 0 && packet_counter != 0) begin
				if (packet_counter == 3)
					cmd <= 7;
				packet_counter <= packet_counter - 1;
				start_packet <= 1;
				packet_timer <= 158400;
			end else
				start_packet <= 0;

			if (rxd_data_ready && packet_counter == 0) begin
				packet_counter <= 220;
				packet_timer <= 0;
				case(rxd_data)
					"0": cmd <= 0;
					"1": cmd <= 1;
					"2": cmd <= 2;
					"3": cmd <= 3;
					"l": cmd <= 4;
				endcase
			end
		end
	end

	assign test1 = 0;
	assign test2 = 0;

	assign led0 = (cmd == 0);
	assign led1 = (cmd == 1);
	assign led2 = (cmd == 2);
	assign led3 = (cmd == 3);
	assign led4 = (cmd == 4);
	assign led5 = 0;
	assign led6 = 0;
	assign led7 = packet_counter != 0;
endmodule
