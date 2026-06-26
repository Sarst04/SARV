////////////////////////////////////////////////////////////////////////////////
// File      : instruction_memory.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-26 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module instructionMemoryModel #(
	parameter MEM_SIZE  = 1024,
	parameter DELAY	   	= 1
) (
    input  wire 	   clk,
    input  wire 	   rst,

	// Port A
	input  wire		   readRequestA,
    input  wire [31:0] addrA,
	input  wire	[ 1:0] accessTypeA,
    output reg  [31:0] dataOutA,
	output reg		   waitRequestA,

	// Port B
	input  wire		   readRequestB,
    input  wire [31:0] addrB,
	input  wire	[ 1:0] accessTypeB,
    output reg  [31:0] dataOutB,
	output reg		   waitRequestB
);

	localparam IDLE = 1'b0;
	localparam WAIT = 1'b1;

	generate
		if (DELAY == 0) begin : ZERO_DELAY_A
			always @(readRequestA) begin
            	waitRequestA = 1'b0;
        	end
		end else begin : NON_ZERO_DELAY_A
			reg [ 3:0] 	counterA;
			reg			countEnA;
			reg			countClearA;
			wire		carryOutA;
			reg         psA, nsA;

			always @(posedge clk, posedge rst) begin
				if (rst) begin
					counterA <= 4'b1111 - DELAY;
				end else if (countEnA) begin
					counterA <= counterA + 1'b1;
				end else if (countClearA) begin
					counterA <= 4'b1111 - DELAY;		
				end
			end
			assign carryOutA = &counterA;
	
    		always @(posedge clk, posedge rst) begin
        		if (rst)  
					psA <= IDLE;
        		else      
					psA <= nsA;
    		end
    
    		always @(psA, readRequestA, carryOutA) begin
		 		nsA = IDLE;
        		case (psA)
            		IDLE: nsA = readRequestA ? WAIT : IDLE;
            		WAIT: nsA = carryOutA    ? IDLE : WAIT;
        		endcase
    		end

    		always @(psA, readRequestA, carryOutA) begin
				waitRequestA = 1'b0;
				countClearA  = 1'b0;
				countEnA	 = 1'b0;
        		case (psA)
            		IDLE: begin
						countClearA  = 1'b1;
						waitRequestA = readRequestA;
					end
            		WAIT: begin  
						countEnA     = 1'b1;
						waitRequestA = carryOutA ? 1'b0 : 1'b1;
					end
        		endcase
    		end
	    end
	endgenerate


	generate
		if (DELAY == 0) begin : ZERO_DELAY_B
			always @(readRequestB) begin
            	waitRequestB = 1'b0;
        	end
		end else begin : NON_ZERO_DELAY_B
			reg [ 3:0] 	counterB;
			reg			countEnB;
			reg			countClearB;
			wire		carryOutB;
			reg         psB, nsB;

			always @(posedge clk, posedge rst) begin
				if (rst) begin
					counterB <= 4'b1111 - DELAY;
				end else if (countEnB) begin
					counterB <= counterB + 1'b1;
				end else if (countClearB) begin
					counterB <= 4'b1111 - DELAY;		
				end
			end
			assign carryOutB = &counterB;
	
    		always @(posedge clk, posedge rst) begin
        		if (rst)  
					psB <= IDLE;
        		else      
					psB <= nsB;
    		end
    
    		always @(psB, readRequestB, carryOutB) begin
		 		nsB = IDLE;
        		case (psB)
            		IDLE: nsB = readRequestB ? WAIT : IDLE;
            		WAIT: nsB = carryOutB    ? IDLE : WAIT;
        		endcase
    		end

    		always @(psB, readRequestB, carryOutB) begin
				waitRequestB = 1'b0;
				countClearB  = 1'b0;
				countEnB	 = 1'b0;
        		case (psB)
            		IDLE: begin
						countClearB  = 1'b1;
						waitRequestB = readRequestB;
					end
            		WAIT: begin  
						countEnB     = 1'b1;
						waitRequestB = carryOutB ? 1'b0 : 1'b1;
					end
        		endcase
    		end
	    end
	endgenerate


	localparam BYTE 			= 2'b00;
	localparam HALFWORD 		= 2'b01;
	localparam WORD 			= 2'b10;
    
	reg [7:0] memory [0:MEM_SIZE-1];
	
	integer i;
	initial begin
		for (i = 0; i < MEM_SIZE; i = i + 1)
			memory[i] = 8'b0;
		$readmemb("D:\\Personal\\RiscV\\Design_V12\\Memory\\instructions.txt", memory);
	end

	always @(readRequestA, addrA, accessTypeA) begin
		dataOutA = 32'b0;
		if (readRequestA) begin
			case (accessTypeA)
				BYTE : begin
					dataOutA = {24'b0, memory[addrA]};
				end
				HALFWORD : begin
					dataOutA = {16'b0, memory[addrA + 1], memory[addrA]};
				end
				WORD : begin
					dataOutA = {memory[addrA + 3], memory[addrA + 2], memory[addrA + 1], memory[addrA]};
				end
			endcase
		end
	end

	always @(readRequestB, addrB, accessTypeB) begin
		dataOutB = 32'b0;
		if (readRequestB) begin
			case (accessTypeB)
				BYTE : begin
					dataOutB = {24'b0, memory[addrB]};
				end
				HALFWORD : begin
					dataOutB = {16'b0, memory[addrB + 1], memory[addrB]};
				end
				WORD : begin
					dataOutB = {memory[addrB + 3], memory[addrB + 2], memory[addrB + 1], memory[addrB]};
				end
			endcase
		end
	end

endmodule