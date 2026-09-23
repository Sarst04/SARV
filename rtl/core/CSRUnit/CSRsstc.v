////////////////////////////////////////////////////////////////////////////////
// File      : CSRsstc.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-09-22 (last modified)
// Description:
//   Sstc Extension for Supervisor-mode Timer Interrupts
////////////////////////////////////////////////////////////////////////////////
module CSR_sstc_unit(
	input  wire 		clk,
	input  wire 		rst,

	output wire			STI,
	
	input  wire [31:0] 	stimecmp,
	input  wire [31:0] 	stimehcmp,

	input  wire [31:0] 	mtime,
	input  wire [31:0] 	mtimeh
);

	assign STI = ({mtimeh, mtime} >= {stimehcmp, stimecmp});

endmodule
