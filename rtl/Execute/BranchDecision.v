module branch_decision (
	input  wire [31:0]	srcA,
	input  wire [31:0]	srcB,
	input  wire			branch,
	input  wire [ 2:0]	branchType,
	
	output reg			takeBranch
);

	localparam	BEQ		= 3'b000;
	localparam	BNE		= 3'b001;
	localparam	BLT		= 3'b100;
	localparam	BGE		= 3'b101;
	localparam	BLTU	= 3'b110;
	localparam	BGEU	= 3'b111;


	reg		isSignedComparison;
	wire	eq;
	wire	gt;
	wire	lt;

	comparator Comp(
		.inA(srcA),
		.inB(srcB),
		.isSignedComparison(isSignedComparison),
		.eq(eq),
		.gt(gt),
		.lt(lt)
	);

	
	always @(eq, gt, lt, branch, branchType) begin
		{takeBranch, isSignedComparison} = 2'b0;
		if (branch) begin
			case (branchType)
				BEQ : begin
					isSignedComparison = 1'b1;
					takeBranch = eq;
				end
				BNE : begin
					isSignedComparison = 1'b1;
					takeBranch = ~eq;
				end
				BLT : begin
					isSignedComparison = 1'b1;
					takeBranch = lt;
				end
				BGE : begin
					isSignedComparison = 1'b1;
					takeBranch = gt | eq;
				end
				BLTU: begin
					isSignedComparison = 1'b0;
					takeBranch = lt;
				end
				BGEU: begin
					isSignedComparison = 1'b0;
					takeBranch = gt | eq;
				end
			endcase
		end
	end
endmodule
	