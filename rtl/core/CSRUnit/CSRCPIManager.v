////////////////////////////////////////////////////////////////////////////////
// File      : CSRCPIManager.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-22 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_CPI_manager(
	input  wire			clk,
	input  wire			rst,

	input  wire	[ 1:0]	priv,
	input  wire	[ 3:0]	CPIRate,
	input  wire [ 7:0]  CPICTRL,

	output wire			stallCore
);

	wire 		enable;
	assign 		enable = CPICTRL[0];

	wire [ 3:0] rate;
	assign 		rate = CPIRate[ 3:0];



	wire [15:0] ringOut;
	ringCounter16bit ringCounter(
		.clk(clk),
		.rst(rst),
	
		.enable(enable),
		.parallelOut(ringOut)
	);


	reg [15:0] stallMask;
	always @(CPIRate, enable) begin
		stallMask = 16'b0;
		if (enable) begin
        	case (rate)
            	16'd0 : stallMask = 16'b0000_0000_0000_0000; // 0% 		stalls ( 0/16 slots)
            	16'd1 : stallMask = 16'b0000_0000_0000_0001; // 6.25% 	stalls ( 1/16 slots)
            	16'd2 : stallMask = 16'b0000_0001_0000_0001; // 12.5% 	stalls ( 2/16 slots)
            	16'd3 : stallMask = 16'b0001_0000_0100_0001; // 18.75% 	stalls ( 3/16 slots)
            	16'd4 : stallMask = 16'b0001_0001_0001_0001; // 25% 	stalls ( 4/16 slots) 
            	16'd5 : stallMask = 16'b0010_0100_1001_0001; // 31.25% 	stalls ( 5/16 slots)
            	16'd6 : stallMask = 16'b0100_1001_0010_0101; // 37.5% 	stalls ( 6/16 slots)
            	16'd7 : stallMask = 16'b0101_0101_0101_0101; // 43.75% 	stalls ( 7/16 slots)
            	16'd8 : stallMask = 16'b0101_0101_0101_0101; // 50% 	stalls ( 8/16 slots)
            	16'd9 : stallMask = 16'b0110_0110_0110_1011; // 56.25% 	stalls ( 9/16 slots)
            	16'd10: stallMask = 16'b0110_1011_0101_1101; // 62.5% 	stalls (10/16 slots)
            	16'd11: stallMask = 16'b0110_1101_1011_0111; // 68.75% 	stalls (11/16 slots)
            	16'd12: stallMask = 16'b0111_0111_0111_0111; // 75% 	stalls (12/16 slots)
            	16'd13: stallMask = 16'b0111_1101_1111_0111; // 81.25% 	stalls (13/16 slots)
            	16'd14: stallMask = 16'b0111_1111_0111_1111; // 87.5% 	stalls (14/16 slots)
            	16'd15: stallMask = 16'b0111_1111_1111_1111; // 93.75% 	stalls (15/16 slots)
        	endcase
		end
	end
	assign stallCore = |(stallMask & ringOut);


endmodule

module ringCounter16bit(
	input  wire				clk,
	input  wire 			rst,

	input  wire				enable,
	output reg	[ 15:0] 	parallelOut
);
	always @(posedge clk, posedge rst) begin
		if (rst)
			parallelOut	<=	16'b1;
		else if (enable)
			parallelOut <= {parallelOut[14:0], parallelOut[15]};
	end	
	
endmodule