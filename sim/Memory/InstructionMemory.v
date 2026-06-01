module instruction_memory #(parameter MEM_SIZE = 1024) (
    input  wire 	   clk,
    input  wire 	   rst,
    input  wire [31:0] addr1,
    input  wire [31:0] addr2,
	input  wire	[ 1:0] accessType,

    output wire [31:0] dataOut1,
    output reg  [31:0] dataOut2
);

    reg [7:0] memory [0:MEM_SIZE-1];

	localparam BYTE 			= 2'b00;
	localparam HALFWORD 		= 2'b01;
	localparam WORD 			= 2'b10;
    
	integer i;
	initial begin
		for (i = 0; i < MEM_SIZE; i = i + 1 )
				memory[i] = 8'b0;
		$readmemb("D:\\Personal\\RiscV\\Design_V10\\Memory\\instructions.txt", memory);
	end
    
    assign dataOut1 = {memory[addr1 + 3], memory[addr1 + 2], memory[addr1 + 1], memory[addr1]};
	
	always @(addr2, accessType) begin
		dataOut2 =32'b0;
		case (accessType)
			BYTE : begin
				dataOut2	= {24'b0, memory[addr2]};
			end
			HALFWORD : begin
				dataOut2 = {16'b0, memory[addr2 + 1], memory[addr2]};
			end
			WORD : begin
				dataOut2	= {memory[addr2 + 3], memory[addr2 + 2], memory[addr2 + 1], memory[addr2]};
			end
		endcase
	end

endmodule