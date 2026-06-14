////////////////////////////////////////////////////////////////////////////////
// File      : WriteBackStage.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-05-26 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module writeBack_stage (
    input wire clk,
    input wire rst,
	
	
	// Control signal
	input  wire		   	stall_W_i,
	input  wire		    instCountEn_W_i,
	input  wire 	   	regWrite_W_i,
	input  wire		    stageSignalValid_W_i,
	
	output wire		  	instCountEn_W_o,
	output wire		   	regWrite_W_o,
	output wire		    stageSignalValid_W_o,


	// Data signal
	input wire  [31:0] 	writeBackResult_W_i,
	input wire  [ 4:0] 	rd_W_i,
		
	output wire [31:0] 	writeBackResult_W_o,
	output wire [ 4:0] 	rd_W_o
);
	assign stageSignalValid_W_o	=	stageSignalValid_W_i;
	assign instCountEn_W_o		=	instCountEn_W_i & (~stall_W_i);

	assign regWrite_W_o 	   	= regWrite_W_i;
	assign rd_W_o 			   	= rd_W_i;


	assign writeBackResult_W_o 	= writeBackResult_W_i;
	
endmodule