module controller(output start_packet, output [2:0] cmd, input ref_clk,
	input reset, input rxd, input [3:0] b_din);

	reg start_burst;
	reg start_packet;
	reg [2:0] cmd;

	reg [16:0] packet_timer;
	reg [5:0] packet_counter;

	wire rxd_data_ready;
	wire [7:0] rxd_data;
	async_receiver rx (
		.clk(ref_clk), .RxD(rxd), .RxD_data_ready(rxd_data_ready),
		.RxD_data(rxd_data));

	always @(posedge ref_clk) begin
		if (reset) begin
			packet_timer <= 0;
			packet_counter <= 0;
			cmd <= 7;
		end else begin
			packet_timer <= packet_timer - 1;

			if (packet_timer == 0 && packet_counter != 0) begin
				packet_counter <= packet_counter - 1;
				start_packet <= 1;
				packet_timer <= ~0;
			end else
				start_packet <= 0;

			if (packet_counter == 0) begin
				start_burst = 1;
				if (rxd_data_ready) begin
					case(rxd_data)
						"0": cmd <= 0;
						"1": cmd <= 1;
						"2": cmd <= 2;
						"3": cmd <= 3;
						"l": cmd <= 4;
					endcase
				end else if (!b_din[0]) begin
					cmd <= 0;
				end else if (!b_din[1]) begin
					cmd <= 1;
				end else if (!b_din[2]) begin
					cmd <= 2;
				end else if (!b_din[3]) begin
					cmd <= 3;
				end else
					start_burst = 0;

				if (start_burst) begin
					packet_counter <= ~0;
					packet_timer <= 0;
				end
			end
		end
	end
endmodule
