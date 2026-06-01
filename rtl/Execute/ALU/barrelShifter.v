module barrel_shifter(
	input  wire			[ 2:0] opcode,

	input  wire signed	[31:0] dataIn,
	input  wire      	[ 4:0] shamt,
	
	output reg			[31:0] dataOut
);
	localparam	BARREL_OP_SLL		=	3'b001;
	localparam	BARREL_OP_SRL		=	3'b010;
	localparam	BARREL_OP_SRA		=	3'b011;
	localparam	BARREL_OP_ROR		=	3'b100;
	localparam	BARREL_OP_ROL		=	3'b101;

	reg [63:0] temp;

	always @(opcode, dataIn, shamt)begin
		dataOut	=	32'b0;
    	case (opcode)
        	BARREL_OP_SLL : dataOut = dataIn 		<< 	shamt;
        	BARREL_OP_SRL : dataOut = dataIn 		>> 	shamt;
        	BARREL_OP_SRA : dataOut = dataIn 		>>> shamt;
        	BARREL_OP_ROR : begin
            	temp 	= {dataIn, dataIn}		    >> 	shamt;
            	dataOut = temp[31:0];
        	end
        	BARREL_OP_ROL : begin
            	temp 	= {dataIn, dataIn} 			<< 	shamt;
            	dataOut = temp[63:32];
        	end
    	endcase
	end
endmodule
