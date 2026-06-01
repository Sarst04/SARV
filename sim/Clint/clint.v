module clint(
	input  wire			clk,
	input  wire			rst,

	input  wire 		readRequest,
	input  wire 		writeRequest,
	input  wire			chipSelect,
	output wire		  	MTI,


	input  wire [31:0]	address,
	input  wire [31:0]	dataIn,
	
	output reg  [31:0]	dataOut
);
    localparam MTIME_ADDR_FROM_BASE 	= 32'h0000_bff8;
    localparam MTIMECMP_ADDR_FROM_BASE 	= 32'h0000_4000;


	reg [63:0] mtimeReg;
	reg [63:0] mtimecmpReg;

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