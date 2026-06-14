////////////////////////////////////////////////////////////////////////////////
// File      : ALUAdder.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-01-30 (last modified)
// Description:
//   adder used in ALU
////////////////////////////////////////////////////////////////////////////////


module ALUAdder(
    input  wire [31:0] inA,
    input  wire [31:0] inB,
	input  wire 	   ci,
	
    output wire [31:0] out,
	output wire 	   co
);
    assign {co, out} = inA + inB + ci;
endmodule