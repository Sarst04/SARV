////////////////////////////////////////////////////////////////////////////////
// File      : DecompressController.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-02-04 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module decompress_controller(
	input  wire [31:0]	instruction_F_i,

	output wire			compressedFlag
);
	assign 	compressedFlag	= (instruction_F_i[1:0]	!=	2'b11);

endmodule