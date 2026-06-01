module CSR_sleeping_unit (
	input  wire			clk,
	input  wire			rst,

	input  wire 		wfi,
	input  wire 		irq,

	output reg 			stallCore
);

	reg	PS, NS;
	parameter WORKING = 1'b0, SLEEPING = 1'b1;

	always @(posedge clk, posedge rst) begin
		if (rst)
			PS <= WORKING;
		else
			PS <= NS;
	end
	
	always @(PS, wfi, irq) begin
		NS = PS;
		case (PS)
			WORKING : begin
				if (wfi)
					NS = SLEEPING;
			end
			SLEEPING : begin
				if (irq)
					NS = WORKING;
			end
		endcase
	end

	always @(PS, irq) begin
		stallCore = 1'b0;
		case (PS)
			SLEEPING 	: begin
				if (!irq)
					stallCore = 1'b1;
			end
		endcase
	end
endmodule