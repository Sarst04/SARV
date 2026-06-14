////////////////////////////////////////////////////////////////////////////////
// File      : MultipicationController.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-07 (last modified)
// Description:
//   select sign and word
////////////////////////////////////////////////////////////////////////////////
module multipicationController (
	input  wire [ 1:0]	mulOpCode,

	output reg			wordSelect,	
	output reg			signA,	
	output reg			signB
);

	localparam MUL 		= 2'b00;
	localparam MULH 	= 2'b01;
	localparam MULHSU 	= 2'b10;
	localparam MULHU 	= 2'b11;
	

	always @(mulOpCode) begin
		{wordSelect, signA, signB} = 3'b0;

		case (mulOpCode)
			MUL 	: begin
				wordSelect	=	1'b0;
				signA		=	1'b0;
				signB		=	1'b0;
			end
			MULH 	: begin
				wordSelect	=	1'b1;
				signA		=	1'b1;
				signB		=	1'b1;
			end
			MULHSU 	: begin
				wordSelect	=	1'b1;
				signA		=	1'b1;
				signB		=	1'b0;
			end
			MULHU 	: begin
				wordSelect	=	1'b1;
				signA		=	1'b0;
				signB		=	1'b0;
			end
		endcase
	end

endmodule