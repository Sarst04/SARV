////////////////////////////////////////////////////////////////////////////////
// File      : Multipication1.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-07 (last modified)
// Description:
//   First stage of multiplier including booth decoder and reduction tree
////////////////////////////////////////////////////////////////////////////////
module multipication1 (
    input wire clk,
    input wire rst,

	// Control signal
	input  wire [ 1:0]	mulOpCode_X1_i,
	input  wire			mulEn_X1_i,

	output wire		  	wordSelect_X1_o,
	output wire			mulEn_X1_o,

	
	// Data signal
	input  wire [31:0] rs1Data_X1_i,
	input  wire [31:0] rs2Data_X1_i,

	output wire [63:0] wallaceSum_X1_o,
	output wire [63:0] wallaceCarry_X1_o
);

	wire signA;
	wire signB;

	
	multipicationController Multipication_Controller(
		.mulOpCode(mulOpCode_X1_i),
		.wordSelect(wordSelect_X1_o),	
		.signA(signA),	
		.signB(signB)
	);


	assign mulEn_X1_o		=	mulEn_X1_i;

	wire [31:0] inputA;
	wire [31:0] inputB;

	assign inputA	=	mulEn_X1_i ? rs1Data_X1_i : 32'b0;
	assign inputB	=	mulEn_X1_i ? rs2Data_X1_i : 32'b0;

	wallace_tree wallace_tree(
		.isASigned(signA),
		.isBSigned(signB),
		.a(inputA),
		.b(inputB),
		.wallaceSum(wallaceSum_X1_o),
		.wallaceCarry(wallaceCarry_X1_o)
	);

	
endmodule