////////////////////////////////////////////////////////////////////////////////
// File      : popCount.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-02-15 (last modified)
// Description:
//   Used for B extension
////////////////////////////////////////////////////////////////////////////////
module popCount (
    input  wire [31:0] in,
    output reg  [31:0] count
);
	integer i;
    always @(in) begin
		count	=	32'b0;
		for ( i=0; i<31; i = i + 1) begin
			if (in[i] == 1'b1)
				count =	count +	1;
		end
	end
endmodule
