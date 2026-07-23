////////////////////////////////////////////////////////////////////////////////
// File      : callDetector.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-07-17 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module call_detector (

	input  wire 		jump,
	input  wire [ 4:0]	rd,

	output wire			call
);

	localparam X1 	= 5'b00_001;
	localparam X5 	= 5'b00_101;

	assign call	= jump & ( (rd == X1) | (rd == X5) );

endmodule