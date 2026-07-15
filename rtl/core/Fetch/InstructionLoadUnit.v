////////////////////////////////////////////////////////////////////////////////
// File      : InstructionLoadUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-22 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module instruction_load_unit(
	// Control signal
	input  wire 		waitRequest_F_i,
	input  wire			disableInstLoad_F_i,

	output wire			waitRequest_F_o,

	// Data signal
	input  wire [31:0] 	PC_F_i,
	input  wire [31:0] 	instructionMemoryData_F_i,

	output wire [31:0] 	instructionMemoryAddress_F_o,
	output wire			instructionMemoryReadRequest_F_o,
	output wire [31:0] 	instructionMemoryData
);
	assign	instructionMemoryAddress_F_o		=	PC_F_i;
	assign  instructionMemoryData				=	instructionMemoryData_F_i;
	assign  instructionMemoryReadRequest_F_o    =   (disableInstLoad_F_i == 1'b0);


	assign	waitRequest_F_o						=	waitRequest_F_i;

endmodule