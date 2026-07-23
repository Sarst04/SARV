////////////////////////////////////////////////////////////////////////////////
// File      : jumpUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-07-17 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module jump_unit #(
    parameter ENTRY_INDEX_BITS = 1
)(
    input  wire         clk,
    input  wire         rst,

	// Control signal
	input  wire 		callDetected_E_o_A_i,
	input  wire			returnDetected_F_o_A_i,
	input  wire			returnDetected_E_o_A_i,
	input  wire			jumpDetect_E_o_A_i,
	input  wire			targetMatch_E_o_A_i,

	output reg			changePCSrcJumpUnitTarget,
	output reg			mispredictJump,

	// Data signal
	input  wire [31:0]	nextPC_E_o_A_i,
	input  wire [31:0]	PCTarget_E_o_A_i,

	output reg  [31:0]	PCTargetJumpUnit,
	output wire	[31:0]	topOfRas
);
    generate
        if (ENTRY_INDEX_BITS == 0) begin : gen_zero_index
            always @(*) begin
                changePCSrcJumpUnitTarget = jumpDetect_E_o_A_i;
                mispredictJump            = jumpDetect_E_o_A_i;
                PCTargetJumpUnit          = PCTarget_E_o_A_i;
            end
			assign	topOfRas 			  = 32'b0;
        end else begin
			reg			push;
			reg		  	pop;
			reg [30:0] 	pushData;
			wire[30:0] 	popData;

			
			circular_buffer #(
     			.ENTRY_INDEX_BITS(ENTRY_INDEX_BITS),
				.DATA_SIZE(31)
			) circularBuffer(
				.clk(clk),
				.rst(rst),
    
				.push(push),
				.pop(pop),

				.pushData(pushData),
				.popData(popData)
			);
			assign	topOfRas 	= {popData, 1'b0};
			always @(returnDetected_F_o_A_i, popData, jumpDetect_E_o_A_i, returnDetected_E_o_A_i, targetMatch_E_o_A_i, PCTarget_E_o_A_i, nextPC_E_o_A_i) begin
				{push,  pop, pushData} = 
				{1'b0, 1'b0, 	31'b0};

				{mispredictJump, changePCSrcJumpUnitTarget, PCTargetJumpUnit} = 
				{1'b0, 			 1'b0, 		   				32'b0};

				if (returnDetected_F_o_A_i) begin
					changePCSrcJumpUnitTarget 	= 1'b1;
					PCTargetJumpUnit		    = {popData, 1'b0};
				end
				if (jumpDetect_E_o_A_i) begin
					if (returnDetected_E_o_A_i) begin
						if (!targetMatch_E_o_A_i) begin  // mispredict	
							mispredictJump		 		= 1'b1;
							changePCSrcJumpUnitTarget 	= 1'b1;
							PCTargetJumpUnit		    = PCTarget_E_o_A_i;
						end else begin // correct predict
							pop = 1'b1;
						end
					end
					else begin
						if (callDetected_E_o_A_i) begin
							pushData 				= nextPC_E_o_A_i[31:1];
							push					= 1'b1;
						end
						mispredictJump		 		= 1'b1;
						changePCSrcJumpUnitTarget 	= 1'b1;
						PCTargetJumpUnit		    = PCTarget_E_o_A_i;
					end
				end
			end
		end
	endgenerate
endmodule