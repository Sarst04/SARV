////////////////////////////////////////////////////////////////////////////////
// File      : CSRInterInterruptController.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-09-20 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_inter_interrupt_controller(
    input wire 		    clk,
    input wire 		    rst,


    input wire [1:0]    curPriv,

	input wire 			mstatusMIE,
	input wire 			mstatusSIE,
	input wire			stageDEMWValid,

	output reg			coldDownPipe,
	output reg			raiseInterrupt,
	output wire			irqReady,
	output wire			delegated,

	input wire [31:0]	mip,
	input wire [31:0]  	mie,
	input wire [31:0]	sip,
	input wire [31:0]  	sie,
	input wire [31:0]   midelegData,
	
	output reg  [31:0]	interruptCause
);
    localparam PRIV_U 	= 2'b00;
    localparam PRIV_S 	= 2'b01;
    localparam PRIV_M 	= 2'b11;

	wire		[31:0]	acceptableMInterrupt;
	wire		[31:0]	acceptableSInterrupt;

	assign 	acceptableMInterrupt 	= 	mip & mie & ~midelegData;
	assign  acceptableSInterrupt	=	sip & sie & midelegData;


    wire mInterruptEnabled;
    wire sInterruptEnabled;

    assign mInterruptEnabled 	= (curPriv == PRIV_M) ? mstatusMIE : 1'b1;

	assign sInterruptEnabled 	= (curPriv == PRIV_U) ? 1'b1 :
    							  (curPriv == PRIV_S) ? mstatusSIE :
                          		   1'b0;


	wire 	irqReadyM;
	wire 	irqReadyS;

	assign	irqReadyM			=	(|acceptableMInterrupt) &  mInterruptEnabled;
	assign	irqReadyS			=	(|acceptableSInterrupt) &  sInterruptEnabled;

	assign  irqReady			=	irqReadyM | irqReadyS;
	assign  delegated			=  ~irqReadyM & irqReadyS;  


	always @(acceptableMInterrupt, acceptableSInterrupt, raiseInterrupt) begin
		interruptCause	=	32'b0;
		if (raiseInterrupt) begin
			if (acceptableMInterrupt[11])		// MEI
				interruptCause = {1'b1, 31'd11};
			else if (acceptableMInterrupt[3])	// MSI
				interruptCause = {1'b1, 31'd3};
			else if (acceptableMInterrupt[7])	// MTI
				interruptCause = {1'b1, 31'd7};
			else if (acceptableSInterrupt[9] | acceptableMInterrupt[9])	// SEI
				interruptCause = {1'b1, 31'd9};
			else if (acceptableSInterrupt[1] | acceptableMInterrupt[1])	// SSI
				interruptCause = {1'b1, 31'd1};
			else if (acceptableSInterrupt[5] | acceptableMInterrupt[5])	// STI
				interruptCause = {1'b1, 31'd5};
		end
	end
	
	parameter [ 1:0] idle = 2'd0, waitForClean = 2'd1, raise = 2'd2;
	reg 	  [ 1:0] ps, ns;

	always @(posedge clk, posedge rst) begin
		if (rst)
			ps <= idle;
		else
			ps <= ns;
	end

	always @(irqReady, ps, stageDEMWValid) begin
		ns = ps;
		case (ps)
			idle 			:	ns	=	irqReady			?	waitForClean	:	idle;
			waitForClean	:	ns	=	(stageDEMWValid)  	?	waitForClean	:	raise;
			raise			:	ns	=	idle;
		endcase
	end

	always @(irqReady, ps) begin
		coldDownPipe	=	1'b0;
		raiseInterrupt	=	1'b0;
		case (ps)
			idle 		:	begin
				if (irqReady)
					coldDownPipe	=	1'b1;
			 end
			waitForClean:	begin 
				coldDownPipe	=	1'b1;
			end
			raise	:	begin
				coldDownPipe	=	1'b1;
				raiseInterrupt	=	1'b1;
			end
		endcase
	end

endmodule