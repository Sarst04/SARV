module fetch_stage (
    input wire 			clk,
    input wire 			rst,
	
	// Control signal
	input  wire		   	stall_F_i,
	input  wire			instMemWaitRequest_F_i,
	input  wire			disablePCAdder_F_i,
	input  wire			disableInstructionLoad_F_i,
	
	output wire			instCountEn_F_o,
	output wire			instMemWaitRequest_F_o,
	output wire			stageSignalValid_F_o,
	output wire			instructionMemoryReadRequest_F_o,

	// Data signal
	input  wire [31:0]	PC_F_i,
	input  wire [31:0] 	instructionMemoryData_F_i,

	output wire [31:0] 	instruction_F_o,
	output wire [31:0]  instructionMemoryAddress_F_o,
	output wire [31:0] 	PC_F_o,
	output wire [31:0] 	nextPC_F_o
);
	wire [31:0] 	instructionMemoryData;

	assign	instCountEn_F_o			=	~stall_F_i;
	assign	stageSignalValid_F_o	=	~stall_F_i;

	assign	PC_F_o					=	PC_F_i;
	
	wire		compressedFlag;    
	wire [31:0] decompressInstruction;
	wire [31:0] PCStep;

	assign PCStep			= (compressedFlag == 0)	? 32'd4		  			: 32'd2;
	assign instruction_F_o 	= (compressedFlag == 0)	? instructionMemoryData	: decompressInstruction;

	wire [31:0]	PCAdderInB;
	assign	PCAdderInB		= (disablePCAdder_F_i == 0) ? PCStep			: 32'd0;
	
	instruction_load_unit InstructionLoadUnit(
		.disableInstructionLoad_F_i(disableInstructionLoad_F_i),
		.waitRequest_F_i(instMemWaitRequest_F_i),
		.instructionMemoryReadRequest_F_o(instructionMemoryReadRequest_F_o),
		.waitRequest_F_o(instMemWaitRequest_F_o),
		.PC_F_i(PC_F_i),
		.instructionMemoryData_F_i(instructionMemoryData_F_i),
		.instructionMemoryAddress_F_o(instructionMemoryAddress_F_o),
		.instructionMemoryData(instructionMemoryData)
	);

	decompress_controller DecompressController(
		.instruction_F_i(instructionMemoryData),
		.compressedFlag(compressedFlag)
	);
	
 	decompress_unit DecompressUnit(
		.compressedInst(instructionMemoryData[15:0]),
		.decompressInst(decompressInstruction)
	);

	
    adder pcAdd (
        .inA(PC_F_i),
        .inB(PCAdderInB),
        .out(nextPC_F_o)
    );
endmodule