////////////////////////////////////////////////////////////////////////////////
// File      : LoadStoreUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-02-26 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module load_store_unit(
	// Control signal
	input  wire		   	memRead_M_i,
	input  wire		   	memWrite_M_i,
	input  wire			waitRequest_M_i,
	input  wire	[ 2:0]	funct3_M_i,
	input  wire			disableLoadStore,

	output wire			memRead_M_o,
	output wire			memWrite_M_o,
	output wire			waitRequest_M_o,
	output wire	[ 1:0]	memAccessType_M_o,
	
	// Data signal
	input  wire [31:0] 	exeResult_M_i,
	input  wire [31:0] 	rs2Data_M_i,
	input  wire [31:0] 	memDataOut_M_i,

	output wire [31:0] 	memAddress_M_o,
	output wire [31:0] 	memDataIn_M_o,
	output reg  [31:0] 	memDataOut_M_o
);

	localparam BYTE 			= 3'b000;
	localparam HALFWORD 		= 3'b001;
	localparam WORD 			= 3'b010;
	localparam BYTEUNSIGNED 	= 3'b100;
	localparam HALFWORDNSIGNED 	= 3'b101;

	assign	memAddress_M_o		=	exeResult_M_i;
	assign	memDataIn_M_o		=	rs2Data_M_i;
	assign 	memRead_M_o			=	memRead_M_i  & (disableLoadStore == 1'b0);
	assign 	memWrite_M_o		=	memWrite_M_i & (disableLoadStore == 1'b0);
	assign  waitRequest_M_o 	=   waitRequest_M_i;
	assign  memAccessType_M_o	=	funct3_M_i[1:0];
	

	always @(memDataOut_M_i,  funct3_M_i, memRead_M_i) begin
		memDataOut_M_o	=	32'b0;
		if (memRead_M_i) begin
			case (funct3_M_i)
				BYTE : begin
					memDataOut_M_o	= {{24{memDataOut_M_i[7]}}, memDataOut_M_i[ 7:0]};
				end
				HALFWORD : begin
					memDataOut_M_o	= {{16{memDataOut_M_i[15]}}, memDataOut_M_i[15:0]};
				end
				WORD : begin
					memDataOut_M_o	= memDataOut_M_i;
				end
				BYTEUNSIGNED : begin
					memDataOut_M_o	= {24'b0, memDataOut_M_i[ 7:0]};
				end
				HALFWORDNSIGNED : begin						
					memDataOut_M_o	= {16'b0, memDataOut_M_i[15:0]};
				end
			endcase
		end
	end
endmodule