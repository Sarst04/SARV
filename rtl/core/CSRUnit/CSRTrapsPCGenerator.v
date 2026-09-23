////////////////////////////////////////////////////////////////////////////////
// File      : CSRTrapsPCGenerator.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-09-19 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_traps_pc_generator(
	input wire			mreturn,
	input wire			sreturn,
	input wire			delegate,
	

	input wire [31:0]	interruptCause,

	input wire [31:0]	mtvec,
	input wire [31:0] 	mepc,

    input wire [31:0]   stvec,
    input wire [31:0]   sepc,

	output reg [31:0]	targetPC
);

    reg [31:0] trapVector;

	always @(mreturn, sreturn, mtvec, mepc, stvec, sepc, delegate, interruptCause) begin
		targetPC 	= 32'b0;
		trapVector 	= 32'b0;

		if (mreturn) begin
			targetPC	=	mepc;
		end else if (sreturn) begin
			targetPC	=	sepc;
		end else begin
            if (delegate) begin
                trapVector = stvec;
            end
            else begin
                trapVector = mtvec;
            end

            if (trapVector[1:0] == 2'b00) begin
                targetPC = {trapVector[31:2], 2'b00};
            end else if (trapVector[1:0] == 2'b01) begin
                // Exception
                if (interruptCause[31] == 1'b0) begin
                    targetPC = {trapVector[31:2], 2'b00};
                end
                // Interrupt
                else begin
                    targetPC = {trapVector[31:2], 2'b00} + (interruptCause[30:0] << 2);
                end
            end
        end
	end
endmodule