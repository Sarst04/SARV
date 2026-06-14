////////////////////////////////////////////////////////////////////////////////
// File      : ExecuteStage.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-05-31 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module execute_stage (
    input wire 		   clk,
    input wire 		   rst,

	// Controll signal
	input  wire		   stall_E_i,
	input  wire		   instCountEn_E_i,
	input  wire		   stageSignalValid_E_i,
	input  wire 	   ALUSrcAType_E_i,
	input  wire 	   ALUSrcBType_E_i,
	input  wire [ 7:0] ALUOpcode_E_i,
	input  wire 	   memWrite_E_i,
	input  wire 	   memRead_E_i,
	input  wire 	   regWrite_E_i,
	input  wire 	   jump_E_i,
	input  wire 	   branch_E_i,
	input  wire [ 1:0] writeBackSrcSelect_E_i,
	input  wire [ 2:0] funct3_E_i,
	input  wire [ 1:0] forwardA_E_i,
	input  wire [ 1:0] forwardB_E_i,
	input  wire		   pause_E_i,

	output wire		   instCountEn_E_o,
	output wire		   stageSignalValid_E_o,
	output wire 	   memWrite_E_o,
	output wire 	   memRead_E_o,
	output wire 	   regWrite_E_o,
	output wire		   changePCSrc_E_o_A_i,
	output wire [ 1:0] writeBackSrcSelect_E_o,
	output wire [ 2:0] funct3_E_o,
	output wire		   pauseCore_E_o,

	// Data signal
	input  wire [31:0] nextPC_E_i,
	input  wire [ 4:0] rs1Addr_E_i,
	input  wire [ 4:0] rs2Addr_E_i,
	input  wire [31:0] rs1Data_E_i,
	input  wire [31:0] rs2Data_E_i,
	input  wire [31:0] PC_E_i,
	input  wire [31:0] immExtend_E_i,
	input  wire [ 4:0] rd_E_i,
	input  wire [31:0] exeResult_M_o_E_i,
	input  wire [31:0] writeBackResult_W_o_E_i,
	output wire [31:0] nextPC_E_o,
	output wire [31:0] ALUResult_E_o,
	output wire [31:0] rs2Data_E_o,
	output wire [ 4:0] rd_E_o,
	output wire [31:0] rs1Data_E_o
);
	assign stageSignalValid_E_o			=	stageSignalValid_E_i;
	assign instCountEn_E_o				=	instCountEn_E_i & (~stall_E_i);

	wire [31:0]		rs1Data;
	wire [31:0]		rs2Data;

	assign			rs1Data				= (forwardA_E_i == 2'b00) ? rs1Data_E_i	:
										  (forwardA_E_i == 2'b01) ? exeResult_M_o_E_i :
										  (forwardA_E_i == 2'b10) ? writeBackResult_W_o_E_i : 
										   32'bx;

	assign			rs2Data				= (forwardB_E_i == 2'b00) ? rs2Data_E_i	:
										  (forwardB_E_i == 2'b01) ? exeResult_M_o_E_i :
										  (forwardB_E_i == 2'b10) ? writeBackResult_W_o_E_i : 
										   32'bx;

	wire [31:0] 	ALUSrcA;
	assign 	   		ALUSrcA 			= (ALUSrcAType_E_i==0) 	  ? rs1Data 	: PC_E_i;

	wire [31:0] 	ALUSrcB;
	assign 	   		ALUSrcB 			= (ALUSrcBType_E_i==0)    ? rs2Data 	: immExtend_E_i;
	
	wire 			takeBranch;

	pause_unit pauseUnit (
		.clk(clk),
		.rst(rst),
		.pauseReq(pause_E_i),
		.pauseCore(pauseCore_E_o)
	);

	branch_decision branchDecision(
		.srcA(rs1Data),
		.srcB(rs2Data),
		.branch(branch_E_i),
		.branchType(funct3_E_i),
		.takeBranch(takeBranch)
	);

	ALU alu (
		.srcA(ALUSrcA),
		.srcB(ALUSrcB),
		.ALUOpcode(ALUOpcode_E_i),
		.result(ALUResult_E_o)
	);
	assign changePCSrc_E_o_A_i 		= jump_E_i | takeBranch;


	assign memWrite_E_o 			= memWrite_E_i;
	assign memRead_E_o 				= memRead_E_i;
	assign regWrite_E_o 			= regWrite_E_i;
	assign writeBackSrcSelect_E_o 	= writeBackSrcSelect_E_i;
	assign funct3_E_o				= funct3_E_i;
	
	assign nextPC_E_o 				= nextPC_E_i;
	assign rs2Data_E_o 				= rs2Data;
	assign rd_E_o      				= rd_E_i;

	assign rs1Data_E_o 				= rs1Data;

endmodule