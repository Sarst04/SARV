////////////////////////////////////////////////////////////////////////////////
// File      : dataMemoryModel.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-26 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module dataMemoryModel #(
	parameter MEM_SIZE 	= 1024,
	parameter DELAY	   	= 0
) (
	input wire 			clk,
	input wire 			rst,
	
	input  wire		   	readRequest,
	input  wire		   	writeRequest,
	input  wire [ 1:0] 	accessType,
	input  wire		   	chipSelect,
	output reg			waitRequest,

	input  wire [31:0] 	address,
	input  wire [31:0] 	dataIn,
	output reg  [31:0] 	dataOut
);
	generate
		if (DELAY == 0) begin : ZERO_DELAY
			always @(readRequest, writeRequest, accessType, chipSelect, address, dataIn) begin
            	waitRequest = 1'b0;
        	end
		end else begin : NON_ZERO_DELAY
			reg [ 3:0] 	counter;
			reg			countEn;
			reg			countClear;
			wire		carryOut;

			always @(posedge clk, posedge rst) begin
				if (rst) begin
					counter <= 4'b1111 - DELAY;
				end else if (countEn) begin
					counter <= counter + 1'b1;
				end else if (countClear) begin
					counter <= 4'b1111 - DELAY;		
				end
			end
			assign carryOut	= &counter;
	


    		localparam IDLE = 1'b0;
    		localparam WAIT = 1'b1;
    
    		reg ps, ns;
    		always @(posedge clk or posedge rst) begin
        		if (rst)
            		ps <= IDLE;
        		else
            		ps <= ns;
    		end
    
    		always @(ps, readRequest, writeRequest, chipSelect, carryOut) begin
		 		ns 		= IDLE;
        		case (ps)
            		IDLE:    ns 		= (readRequest && chipSelect) |  (writeRequest && chipSelect)  ? WAIT : IDLE;
            		WAIT:    ns 		= carryOut ? IDLE : WAIT;
        		endcase
    		end

    		always @(ps, readRequest, writeRequest, chipSelect, carryOut) begin
				waitRequest = 1'b0;
				countClear  = 1'b0;
				countEn		= 1'b0;
        		case (ps)
            		IDLE: begin
						countClear 	= 1'b1;
						waitRequest = ((readRequest && chipSelect) | (writeRequest && chipSelect));
					end
            		WAIT: begin  
						countEn		= 1'b1;
					waitRequest = carryOut ? 1'b0 : 1'b1;
					end
        			endcase
    		end
	    end
	endgenerate


	localparam BYTE 			= 2'b00;
	localparam HALFWORD 		= 2'b01;
	localparam WORD 			= 2'b10;
	
    reg [7:0]  memory [0:MEM_SIZE - 1];

	always @(readRequest, chipSelect, accessType, address) begin
		dataOut  = 32'b0;
		if (readRequest & chipSelect) begin
			case (accessType)
				BYTE : begin
					dataOut	= {24'b0, memory[address]};
				end
				HALFWORD : begin
					dataOut = {16'b0, memory[address + 1], memory[address]};
				end
				WORD : begin
					dataOut	= {memory[address + 3], memory[address + 2], memory[address + 1], memory[address]};
				end
			endcase
		end
	end 


	integer i;
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			for (i = 0; i < MEM_SIZE; i = i + 1 )
				memory[i] = 8'b0;
		end
		else begin
			if (writeRequest & chipSelect) begin
				case (accessType)
					BYTE : begin
						memory[address    ] = dataIn[ 7: 0];
					end
					HALFWORD : begin
						memory[address	  ] = dataIn[ 7: 0];
						memory[address + 1] = dataIn[15: 8];
					end
					WORD : begin
						memory[address	  ] = dataIn[ 7: 0];
						memory[address + 1] = dataIn[15: 8];
						memory[address + 2] = dataIn[23:16];
						memory[address + 3] = dataIn[31:24];
					end
				endcase
			end
		end
	end

endmodule
