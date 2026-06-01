module adder(
    input  wire [31:0] inA,
    input  wire [31:0] inB,

    output wire [31:0] out
);
    assign out = inA + inB;
endmodule