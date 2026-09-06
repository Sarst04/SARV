////////////////////////////////////////////////////////////////////////////////
// File      : carryLessMultiply.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-08-18 (last modified)
// Description:
//   carry less multiplier using karatsuba algorithm for area optimized
////////////////////////////////////////////////////////////////////////////////
module clmul_karatsuba #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] 	a,
    input  wire [WIDTH-1:0] 	b,
    output wire [2*WIDTH-2:0] 	product
);
    generate
        if (WIDTH == 2) begin : base2
            assign product[0] = a[0] & b[0];
            assign product[1] =(a[1] & b[0]) ^ (a[0] & b[1]);
            assign product[2] = a[1] & b[1];
        end
        else if (WIDTH == 4) begin : base4
            assign product[0] = a[0] & b[0];
            assign product[1] =(a[0] & b[1]) ^ (a[1] & b[0]);
            assign product[2] =(a[0] & b[2]) ^ (a[1] & b[1]) ^ (a[2] & b[0]);
            assign product[3] =(a[0] & b[3]) ^ (a[1] & b[2]) ^ (a[2] & b[1]) ^ (a[3] & b[0]);
            assign product[4] =(a[1] & b[3]) ^ (a[2] & b[2]) ^ (a[3] & b[1]);
            assign product[5] =(a[2] & b[3]) ^ (a[3] & b[2]);
            assign product[6] = a[3] & b[3];
        end
        else begin : recurse
            localparam H = WIDTH / 2;

            wire [H-1:0] a0 = a[H-1:0];
            wire [H-1:0] a1 = a[WIDTH-1:H];
            wire [H-1:0] b0 = b[H-1:0];
            wire [H-1:0] b1 = b[WIDTH-1:H];

            wire [2*H-2:0] p0;
            wire [2*H-2:0] p1;
            wire [2*H-2:0] p2;

            clmul_karatsuba #(.WIDTH(H)) u0 (
                .a      (a0),
                .b      (b0),
                .product(p0)
            );

            clmul_karatsuba #(.WIDTH(H)) u1 (
                .a      (a1),
                .b      (b1),
                .product(p1)
            );

            clmul_karatsuba #(.WIDTH(H)) u2 (
                .a      (a0 ^ a1),
                .b      (b0 ^ b1),
                .product(p2)
            );

            wire [2*H-2:0] mid = p2 ^ p0 ^ p1;

            assign product[H-1:0]        = p0[H-1:0];
            assign product[2*H-2:H]      = p0[2*H-2:H] ^ mid[H-2:0];
            assign product[2*H-1]        = mid[H-1];
            assign product[3*H-2:2*H]    = mid[2*H-2:H] ^ p1[H-2:0];
            assign product[4*H-2:3*H-1]  = p1[2*H-2:H-1];
        end
    endgenerate
endmodule


module carry_less_multiplier (
    input  wire [31:0] inA,
    input  wire [31:0] inB,
    input  wire [1:0]  op,  // 00: clmul, 01: clmulh, 10: clmulr
    output reg  [31:0] out
);

    wire [62:0] product;

    clmul_karatsuba #(.WIDTH(32)) clmulKaratsuba (
        .a      (inA),
        .b      (inB),
        .product(product)
    );

    always @(product) begin
		out	= 32'b0;
        case (op)
            2'b00:   out = product[31:0];              // clmul
            2'b01:   out = {1'b0, product[62:32]};     // clmulh
            2'b10:   out = product[62:31];             // clmulr
        endcase
    end

endmodule