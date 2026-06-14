////////////////////////////////////////////////////////////////////////////////
// File      : CSRReadUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-15 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_read_unit(
	input wire  [11:0] CSRAddr,
	
	input wire	[31:0] mvendoridData,	
	input wire	[31:0] marchidData,	
	input wire	[31:0] mimpidData,	
	input wire	[31:0] mhartidData,	
	input wire	[31:0] mconfigptrData,

	input wire	[31:0] mstatusData,
	input wire	[31:0] misaData,	
	input wire	[31:0] mieData,	
	input wire	[31:0] mtvecData,	
	input wire	[31:0] mscratchData,	
	input wire	[31:0] mepcData,
	input wire	[31:0] mcauseData,
	input wire	[31:0] mtvalData,
	input wire	[31:0] mipData,

	input wire	[31:0] mcycleData,
	input wire	[31:0] mcyclehData,
	input wire	[31:0] minstretData,
	input wire	[31:0] minstrethData,
	input wire	[31:0] mhpmcounter3Data,
	input wire	[31:0] mhpmcounter4Data,
	input wire	[31:0] mhpmcounter5Data,
	input wire	[31:0] mhpmcounter6Data,
	input wire	[31:0] mhpmcounter7Data,
	input wire	[31:0] mhpmcounter8Data,
	input wire	[31:0] mcountinhibitData,
	input wire	[ 3:0] mcpirateData,
	input wire	[ 7:0] mcpictrlData,

	output reg  [31:0] selectedData
);

	localparam 	mvendorid 		=	12'hF11;
	localparam 	marchid	 		=	12'hF12;
	localparam 	mimpid	 		=	12'hF13;
	localparam 	mhartid	 		=	12'hF14;
	localparam 	mconfigptr		=	12'hF15;
	
	localparam 	mstatus 		=	12'h300;
	localparam 	misa	 		=	12'h301;
	localparam 	mie	 			=	12'h304;
	localparam 	mtvec	 		=	12'h305;

	localparam 	mscratch		=	12'h340;
	localparam 	mepc			=	12'h341;
	localparam 	mcause			=	12'h342;
	localparam 	mtval			=	12'h343;
	localparam 	mip				=	12'h344;

	localparam	mcycle			=	12'hB00;
	localparam	mcycleh			=	12'hB80;
	localparam	minstret		=	12'hB02;
	localparam	mhpmcounter3	=	12'hB03;
	localparam	mhpmcounter4	=	12'hB04;
	localparam	mhpmcounter5	=	12'hB05;
	localparam	mhpmcounter6	=	12'hB06;
	localparam	mhpmcounter7	=	12'hB07;
	localparam	mhpmcounter8	=	12'hB08;
	localparam	minstreth		=	12'hB82;
	localparam	mcountinhibit	=	12'h320;

	// Custom read/write
	localparam	mcpirate		=	12'h7C0;
	localparam	mcpictrl		=	12'h7C4;

	
	always @(CSRAddr, mvendoridData, marchidData, mimpidData, mhartidData, mconfigptrData, mstatusData, misaData,
			 mieData, mtvecData, mscratchData, mepcData, mcauseData, mtvalData, mipData, mcycleData, mcyclehData,
			 minstretData, minstrethData, mhpmcounter3Data, mhpmcounter4Data, mhpmcounter5Data, mhpmcounter6Data,
			mhpmcounter7Data, mhpmcounter8Data, mcountinhibitData, mcpirateData, mcpictrlData) begin
		selectedData = 32'b0;
		case (CSRAddr) 
			mvendorid 		: selectedData = mvendoridData;
			marchid 		: selectedData = marchidData;
			mimpid			: selectedData = mimpidData;
			mhartid 		: selectedData = mhartidData;
			mconfigptr		: selectedData = mconfigptrData;

			mstatus 		: selectedData = mstatusData;
			misa 			: selectedData = misaData;
			mie 			: selectedData = mieData;
			mtvec 			: selectedData = mtvecData;

			mscratch		: selectedData = mscratchData;
			mepc			: selectedData = mepcData;
			mcause			: selectedData = mcauseData;
			mtval			: selectedData = mtvalData;
			mip				: selectedData = mipData;

			mcycle			: selectedData = mcycleData;
			mcycleh 		: selectedData = mcyclehData;
			minstret		: selectedData = minstretData;
			minstreth		: selectedData = minstrethData;
			mhpmcounter3	: selectedData = mhpmcounter3Data;
			mhpmcounter4	: selectedData = mhpmcounter4Data;
			mhpmcounter5	: selectedData = mhpmcounter5Data;
			mhpmcounter6	: selectedData = mhpmcounter6Data;
			mhpmcounter7	: selectedData = mhpmcounter7Data;
			mhpmcounter8	: selectedData = mhpmcounter8Data;
			mcountinhibit 	: selectedData = mcountinhibitData;
	
			mcpirate		: selectedData = {28'b0, mcpirateData};
			mcpictrl		: selectedData = {24'b0, mcpictrlData};
		endcase
	end
endmodule