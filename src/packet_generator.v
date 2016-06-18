module packet_generator(output out, input ref_clk, input reset, input [2:0] cmd,
	input start);

	parameter CTR_WIDTH = 8;
	parameter ID_WIDTH = 4;
	parameter CMD_WIDTH = 7;
	parameter PACKET_OFFSET_WIDTH = 4;

	wire out, clk, reset;

	reg packet_sending;
	reg data, pwm;

	reg [12:0] protocol_clk_phase;

	reg [1:0] pwm_phase;
	reg [PACKET_OFFSET_WIDTH : 0] packet_offset;

	wire [ID_WIDTH : 0] id;
	assign id = 4'b1010;

	reg [CMD_WIDTH : 0] payload;

	reg out;

	always @(*) begin
		case (cmd)
			0: payload <= 7'b1001111;
			1: payload <= 7'b1000111;
			2: payload <= 7'b0100111;
			3: payload <= 7'b0010111;
			4: payload <= 7'b0001111;
			default: payload <= 7'b0000000;
		endcase
	end

	always @(posedge ref_clk)
	begin
		if (protocol_clk_phase == 0) begin
			protocol_clk_phase <= 2202;
		end else begin
			protocol_clk_phase <= protocol_clk_phase - 1;
		end

		if (reset) begin
			packet_sending <= 0;
		end else if (start) begin
			pwm_phase <= 0;
			packet_offset <= 0;
			packet_sending <= 1;
			protocol_clk_phase <= 0;
		end else if (protocol_clk_phase == 0) begin
			if (packet_offset == 13)
				out <= 0;
			else begin
				if (pwm_phase == 2'b10) begin
					pwm_phase <= 2'b00;
					packet_offset <= packet_offset + 1;
				end else
					pwm_phase <= pwm_phase + 1;

				case(packet_offset)
					2: data <= id[0];
					3: data <= id[1];
					4: data <= id[2];
					5: data <= id[3];
					6: data <= payload[0];
					7: data <= payload[1];
					8: data <= payload[2];
					9: data <= payload[3];
					10: data <= payload[4];
					11: data <= payload[5];
					12: data <= payload[6];
					default: data <= 0;
				endcase

				case(pwm_phase)
					2'b00 : out <= 0;
					2'b01 : out <= data;
					2'b10 : out <= 1;
				endcase
			end
		end
	end

endmodule // counter
