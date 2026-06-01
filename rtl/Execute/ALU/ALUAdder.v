module ALUAdder(
    input  wire [31:0] inA,
    input  wire [31:0] inB,
	input  wire 	   ci,
	
    output wire [31:0] out,
	output wire 	   co
);
    assign {co, out} = inA + inB + ci;
endmodule