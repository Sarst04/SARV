////////////////////////////////////////////////////////////////////////////////
// File      : CSRTrapHandler.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-09-20 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_trap_handler(
	// Controll signal
	input  wire 		mret,
	input  wire 		sret,
	input  wire			ecall,
	input  wire			raiseInterrupt,
	input  wire	[ 1:0]  curPriv,
	input  wire			delegated,
	input  wire			illegalInstruction,

	output reg			mreturn,
	output reg			sreturn,

	output reg			mcauseEn,
	output reg			mtvalEn,
	output reg			mepcEn,
	output reg			mstatusEn,

    output reg          scauseEn,
    output reg          stvalEn,
    output reg          sepcEn,

	output reg			changePCSrc,
	output reg			cleanPipe,
	output reg			newCurPrivEn,
	output reg			delegate,
	
	// Data signal
	input  wire	[31:0]	interruptCause,
	input  wire	[31:0]	mstatus,
	input  wire	[31:0]	PC_E_o,
	input  wire	[31:0]	PC_A_o,
	input  wire	[31:0]	medelegData,
	input  wire [31:0]  illegalInstructionData,

	output reg	[31:0]	mcauseNewData,
	output reg	[31:0]	mtvalNewData,
	output reg	[31:0]	mepcNewData,
	output reg	[31:0]	mstatusNewData,

    output reg [31:0] 	scauseNewData,
    output reg [31:0]   stvalNewData,
    output reg [31:0]   sepcNewData,

	output reg	[ 1:0]  newCurPriv
);

    localparam PRIV_U = 2'b00;
    localparam PRIV_S = 2'b01;
    localparam PRIV_M = 2'b11;

	always @(mret, sret, ecall, raiseInterrupt, curPriv, delegated, interruptCause, mstatus, PC_E_o,
			 PC_A_o, medelegData, illegalInstruction, illegalInstructionData) begin
		{cleanPipe, sreturn, mreturn, mcauseEn, mtvalEn, mepcEn, scauseEn, stvalEn, sepcEn, mstatusEn}=
		{1'b0     ,1'b0    , 1'b0   , 1'b0    , 1'b0   , 1'b0  , 1'b0    , 1'b0   , 1'b0  , 1'b0     };
 		{changePCSrc, mcauseNewData, mtvalNewData, mepcNewData, mstatusNewData, newCurPrivEn, newCurPriv, delegate} =
		{1'b0 	    , 32'b0        , 32'b0       , 32'b0	  , 32'b0		  , 1'b0	   	, 2'b0	  	, 1'b0};
		{scauseNewData, stvalNewData, sepcNewData } = 
		{32'b0		  , 32'b0		, 32'b0};

		if (illegalInstruction) begin
			cleanPipe   = 1'b1;
			changePCSrc = 1'b1;
			if (((curPriv == PRIV_U) || (curPriv == PRIV_S)) && medelegData[2]) begin
				delegate 			= 1'b1;

				sepcNewData 		= PC_E_o;
				sepcEn      		= 1'b1;

				scauseNewData 		= 32'd2;
				scauseEn      		= 1'b1;

				stvalNewData 		= illegalInstructionData;
				stvalEn      		= 1'b1;

				mstatusNewData    	= mstatus;
				mstatusNewData[5] 	= mstatus[1];
				mstatusNewData[1] 	= 1'b0;
				mstatusNewData[8] 	= (curPriv == PRIV_S);
				mstatusEn 			= 1'b1;

				newCurPriv   		= PRIV_S;
				newCurPrivEn 		= 1'b1;
			end
			else begin
				delegate 			= 1'b0;

				mepcNewData 		= PC_E_o;
				mepcEn      		= 1'b1;

				mcauseNewData 		= 32'd2;
				mcauseEn      		= 1'b1;

				mtvalNewData 		= illegalInstructionData;
				mtvalEn      		= 1'b1;


				mstatusNewData 		= mstatus;
				mstatusNewData[7]   = mstatus[3];
				mstatusNewData[3]   = 1'b0;
				mstatusNewData[12:11] = curPriv;
				mstatusEn 			= 1'b1;

				newCurPriv   		= PRIV_M;
				newCurPrivEn 		= 1'b1;
			end
		end else if (raiseInterrupt) begin
			if (delegated) begin
        		delegate 			= 	1'b1;
				sepcNewData			=	PC_A_o;
				sepcEn				=	1'b1;

				scauseNewData		=	interruptCause;
				scauseEn			=	1'b1;

				stvalNewData		=	32'b0;
				stvalEn				=	1'b1;


                mstatusNewData 		= mstatus;

                mstatusNewData[5] 	= mstatus[1]; 			// SPIE <- SIE
                mstatusNewData[1] 	= 1'b0;       			// SIE  <- 0
                mstatusNewData[8] 	= (curPriv == PRIV_S);	// SPP

				mstatusEn			=	1'b1;
			
				changePCSrc			=	1'b1;

                newCurPriv    		= 	PRIV_S;
                newCurPrivEn  		= 	1'b1;

			end else begin
        		delegate 			= 	1'b0;
				mepcNewData			=	PC_A_o;
				mepcEn				=	1'b1;

				mcauseNewData		=	interruptCause;
				mcauseEn			=	1'b1;

				mtvalNewData		=	32'b0;
				mtvalEn				=	1'b1;

                mstatusNewData 		= mstatus;

                mstatusNewData[7]   = mstatus[3]; 			// MPIE <- MIE
                mstatusNewData[3]   = 1'b0;       			// MIE  <- 0
                mstatusNewData[12:11]= curPriv;  			// MPP

				mstatusEn			=	1'b1;
			
				changePCSrc			=	1'b1;

                newCurPriv    		= 	PRIV_M;
                newCurPrivEn  		= 	1'b1;
			end
		end
		else if (mret)	begin
			mreturn				=	1'b1;

            mstatusNewData 		= mstatus;
            mstatusNewData[3] 	= mstatus[7];   // MIE <- MPIE
            mstatusNewData[7] 	= 1'b1;         // MPIE <- 1
            case (mstatus[12:11])
                PRIV_M: 	newCurPriv = PRIV_M;
                PRIV_S: 	newCurPriv = PRIV_S;
                default:	newCurPriv = PRIV_U;
            endcase
            newCurPrivEn = 1'b1;
            mstatusNewData[12:11] = 2'b00;    	// MPP <- U
			mstatusEn			=	1'b1;

			changePCSrc			=	1'b1;	   
			cleanPipe			=	1'b1;
			delegate			=	1'b0;
		end
		else if (sret)	begin
			sreturn				=	1'b1;

            mstatusNewData 		= mstatus;
            mstatusNewData[1] 	= mstatus[5];   // SIE <- SPIE
            mstatusNewData[5] 	= 1'b1;         // SPIE <- 1
            if (mstatus[8])
                newCurPriv = PRIV_S;
            else
                newCurPriv = PRIV_U;
            newCurPrivEn = 1'b1;
            mstatusNewData[8] 	= 1'b0;         // SPP <- U
			mstatusEn			=	1'b1;

			changePCSrc			=	1'b1;	   
			cleanPipe			=	1'b1;
			delegate			=	1'b1;
		end
		else if (ecall) begin
        	changePCSrc = 1'b1;
            cleanPipe   = 1'b1;
            if ((curPriv == PRIV_S) && medelegData[9]) begin // S-mode ECALL delegated to S
    			delegate 			= 1'b1;
                sepcNewData 		= PC_E_o;
                sepcEn      		= 1'b1;

                scauseNewData 		= 32'd9;
                scauseEn     		= 1'b1;

                stvalNewData 		= 32'b0;
                stvalEn      		= 1'b1;

                mstatusNewData 		= mstatus;
                mstatusNewData[5] 	= mstatus[1]; // SPIE <- SIE
                mstatusNewData[1] 	= 1'b0;       // SIE <- 0
                mstatusNewData[8] 	= 1'b1;       // SPP <- S
                mstatusEn 			= 1'b1;

                newCurPriv   		= PRIV_S;
                newCurPrivEn 		= 1'b1;
            end else if ((curPriv == PRIV_U) && medelegData[8]) begin // U-mode ECALL delegated to S
    			delegate 			= 1'b1;
                sepcNewData 		= PC_E_o;
                sepcEn      		= 1'b1;

                scauseNewData 		= 32'd8;
                scauseEn      		= 1'b1;

                stvalNewData 		= 32'b0;
                stvalEn      		= 1'b1;

                mstatusNewData 		= mstatus;
                mstatusNewData[5] 	= mstatus[1]; // SPIE <- SIE
                mstatusNewData[1] 	= 1'b0;       // SIE <- 0
                mstatusNewData[8] 	= 1'b0;       // SPP <- U
                mstatusEn 			= 1'b1;

                newCurPriv   		= PRIV_S;
                newCurPrivEn 		= 1'b1;
            end else begin // Otherwise ECALL -> M
    			delegate 			= 1'b0;
                mepcNewData 		= PC_E_o;
                mepcEn      		= 1'b1;

                case (curPriv)
                    PRIV_U: 	mcauseNewData = 32'd8;
                    PRIV_S: 	mcauseNewData = 32'd9;
                    default: 	mcauseNewData = 32'd11;
                endcase
                mcauseEn = 1'b1;

                mtvalNewData 		= 32'b0;
                mtvalEn      		= 1'b1;

                mstatusNewData 		= mstatus;
                mstatusNewData[7]   = mstatus[3]; // MPIE <- MIE
                mstatusNewData[3]   = 1'b0;       // MIE <- 0
                mstatusNewData[12:11] = curPriv;  // MPP
                mstatusEn 			= 1'b1;

                newCurPriv   		= PRIV_M;
                newCurPrivEn 		= 1'b1;
            end
        end
	end
endmodule