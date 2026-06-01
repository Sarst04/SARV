module CSR_traps_pc_generator(
	input wire			return,
	
	input wire [31:0]	mtvec,
	input wire [31:0]	mcause,
	input wire [31:0] 	mepc,

	
	output reg [31:0]	targetPC
);
	always @(return, mtvec, mcause, mepc) begin
		targetPC = 32'b0;

		if (return) begin

			targetPC	=	mepc;
		end
		else begin
			if (mtvec[1:0] == 2'b00) begin			// Direct
				targetPC	=	{mtvec[31:2], 2'b0};
			end
			else if (mtvec[1:0] == 2'b01) begin 	// Vectored
				// exceptions
				if (mcause[31] == 1'b0)
					targetPC	=	{mtvec[31:2], 2'b0};
				// Interrupts
				else
					targetPC	=	{mtvec[31:2], 2'b0} + (mcause[30:0]) << 2;
			end
		end

	end
	/*
	always @(posedge return) begin
		 	$display("\n[return] Time: %0t ns, targetPC:0x%h ", $time, mepc);
	end
	*/
endmodule