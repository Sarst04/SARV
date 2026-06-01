module data_memory #(parameter MEM_SIZE = 1024) (
	input wire 			clk,
	input wire 			rst,
	
	input  wire		   	readRequest,
	input  wire		   	writeRequest,
	input  wire [ 1:0] 	accessType,
	input  wire		   	chipSelect,
	output wire			waitRequest,

	input  wire [31:0] 	address,
	input  wire [31:0] 	dataIn,
	output reg  [31:0] 	dataOut
);
	localparam BYTE 			= 2'b00;
	localparam HALFWORD 		= 2'b01;
	localparam WORD 			= 2'b10;

	
    reg [7:0] memory [0:MEM_SIZE - 1];

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
	
   assign	waitRequest	=	1'b0;
endmodule
