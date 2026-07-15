////////////////////////////////////////////////////////////////////////////////
// File      : PipeManagerUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-26 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module pipe_manager_unit (
	input  wire			clk,
	input  wire 		rst,

	// Control signal
	input  wire			jumpOrBranchFlush_A_o,
	input  wire 		memRead_E,
	input  wire 		memWrite_E,
	input  wire			mulEn_X1_i,
	input  wire			regWrite_M,
	input  wire			regWrite_W,
	input  wire			stallPipe_C_o,
	input  wire			waitRequest_M_o,
	input  wire			waitRequest_F_o,
	input  wire			coldDownPipe_C_o,
	input  wire			cleanPipe_C_o,
	input  wire			stageDEMWValid,
	input  wire			pauseCore_E_o,

	output wire			disablePCAdder_F_i,
	output wire			clear_F,
	output wire			stall_F,
	output wire			clear_D,
	output wire			stall_D,
	output wire			clear_EC,
	output wire			stall_EC,
	output wire			clear_MX,
	output wire			stall_MX,
	output wire			clear_W,
	output wire			stall_W,
	output wire			stallStatus,
	output wire			disableLoadStore_M_i,
	output wire			disableInstLoad_F_i,
	
	// Data signal
	input  wire [ 4:0] 	rs1Add_D,
	input  wire [ 4:0] 	rs2Add_D,
	input  wire [ 4:0] 	rs1Add_E,
	input  wire [ 4:0] 	rs2Add_E,
	input  wire [ 4:0] 	rd_E,
	input  wire [ 4:0] 	rd_M,
	input  wire [ 4:0] 	rd_W,

	output reg  [ 1:0] 	forwardA_E_i,
	output reg  [ 1:0] 	forwardB_E_i
);
	wire   	loadWordStall;
	wire	multiplyStall;	
	wire    pauseCore;
	wire   	fullPipeStall;

	// ForwardA_E
	always @(rs1Add_E, rd_M, rd_W, regWrite_M, regWrite_W) begin
		if ( ( (rs1Add_E == rd_M) & regWrite_M ) & (rs1Add_E != 5'b0) )
			forwardA_E_i = 2'b01;
		else if ( ( (rs1Add_E == rd_W) & regWrite_W ) & (rs1Add_E != 5'b0) )
			forwardA_E_i = 2'b10;
		else 
			forwardA_E_i = 2'b00;
	end
	
	// ForwardB_E
	always @(rs2Add_E, rd_M, rd_W, regWrite_M, regWrite_W) begin
		if ( ( (rs2Add_E == rd_M) & regWrite_M) & (rs2Add_E != 5'b0) )
			forwardB_E_i = 2'b01;
		else if ( ( (rs2Add_E == rd_W) & regWrite_W) & (rs2Add_E != 5'b0) )
			forwardB_E_i = 2'b10;
		else 
			forwardB_E_i = 2'b00;
	end


	assign  loadWordStall			= memRead_E & ( (rs1Add_D == rd_E) | (rs2Add_D == rd_E) );
	assign	multiplyStall			= ( (rs1Add_D == rd_E) | (rs2Add_D == rd_E)  ) & mulEn_X1_i;
	assign 	disablePCAdder_F_i		= coldDownPipe_C_o | waitRequest_F_o;
	assign  pauseCore				= pauseCore_E_o & (~coldDownPipe_C_o);
	assign  fullPipeStall			= stallPipe_C_o;
	assign  disableLoadStore_M_i	= stallPipe_C_o;
	assign  disableInstLoad_F_i		= stallPipe_C_o;

	assign clear_F 					= 1'b0;
	assign clear_D 					= (jumpOrBranchFlush_A_o | cleanPipe_C_o | coldDownPipe_C_o | waitRequest_F_o) 	& (~fullPipeStall) & (~waitRequest_M_o);
	assign clear_EC 				= (jumpOrBranchFlush_A_o | cleanPipe_C_o | loadWordStall    | multiplyStall  ) 	& (~fullPipeStall) & (~waitRequest_M_o);
	assign clear_MX 				= (pauseCore)																	& (~fullPipeStall) & (~waitRequest_M_o);
	assign clear_W 					= 1'b0;

	assign stall_F 					= loadWordStall | fullPipeStall   | waitRequest_M_o | pauseCore | multiplyStall;
	assign stall_D 					= loadWordStall | fullPipeStall   | waitRequest_M_o | pauseCore | multiplyStall;
	assign stall_EC 				= 				  fullPipeStall   | waitRequest_M_o | pauseCore;
	assign stall_MX 				= 				  fullPipeStall   | waitRequest_M_o ;
	assign stall_W 					= 				  fullPipeStall   | waitRequest_M_o ;

		
	assign stallStatus				=	stall_F 	| stall_D 	| stall_EC 	| 	stall_MX 	| 	stall_W; 
endmodule