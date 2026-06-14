////////////////////////////////////////////////////////////////////////////////
// File      : CSRTrapHandler.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-05-24 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_trap_handler(
	// Controll signal
	input  wire 		mret,
	input  wire			ecall,
	input  wire			raiseInterrupt,

	output reg			return,
	output reg			mcauseEn,
	output reg			mtvalEn,
	output reg			mepcEn,
	output reg			mstatusEn,
	output reg			changePCSrc,
	output reg			cleanPipe,
	
	
	// Data signal
	input  wire	[31:0]	interruptCause,
	input  wire	[31:0]	mstatus,
	input  wire	[31:0]	PC_E_o,
	input  wire	[31:0]	PC_A_o,

	output reg	[31:0]	mcauseNewData,
	output reg	[31:0]	mtvalNewData,
	output reg	[31:0]	mepcNewData,
	output reg	[31:0]	mstatusNewData
);
	always @(mret, ecall, raiseInterrupt, interruptCause, mstatus, PC_E_o, PC_A_o) begin
		{cleanPipe, return, mcauseEn, mtvalEn, mepcEn, mstatusEn, changePCSrc, mcauseNewData, mtvalNewData, mepcNewData, mstatusNewData} =
		{1'b0     ,1'b0   , 1'b0    , 1'b0   , 1'b0  , 1'b0     , 1'b0 	   , 32'b0        , 32'b0    	  , 32'b0	   , 32'b0		   };

		if (raiseInterrupt) begin
			mepcNewData		=	PC_A_o;
			mepcEn			=	1'b1;

			mcauseNewData	=	interruptCause;
			mcauseEn		=	1'b1;

			mtvalNewData	=	32'b0;
			mtvalEn			=	1'b1;

			mstatusNewData	=	{mstatus[31:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
			mstatusEn		=	1'b1;
			
			changePCSrc		=	1'b1;
		end
		else if (mret)	begin
			return			=	1'b1;

			mstatusNewData	=	{mstatus[31:8], 1'b1, mstatus[6:4], mstatus[7], mstatus[2:0]};
			mstatusEn		=	1'b1;

			changePCSrc		=	1'b1;	   
			cleanPipe		=	1'b1;
		end
		else if (ecall) begin
			mepcNewData		=	PC_E_o;
			mepcEn			=	1'b1;

			mcauseNewData	=	31'd11;
			mcauseEn		=	1'b1;

			mtvalNewData	=	32'b0;
			mtvalEn			=	1'b1;

			mstatusNewData	=	{mstatus[31:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
			mstatusEn		=	1'b1;
			
			changePCSrc		=	1'b1;
			cleanPipe		=	1'b1;
		end

	end
endmodule