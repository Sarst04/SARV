////////////////////////////////////////////////////////////////////////////////
// File      : clint.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-01-30 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module clint(
	input  wire			clk,
	input  wire			rst,

	input  wire 		readRequest,
	input  wire 		writeRequest,
	input  wire			chipSelect,
	output wire		  	MTI,


	input  wire [31:0]	address,
	input  wire [31:0]	dataIn,
	
	output reg  [31:0]	dataOut,
	output wire	[31:0]  mtimeData,
	output wire	[31:0]  mtimehData
);
    localparam MSIP_ADDR_FROM_BASE 		= 32'h0000_0000;
    localparam MTIME_ADDR_FROM_BASE 	= 32'h0000_bff8;
    localparam MTIMECMP_ADDR_FROM_BASE 	= 32'h0000_4000;


	reg [63:0] mtimeReg;
	reg [63:0] mtimecmpReg;

	assign mtimeData = mtimeReg[31:0];
	assign mtimehData = mtimeReg[63:32];

	assign MTI	=	(mtimeReg >= mtimecmpReg);

	always@(readRequest, chipSelect, address, mtimeReg, mtimecmpReg) begin
		dataOut	= 32'b0;
		if (readRequest & chipSelect) begin
			case (address)
				MTIMECMP_ADDR_FROM_BASE		:	dataOut = mtimecmpReg[31: 0];
				MTIMECMP_ADDR_FROM_BASE + 4	:	dataOut = mtimecmpReg[63:32];
				MTIME_ADDR_FROM_BASE		:	dataOut = mtimeReg[31: 0];
				MTIME_ADDR_FROM_BASE 	+ 4	:	dataOut = mtimeReg[63:32];
			endcase
		end
	end

	always @(posedge clk, posedge rst) begin
		if (rst)
			mtimecmpReg <=	64'hFFFFFFFF_FFFFFFFF;
		else begin
			if (writeRequest & chipSelect) begin
				case (address)
					MTIMECMP_ADDR_FROM_BASE		:	mtimecmpReg[31: 0]	<= 	dataIn;
					MTIMECMP_ADDR_FROM_BASE + 4	:	mtimecmpReg[63:32]	<= 	dataIn;
				endcase
			end
		end
	end
	

	always @(posedge clk, posedge rst) begin
		if (rst)
			mtimeReg <=	64'b0;
		else
			mtimeReg <=	mtimeReg + 1;
	end
	

endmodule