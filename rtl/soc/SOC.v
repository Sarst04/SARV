module SOC(
	input wire  clk,
	input wire  rst,
	input wire	MSI,
	input wire  MEI
);
	localparam	INSTRUCTION_MEMORY_BASE_ADDR	= 32'h0000_0000;
	localparam	INSTRUCTION_MEMORY_END_ADDR		= INSTRUCTION_MEMORY_BASE_ADDR + 32'd70000;

	localparam	DATA_MEMORY_BASE_ADDR			= 32'h8000_0000;
	localparam	DATA_MEMORY_END_ADDR			= DATA_MEMORY_BASE_ADDR + 32'd70000;

	localparam	CLINT_BASE_ADDR					= 32'hfff4_0000;
	localparam	CLINT_END_ADDR					= CLINT_BASE_ADDR + 32'hBFFF;


	wire [31:0] instructionMemoryAddress;
	wire [31:0] instructionMemoryData;
	wire 		instructionMemoryWaitRequest;
	wire		instructionMemoryReadRequest;

	wire [ 1:0] MemoryAccessType;
	wire 		MemoryWriteRequest;
	wire		MemoryReadRequest;
	wire [31:0] MemoryAddress;
	wire [31:0] MemoryWriteData;
	wire [31:0] MemoryReadData;
	wire		MemoryWaitRequest;

	wire		MTI;


	wire		dataMemorySelect;
	wire [31:0]	DataMemoryReadData;
	wire		clintSelect;
	wire [31:0]	clintReadData;
	wire		instructionMemorySelect;
	wire [31:0]	instructionMemoryReadData;

	assign		dataMemorySelect 		= (MemoryAddress >= DATA_MEMORY_BASE_ADDR) & 
										  (MemoryAddress <= DATA_MEMORY_END_ADDR);

	assign		clintSelect 			= (MemoryAddress >= CLINT_BASE_ADDR)  & 
										  (MemoryAddress <= CLINT_END_ADDR );

	assign		instructionMemorySelect	= (MemoryAddress >= INSTRUCTION_MEMORY_BASE_ADDR)  & 
										  (MemoryAddress <= INSTRUCTION_MEMORY_END_ADDR);


	assign 		MemoryReadData		= (dataMemorySelect 		== 1'b1) ? DataMemoryReadData :
									  (clintSelect 				== 1'b1) ? clintReadData :
									  (instructionMemorySelect 	== 1'b1) ? instructionMemoryReadData :
										32'bz;

	SARV_Core Core(
    	.clk(clk),
		.rst(rst),

		.MEI(MEI),
		.MTI(MTI),
		.MSI(MSI),

		.instructionMemoryAddress(instructionMemoryAddress),
		.instructionMemoryReadRequest(instructionMemoryReadRequest),
		.instructionMemoryData(instructionMemoryData),
		.instructionMemoryWaitRequest(instructionMemoryWaitRequest),

		.memoryAddress(MemoryAddress),
		.memoryWriteData(MemoryWriteData),
		.memoryAccessType(MemoryAccessType),
		.memoryWriteRequest(MemoryWriteRequest),
		.memoryReadRequest(MemoryReadRequest),
		.memoryReadData(MemoryReadData),
		.memoryWaitRequest(MemoryWaitRequest)
	);

	instructionMemoryModel #(INSTRUCTION_MEMORY_END_ADDR - INSTRUCTION_MEMORY_BASE_ADDR) instructionMem(
    	.clk(clk),
		.rst(rst),

		.readRequestA(instructionMemoryReadRequest),
		.addrA(instructionMemoryAddress - INSTRUCTION_MEMORY_BASE_ADDR),
		.dataOutA(instructionMemoryData),
		.accessTypeA(2'b10),
		.waitRequestA(instructionMemoryWaitRequest),

		.readRequestB(MemoryReadRequest),
		.addrB(MemoryAddress - INSTRUCTION_MEMORY_BASE_ADDR),
		.dataOutB(instructionMemoryReadData),
		.accessTypeB(MemoryAccessType),
		.waitRequestB()
	);

	dataMemoryModel #(DATA_MEMORY_END_ADDR - DATA_MEMORY_BASE_ADDR) DataMem(
    	.clk(clk),
		.rst(rst),

		.readRequest(MemoryReadRequest),
		.writeRequest(MemoryWriteRequest),
		.chipSelect(dataMemorySelect),

		.accessType(MemoryAccessType),
		.address(MemoryAddress - DATA_MEMORY_BASE_ADDR),
		.dataIn(MemoryWriteData),
		.dataOut(DataMemoryReadData),
		.waitRequest(MemoryWaitRequest)
	);

	clint CLINT(
    	.clk(clk),
		.rst(rst),
		.readRequest(MemoryReadRequest),
		.writeRequest(MemoryWriteRequest),
		.chipSelect(clintSelect),
		.MTI(MTI),
		.address(MemoryAddress - CLINT_BASE_ADDR),
		.dataIn(MemoryWriteData),
		.dataOut(clintReadData)
	);

endmodule