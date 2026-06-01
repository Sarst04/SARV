module extend(
	input wire [31:0] instr,
	input wire [2: 0] immExtendSelect,
 	output reg [31:0] immExt
);
	always @(instr, immExtendSelect) begin
		immExt = 0;
		case (immExtendSelect)
 			/* I-immediate */
			3'b000 : immExt = {{21{instr[31]}}, instr[30:25], instr[24:21], instr[20]};
			/* S-immediate */
			3'b001 : immExt = {{21{instr[31]}}, instr[30:25], instr[11: 8], instr[ 7]}; 
 			/* B-immediate */
			3'b010 : immExt = {{20{instr[31]}}, instr[7], instr[30:25], instr[11: 8], 1'b0};
			/* J-immediate */
			3'b011 : immExt = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:25], instr[24:21], 1'b0}; 
			/* U-immediate */
			3'b100 : immExt = {instr[31], instr[30:20], instr[19:12],12'b0};
			default: immExt = 0;
		endcase
	end
endmodule