module addressGeneration_stage (
    input wire 			clk,
    input wire 			rst,
	
	// Control signal
	input  wire 		changePCSrc_E_o_A_i,
	input  wire			changePCSrc_C_o_A_i,

	// Data signal
	input  wire [31:0] 	PCTarget_E_o_A_i,
	input  wire [31:0] 	PCTarget_C_o_A_i,
	input  wire [31:0] 	nextPC_A_i,

	output wire [31:0] 	selectedPC_A_o,
	output wire [31:0] 	PC_A_o
);

	assign	selectedPC_A_o	=	(changePCSrc_E_o_A_i 	==  1'b0)	?	nextPC_A_i		:	PCTarget_E_o_A_i;
	assign	PC_A_o			=	(changePCSrc_C_o_A_i	==	1'b0)	?	selectedPC_A_o	:	PCTarget_C_o_A_i;

endmodule