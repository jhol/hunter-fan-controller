module packet_generator(output out, input clk, input reset);

	parameter CTR_WIDTH = 8;
	parameter ID_WIDTH = 4;
	parameter CMD_WIDTH = 7;
	parameter PACKET_OFFSET_WIDTH = 4;

	reg out;
	wire clk, reset;

	reg packet_sending;
	reg data;

	reg [1:0] pwm_phase;
	reg [PACKET_OFFSET_WIDTH : 0] packet_offset;

	wire [ID_WIDTH : 0] id;
	assign id = 4'b1010;

	wire [CMD_WIDTH : 0] cmd;
	assign cmd = 7'b0010111;

	always @(posedge clk)
	begin
		case(packet_offset)
			2: data = id[0];
			3: data = id[1];
			4: data = id[2];
			5: data = id[3];
			6: data = cmd[0];
			7: data = cmd[1];
			8: data = cmd[2];
			9: data = cmd[3];
			10: data = cmd[4];
			11: data = cmd[5];
			12: data = cmd[6];
			default: data = 0;
		endcase

		if (packet_offset == 13)
			packet_sending <= 0;

		case(pwm_phase)
			2'b00 : out <= 0;
			2'b01 : out <= data;
			2'b10 : out <= packet_sending;
		endcase

		if (reset) begin
			pwm_phase <= 0;
			packet_offset <= 0;
			packet_sending <= 1;
		end else if (pwm_phase == 2'b10) begin
			pwm_phase <= 2'b00;
			packet_offset <= packet_offset + 1;
		end else
			pwm_phase <= pwm_phase + 1;
	end

endmodule // counter
