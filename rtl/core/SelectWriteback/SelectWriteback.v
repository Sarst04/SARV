////////////////////////////////////////////////////////////////////////////////
// File      : SelectWriteback.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-07 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module selectWriteBack_stage (
    input wire clk,
    input wire rst,
	
	
	// Control signal
	input  wire		    instCountEn_S_i,
	input  wire		    stageSignalValid_S_i,
	input  wire [1:0]  	writeBackSrcSelect_S_i,
	input  wire 	   	regWrite_S_i,
	
	output wire		  	instCountEn_S_o,
	output wire		    stageSignalValid_S_o,
	output wire		   	regWrite_S_o,


	// Data signal
	input wire  [31:0] 	mulResult_S_i,
	input wire  [31:0] 	nextPC_S_i,
	input wire  [31:0] 	exeResult_S_i,
	input wire  [31:0] 	memDataOut_S_i,
	input wire  [ 4:0] 	rd_S_i,
		
	output wire [31:0] 	writeBackResult_S_o,
	output wire [ 4:0] 	rd_S_o
);

	assign instCountEn_S_o			=	instCountEn_S_i;
	assign stageSignalValid_S_o		=	stageSignalValid_S_i;
	assign regWrite_S_o				=	regWrite_S_i;


	assign writeBackResult_S_o 	= (writeBackSrcSelect_S_i == 2'b00) ? nextPC_S_i   :
								  (writeBackSrcSelect_S_i == 2'b01) ? exeResult_S_i:
								  (writeBackSrcSelect_S_i == 2'b10) ? memDataOut_S_i:
								   mulResult_S_i;


	assign rd_S_o 			   	= rd_S_i;


	
endmodule