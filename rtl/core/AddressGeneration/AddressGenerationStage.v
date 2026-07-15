////////////////////////////////////////////////////////////////////////////////
// File      : AddressGenerationStage.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-02-19
// Description:
//   Selection of next PC to fetch instruction
////////////////////////////////////////////////////////////////////////////////
module addressGeneration_stage #(
    parameter BRANCH_PREDICTION_ENTRY_INDEX_BITS = 4
)(
    input wire 			clk,
    input wire 			rst,
	
	// Control signal
	input  wire 		changePCSrc_E_o_A_i,
	input  wire			changePCSrc_C_o_A_i,
	input  wire			branchTakenDetect_E_o_A_i,
	input  wire			branch_E_o_A_i,
	input  wire			predictTaken_E_o_A_i,

	output wire			jumpOrBranchFlush_A_o,
	output wire			predictTaken_A_o,

	// Data signal
	input  wire [31:0] 	PCTarget_E_o_A_i,
	input  wire [31:0] 	PCTarget_C_o_A_i,
	input  wire	[31:0]	PC_E_o_A_i,
	input  wire [31:0] 	nextPC_A_i,
	input  wire [31:0]	PC_F_o_A_i,
	input  wire [31:0]	nextPC_E_o_A_i,

	output wire [31:0] 	selectedPC_A_o,
	output wire [31:0] 	PC_A_o
);

	wire		changePCSrcBranchUnitTarget;
	wire		mispredictBranch;
	wire [31:0] PCTargetBranchUnit;
	wire [31:0] nextPC;

	branch_prediction_unit #(
		.ENTRY_INDEX_BITS(BRANCH_PREDICTION_ENTRY_INDEX_BITS)
		) branchPredictionUnit(
    	.clk(clk),
		.rst(rst),

		.branchTakenDetect_E_o_A_i(branchTakenDetect_E_o_A_i),
		.branch_E_o_A_i(branch_E_o_A_i),
		.predictTaken_E_o_A_i(predictTaken_E_o_A_i),

		.changePCSrcBranchUnitTarget(changePCSrcBranchUnitTarget),
		.mispredictBranch(mispredictBranch),
		.predictTaken_A_o(predictTaken_A_o),

		.PC_F_o_A_i(PC_F_o_A_i),
		.PC_E_o_A_i(PC_E_o_A_i),
		.nextPC_E_o_A_i(nextPC_E_o_A_i),
		.PCTarget_E_o_A_i(PCTarget_E_o_A_i),

		.PCTargetBranchUnit(PCTargetBranchUnit)
	);

	assign  jumpOrBranchFlush_A_o 	= mispredictBranch | changePCSrc_E_o_A_i;

	assign  nextPC					= (changePCSrcBranchUnitTarget == 0)?	nextPC_A_i		:	PCTargetBranchUnit;

	assign	selectedPC_A_o			= (changePCSrc_E_o_A_i	==  1'b0)	?	nextPC			:	PCTarget_E_o_A_i;
	assign	PC_A_o					= (changePCSrc_C_o_A_i	==	1'b0)	?	selectedPC_A_o	:	PCTarget_C_o_A_i;

endmodule