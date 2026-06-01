module memory_stage (
    input wire clk,
    input wire rst,

	// Control signal
	input  wire		   	stall_M_i,
	input  wire		    instCountEn_M_i,
	input  wire 	    memWrite_M_i,
	input  wire 	    memRead_M_i,
	input  wire 	    regWrite_M_i,
	input  wire  [ 1:0] writeBackSrcSelect_M_i,
	input  wire  [ 2:0] funct3_M_i,
	input  wire			waitRequest_M_i,
	input  wire		    stageSignalValid_M_i,
	input  wire			disableLoadStore_M_i,

	output wire		  	instCountEn_M_o,
	output wire 	    memWrite_M_o,
	output wire 	    memRead_M_o,
	output wire 	    regWrite_M_o,
	output wire			waitRequest_M_o,
	output wire	 [ 1:0] memAccessType_M_o,
	output wire		    stageSignalValid_M_o,

	
	// Data signal
	input  wire [31:0] nextPC_M_i,
	input  wire [31:0] exeResult_M_i,
	input  wire [ 4:0] rd_M_i,
	input  wire [31:0] rs2Data_M_i,
	input  wire [31:0] memDataOut_M_i,

	output wire [ 4:0] rd_M_o,
	output wire [31:0] memDataIn_M_o,
	output wire [31:0] memAddress_M_o,
	output wire [31:0] memDataOut_M_o,
	output wire [31:0] exeResult_M_o,
	output wire [31:0] writeBackResult_M_o
);
	assign stageSignalValid_M_o		= stageSignalValid_M_i;
	assign instCountEn_M_o			= instCountEn_M_i & (~stall_M_i);

	assign regWrite_M_o 			= regWrite_M_i;

	assign rd_M_o					= rd_M_i;
	
	assign exeResult_M_o			= exeResult_M_i;

	assign writeBackResult_M_o 	= (writeBackSrcSelect_M_i == 2'b00) ? nextPC_M_i   :
								  (writeBackSrcSelect_M_i == 2'b01) ? exeResult_M_i:
								   memDataOut_M_o;

	load_store_unit LoadStoreUnit(
		.memRead_M_i(memRead_M_i),
		.memWrite_M_i(memWrite_M_i),
		.waitRequest_M_i(waitRequest_M_i),
		.funct3_M_i(funct3_M_i),
		.disableLoadStore_M_i(disableLoadStore_M_i),

		.memRead_M_o(memRead_M_o),
		.memWrite_M_o(memWrite_M_o),
		.waitRequest_M_o(waitRequest_M_o),
		.memAccessType_M_o(memAccessType_M_o),

		.exeResult_M_i(exeResult_M_i),
		.rs2Data_M_i(rs2Data_M_i),
		.memDataOut_M_i(memDataOut_M_i),

		.memAddress_M_o(memAddress_M_o),
		.memDataIn_M_o(memDataIn_M_o),
		.memDataOut_M_o(memDataOut_M_o)
	);
	
endmodule