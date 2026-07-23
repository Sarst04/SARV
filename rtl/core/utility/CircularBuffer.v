////////////////////////////////////////////////////////////////////////////////
// File      : CircularBuffer.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-07-18
// Description: LIFO implemented on the top of circular buffer
//
////////////////////////////////////////////////////////////////////////////////
module circular_buffer #(
    parameter ENTRY_INDEX_BITS = 2,
    parameter DATA_SIZE = 31
)(
    input  wire                         clk,
    input  wire                         rst,
    
    input  wire                         push,
    input  wire                         pop,

    input  wire [DATA_SIZE-1:0]         pushData,
    output wire [DATA_SIZE-1:0]         popData
);
    localparam DEPTH = 1 << ENTRY_INDEX_BITS;

    reg [DATA_SIZE - 1:0] stack [0:DEPTH-1];
    reg [ENTRY_INDEX_BITS - 1 : 0] sp;

    integer i;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            sp <= {ENTRY_INDEX_BITS{1'b0}};
            for (i = 0; i < DEPTH; i = i + 1) begin
                stack[i] <= {DATA_SIZE{1'b0}};
            end
        end else begin
            case ({push, pop})
                2'b10: begin // Push
                    stack[sp] <= pushData;
                    sp        <= sp + 1'b1;
                end
                2'b01: begin // Pop
                    sp        <= sp - 1'b1;
                end
                2'b11: begin // Push & Pop
                    stack[sp - 1'b1] <= pushData;
                end
            endcase
        end
    end

    assign popData = stack[sp - 1'b1];

endmodule