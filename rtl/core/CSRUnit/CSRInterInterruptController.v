////////////////////////////////////////////////////////////////////////////////
// File      : CSRInterInterruptController.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-05-24 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_inter_interrupt_controller(
    input wire 		    clk,
    input wire 		    rst,

	input wire [31:0]	mip,
	input wire [31:0]  	mie,
	input wire 			mstatusMIE,
	input wire			stageDEMWValid,

	output reg			coldDownPipe,
	output reg			raiseInterrupt,
	output wire			irqReady,
	output reg  [31:0]	interruptCause
);
	wire		[31:0]	acceptableInterrupt;

	assign 	acceptableInterrupt	=	(mip & mie);
	assign	irqReady			= |acceptableInterrupt;

	always @(acceptableInterrupt, raiseInterrupt) begin
		interruptCause	=	32'b0;
		if (raiseInterrupt) begin
			if (acceptableInterrupt[11]) 		// MEI
				interruptCause = {1'b1, 31'd11};
			else if (acceptableInterrupt[3]) 	// MSI
				interruptCause = {1'b1, 31'd3};
			else if (acceptableInterrupt[7]) 	// MTI
				interruptCause = {1'b1, 31'd7};
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

	always @(irqReady, mstatusMIE, ps, stageDEMWValid) begin
		ns = ps;
		case (ps)
			idle 			:	ns	=	(irqReady & mstatusMIE) 	?	waitForClean	:	idle;
			waitForClean	:	ns	=	(stageDEMWValid)  		?	waitForClean	:	raise;
			raise			:	ns	=	idle;
		endcase
	end

	always @(irqReady, mstatusMIE, ps) begin
		coldDownPipe	=	1'b0;
		raiseInterrupt	=	1'b0;
		case (ps)
			idle 		:	begin
				if ((irqReady & mstatusMIE))
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