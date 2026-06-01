module CSR_write_unit(
	input  wire	[ 1:0] operation,
	input  wire	[31:0] CSRData,
	input  wire	[11:0] CSRAddr,
	input  wire [31:0] lastData,

	output reg  [31:0] newData,
	output reg		   mstatusEn,
	output reg		   mieEn,
	output reg		   mtvecEn,
	output reg		   mscratchEn,
	output reg		   mepcEn,
	output reg		   mcauseEn,
	output reg		   mtvalEn,
	output reg		   mcycleEn,
	output reg		   mcyclehEn,
	output reg		   minstretEn,
	output reg		   minstrethEn,
	output reg		   mhpmcounter3En,
	output reg		   mhpmcounter4En,
	output reg		   mhpmcounter5En,
	output reg		   mhpmcounter6En,
	output reg		   mhpmcounter7En,
	output reg		   mcountinhibitEn,
	output reg		   mcpirateEn,
	output reg		   mcpictrlEn
);

	localparam 	mstatus 		=	12'h300;
	localparam 	mie	 			=	12'h304;
	localparam 	mtvec	 		=	12'h305;

	localparam 	mscratch		=	12'h340;
	localparam 	mepc			=	12'h341;
	localparam 	mcause			=	12'h342;
	localparam 	mtval			=	12'h343;

	localparam	mcycle			=	12'hB00;
	localparam	mcycleh			=	12'hB80;
	localparam	minstret		=	12'hB02;
	localparam	mhpmcounter3	=	12'hB03;
	localparam	mhpmcounter4	=	12'hB04;
	localparam	mhpmcounter5	=	12'hB05;
	localparam	mhpmcounter6	=	12'hB06;
	localparam	mhpmcounter7	=	12'hB07;
	localparam	minstreth		=	12'hB82;
	localparam	mcountinhibit	=	12'h320;

	// Custom read/write
	localparam	mcpirate		=	12'h7C0;
	localparam	mcpictrl		=	12'h7C4;



	// operation
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
		{mstatusEn, mieEn, mtvecEn, mscratchEn, mepcEn, mcauseEn, mtvalEn, mcycleEn, mcyclehEn, minstretEn,
		 minstrethEn, mcountinhibitEn, mcpirateEn, mcpictrlEn, mhpmcounter3En, mhpmcounter4En ,mhpmcounter5En,
		mhpmcounter6En, mhpmcounter7En } = 19'b0;
		case (CSRAddr)
			mstatus 		:	mstatusEn 		= 1'b1; 
			mie				:	mieEn 			= 1'b1; 
			mtvec			:	mtvecEn 		= 1'b1; 
			mscratch		:	mscratchEn 		= 1'b1; 
			mepc			:	mepcEn 			= 1'b1; 
			mcause			:	mcauseEn 		= 1'b1; 
			mtval			:	mtvalEn 		= 1'b1;
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
		endcase
	end

endmodule