////////////////////////////////////////////////////////////////////////////////
// File      : DecodeStage.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-07 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module decode_stage (
    input wire clk,
    input wire rst,

	// Control signal
	input  wire		   stall_D_i,
	input  wire		   instCountEn_D_i,
	input  wire		   stageSignalValid_D_i,
	input  wire		   predictTaken_D_i,

	output wire		   instCountEn_D_o,
	output wire		   stageSignalValid_D_o,
	output wire		   ALUSrcAType_D_o,
	output wire		   ALUSrcBType_D_o,
	output wire [ 7:0] ALUOpcode_D_o,
	output wire 	   memWrite_D_o,
	output wire 	   memRead_D_o,
	output wire 	   regWrite_D_o,
	output wire 	   jump_D_o,
	output wire 	   branch_D_o,
	output wire [ 1:0] writeBackSrcSelect_D_o,
	output wire [ 2:0] funct3_D_o,
	output wire		   system_D_o,
	output wire		   pause_D_o,
	output wire		   mulEn_D_o,
	output wire	[ 1:0] mulOpCode_D_o,
	output wire		   predictTaken_D_o,

	// Data signal
    input wire  [31:0] nextPC_D_i,
    input wire  [31:0] PC_D_i,
    input wire  [31:0] instruction_D_i,
	input wire  [31:0] rs1Data_D_i,
	input wire  [31:0] rs2Data_D_i,


	output wire [31:0] nextPC_D_o,
	output wire [31:0] rs1Data_D_o,
	output wire [31:0] rs2Data_D_o,
	output wire [31:0] PC_D_o,
	output wire [31:0] immExtend_D_o,
	output wire [ 4:0] rd_D_o,
	output wire [ 4:0] rs1Addr_D_o,
	output wire [ 4:0] rs2Addr_D_o,
	output wire	[11:0] funct12_D_o
);
	assign stageSignalValid_D_o		=	stageSignalValid_D_i;
	assign instCountEn_D_o			=	instCountEn_D_i & (~stall_D_i);
	assign  predictTaken_D_o		=	predictTaken_D_i;
	
	wire [ 2:0] immExtendSelect;

	control_unit Controler(
		.opcode (instruction_D_i[ 6: 0]),
		.funct3 (instruction_D_i[14:12]),
		.funct5 (instruction_D_i[31:27]),
		.funct7 (instruction_D_i[31:25]),
		.funct12(instruction_D_i[31:20]),
		
		.ALUSrcAType(ALUSrcAType_D_o),
		.ALUSrcBType(ALUSrcBType_D_o),
		.ALUOpcode(ALUOpcode_D_o),
		.memWrite(memWrite_D_o),
		.memRead(memRead_D_o),
		.regWrite(regWrite_D_o),
		.jump(jump_D_o),
		.branch(branch_D_o),
		.writeBackSrcSelect(writeBackSrcSelect_D_o),
		.immExtendSelect(immExtendSelect),
		.system(system_D_o),
		.pause(pause_D_o),
		.mulOpCode(mulOpCode_D_o),
		.mulEn(mulEn_D_o)
	);
	assign funct3_D_o  	= instruction_D_i[14:12];

	assign nextPC_D_o 	= nextPC_D_i;
	assign PC_D_o 		= PC_D_i;
	assign rd_D_o 		= instruction_D_i[11:7];

	assign rs1Addr_D_o 	= instruction_D_i[19:15];
	assign rs2Addr_D_o 	= instruction_D_i[24:20];
	assign funct12_D_o 	= instruction_D_i[31:20];

	extend extendUnitDecode (
		.instr(instruction_D_i),
		.immExtendSelect(immExtendSelect),
		.immExt(immExtend_D_o)
	);
	
	assign rs1Data_D_o 	= rs1Data_D_i;
	assign rs2Data_D_o 	= rs2Data_D_i;

endmodule