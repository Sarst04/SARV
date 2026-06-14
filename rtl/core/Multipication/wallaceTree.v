////////////////////////////////////////////////////////////////////////////////
// File      : wallaceTree.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-10 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module wallace_tree (
    input  wire        isASigned,
    input  wire        isBSigned,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [63:0] wallaceSum,
    output wire [63:0] wallaceCarry
);
    localparam NUM_PARTIAL_PRODUCTS = 17;
    localparam EFFECTIVE_WIDTH      = 64;
    
    wire [NUM_PARTIAL_PRODUCTS*EFFECTIVE_WIDTH-1:0] partial_products;
    
    wire [34:0] b_padded;
    assign b_padded = isBSigned ? { {2{b[31]}}, b, 1'b0 } : { 2'b0, b, 1'b0 };

    wire signed [63:0] a_ext;
    assign a_ext = isASigned ? $signed(a) : $signed({32'b0, a});

    genvar i;
    generate
        for (i = 0; i < NUM_PARTIAL_PRODUCTS; i = i + 1) begin : gen_booth_partial_products
            wire [2:0] booth_bits;
            assign booth_bits = b_padded[2*i+2 : 2*i];

            wire signed [63:0] raw_pp;

            assign raw_pp = (booth_bits == 3'b000 || booth_bits == 3'b111) ? 64'd0 :
                            (booth_bits == 3'b001 || booth_bits == 3'b010) ? a_ext :
                            (booth_bits == 3'b011) ? (a_ext << 1) :
                            (booth_bits == 3'b100) ? (-a_ext << 1) :
                            (booth_bits == 3'b101 || booth_bits == 3'b110) ? -a_ext :
                            64'd0;

            assign partial_products[i*EFFECTIVE_WIDTH +: EFFECTIVE_WIDTH] = raw_pp << (2*i);
        end
    endgenerate
    
    wallace_tree_recursive #(
        .NUM_ROWS(NUM_PARTIAL_PRODUCTS)
    ) wallace_tree_inst (
        .partial_sums(partial_products),
        .sum         (wallaceSum),
        .carry       (wallaceCarry)
    );
    
endmodule

module wallace_tree_recursive #(
    parameter NUM_ROWS = 17
) (
    input  wire [NUM_ROWS*64-1:0] partial_sums,
    output wire [63:0] sum,
    output wire [63:0] carry
);

  localparam NUM_CSA_ROWS    = NUM_ROWS / 3;
  localparam LEFTOVER_ROWS   = NUM_ROWS % 3;
  localparam NEXT_STAGE_ROWS = (NUM_CSA_ROWS * 2) + LEFTOVER_ROWS;

  wire [NEXT_STAGE_ROWS*64-1:0] partial_sums_next; 

  genvar row_idx;
  generate
    if (NUM_ROWS <= 2) begin : gen_tree_root
      assign sum   = partial_sums[63:0];
      assign carry = (NUM_ROWS == 2) ? partial_sums[127:64] : 64'd0;

    end else begin : gen_recursive_tree
      for (row_idx = 0; row_idx < NUM_CSA_ROWS; row_idx = row_idx + 1) begin : csa_rows
        wire [63:0] csa_sum;
        wire [63:0] csa_carry;
        wire [63:0] csa_carry_shifted;
        
        wire [63:0] row_a = partial_sums[(row_idx*3)*64 +: 64];
        wire [63:0] row_b = partial_sums[(row_idx*3+1)*64 +: 64];
        wire [63:0] row_c = partial_sums[(row_idx*3+2)*64 +: 64];

        carry_save_row_adder carry_save_rows_inst (
            .row_a(row_a),
            .row_b(row_b),
            .row_c(row_c),
            .sum  (csa_sum),
            .carry(csa_carry)
        );

        assign csa_carry_shifted = {csa_carry[62:0], 1'b0};
        
        assign partial_sums_next[row_idx*2*64 +: 64]     = csa_sum;
        assign partial_sums_next[(row_idx*2+1)*64 +: 64] = csa_carry_shifted;
      end

      for (row_idx = 0; row_idx < LEFTOVER_ROWS; row_idx = row_idx + 1) begin
        assign partial_sums_next[((NUM_CSA_ROWS*2)+row_idx)*64 +: 64] = 
               partial_sums[((NUM_CSA_ROWS*3)+row_idx)*64 +: 64];
      end

      wallace_tree_recursive #(
          .NUM_ROWS(NEXT_STAGE_ROWS)
      ) next_wallance_tree_level (
          .partial_sums(partial_sums_next),
          .sum         (sum),
          .carry       (carry)
      );
    end

  endgenerate

endmodule

module carry_save_row_adder (
    input  wire [63:0] row_a,
    input  wire [63:0] row_b,
    input  wire [63:0] row_c,
    output wire [63:0] sum,
    output wire [63:0] carry
);

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : csa_bits
            assign sum[i]   = row_a[i] ^ row_b[i] ^ row_c[i];
            assign carry[i] = (row_a[i] & row_b[i]) | (row_b[i] & row_c[i]) | (row_a[i] & row_c[i]);
        end
    endgenerate

endmodule
