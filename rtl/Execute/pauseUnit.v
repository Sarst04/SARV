module pause_unit(
	input  wire		clk,
	input  wire		rst,

	input  wire		pauseReq,

	output reg		pauseCore
);
	reg		   countEnable;
	reg [ 7:0] count;
	wire	   carryOut;

	parameter ACTIVE = 0, PAUSE = 1;

	reg ps,ns;

	always @(posedge clk, posedge rst) begin
		if (rst)
			ps = 1'b0;
		else
			ps = ns;
	end
	
	always @(ps, pauseReq, carryOut) begin		ns = ps;
		case (ps)
			ACTIVE 	: begin
				if (pauseReq)
					ns = PAUSE;
			end
			PAUSE 	: begin
				//$display("\n[pause] Time: %0t ns", $time);
				if (carryOut | (~pauseReq))
					ns = ACTIVE;
			end
		endcase
	end

	always @(ps, pauseReq, carryOut) begin
		pauseCore	=	1'b0;
		countEnable	=	1'b0;
		case (ps)
			ACTIVE 	: begin
				if (pauseReq)
					pauseCore	=	1'b1;
			end
			PAUSE 	: begin
				pauseCore	=	1'b1;
				countEnable	=	1'b1;
				if (carryOut | (~pauseReq))
					pauseCore	=	1'b0;
			end
		endcase
	end

	always @(posedge clk, posedge rst) begin
		if (rst)
			count 		= 	8'b0;
		else if (countEnable)
			count 		= 	count + 1;
		else
			count 		= 	8'b0;
	end

	assign	carryOut	=	&count;
	
endmodule