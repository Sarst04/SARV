////////////////////////////////////////////////////////////////////////////////
// File      : Register.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2025-12-10 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module register #(parameter WIDTH = 8)(
    input wire clk,
    input wire rst,
    
    input wire enable,
    input wire clear,
    input wire [WIDTH-1:0] regIn,

    output reg [WIDTH-1:0] regOut
);
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            regOut <= {WIDTH{1'b0}};
        end else if (clear) begin
            regOut <= {WIDTH{1'b0}};
        end else if (enable) begin
            regOut <= regIn;
        end
    end

endmodule