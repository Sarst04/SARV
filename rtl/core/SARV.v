////////////////////////////////////////////////////////////////////////////////
// SARV RISC-V Core
//
// Copyright (C) 2026 Sayyid Amirreza Sayyid Torabi
//
// This source describes Open Hardware and is licensed under the
// CERN-OHL-S v2.
//
// You may redistribute and modify this source and make products using it
// under the terms of the CERN-OHL-S v2.
//
// This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
// INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
// PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.
//
// Source location:
// https://github.com/sarst04/SARV
//
// As per CERN-OHL-S v2 section 4, should you produce hardware based on this
// source, you must maintain the Source Location visible on the external case
// of the product or in the documentation accompanying the product.
//
// File      : SARV.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-07-14 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module SARV_Core #(
	parameter		   HART_ID = 0,
    parameter 		   BRANCH_PREDICTION_ENTRY_INDEX_BITS = 2,
	parameter		   RETURN_ADDRESS_PREDICTION_ENTRY_INDEX_BITS = 1
)(
    input  wire 	   clk,
    input  wire 	   rst,
	
	input  wire		   MEI,
	input  wire		   MTI,
	input  wire		   MSI,
	
	output wire [31:0] instructionMemoryAddress,
	output wire 	   instructionMemoryReadRequest,
	input  wire [31:0] instructionMemoryData,
	input  wire		   instructionMemoryWaitRequest,

	output wire [31:0] memoryAddress,
	output wire [31:0] memoryWriteData,
	input  wire [31:0] memoryReadData,
	output wire [ 1:0] memoryAccessType,
	output wire 	   memoryWriteRequest,
	output wire 	   memoryReadRequest,
	input  wire		   memoryWaitRequest

);

	// Address Generation Stage
	// Control signal
	wire		jumpDetect_E_o_A_i;
	wire		changePCSrc_C_o_A_i;
	wire		branchTakenDetect_E_o_A_i;
	wire		returnDetected_E_o_A_i;
	wire		RASTargetMatch_E_o_A_i;

	wire		jumpOrBranchFlush_A_o;
	wire		predictTaken_A_o;

	// Data signal
	wire [31:0]	PCTarget_E_o_A_i;
	wire [31:0]	PCTarget_C_o_A_i;
	wire [31:0]	selectedPC_A_o;
	wire [31:0]	PC_A_o;
	wire [31:0]	topOfRas_A_o_D_i;


	// Fetch Stage
	// Control signal
	wire		instMemWaitRequest_F_i;
	wire		disablePCAdder_F_i;
	wire		disableInstLoad_F_i;
	wire		predictTaken_F_i;

	wire		instCountEn_F_o;
	wire		instMemWaitRequest_F_o;
	wire		stageSignalValid_F_o;
	wire		instructionMemoryReadRequest_F_o;
	wire		predictTaken_F_o;
	wire		returnDetected_F_o;

	// Data signal
	wire [31:0] PC_F_i;
	wire [31:0] instructionMemoryData_F_i;
	wire [31:0] instructionMemoryAddress_F_o;
	wire [31:0] instruction_F_o;
	wire [31:0] PC_F_o;
	wire [31:0] nextPC_F_o;

	// Decode Stage
	// Control signall
	wire		instCountEn_D_i;
	wire		stageSignalValid_D_i;
	wire		predictTaken_D_i;
	wire		returnDetected_D_i;

	wire 		mulEn_D_o;
	wire [ 1:0]	mulOpCode_D_o;
	wire		instCountEn_D_o;
	wire 	    ALUSrcAType_D_o;
	wire 	    ALUSrcBType_D_o;
	wire 		branch_D_o;
	wire 		jump_D_o;
	wire [ 7:0] ALUOpcode_D_o;
	wire 		memWrite_D_o;
	wire 		memRead_D_o;
	wire 		regWrite_D_o;
	wire [ 2:0] funct3_D_o;
	wire [ 1:0] writeBackSrcSelect_D_o;
	wire		system_D_o;
	wire		stageSignalValid_D_o;
	wire		pause_D_o;
	wire		predictTaken_D_o;
	wire		returnDetected_D_o;
	wire		RASTargetMatch_D_o;

	// Data signall
	wire [31:0] nextPC_D_i;
	wire [31:0] PC_D_i;
	wire [31:0] instruction_D_i;
	wire [31:0] rs1Data_D_i;
	wire [31:0] rs2Data_D_i;

	wire [31:0] rs1Data_D_o;
	wire [31:0] rs2Data_D_o;
	wire [31:0] PC_D_o;
	wire [31:0] nextPC_D_o;
	wire [31:0] immExtend_D_o;
	wire [ 4:0] rd_D_o;
	wire [ 4:0] rs1Addr_D_o;
	wire [ 4:0] rs2Addr_D_o;
	wire [11:0] funct12_D_o;

	// Execute Stage
	// Control signal
	wire		instCountEn_E_i;
	wire [ 1:0] forwardA_E_i;
	wire [ 1:0] forwardB_E_i;
	wire 	    ALUSrcAType_E_i;
	wire 	    ALUSrcBType_E_i;
	wire 		branch_E_i;
	wire 		jump_E_i;
	wire [ 7:0] ALUOpcode_E_i;
	wire 		memWrite_E_i;
	wire 		memRead_E_i;
	wire 		regWrite_E_i;
	wire [ 2:0] funct3_E_i;
	wire [ 1:0] writeBackSrcSelect_E_i;
	wire		stageSignalValid_E_i;
	wire		pause_E_i;
	wire		predictTaken_E_i;
	wire		returnDetected_E_i;
	wire		RASTargetMatch_E_i;

	wire		jumpDetect_E_o;
	wire		instCountEn_E_o;
	wire [ 1:0] writeBackSrcSelect_E_o;
	wire 		regWrite_E_o;
	wire 		memWrite_E_o;
	wire 		memRead_E_o;
	wire [ 2:0] funct3_E_o;
	wire		stageSignalValid_E_o;
	wire		pauseCore_E_o;
	wire		predictTaken_E_o;
	wire		returnDetected_E_o;
	wire		callDetected_E_o_A_i;
	wire		RASTargetMatch_E_o;

	// Data signal
	wire [31:0] nextPC_E_i;
	wire [31:0] rs1Data_E_i;
	wire [31:0] rs2Data_E_i;
	wire [31:0] PC_E_i;
	wire [31:0] immExtend_E_i;
	wire [ 4:0] rd_E_i;
	wire [ 4:0] rs1Addr_E_i;
	wire [ 4:0] rs2Addr_E_i;

	wire [31:0] nextPC_E_o;
	wire [31:0] ALUResult_E_o;
	wire [31:0] exeResult_E_o;
	wire [31:0] rs2Data_E_o;
	wire [ 4:0] rd_E_o;
	wire [31:0] rs1Data_E_o;

	// Multipication
	// Control signal
	wire 		mulEn_X1_i;
	wire [ 1:0]	mulOpCode_X1_i;
	wire 		mulEn_X2_i;
	wire		wordSelect_X2_i;

	wire		wordSelect_X1_o;
	wire 		mulEn_X1_o;

	// Data signal
	wire [31:0] rs1Data_X1_i;
	wire [31:0] rs2Data_X1_i;
	wire [63:0] wallaceSum_X2_i;
	wire [63:0] wallaceCarry_X2_i;

	wire [63:0] wallaceSum_X1_o;
	wire [63:0] wallaceCarry_X1_o;
	wire [31:0] mulResult_X2_o;
	

	// Memory Stage
	// Control signal
	wire		instCountEn_M_i;
	wire [ 1:0] writeBackSrcSelect_M_i;
	wire 		regWrite_M_i;
	wire 		memWrite_M_i;
	wire 		memRead_M_i;
	wire [ 2:0] funct3_M_i;
	wire		waitRequest_M_i;
	wire		stageSignalValid_M_i;
	wire		disableLoadStore_M_i;

	wire		instCountEn_M_o;
	wire [ 1:0] writeBackSrcSelect_M_o;
	wire 		regWrite_M_o;
	wire 		memWrite_M_o;
	wire 		memRead_M_o;
	wire [ 1:0]	memAccessType_M_o;
	wire		waitRequest_M_o;
	wire		stageSignalValid_M_o;

	// Data signal
	wire [31:0] nextPC_M_i;
	wire [31:0] exeResult_M_i;
	wire [31:0] rs2Data_M_i;
	wire [ 4:0] rd_M_i;
	wire [31:0] memDataOut_M_i;

	wire [31:0] nextPC_M_o;
	wire [31:0] exeResult_M_o;
	wire [31:0] memDataOut_M_o;
	wire [ 4:0] rd_M_o;
	wire [31:0] memDataIn_M_o;
	wire [31:0] memAddress_M_o;	


	// SelectWriteBack Stage
	// Control signal
	wire		instCountEn_S_i;
	wire		stageSignalValid_S_i;
	wire [1:0]  writeBackSrcSelect_S_i;
	wire		regWrite_S_i;

	wire		instCountEn_S_o;
	wire		stageSignalValid_S_o;
	wire 		regWrite_S_o;

	// Data signal
	wire [31:0] mulResult_S_i;
	wire [31:0] nextPC_S_i;
	wire [31:0] exeResult_S_i;
	wire [31:0]	memDataOut_S_i;
	wire [ 4:0] rd_S_i;

	wire [31:0] writeBackResult_S_o;
	wire [ 4:0] rd_S_o;


	// WriteBack Stage
	// Control signal
	wire		instCountEn_W_i;
	wire		regWrite_W_i;
	wire		stageSignalValid_W_i;

	wire 		regWrite_W_o;
	wire		instCountEn_W_o;
	wire		stageSignalValid_W_o;

	// Data signal
	wire [31:0] writeBackResult_W_i;
	wire [ 4:0] rd_W_i;

	wire [ 4:0] rd_W_o;
	wire [31:0] writeBackResult_W_o;


	// Pipe Manager Unit
	wire 		clear_F;
	wire 		clear_D;
	wire 		clear_EC;
	wire 		clear_MX;
	wire 		clear_W;

	wire 		stall_F;
	wire 		stall_D;
	wire 		stall_EC;
	wire 		stall_MX;
	wire 		stall_W;
	wire		stallStatus;

	// CSR Unit
	// Control signal
	wire		system_C_i;
	wire		instCountEn_C_i;
	wire [ 4:0]	pmCounterEn_C_i;

	wire		stallPipe_C_o;
	wire		changeExeSrc_C_o;
	wire		cleanPipe_C_o;

	// Data signal
	wire [31:0] rs1Data_C_i;
	wire [11:0] funct12_C_i;

	wire [31:0] rdData_C_o;

	// stage Valid
	wire		stageDEValid;
	wire		stageDEMValid;
	wire		stageDEMWValid;

	// pipe status
	wire		loadStore;
	wire		changePCSrc;
	wire		multiply;
	wire		regWrite;


 	pipe_manager_unit Pipe_Manager(
		.clk(clk),
		.rst(rst),

		.jumpOrBranchFlush_A_o(jumpOrBranchFlush_A_o),
		.memRead_E(memRead_E_i),
		.memWrite_E(memWrite_E_i),
		.mulEn_X1_i(mulEn_X1_i),
		.regWrite_M(regWrite_M_i),
		.regWrite_W(regWrite_W_i),
		.stallPipe_C_o(stallPipe_C_o),
		.waitRequest_M_o(waitRequest_M_o),
		.waitRequest_F_o(instMemWaitRequest_F_o),
		.coldDownPipe_C_o(coldDownPipe_C_o),
		.cleanPipe_C_o(cleanPipe_C_o),
		.stageDEMWValid(stageDEMWValid),
		.pauseCore_E_o(pauseCore_E_o),

		.disablePCAdder_F_i(disablePCAdder_F_i),
		.clear_F(clear_F),
		.stall_F(stall_F),
		.clear_D(clear_D),
		.stall_D(stall_D),
		.clear_EC(clear_EC),
		.stall_EC(stall_EC),
		.clear_MX(clear_MX),
		.stall_MX(stall_MX),
		.clear_W(clear_W),
		.stall_W(stall_W),
		.stallStatus(stallStatus),
		.disableLoadStore_M_i(disableLoadStore_M_i),
		.disableInstLoad_F_i(disableInstLoad_F_i),

		.rs1Add_D(rs1Addr_D_o),
		.rs2Add_D(rs2Addr_D_o),
		.rs1Add_E(rs1Addr_E_i),
		.rs2Add_E(rs2Addr_E_i),
		.rd_E(rd_E_i),
		.rd_M(rd_M_i),
		.rd_W(rd_W_i),
		.forwardA_E_i(forwardA_E_i),
		.forwardB_E_i(forwardB_E_i)
	);


 	addressGeneration_stage #(
		.BRANCH_PREDICTION_ENTRY_INDEX_BITS(BRANCH_PREDICTION_ENTRY_INDEX_BITS),
		.RETURN_ADDRESS_PREDICTION_ENTRY_INDEX_BITS(RETURN_ADDRESS_PREDICTION_ENTRY_INDEX_BITS)
		) AddressGenerayion (
		.clk(clk),
		.rst(rst),

		.jumpDetect_E_o_A_i(jumpDetect_E_o),
		.changePCSrc_C_o_A_i(changePCSrc_C_o_A_i),
		.branchTakenDetect_E_o_A_i(branchTakenDetect_E_o_A_i),
		.branch_E_o_A_i(branch_E_i),
		.predictTaken_E_o_A_i(predictTaken_E_o),
		.returnDetected_F_o_A_i(returnDetected_F_o),
		.callDetected_E_o_A_i(callDetected_E_o_A_i),
		.returnDetected_E_o_A_i(returnDetected_E_o_A_i),
		.RASTargetMatch_E_o_A_i(RASTargetMatch_E_o_A_i),
		
		.jumpOrBranchFlush_A_o(jumpOrBranchFlush_A_o),
		.predictTaken_A_o(predictTaken_A_o),

		.PCTarget_E_o_A_i(PCTarget_E_o_A_i),
		.PCTarget_C_o_A_i(PCTarget_C_o_A_i),
		.PC_E_o_A_i(PC_E_i),
		.nextPC_A_i(nextPC_F_o),
		.PC_F_o_A_i(PC_F_o),
		.nextPC_E_o_A_i(nextPC_E_o),

		.selectedPC_A_o(selectedPC_A_o),
		.PC_A_o(PC_A_o),
		.topOfRas_A_o_D_i(topOfRas_A_o_D_i)
	);
	assign	changePCSrc	=	jumpOrBranchFlush_A_o | changePCSrc_C_o_A_i;


	assign 	predictTaken_F_i = predictTaken_A_o;
	register #(32) Fetch_Reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_F),
        .clear(clear_F),
        .regIn(  {PC_A_o}),
        .regOut( {PC_F_i})
    );


	fetch_stage Fetch (
		.clk(clk),
		.rst(rst),

		.stall_F_i(stall_F),
		.instMemWaitRequest_F_i(instMemWaitRequest_F_i),
		.disablePCAdder_F_i(disablePCAdder_F_i),
		.disableInstLoad_F_i(disableInstLoad_F_i),
		.predictTaken_F_i(predictTaken_F_i),

		.instCountEn_F_o(instCountEn_F_o),
		.instMemWaitRequest_F_o(instMemWaitRequest_F_o),
		.stageSignalValid_F_o(stageSignalValid_F_o),
		.instructionMemoryReadRequest_F_o(instructionMemoryReadRequest_F_o),
		.predictTaken_F_o(predictTaken_F_o),
		.returnDetected_F_o(returnDetected_F_o),
		
		.PC_F_i(PC_F_i),
		.instructionMemoryData_F_i(instructionMemoryData_F_i),

		.instructionMemoryAddress_F_o(instructionMemoryAddress_F_o),
		.instruction_F_o(instruction_F_o),
		.PC_F_o(PC_F_o),
		.nextPC_F_o(nextPC_F_o)
	);
	
	register #(100) Decode_Reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_D),
        .clear(clear_D),
        .regIn(  {instCountEn_F_o, stageSignalValid_F_o, predictTaken_F_o, returnDetected_F_o
					,PC_F_o, nextPC_F_o, instruction_F_o}),
        .regOut( {instCountEn_D_i, stageSignalValid_D_i, predictTaken_D_i, returnDetected_D_i
					,PC_D_i, nextPC_D_i, instruction_D_i})
    );

	
	decode_stage Decode (
		.clk(clk),
		.rst(rst),

		.stall_D_i(stall_D),
		.instCountEn_D_i(instCountEn_D_i),
		.stageSignalValid_D_i(stageSignalValid_D_i),
		.predictTaken_D_i(predictTaken_D_i),
		.returnDetected_D_i(returnDetected_D_i),

		.stageSignalValid_D_o(stageSignalValid_D_o),
		.instCountEn_D_o(instCountEn_D_o),
		.ALUSrcAType_D_o(ALUSrcAType_D_o),
		.ALUSrcBType_D_o(ALUSrcBType_D_o),
		.branch_D_o(branch_D_o),
		.jump_D_o(jump_D_o),
		.ALUOpcode_D_o(ALUOpcode_D_o),
		.memWrite_D_o(memWrite_D_o),
		.memRead_D_o(memRead_D_o),
		.regWrite_D_o(regWrite_D_o),	
		.funct3_D_o(funct3_D_o),
		.writeBackSrcSelect_D_o(writeBackSrcSelect_D_o),
		.system_D_o(system_D_o),
		.pause_D_o(pause_D_o),
		.mulEn_D_o(mulEn_D_o),
		.mulOpCode_D_o(mulOpCode_D_o),
		.predictTaken_D_o(predictTaken_D_o),
		.returnDetected_D_o(returnDetected_D_o),
		.RASTargetMatch_D_o(RASTargetMatch_D_o),

		.nextPC_D_i(nextPC_D_i),
		.PC_D_i(PC_D_i),
		.instruction_D_i(instruction_D_i),
		.rs1Data_D_i(rs1Data_D_i),
		.rs2Data_D_i(rs2Data_D_i),
		.topOfRas_D_i(topOfRas_A_o_D_i),

		.rs1Data_D_o(rs1Data_D_o),
		.rs2Data_D_o(rs2Data_D_o),
		.PC_D_o(PC_D_o),
		.nextPC_D_o(nextPC_D_o),
		.immExtend_D_o(immExtend_D_o),
		.rd_D_o(rd_D_o),
		.rs1Addr_D_o(rs1Addr_D_o),
		.rs2Addr_D_o(rs2Addr_D_o),
		.funct12_D_o(funct12_D_o)
	);

	register #(204) Execute_Reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_EC),
        .clear(clear_EC),
        .regIn( {instCountEn_D_o, ALUSrcAType_D_o, ALUSrcBType_D_o, ALUOpcode_D_o, memWrite_D_o, memRead_D_o, regWrite_D_o,funct3_D_o, jump_D_o, branch_D_o, writeBackSrcSelect_D_o, stageSignalValid_D_o, pause_D_o, mulEn_D_o,  mulOpCode_D_o , predictTaken_D_o, returnDetected_D_o, RASTargetMatch_D_o 
				,PC_D_o, nextPC_D_o, rs1Data_D_o, rs2Data_D_o, immExtend_D_o, rd_D_o, rs1Addr_D_o, rs2Addr_D_o}),
        .regOut({instCountEn_E_i, ALUSrcAType_E_i, ALUSrcBType_E_i, ALUOpcode_E_i, memWrite_E_i, memRead_E_i, regWrite_E_i,funct3_E_i, jump_E_i, branch_E_i, writeBackSrcSelect_E_i, stageSignalValid_E_i, pause_E_i, mulEn_X1_i, mulOpCode_X1_i, predictTaken_E_i, returnDetected_E_i, RASTargetMatch_E_i
				,PC_E_i, nextPC_E_i, rs1Data_E_i, rs2Data_E_i, immExtend_E_i, rd_E_i, rs1Addr_E_i, rs2Addr_E_i})
    );
	
	assign	stageDEValid	=	stageSignalValid_E_i	|	stageSignalValid_D_i;

	register_file #(32, 5, 32) RegFile(
		.clk(clk),
		.rst(rst),
		.rs1_addr(rs1Addr_D_o),
		.rs1_data(rs1Data_D_i),
		.rs2_addr(rs2Addr_D_o),
		.rs2_data(rs2Data_D_i),
		.rd_addr(rd_W_o),
		.rd_data(writeBackResult_W_o),
		.rd_write_enable(regWrite_W_o)
	);
	


	assign		returnDetected_E_o_A_i = returnDetected_E_o & ~stall_EC;
	assign		jumpDetect_E_o_A_i = jumpDetect_E_o & ~stall_EC;

	execute_stage Execute(
		.clk(clk),
		.rst(rst),
		
		.stall_E_i(stall_EC),
		.stageSignalValid_E_i(stageSignalValid_E_i),
		.instCountEn_E_i(instCountEn_E_i),
		.ALUSrcAType_E_i(ALUSrcAType_E_i),
		.ALUSrcBType_E_i(ALUSrcBType_E_i),
		.ALUOpcode_E_i(ALUOpcode_E_i),
		.memWrite_E_i(memWrite_E_i),
		.memRead_E_i(memRead_E_i),
		.regWrite_E_i(regWrite_E_i),
		.branch_E_i(branch_E_i),
		.jump_E_i(jump_E_i),
		.writeBackSrcSelect_E_i(writeBackSrcSelect_E_i),
		.funct3_E_i(funct3_E_i),
		.forwardA_E_i(forwardA_E_i),
		.forwardB_E_i(forwardB_E_i),
		.pause_E_i(pause_E_i),
		.predictTaken_E_i(predictTaken_E_i),
		.returnDetected_E_i(returnDetected_E_i),
		.RASTargetMatch_E_i(RASTargetMatch_E_i),

		.instCountEn_E_o(instCountEn_E_o),
		.memWrite_E_o(memWrite_E_o),
		.memRead_E_o(memRead_E_o),
		.regWrite_E_o(regWrite_E_o),
		.jumpDetect_E_o(jumpDetect_E_o),
		.branchTakenDetect_E_o_A_i(branchTakenDetect_E_o_A_i),
		.writeBackSrcSelect_E_o(writeBackSrcSelect_E_o),
		.funct3_E_o(funct3_E_o),
		.stageSignalValid_E_o(stageSignalValid_E_o),
		.pauseCore_E_o(pauseCore_E_o),
		.predictTaken_E_o(predictTaken_E_o),
		.callDetected_E_o(callDetected_E_o_A_i),
		.returnDetected_E_o(returnDetected_E_o),
		.RASTargetMatch_E_o(RASTargetMatch_E_o_A_i),

		.nextPC_E_i(nextPC_E_i),
		.rs1Data_E_i(rs1Data_E_i),
		.rs2Data_E_i(rs2Data_E_i),
		.PC_E_i(PC_E_i),
		.immExtend_E_i(immExtend_E_i),
		.rd_E_i(rd_E_i),
		.rs1Addr_E_i(rs1Addr_E_i),
		.rs2Addr_E_i(rs2Addr_E_i),
		.writeBackResult_W_o_E_i(writeBackResult_W_o),
		.exeResult_M_o_E_i(exeResult_M_o),

		.nextPC_E_o(nextPC_E_o),
		.ALUResult_E_o(ALUResult_E_o),
		.rs2Data_E_o(rs2Data_E_o),
		.rd_E_o(rd_E_o),
		.rs1Data_E_o(rs1Data_E_o)
	);

	register #(13) CSR_Reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_EC),
        .clear(clear_EC),
        .regIn( {system_D_o,
				 funct12_D_o}),
        .regOut({system_C_i, 
				 funct12_C_i})
    );

	assign rs1Data_C_i		=	rs1Data_E_o;

	assign pmCounterEn_C_i	=	{regWrite, multiply, changePCSrc, stallStatus, loadStore};

	CSR_unit #(.HART_ID(HART_ID)) CSR(
		.clk(clk),
		.rst(rst),

		.MEI(MEI),
		.MTI(MTI),
		.MSI(MSI),

		.stageDEMWValid_C_i(stageDEMWValid),
		.instCountEn_C_i(instCountEn_C_i),
		.funct3_C_i(funct3_E_i),
		.systemInst_C_i(system_C_i),
		.stallPipe_C_o(stallPipe_C_o),
		.coldDownPipe_C_o(coldDownPipe_C_o),
		.changePCSrc_C_o(changePCSrc_C_o_A_i),
		.changeExeSrc_C_o(changeExeSrc_C_o),
		.cleanPipe_C_o(cleanPipe_C_o),
		.pmCounterEn_C_i(pmCounterEn_C_i),
		
		.PC_E_o_C_i(PC_E_i),
		.PC_A_o_C_i(selectedPC_A_o),
		.rs1Data_C_i(rs1Data_C_i),
		.rdAddr_C_i(rd_E_i),
		.uimm_C_i(rs1Addr_E_i),
		.funct12_C_i(funct12_C_i),
		.rdData_C_o(rdData_C_o),
		.PCTarget_C_o(PCTarget_C_o_A_i)
	);

	assign PCTarget_E_o_A_i =  	ALUResult_E_o;
	assign exeResult_E_o	=	(changeExeSrc_C_o == 1'b0) ? ALUResult_E_o 	  : rdData_C_o;

	register #(111) Memory_Reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_MX),
        .clear(clear_MX),
        .regIn( {instCountEn_E_o, writeBackSrcSelect_E_o, regWrite_E_o, memWrite_E_o, memRead_E_o, funct3_E_o, stageSignalValid_E_o
				 ,nextPC_E_o, exeResult_E_o, rs2Data_E_o, rd_E_o}),

        .regOut({instCountEn_M_i, writeBackSrcSelect_M_i, regWrite_M_i, memWrite_M_i, memRead_M_i, funct3_M_i, stageSignalValid_M_i
				 ,nextPC_M_i, exeResult_M_i, rs2Data_M_i, rd_M_i})
    );

	assign	stageDEMValid	=	stageDEValid	|	stageSignalValid_M_i;	

	assign	loadStore		=	(memRead_M_i	| 	memWrite_M_i) & (~stall_MX);

 	memory_stage Memory(
		.clk(clk),
		.rst(rst),

		.stall_M_i(stall_MX),
		.instCountEn_M_i(instCountEn_M_i),
		.memWrite_M_i(memWrite_M_i),
		.memRead_M_i(memRead_M_i),
		.regWrite_M_i(regWrite_M_i),
		.writeBackSrcSelect_M_i(writeBackSrcSelect_M_i),
		.funct3_M_i(funct3_M_i),
		.waitRequest_M_i(waitRequest_M_i),
		.stageSignalValid_M_i(stageSignalValid_M_i),
		.disableLoadStore_M_i(disableLoadStore_M_i),

		.instCountEn_M_o(instCountEn_M_o),
		.memWrite_M_o(memWrite_M_o),
		.memRead_M_o(memRead_M_o),
		.regWrite_M_o(regWrite_M_o),
		.writeBackSrcSelect_M_o(writeBackSrcSelect_M_o),
		.memAccessType_M_o(memAccessType_M_o),
		.waitRequest_M_o(waitRequest_M_o),
		.stageSignalValid_M_o(stageSignalValid_M_o),

		.nextPC_M_i(nextPC_M_i),
		.exeResult_M_i(exeResult_M_i),
		.rd_M_i(rd_M_i),
		.rs2Data_M_i(rs2Data_M_i),
		.memDataOut_M_i(memDataOut_M_i),

		.nextPC_M_o(nextPC_M_o),
		.exeResult_M_o(exeResult_M_o),
		.rd_M_o(rd_M_o),
		.memDataIn_M_o(memDataIn_M_o),
		.memAddress_M_o(memAddress_M_o),
		.memDataOut_M_o(memDataOut_M_o)
	);

	assign instCountEn_S_i = instCountEn_M_o;
	assign stageSignalValid_S_i = stageSignalValid_M_o;
	assign writeBackSrcSelect_S_i = writeBackSrcSelect_M_o;
	assign regWrite_S_i = regWrite_M_o;

	assign nextPC_S_i = nextPC_M_o;
	assign exeResult_S_i = exeResult_M_o;
	assign memDataOut_S_i = memDataOut_M_o;
	assign rd_S_i = rd_M_o;

 	selectWriteBack_stage SelectWriteBack(
    	.clk(clk),
    	.rst(rst),
	
		.instCountEn_S_i(instCountEn_S_i),
		.stageSignalValid_S_i(stageSignalValid_S_i),
		.writeBackSrcSelect_S_i(writeBackSrcSelect_S_i),
		.regWrite_S_i(regWrite_S_i),
	
		.instCountEn_S_o(instCountEn_S_o),
		.stageSignalValid_S_o(stageSignalValid_S_o),
		.regWrite_S_o(regWrite_S_o),


		.mulResult_S_i(mulResult_S_i),
		.nextPC_S_i(nextPC_S_i),
		.exeResult_S_i(exeResult_S_i),
		.memDataOut_S_i(memDataOut_S_i),
		.rd_S_i(rd_S_i),
		
		.writeBackResult_S_o(writeBackResult_S_o),
		.rd_S_o(rd_S_o)
	);
	

	register #(40) WriteBack_Reg (
        .clk(clk),
        .rst(rst),
        .enable(~stall_W),
        .clear(clear_W),
        .regIn( {instCountEn_S_o, regWrite_S_o, stageSignalValid_S_o
				 ,writeBackResult_S_o, rd_S_o}),
        .regOut({instCountEn_W_i, regWrite_W_i, stageSignalValid_W_i
				 ,writeBackResult_W_i, rd_W_i})
    );

	assign	stageDEMWValid	=	stageDEMValid	|	stageSignalValid_W_i;	

	assign	regWrite		= regWrite_W_i & (~stall_W);
	writeBack_stage WriteBack(
		.clk(clk),
		.rst(rst),

		.stall_W_i(stall_W),
		.instCountEn_W_i(instCountEn_W_i),
		.regWrite_W_i(regWrite_W_i),
		.stageSignalValid_W_i(stageSignalValid_W_i),

		.instCountEn_W_o(instCountEn_W_o),
		.regWrite_W_o(regWrite_W_o),
		.stageSignalValid_W_o(stageSignalValid_W_o),

		.writeBackResult_W_i(writeBackResult_W_i),
		.rd_W_i(rd_W_i),
		.writeBackResult_W_o(writeBackResult_W_o),
		.rd_W_o(rd_W_o)
	);


	assign rs1Data_X1_i	= rs1Data_E_o;
	assign rs2Data_X1_i	= rs2Data_E_o;

	multipication1 Multipication1(
		.clk(clk),
		.rst(rst),
		
		.mulOpCode_X1_i(mulOpCode_X1_i),
		.mulEn_X1_i(mulEn_X1_i),

		.wordSelect_X1_o(wordSelect_X1_o),
		.mulEn_X1_o(mulEn_X1_o),

		.rs1Data_X1_i(rs1Data_X1_i),
		.rs2Data_X1_i(rs2Data_X1_i),

		.wallaceSum_X1_o(wallaceSum_X1_o),
		.wallaceCarry_X1_o(wallaceCarry_X1_o)
	);
		
	register #(130) Mul_Reg (
        .clk(clk),
        .rst(rst),

        .enable(~stall_MX),
        .clear(clear_MX),
        .regIn( {wordSelect_X1_o, mulEn_X1_o
				 ,wallaceSum_X1_o, wallaceCarry_X1_o}),
        .regOut({wordSelect_X2_i, mulEn_X2_i
				 ,wallaceSum_X2_i, wallaceCarry_X2_i})
    );

	multipication2 Multipication2(
        .clk(clk),
        .rst(rst),

		.wordSelect_X2_i(wordSelect_X2_i),
		.mulEn_X2_i(mulEn_X2_i),

		.wallaceSum_X2_i(wallaceSum_X2_i),
		.wallaceCarry_X2_i(wallaceCarry_X2_i),

		.mulResult_X2_o(mulResult_X2_o)
	);
	assign mulResult_S_i					= mulResult_X2_o;
	assign multiply							= mulEn_X1_i & (~stall_EC);

	
	assign instCountEn_C_i					= instCountEn_W_o;
	
	assign instructionMemoryAddress 		= instructionMemoryAddress_F_o;
	assign instructionMemoryReadRequest 	= instructionMemoryReadRequest_F_o;
	assign instructionMemoryData_F_i		= instructionMemoryData;
	assign instMemWaitRequest_F_i			= instructionMemoryWaitRequest;

	assign memoryAddress 					= memAddress_M_o;
	assign memoryWriteData 					= memDataIn_M_o;
	assign memDataOut_M_i					= memoryReadData;
	assign memoryAccessType					= memAccessType_M_o;
	assign memoryWriteRequest				= memWrite_M_o;
	assign memoryReadRequest 				= memRead_M_o;
	assign waitRequest_M_i					= memoryWaitRequest;
endmodule
