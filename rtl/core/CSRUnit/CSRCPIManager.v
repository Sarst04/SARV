////////////////////////////////////////////////////////////////////////////////
// File      : CSRCPIManager.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-06-22 (last modified)
// Description:
//            
////////////////////////////////////////////////////////////////////////////////
module CSR_CPI_manager(
	input  wire			clk,
	input  wire			rst,

	input  wire	[ 1:0]	priv,
	input  wire	[ 3:0]	CPIRate,
	input  wire [ 7:0]  CPICTRL,

	output wire			stallCore
);
	//	CPI CTRL
	//								/		2:1		   /	0		//
	//								/ Most Priviledge  /	enable	//

	//  CPIT RATE
	// FROM 0  to 15 increase rate of STALL injection


	wire 		enable;
	wire		sign;
	wire [ 2:0] rate;


	assign 	enable 	= CPICTRL[ 0] & ( priv <= CPICTRL[2:1]);
	assign	sign 	= CPIRate[ 3];
	assign 	rate 	= CPIRate[ 2:0] ^ {sign, sign, sign};



	wire [23:0] ringOut;
	ringCounter24bit ringCounter (
		.clk(clk),
		.rst(rst),
	
		.enable(enable),
		.parallelOut(ringOut)
	);


	reg [23:0] stallMask;
	always @(CPIRate, enable) begin
		stallMask = 24'b0;
		if (enable) begin
			case (rate)
				3'b000 : stallMask = 24'b000000_000000_000000_000000; // 0/24
				3'b001 : stallMask = 24'b000000_000000_000000_000001; // 1/24
				3'b010 : stallMask = 24'b000000_000001_000000_000001; // 2/24
				3'b011 : stallMask = 24'b000000_010000_000100_000001; // 3/24
				3'b100 : stallMask = 24'b000001_000001_000001_000001; // 4/24
				3'b101 : stallMask = 24'b000100_010001_000100_010001; // 6/24
				3'b110 : stallMask = 24'b001001_001001_001001_001001; // 8/24
				3'b111 : stallMask = 24'b010101_010101_010101_010101; // 12/24
				default: stallMask = 24'b000000_000000_000000_000000;
			endcase
		end
	end
	
	assign stallCore = ((|(stallMask & ringOut)) ^ sign) & enable;
	
endmodule


module ringCounter24bit(
	input  wire			clk,
	input  wire 		rst,

	input  wire			enable,
	output reg	[23:0] 	parallelOut
);
	always @(posedge clk, posedge rst) begin
		if (rst)
			parallelOut	<=	24'b1;
		else if (enable)
			parallelOut <= {parallelOut[22:0], parallelOut[23]};
	end	
	
endmodule