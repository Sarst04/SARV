////////////////////////////////////////////////////////////////////////////////
// File      : ReturnDetector.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-07-17 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module return_detector (

	input  wire [31:0]	instruction,

	output wire			return
);
	localparam JALR = 7'b11_001_11;
	localparam X0 	= 5'b00_000;
	localparam X1 	= 5'b00_001;
	localparam X5 	= 5'b00_101;

	wire [ 6:0]	opcode	= instruction[ 6: 0];
	wire [ 4:0] rd     	= instruction[11: 7];
    wire [ 4:0] rs1    	= instruction[19:15];


	assign return	= (opcode == JALR) & ( (rs1 == X1)|(rs1 == X5) ) & (rd == X0);

endmodule