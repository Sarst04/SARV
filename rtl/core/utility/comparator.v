////////////////////////////////////////////////////////////////////////////////
// File      : comparator.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-01-24 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module comparator (
    input  wire [31:0] inA,
    input  wire [31:0] inB,
    input  wire        isSignedComparison,
    
    output wire        eq,
    output wire        gt,
    output wire        lt
);
    wire e1, e2, e3, e4;
    wire g1, g2, g3, g4;

    wire [31:0] aa;
    wire [31:0] bb;

    assign aa = (isSignedComparison) ? {~inA[31], inA[30:0]} : inA;
    assign bb = (isSignedComparison) ? {~inB[31], inB[30:0]} : inB;

    assign e1 = (aa[ 7: 0] == bb[ 7: 0]);
    assign e2 = (aa[15: 8] == bb[15: 8]);
    assign e3 = (aa[23:16] == bb[23:16]);
    assign e4 = (aa[31:24] == bb[31:24]);

	assign eq = e1 & e2 & e3 & e4;

    assign g1 = (aa[ 7: 0] > bb[ 7: 0]);
    assign g2 = (aa[15: 8] > bb[15: 8]);
    assign g3 = (aa[23:16] > bb[23:16]);
    assign g4 = (aa[31:24] > bb[31:24]);

    assign gt =  g4 |
                (e4 & g3)|
                (e4 & e3 & g2)|
                (e4 & e3 & e2 & g1);

	assign lt = ~eq & ~gt;
endmodule
