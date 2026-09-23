////////////////////////////////////////////////////////////////////////////////
// File      : CSRTripleInRegister.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-09-21 (last modified)
// Description:
//   Register used in CSR unit whith three input ports
//	 input 3 has priority over input 2
//	 input 2 has priority over input 1
////////////////////////////////////////////////////////////////////////////////
module triplePortRegister #(parameter WIDTH = 8, parameter rstValue = 8'b0)(
    input  wire clk,
    input  wire rst,
    
    input  wire en1,
    input  wire [WIDTH-1:0] dataIn1,

    input  wire en2,
    input  wire [WIDTH-1:0] dataIn2,

    input  wire en3,
    input  wire [WIDTH-1:0] dataIn3,

    output reg [WIDTH-1:0] dataOut
);
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            dataOut <= rstValue;
        end else if (en3) begin
            dataOut <= dataIn3;
        end else if (en2) begin
            dataOut <= dataIn2;
        end else if (en1) begin
            dataOut <= dataIn1;
        end
    end

endmodule