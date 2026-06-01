module CSR_unit(
	input wire 			clk,
	input wire			rst,
	
	// Control signal
	input  wire 		MEI,
	input  wire 		MTI,
	input  wire 		MSI,
	input  wire [ 2:0] 	funct3_C_i,
	input  wire 		systemInst_C_i,
	input  wire		    instCountEn_C_i,
	input  wire			stageDEMWValid_C_i,
	input  wire	[ 2:0]	pmCounterEn_C_i,

	output wire			cleanPipe_C_o,
	output wire 		stallPipe_C_o,
	output wire 		coldDownPipe_C_o,
	output wire			changePCSrc_C_o,
	output wire			changeExeSrc_C_o,

	// Data signal
	input  wire [31:0]  PC_E_o_C_i,
	input  wire [31:0]  PC_A_o_C_i,
	input  wire [31:0]  rs1Data_C_i,
	input  wire [ 4:0] 	rdAddr_C_i,
	input  wire [ 4:0] 	uimm_C_i,
	input  wire [11:0]	funct12_C_i,

	output wire [31:0] 	rdData_C_o,
	output wire [31:0] 	PCTarget_C_o
);
	wire [31:0]	CSRWtiteData;
	wire [31:0]	CSRData;
	wire [11:0]	CSRAddr;

	wire [31:0]	mipInput;
	assign		mipInput	=	{20'b0, MEI, 3'b0, MTI, 3'b0, MSI, 3'b0};

	// CSR registers
	wire [31:0] mvendoridData;
	wire [31:0] marchidData;
	wire [31:0] mimpidData;
	wire [31:0] mhartidData;
	wire [31:0] mconfigptrData;
	wire [31:0] mstatusData;
	wire		mstatusEn;
	wire [31:0] mstatusIn;
	wire		mstatusEn2;
	wire [31:0] misaData;
	wire [31:0] mieData;
	wire		mieEn;
	wire [31:0] mtvecData;
	wire		mtvecEn;
	wire [31:0] mscratchData;
	wire		mscratchEn;
	wire [31:0] mepcData;
	wire		mepcEn;
	wire [31:0] mepcIn;
	wire		mepcEn2;
	wire [31:0] mcauseData;
	wire	 	mcauseEn;
	wire [31:0] mcauseIn;
	wire	 	mcauseEn2;
	wire [31:0] mtvalData;
	wire		mtvalEn;
	wire [31:0] mtvalIn;
	wire		mtvalEn2;
	wire [31:0] mipData;

	wire 		mcycleEn;
	wire [31:0] mcycleData;
	wire 		mcyclehEn;
	wire [31:0] mcyclehData;
	wire [31:0] mhpmcounter3Data;
	wire 		mhpmcounter3En;
	wire [31:0] mhpmcounter4Data;
	wire 		mhpmcounter4En;
	wire [31:0] mhpmcounter5Data;
	wire 		mhpmcounter5En;
	wire [31:0] mhpmcounter6Data;
	wire 		mhpmcounter6En;
	wire [31:0] mhpmcounter7Data;
	wire 		mhpmcounter7En;
	wire 		minstretEn;
	wire [31:0] minstretData;
	wire 		minstrethEn;
	wire [31:0] minstrethData;
	wire		minstretCountEnable;
	wire 		mcountinhibitEn;
	wire [31:0] mcountinhibitData;

	wire		mcpirateEn;
	wire [ 3:0]	mcpirateData;
	wire		mcpictrlEn;
	wire [ 7:0]	mcpictrlData;

	// CSR Controller
	wire		PassCSRData;
	wire		PassCSRAddr;
	wire [ 1:0] operation;
	wire		CSRDataSelect;
	wire		ecall;
	wire		mret;
	wire		wfi;
	wire		CSRAccess;

	wire		return;

	//CSR Inter Interrupt Controller
	wire		raiseInterrupt;
	wire		irqReady;
	wire [31:0]	interruptCause;

	// stall Pipe
	wire		stallPipeSleepingUnit;
	wire		stallPipeCPIUnit;
	assign		stallPipe_C_o	=	stallPipeSleepingUnit	|	stallPipeCPIUnit;
	
	assign	minstretCountEnable	=	instCountEn_C_i;

	wire		systemOrTrapCe;

 	CSR_trap_handler CSRTrapHandler(
		.mret(mret),
		.ecall(ecall),
		.raiseInterrupt(raiseInterrupt),
		.return(return),
		.mcauseEn(mcauseEn2),
		.mtvalEn(mtvalEn2),
		.mepcEn(mepcEn2),
		.mstatusEn(mstatusEn2),
		.changePCSrc(changePCSrc_C_o),
		.cleanPipe(cleanPipe_C_o),

		.interruptCause(interruptCause),
		.mstatus(mstatusData),

		.PC_E_o(PC_E_o_C_i),
		.PC_A_o(PC_A_o_C_i),
		.mcauseNewData(mcauseIn),
		.mtvalNewData(mtvalIn),
		.mepcNewData(mepcIn),
		.mstatusNewData(mstatusIn)
	);

	assign	systemOrTrapCe	= mret | ecall | raiseInterrupt;

	CSR_inter_interrupt_controller	CSRinterInterruptController (
		.clk(clk),
		.rst(rst),
		.mip(mipData),
		.mie(mieData),
		.mstatusMIE(mstatusData[3]),
		.stageDEMWValid(stageDEMWValid_C_i),

		.coldDownPipe(coldDownPipe_C_o),
		.raiseInterrupt(raiseInterrupt),
		.irqReady(irqReady),
		.interruptCause(interruptCause)
	);

	CSR_traps_pc_generator CSRTrapsPCGenerator (
		.return(return),
		.mtvec(mtvecData),
		.mcause(mcauseData),
		.mepc(mepcData),
		.targetPC(PCTarget_C_o)
	);

	CSR_controller CSRController(
		.funct3(funct3_C_i),
		.systemInst(systemInst_C_i),
		.operation(operation),
		.CSRAccess(CSRAccess),
		.PassCSRData(PassCSRData),
		.PassCSRAddr(PassCSRAddr),
		.changeExeSrc(changeExeSrc_C_o),
		.CSRDataSelect(CSRDataSelect),
		.ecall(ecall),
		.mret(mret),
		.wfi(wfi),
		.funct12(funct12_C_i),
		.rdAddr(rdAddr_C_i)
	);

	CSR_sleeping_unit CSRSleepingUnit(
    	.clk(clk),
		.rst(rst),
		.wfi(wfi),
		.irq(irqReady),
		.stallCore(stallPipeSleepingUnit)
	);

 	CSR_CPI_manager CPIManagerUnit(
    	.clk(clk),
		.rst(rst),
		.priv(2'b0),
		.CPIRate(mcpirateData),
		.CPICTRL(mcpictrlData),
		.stallCore(stallPipeCPIUnit)
	);

	assign CSRAddr	=	(PassCSRAddr == 1'b1 ) ? funct12_C_i : 32'b0;
	assign CSRData  =	(PassCSRData == 1'b1 ) ? ( (CSRDataSelect == 1'b0 ) ?  rs1Data_C_i  : {27'b0, uimm_C_i} ) : 32'b0;

	CSR_write_unit CSRWriteUnit(
		.operation(operation),
		.CSRData(CSRData),
		.CSRAddr(CSRAddr),
		.lastData(rdData_C_o),
		.newData(CSRWtiteData),
		.mstatusEn(mstatusEn),
		.mieEn(mieEn),
		.mtvecEn(mtvecEn),
		.mscratchEn(mscratchEn),
		.mepcEn(mepcEn),
		.mcauseEn(mcauseEn),
		.mtvalEn(mtvalEn),
		.mcycleEn(mcycleEn),
		.mcyclehEn(mcyclehEn),
		.minstretEn(minstretEn),
		.minstrethEn(minstrethEn),
		.mhpmcounter3En(mhpmcounter3En),
		.mhpmcounter4En(mhpmcounter4En),
		.mhpmcounter5En(mhpmcounter5En),
		.mhpmcounter6En(mhpmcounter6En),
		.mhpmcounter7En(mhpmcounter7En),
		.mcountinhibitEn(mcountinhibitEn),
		.mcpirateEn(mcpirateEn),
		.mcpictrlEn(mcpictrlEn)
	);

 	dualPortRegister #(32, 32'b0) mstatus (
    	.clk(clk),
		.rst(rst),
		.en1(mstatusEn),
		.dataIn1(CSRWtiteData),
		.en2(mstatusEn2),
		.dataIn2(mstatusIn),
		.dataOut(mstatusData)
	);

 	register #(32) mie (
    	.clk(clk),
		.rst(rst),
        .enable(mieEn),
        .clear(1'b0),
        .regIn({CSRWtiteData}),
        .regOut({mieData})
	);

 	register #(32) mtvec (
    	.clk(clk),
		.rst(rst),
        .enable(mtvecEn),
        .clear(1'b0),
        .regIn({CSRWtiteData}),
        .regOut({mtvecData})
	);
	
	register #(32) mscratch (
        .clk(clk),
        .rst(rst),
        .enable(mscratchEn),
        .clear(1'b0),
        .regIn({CSRWtiteData}),
        .regOut({mscratchData})
    );

 	dualPortRegister #(32, 32'b0) mepc (
    	.clk(clk),
		.rst(rst),
		.en1(mepcEn),
		.dataIn1(CSRWtiteData),
		.en2(mepcEn2),
		.dataIn2(mepcIn),
		.dataOut(mepcData)
	);

 	dualPortRegister #(32, 32'b0) mcause (
    	.clk(clk),
		.rst(rst),
		.en1(mcauseEn),
		.dataIn1(CSRWtiteData),
		.en2(mcauseEn2),
		.dataIn2(mcauseIn),
		.dataOut(mcauseData)
	);

 	dualPortRegister #(32, 32'b0) mtval (
    	.clk(clk),
		.rst(rst),
		.en1(mtvalEn),
		.dataIn1(CSRWtiteData),
		.en2(mtvalEn2),
		.dataIn2(mtvalIn),
		.dataOut(mtvalData)
	);

 	register #(32) mip (
    	.clk(clk),
		.rst(rst),
        .enable(1'b1),
        .clear(1'b0),
        .regIn({mipInput}),
        .regOut({mipData})
	);

 	CSR_dual_counter minstret(
    	.clk(clk),
		.rst(rst),
		.enL(minstretEn),
		.enH(minstrethEn),
		.ce(minstretCountEnable),
		.stall(mcountinhibitData[2]),
		.dataInL(CSRWtiteData),
		.dataInH(CSRWtiteData),
		.dataOutL(minstretData),
		.dataOutH(minstrethData)
	);

 	CSR_dual_counter mcycle (
    	.clk(clk),
		.rst(rst),
		.enL(mcycleEn),
		.enH(mcyclehEn),
		.ce(1'b1),
		.stall(mcountinhibitData[0]),
		.dataInL(CSRWtiteData),
		.dataInH(CSRWtiteData),
		.dataOutL(mcycleData),
		.dataOutH(mcyclehData)
	);

 	register #(32) mcountinhibit (
    	.clk(clk),
		.rst(rst),
        .enable(mcountinhibitEn),
        .clear(1'b0),
        .regIn({CSRWtiteData}),
        .regOut({mcountinhibitData})
	);
 	dualPortRegister #(4, 4'b0) mcpirate (
    	.clk(clk),
		.rst(rst),
		.en1(mcpirateEn),
		.dataIn1(CSRWtiteData[ 3:0]),
		.en2(1'b0),
		.dataIn2(4'b0),
		.dataOut(mcpirateData)
	);
 	register #(8) mcpictrl (
    	.clk(clk),
		.rst(rst),
        .enable(mcpictrlEn),
        .clear(1'b0),
        .regIn({CSRWtiteData[ 7:0]}),
        .regOut({mcpictrlData})
	);

	CSR_counter	#(12) mhpmcounter3(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter3En),
		.ce(pmCounterEn_C_i[0]),
		.stall(mcountinhibitData[3]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter3Data)

	);

	CSR_counter	#(12) mhpmcounter4(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter4En),
		.ce(pmCounterEn_C_i[2]),
		.stall(mcountinhibitData[4]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter4Data)

	);
	CSR_counter	#(12) mhpmcounter5(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter5En),
		.ce(systemOrTrapCe),
		.stall(mcountinhibitData[5]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter5Data)

	);
	CSR_counter	#(12) mhpmcounter6(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter6En),
		.ce(pmCounterEn_C_i[1]),
		.stall(mcountinhibitData[6]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter6Data)

	);
	CSR_counter	#(12) mhpmcounter7(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter7En),
		.ce(CSRAccess),
		.stall(mcountinhibitData[7]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter7Data)

	);

	CSR_read_unit CSRReadUnit(
		.CSRAddr(CSRAddr),
		.mvendoridData(mvendoridData),
		.marchidData(marchidData),
		.mimpidData(mimpidData),
		.mhartidData(mhartidData),
		.mconfigptrData(mconfigptrData),

		.mstatusData(mstatusData),
		.misaData(misaData),
		.mieData(mieData),
		.mtvecData(mtvecData),

		.mscratchData(mscratchData),
		.mepcData(mepcData),
		.mcauseData(mcauseData),
		.mtvalData(mtvalData),
		.mipData(mipData),

		.mcycleData(mcycleData),
		.mcyclehData(mcyclehData),
		.minstretData(minstretData),
		.minstrethData(minstrethData),
		.mhpmcounter3Data(mhpmcounter3Data),
		.mhpmcounter4Data(mhpmcounter4Data),
		.mhpmcounter5Data(mhpmcounter5Data),
		.mhpmcounter6Data(mhpmcounter6Data),
		.mhpmcounter7Data(mhpmcounter7Data),
		.mcountinhibitData(mcountinhibitData),

		.mcpirateData(mcpirateData),
		.mcpictrlData(mcpictrlData),

		.selectedData(rdData_C_o)
	);

	assign 	mvendoridData 	= 32'b0 ;
	assign 	marchidData 	= 32'b0;
	assign 	mimpidData 		= 32'b0;
	assign 	mhartidData 	= 32'b0;
	assign 	mconfigptrData 	= 32'b0;
	assign 	misaData 		= 32'b0100_0000_0000_0000_0001_0001_0000_0100;

endmodule