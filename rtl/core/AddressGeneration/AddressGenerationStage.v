////////////////////////////////////////////////////////////////////////////////
// File      : AddressGenerationStage.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-02-19
// Description:
//   Selection of next PC to fetch instruction
////////////////////////////////////////////////////////////////////////////////
module addressGeneration_stage #(
    parameter BRANCH_PREDICTION_ENTRY_INDEX_BITS = 4,
	parameter RETURN_ADDRESS_PREDICTION_ENTRY_INDEX_BITS = 4
)(
    input wire 			clk,
    input wire 			rst,
	
	// Control signal
	input  wire 		jumpDetect_E_o_A_i,
	input  wire			changePCSrc_C_o_A_i,
	input  wire			branchTakenDetect_E_o_A_i,
	input  wire			branch_E_o_A_i,
	input  wire			predictTaken_E_o_A_i,
	input  wire			callDetected_E_o_A_i,
	input  wire			returnDetected_F_o_A_i,
	input  wire			returnDetected_E_o_A_i,
	input  wire			RASTargetMatch_E_o_A_i,


	output wire			jumpOrBranchFlush_A_o,
	output wire			predictTaken_A_o,

	// Data signal
	input  wire [31:0] 	PCTarget_E_o_A_i,
	input  wire [31:0] 	PCTarget_C_o_A_i,
	input  wire	[31:0]	PC_E_o_A_i,
	input  wire [31:0] 	nextPC_A_i,
	input  wire [31:0]	PC_F_o_A_i,
	input  wire [31:0]	nextPC_E_o_A_i,

	output reg  [31:0] 	selectedPC_A_o,
	output wire [31:0] 	PC_A_o,
	output wire	[31:0]	topOfRas_A_o_D_i
);

	wire		changePCSrcBranchUnitTarget;
	wire		mispredictBranch;
	wire [31:0] PCTargetBranchUnit;

	wire		changePCSrcJumpUnitTarget;
	wire		mispredictJump;
	wire [31:0] PCTargetJumpUnit;

	jump_unit #(
		.ENTRY_INDEX_BITS(RETURN_ADDRESS_PREDICTION_ENTRY_INDEX_BITS)
	) JumpUnit (
    	.clk(clk),
		.rst(rst),
	
		.callDetected_E_o_A_i(callDetected_E_o_A_i),
		.returnDetected_F_o_A_i(returnDetected_F_o_A_i),
		.returnDetected_E_o_A_i(returnDetected_E_o_A_i),
		.jumpDetect_E_o_A_i(jumpDetect_E_o_A_i),
		.targetMatch_E_o_A_i(RASTargetMatch_E_o_A_i),

		.changePCSrcJumpUnitTarget(changePCSrcJumpUnitTarget),
		.mispredictJump(mispredictJump),

		.nextPC_E_o_A_i(nextPC_E_o_A_i),
		.PCTarget_E_o_A_i(PCTarget_E_o_A_i),

		.PCTargetJumpUnit(PCTargetJumpUnit),
		.topOfRas(topOfRas_A_o_D_i)
	);

	branch_prediction_unit #(
		.ENTRY_INDEX_BITS(BRANCH_PREDICTION_ENTRY_INDEX_BITS)
		) BranchPredictionUnit(
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

	assign  jumpOrBranchFlush_A_o 	= mispredictBranch | mispredictJump;

	always @(nextPC_A_i, PCTargetBranchUnit, PCTargetJumpUnit, mispredictBranch, mispredictJump, changePCSrcBranchUnitTarget, changePCSrcJumpUnitTarget) begin
		selectedPC_A_o 		= nextPC_A_i;
		if (mispredictBranch || mispredictJump) begin
			if (mispredictBranch)
				selectedPC_A_o 	= PCTargetBranchUnit;
			if (mispredictJump)
				selectedPC_A_o 	= PCTargetJumpUnit;
		end else if (changePCSrcBranchUnitTarget || changePCSrcJumpUnitTarget) begin
			if (changePCSrcBranchUnitTarget)
				selectedPC_A_o 	= PCTargetBranchUnit;
			if (changePCSrcJumpUnitTarget)
				selectedPC_A_o 	= PCTargetJumpUnit;
		end
	end

	assign	PC_A_o					= (changePCSrc_C_o_A_i	==	1'b0)	?	selectedPC_A_o	:	PCTarget_C_o_A_i;

endmodule