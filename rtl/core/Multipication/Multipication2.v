////////////////////////////////////////////////////////////////////////////////
// File      : Multipication2.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-10 (last modified)
// Description:
//   Second stage of multiplier including 64 bit adder and selection logic
////////////////////////////////////////////////////////////////////////////////
module multipication2 (
    input wire clk,
    input wire rst,

	// Control signal
	input  wire 		wordSelect_X2_i,
	input  wire			mulEn_X2_i,

	
	// Data signal
	input  wire [63:0] wallaceSum_X2_i,
	input  wire [63:0] wallaceCarry_X2_i,

	output wire [31:0] mulResult_X2_o
);
	
	
	wire [63:0] inputA;
	wire [63:0] inputB;

	assign inputA	=	mulEn_X2_i ? wallaceSum_X2_i 	: 64'b0;
	assign inputB	=	mulEn_X2_i ? wallaceCarry_X2_i 	: 64'b0;

	wire [63:0]	mulResult;
	
	adder64 adder64 (
		.inA(inputA),
		.inB(inputB),

		.out(mulResult)
	);


	assign mulResult_X2_o	=	wordSelect_X2_i	?	mulResult[63:32]	:	mulResult[31:0]	;
	
endmodule