////////////////////////////////////////////////////////////////////////////////
// File      : adder.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-01-23 (last modified)
// Description:
//   32 bit adder
////////////////////////////////////////////////////////////////////////////////

module adder(
    input  wire [31:0] inA,
    input  wire [31:0] inB,

    output wire [31:0] out
);
    assign out = inA + inB;
endmodule