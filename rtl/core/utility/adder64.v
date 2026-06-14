////////////////////////////////////////////////////////////////////////////////
// File      : adder64.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-10 (last modified)
// Description:
//   64-bit adder used in multiplier uint
//	 CSA architucture is selected to have a delay near a 32-bit adder
////////////////////////////////////////////////////////////////////////////////
module adder64(
    input  wire [63:0] inA,
    input  wire [63:0] inB,

    output wire [63:0] out
);

	wire [31:0] outLow;
	wire		carryLow;

	wire [31:0] outHigh;
	wire [31:0] outHigh0;
	wire [31:0] outHigh1;
	
		
	assign {carryLow, outLow} = inA[31: 0] + inB[31: 0];

	assign outHigh0			  = inA[63:32] + inB[63:32];
	assign outHigh1			  = inA[63:32] + inB[63:32] + 1;


	assign outHigh	=	carryLow ? outHigh1 : outHigh0;
	assign out		= {outHigh, outLow};
	
	
endmodule