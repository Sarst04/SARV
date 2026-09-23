////////////////////////////////////////////////////////////////////////////////
// File      : CSRWriteUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-09-19 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_write_unit(
	input  wire	[ 1:0] operation,
	input  wire	[31:0] CSRData,
	input  wire	[11:0] CSRAddr,
	input  wire [31:0] lastData,

	output reg  [31:0] newData,
	output reg		   mstatusEn,
	output reg		   medelegEn,
	output reg		   midelegEn,
	output reg		   mieEn,
	output reg		   mtvecEn,
	output reg		   mscratchEn,
	output reg		   mepcEn,
	output reg		   mcauseEn,
	output reg		   mtvalEn,
	output reg		   mipEn,
	output reg		   mcycleEn,
	output reg		   mcyclehEn,
	output reg		   minstretEn,
	output reg		   minstrethEn,
	output reg		   mhpmcounter3En,
	output reg		   mhpmcounter4En,
	output reg		   mhpmcounter5En,
	output reg		   mhpmcounter6En,
	output reg		   mhpmcounter7En,
	output reg		   mhpmcounter8En,
	output reg		   mhpmcounter9En,
	output reg		   mcountinhibitEn,
	output reg		   mcpirateEn,
	output reg		   mcpictrlEn,

	output reg		   sstatusEn,
	output reg		   sieEn,
	output reg		   stvecEn,
	output reg		   sscratchEn,
	output reg		   sepcEn,
	output reg		   scauseEn,
	output reg		   stvalEn,
	output reg		   sipEn,
	output reg		   stimecmpEn,
	output reg		   stimecmphEn
);

	localparam 	mstatus 		=	12'h300;
	localparam 	medeleg 		=	12'h302;
	localparam 	mideleg 		=	12'h303;
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
	localparam	mhpmcounter9	=	12'hB09;
	localparam	minstreth		=	12'hB82;
	localparam	mcountinhibit	=	12'h320;

	// Custom read/write
	localparam	mcpirate		=	12'h7C0;
	localparam	mcpictrl		=	12'h7C4;

	localparam	sstatus			=	12'h100;
	localparam	sie				=	12'h104;
	localparam	stvec			=	12'h105;

	localparam	sscratch		=	12'h140;
	localparam	sepc			=	12'h141;
	localparam	scause			=	12'h142;
	localparam	stval			=	12'h143;
	localparam	sip				=	12'h144;

	localparam	stimecmp		=	12'h14D;
	localparam	stimecmph		=	12'h15D;

	// operation
	localparam  System		=   2'b00;
	localparam 	Write 		=	2'b01;
	localparam 	Set	 		=	2'b10;
	localparam 	Clear	 	=	2'b11;

	always @(operation, CSRData, lastData) begin
		newData = 32'b0;
		case (operation)
			Write 	: begin
				newData = CSRData;
			end
			Set		: begin
				newData = lastData | CSRData;
			end
			Clear	: begin
				newData = lastData & ~CSRData;
			end
		endcase
	end

	always @(operation, CSRData, CSRAddr, lastData) begin
		{mstatusEn, medelegEn, midelegEn, mieEn, mtvecEn, mscratchEn, mepcEn, mcauseEn, mtvalEn, mipEn, mcycleEn, mcyclehEn, minstretEn,
		 minstrethEn, mcountinhibitEn, mcpirateEn, mcpictrlEn, mhpmcounter3En, mhpmcounter4En ,mhpmcounter5En,
		mhpmcounter6En, mhpmcounter7En, mhpmcounter8En, mhpmcounter9En, sstatusEn, sieEn, stvecEn, sscratchEn, 
		sepcEn, scauseEn, stvalEn, sipEn, stimecmpEn, stimecmphEn  } = 34'b0;
		if (operation != System) begin
			case (CSRAddr)
				mstatus 		:	mstatusEn 		= 1'b1; 
				medeleg 		:	medelegEn 		= 1'b1; 
				mideleg 		:	midelegEn 		= 1'b1;
				mie				:	mieEn 			= 1'b1; 
				mtvec			:	mtvecEn 		= 1'b1; 
				mscratch		:	mscratchEn 		= 1'b1; 
				mepc			:	mepcEn 			= 1'b1; 
				mcause			:	mcauseEn 		= 1'b1; 
				mtval			:	mtvalEn 		= 1'b1;
				mip				:	mipEn	 		= 1'b1;
				mcycle			:	mcycleEn		= 1'b1;
				mcycleh 		:	mcyclehEn		= 1'b1;
				minstret		:	minstretEn		= 1'b1;
				minstreth		:	minstrethEn		= 1'b1;
				mcountinhibit 	: 	mcountinhibitEn = 1'b1;
				mcpirate		:	mcpirateEn		= 1'b1;
				mcpictrl 		: 	mcpictrlEn		= 1'b1;

				mhpmcounter3	: 	mhpmcounter3En 	= 1'b1;
				mhpmcounter4	:	mhpmcounter4En 	= 1'b1;
				mhpmcounter5	:	mhpmcounter5En 	= 1'b1;
				mhpmcounter6	:	mhpmcounter6En 	= 1'b1;
				mhpmcounter7	: 	mhpmcounter7En 	= 1'b1;
				mhpmcounter8	: 	mhpmcounter8En 	= 1'b1;
				mhpmcounter9	: 	mhpmcounter9En 	= 1'b1;

				sstatus			:	sstatusEn		= 1'b1;
				sie				:	sieEn			= 1'b1;
				stvec			:	stvecEn			= 1'b1;

				sscratch		:	sscratchEn		= 1'b1;
				sepc			:	sepcEn			= 1'b1;
				scause			:	scauseEn		= 1'b1;
				stval			:	stvalEn			= 1'b1;
				sip				:	sipEn			= 1'b1;

				stimecmp		:	stimecmpEn		= 1'b1;
				stimecmph		:	stimecmphEn		= 1'b1;
			endcase
		end
	end

endmodule