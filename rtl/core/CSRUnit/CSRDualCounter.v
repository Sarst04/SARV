////////////////////////////////////////////////////////////////////////////////
// File      : CSRDualCounter.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-02-06 (last modified)
// Description:
//   64 bit counter with low and high ports
////////////////////////////////////////////////////////////////////////////////
module CSR_dual_counter (
    input  wire 		clk,
    input  wire 		rst,
    
    input  wire 		enL,
    input  wire 		enH,
    input  wire 		ce,
    input  wire 		stall,

    input  wire [31:0]  dataInL,
    input  wire [31:0]  dataInH,
    output wire [31:0] 	dataOutL,
    output wire [31:0] 	dataOutH
);
	reg	[63:0]	count;
    always @(posedge clk, posedge rst) begin
        if (rst)
            count 		 <= 64'b0;
        else if (enL) 
            count[31: 0] <= dataInL;
        else if (enH) 
            count[63:32] <= dataInH;
        else if (stall) 
            count		 <= count;
        else if (ce) 
            count		 <= count + 1;
    end
	
	assign	dataOutL	=	count[31: 0];
	assign	dataOutH	=	count[63:32];

endmodule