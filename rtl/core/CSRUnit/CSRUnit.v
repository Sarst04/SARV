////////////////////////////////////////////////////////////////////////////////
// File      : CSRunit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-09-20 (last modified)
// Description:
//   CSR top module 
////////////////////////////////////////////////////////////////////////////////
module CSR_unit#(
	parameter	HART_ID = 0,
	parameter 	MHPM_COUNTER_SIZE = 12
)(
	input wire 			clk,
	input wire			rst,
	
	// Control signal
	input  wire 		MEI,
	input  wire 		SEI,
	input  wire 		MTI,
	input  wire 		MSI,
	input  wire [ 2:0] 	funct3_C_i,
	input  wire 		systemInst_C_i,
	input  wire		    instCountEn_C_i,
	input  wire			stageDEMWValid_C_i,
	input  wire	[ 4:0]	pmCounterEn_C_i,
	input  wire			illegalInstruction_C_i,

	output wire			cleanPipe_C_o,
	output wire 		stallPipe_C_o,
	output wire 		coldDownPipe_C_o,
	output wire			changePCSrc_C_o,
	output wire			changeExeSrc_C_o,

	// Data signal
	input  wire [ 6:0]  instOpcode_C_i,
	input  wire [31:0]  PC_E_o_C_i,
	input  wire [31:0]  PC_A_o_C_i,
	input  wire [31:0]  rs1Data_C_i,
	input  wire [ 4:0] 	rdAddr_C_i,
	input  wire [ 4:0] 	uimm_C_i,
	input  wire [11:0]	funct12_C_i,
	input  wire [31:0] 	mtimeData,
	input  wire [31:0] 	mtimehData,

	output wire [31:0] 	rdData_C_o,
	output wire [31:0] 	PCTarget_C_o
);
	wire [31:0]	CSRWtiteData;
	wire [31:0]	CSRData;
	wire [11:0]	CSRAddr;

	wire		STI;
	wire [31:0]	mipInput;
	assign		mipInput	=	{20'b0, MEI, 1'b0, SEI, 1'b0, MTI, 1'b0, STI, 1'b0, MSI, 1'b0, 1'b0, 1'b0};

	// CSR registers
	wire [31:0] ucycleData;
	wire [31:0] ucyclehData;
	wire [31:0] utimeData;
	wire [31:0] utimehData;
	wire [31:0] uinstretData;
	wire [31:0] uinstrethData;

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
	wire [31:0] medelegData;
	wire		medelegEn;
	wire [31:0] midelegData;
	wire		midelegEn;
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
	wire		mipEn;
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
	wire [31:0] mhpmcounter8Data;
	wire 		mhpmcounter8En;
	wire [31:0] mhpmcounter9Data;
	wire 		mhpmcounter9En;
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

	wire [31:0] sstatusData;
	wire		sstatusEn;
	wire [31:0] sieData;
	wire		sieEn;
	wire [31:0] stvecData;
	wire		stvecEn;

	wire [31:0] sscratchData;
	wire		sscratchEn;
	wire [31:0] sepcData;
	wire		sepcEn;
	wire [31:0] sepcIn;
	wire		sepcEn2;
	wire [31:0] scauseData;
	wire		scauseEn;
	wire [31:0] scauseIn;
	wire		scauseEn2;
	wire [31:0] stvalData;
	wire		stvalEn;
	wire [31:0] stvalIn;
	wire		stvalEn2;
	wire [31:0] sipData;
	wire		sipEn;

	wire [31:0] stimecmpData;
	wire		stimecmpEn;
	wire [31:0] stimecmphData;
	wire		stimecmphEn;

	// current Privilege
	wire 	   newCurPrivEn;
	wire [1:0] newCurPriv;
	wire [1:0] curPriv;

	// CSR Controller
	wire		PassCSRData;
	wire		PassCSRAddr;
	wire [ 1:0] operation;
	wire		CSRDataSelect;
	wire		ecall;
	wire		mret;
	wire		sret;
	wire		wfi;
	wire		CSRAccess;
	wire		illegalCSRAccess;

	wire		mreturn;
	wire		sreturn;
	wire		delegate;

	//CSR Inter Interrupt Controller
	wire		raiseInterrupt;
	wire		irqReady;
	wire		delegated;
	wire [31:0]	interruptCause;

	// stall Pipe
	wire		stallPipeSleepingUnit;
	wire		stallPipeCPIUnit;
	assign		stallPipe_C_o	=	stallPipeSleepingUnit	|	stallPipeCPIUnit;
	
	assign		minstretCountEnable	=	instCountEn_C_i;

	wire		systemOrTrapCe;

	
	wire		illegalInstruction;
	assign		illegalInstruction = illegalInstruction_C_i | illegalCSRAccess;

	wire [31:0]	illegalInstructionData;
	assign		illegalInstructionData = {funct12_C_i, uimm_C_i, funct3_C_i, rdAddr_C_i, instOpcode_C_i};

 	CSR_trap_handler CSRTrapHandler(
		.mret(mret),
		.sret(sret),
		.ecall(ecall),
		.raiseInterrupt(raiseInterrupt),
		.curPriv(curPriv),
		.delegated(delegated),
		.illegalInstruction(illegalInstruction),
		.illegalInstructionData(illegalInstructionData),
		.mreturn(mreturn),
		.sreturn(sreturn),
		.mcauseEn(mcauseEn2),
		.mtvalEn(mtvalEn2),
		.mepcEn(mepcEn2),
		.mstatusEn(mstatusEn2),
		.scauseEn(scauseEn2),
		.stvalEn(stvalEn2),
		.sepcEn(sepcEn2),
		.changePCSrc(changePCSrc_C_o),
		.cleanPipe(cleanPipe_C_o),
		.newCurPrivEn(newCurPrivEn),
		.delegate(delegate),

		.interruptCause(interruptCause),
		.mstatus(mstatusData),

		.PC_E_o(PC_E_o_C_i),
		.PC_A_o(PC_A_o_C_i),
		.medelegData(medelegData),
		.mcauseNewData(mcauseIn),
		.mtvalNewData(mtvalIn),
		.mepcNewData(mepcIn),
		.scauseNewData(scauseIn),
		.stvalNewData(stvalIn),
		.sepcNewData(sepcIn),
		.mstatusNewData(mstatusIn),
		.newCurPriv(newCurPriv)
	);

	assign	systemOrTrapCe	= mret | sret | ecall | raiseInterrupt | illegalInstruction;

	CSR_inter_interrupt_controller	CSRinterInterruptController (
		.clk(clk),
		.rst(rst),
		
		.curPriv(curPriv),
		.mip(mipData),
		.mie(mieData),
		.sip(sipData),
		.sie(sieData),
		.midelegData(midelegData),
		.mstatusMIE(mstatusData[3]),
		.mstatusSIE(mstatusData[1]),
		.stageDEMWValid(stageDEMWValid_C_i),

		.coldDownPipe(coldDownPipe_C_o),
		.raiseInterrupt(raiseInterrupt),
		.irqReady(irqReady),
		.delegated(delegated),
		.interruptCause(interruptCause)
	);

	CSR_traps_pc_generator CSRTrapsPCGenerator (
		.mreturn(mreturn),
		.sreturn(sreturn),
		.interruptCause(interruptCause),
		.delegate(delegate),
		.mtvec(mtvecData),
		.mepc(mepcData),
		.stvec(stvecData),
		.sepc(sepcData),
		.targetPC(PCTarget_C_o)
	);

	CSR_controller CSRController(
		.funct3(funct3_C_i),
		.systemInst(systemInst_C_i),
		.operation(operation),
		.CSRAccess(CSRAccess),
		.illegalCSRAccess(illegalCSRAccess),
		.PassCSRData(PassCSRData),
		.PassCSRAddr(PassCSRAddr),
		.changeExeSrc(changeExeSrc_C_o),
		.CSRDataSelect(CSRDataSelect),
		.ecall(ecall),
		.mret(mret),
		.sret(sret),
		.wfi(wfi),
		.funct12(funct12_C_i),
		.curPriv(curPriv),
		.rs1Addr(uimm_C_i)
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

		.priv(curPriv),
		.CPIRate(mcpirateData),
		.CPICTRL(mcpictrlData),

		.stallCore(stallPipeCPIUnit)
	);

	CSR_sstc_unit CSRsstcUnit(
    	.clk(clk),
		.rst(rst),

		.STI,
		
		.stimecmp(stimecmpData),
		.stimehcmp(stimecmphData),

		.mtime(mtimeData),
		.mtimeh(mtimehData)
	);

 	register #(2, 2'b11) currentPrivilege (
    	.clk(clk),
		.rst(rst),

        .enable(newCurPrivEn),
        .clear(1'b0),
        .regIn({newCurPriv}),
        .regOut({curPriv})
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
		.medelegEn(medelegEn),
		.midelegEn(midelegEn),
		.mieEn(mieEn),
		.mtvecEn(mtvecEn),
		.mscratchEn(mscratchEn),
		.mepcEn(mepcEn),
		.mcauseEn(mcauseEn),
		.mtvalEn(mtvalEn),
		.mipEn(mipEn),
		.mcycleEn(mcycleEn),
		.mcyclehEn(mcyclehEn),
		.minstretEn(minstretEn),
		.minstrethEn(minstrethEn),
		.mhpmcounter3En(mhpmcounter3En),
		.mhpmcounter4En(mhpmcounter4En),
		.mhpmcounter5En(mhpmcounter5En),
		.mhpmcounter6En(mhpmcounter6En),
		.mhpmcounter7En(mhpmcounter7En),
		.mhpmcounter8En(mhpmcounter8En),
		.mhpmcounter9En(mhpmcounter9En),
		.mcountinhibitEn(mcountinhibitEn),
		.mcpirateEn(mcpirateEn),
		.mcpictrlEn(mcpictrlEn),
		.sstatusEn(sstatusEn),
		.sieEn(sieEn),
		.stvecEn(stvecEn),
		.sscratchEn(sscratchEn),
		.sepcEn(sepcEn),
		.scauseEn(scauseEn),
		.stvalEn(stvalEn),
		.sipEn(sipEn),
		.stimecmpEn(stimecmpEn),
		.stimecmphEn(stimecmphEn)
	);

	localparam SSTATUS_MASK  =  32'h800C_0122;
 	triplePortRegister #(32, 32'b0) mstatus (
    	.clk(clk),
		.rst(rst),
		.en1(mstatusEn),
		.dataIn1(CSRWtiteData),
		.en2(mstatusEn2),
		.dataIn2(mstatusIn),
		.en3(sstatusEn),
		.dataIn3((CSRWtiteData & SSTATUS_MASK) | (mstatusData & ~SSTATUS_MASK)),
		.dataOut(mstatusData)
	);
	assign sstatusData	= mstatusData & SSTATUS_MASK;

 	register #(32) medeleg (
    	.clk(clk),
		.rst(rst),
        .enable(medelegEn),
        .clear(1'b0),
        .regIn({CSRWtiteData}),
        .regOut({medelegData})
	);

 	register #(32) mideleg (
    	.clk(clk),
		.rst(rst),
        .enable(midelegEn),
        .clear(1'b0),
        .regIn({CSRWtiteData}),
        .regOut({midelegData})
	);

	localparam SIE_MASK  =  32'h0000_0222;
 	dualPortRegister #(32, 32'b0) mie (
    	.clk(clk),
		.rst(rst),
		.en1(mieEn),
		.dataIn1(CSRWtiteData),
		.en2(sieEn),
		.dataIn2((CSRWtiteData & SIE_MASK & midelegData) | (mieData & ~SIE_MASK)),
		.dataOut(mieData)
	);
	assign	sieData =  mieData & midelegData & SIE_MASK;

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
	
	localparam [31:0] SIP_MASK 			= 32'h0000_0222;
	localparam [31:0] SIP_WRITE_MASK 	= 32'h0000_0002;
 	triplePortRegister #(32, 32'b0) mip (
    	.clk(clk),
		.rst(rst),
		.en1(mipEn),
		.dataIn1(CSRWtiteData),
		.en2(~mipEn),
		.dataIn2((mipInput & ~SIP_WRITE_MASK) |(mipData & SIP_WRITE_MASK)),
		.en3(sipEn),
		.dataIn3((CSRWtiteData & SIP_WRITE_MASK & midelegData) | (mipData & ~SIP_WRITE_MASK)),
		.dataOut(mipData)
	);
	assign sipData = mipData & SIP_MASK;

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

	CSR_counter	#(MHPM_COUNTER_SIZE) mhpmcounter3(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter3En),
		.ce(pmCounterEn_C_i[0]),
		.stall(mcountinhibitData[3]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter3Data)

	);

	CSR_counter	#(MHPM_COUNTER_SIZE) mhpmcounter4(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter4En),
		.ce(pmCounterEn_C_i[2]),
		.stall(mcountinhibitData[4]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter4Data)

	);
	CSR_counter	#(MHPM_COUNTER_SIZE) mhpmcounter5(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter5En),
		.ce(systemOrTrapCe),
		.stall(mcountinhibitData[5]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter5Data)

	);
	CSR_counter	#(MHPM_COUNTER_SIZE) mhpmcounter6(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter6En),
		.ce(pmCounterEn_C_i[1]),
		.stall(mcountinhibitData[6]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter6Data)

	);
	CSR_counter	#(MHPM_COUNTER_SIZE) mhpmcounter7(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter7En),
		.ce(CSRAccess),
		.stall(mcountinhibitData[7]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter7Data)

	);
	CSR_counter	#(MHPM_COUNTER_SIZE) mhpmcounter8(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter8En),
		.ce(pmCounterEn_C_i[3]),
		.stall(mcountinhibitData[8]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter8Data)

	);
	CSR_counter	#(MHPM_COUNTER_SIZE) mhpmcounter9(
    	.clk(clk),
		.rst(rst),

		.en(mhpmcounter9En),
		.ce(pmCounterEn_C_i[4]),
		.stall(mcountinhibitData[9]),
		.dataIn(CSRWtiteData),
		.dataOut(mhpmcounter9Data)

	);

	register #(32) stvec (
		.clk(clk),
		.rst(rst),
		.enable(stvecEn),
		.clear(1'b0),
		.regIn(CSRWtiteData),
		.regOut(stvecData)
	);

	register #(32) sscratch (
		.clk(clk),
		.rst(rst),
		.enable(sscratchEn),
		.clear(1'b0),
		.regIn(CSRWtiteData),
		.regOut(sscratchData)
	);

 	dualPortRegister #(32, 32'b0) sepc (
    	.clk(clk),
		.rst(rst),
		.en1(sepcEn),
		.dataIn1(CSRWtiteData),
		.en2(sepcEn2),
		.dataIn2(sepcIn),
		.dataOut(sepcData)
	);

 	dualPortRegister #(32, 32'b0) scause (
    	.clk(clk),
		.rst(rst),
		.en1(scauseEn),
		.dataIn1(CSRWtiteData),
		.en2(scauseEn2),
		.dataIn2(scauseIn),
		.dataOut(scauseData)
	);


 	dualPortRegister #(32, 32'b0) stval (
    	.clk(clk),
		.rst(rst),
		.en1(stvalEn),
		.dataIn1(CSRWtiteData),
		.en2(stvalEn2),
		.dataIn2(stvalIn),
		.dataOut(stvalData)
	);

	register #(32) stimecmp (
		.clk(clk),
		.rst(rst),
		.enable(stimecmpEn),
		.clear(1'b0),
		.regIn(CSRWtiteData),
		.regOut(stimecmpData)
	);

	register #(32) stimecmph (
		.clk(clk),
		.rst(rst),
		.enable(stimecmphEn),
		.clear(1'b0),
		.regIn(CSRWtiteData),
		.regOut(stimecmphData)
	);

	assign	ucycleData 		= mcycleData;
	assign	ucyclehData 	= mcyclehData;
	assign	utimeData 		= mtimeData;
	assign	utimehData 		= mtimehData;
	assign	uinstretData 	= minstretData;
	assign	uinstrethData	= minstrethData;


	CSR_read_unit CSRReadUnit(
		.CSRAddr(CSRAddr),

		.ucycleData(ucycleData),
		.ucyclehData(ucyclehData),
		.utimeData(utimeData),
		.utimehData(utimehData),
		.uinstretData(uinstretData),
		.uinstrethData(uinstrethData),

		.mvendoridData(mvendoridData),
		.marchidData(marchidData),
		.mimpidData(mimpidData),
		.mhartidData(mhartidData),
		.mconfigptrData(mconfigptrData),

		.mstatusData(mstatusData),
		.misaData(misaData),
		.medelegData(medelegData),
		.midelegData(midelegData),
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
		.mhpmcounter8Data(mhpmcounter8Data),
		.mhpmcounter9Data(mhpmcounter9Data),
		.mcountinhibitData(mcountinhibitData),

		.mcpirateData(mcpirateData),
		.mcpictrlData(mcpictrlData),

		.sstatusData(sstatusData),
		.sieData(sieData),
		.stvecData(stvecData),

		.sscratchData(sscratchData),
		.sepcData(sepcData),
		.scauseData(scauseData),
		.stvalData(stvalData),
		.sipData(sipData),

		.stimecmpData(stimecmpData),
		.stimecmphData(stimecmphData),

		.selectedData(rdData_C_o)
	);


	assign 	mvendoridData 	= 32'b0 ;
	assign 	marchidData 	= 32'b110111; // https://github.com/riscv/riscv-isa-manual/blob/main/marchid.md
	assign 	mimpidData 		= 32'b0;
	assign 	mhartidData 	= 32'b0;
	assign 	mconfigptrData 	= 32'b0;
	assign 	misaData 		= 32'b0100_0000_0000_0000_1000_0001_0000_0110;

endmodule