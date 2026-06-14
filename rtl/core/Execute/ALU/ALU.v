////////////////////////////////////////////////////////////////////////////////
// File      : ALU.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-02-17 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////

module ALU(
	input  wire [31:0] srcA,
	input  wire [31:0] srcB,
	input  wire [ 7:0] ALUOpcode,

 	output reg  [31:0] result
);
    localparam 	ADD  		= 8'b00000_000;
    localparam 	SUB  		= 8'b10000_000;
    localparam 	SEXTB  		= 8'b11100_001;
    localparam 	SEXTH  		= 8'b11101_001;
    localparam 	SLL  		= 8'b00000_001;
    localparam 	CLZ  		= 8'b11010_001;
    localparam 	CPOP 		= 8'b11011_001;
    localparam 	CTZ  		= 8'b11001_001;
    localparam 	ROL  		= 8'b11000_001;
    localparam 	BCLR  		= 8'b10110_001;
    localparam 	BINV  		= 8'b11110_001;
    localparam 	BSET  		= 8'b01110_001;
    localparam 	SH1ADD  	= 8'b01000_010;
    localparam 	SLT  		= 8'b00000_010;
    localparam 	SLTU 		= 8'b00000_011;
    localparam 	ZEXTH  		= 8'b00100_100;
    localparam 	XOR  		= 8'b00000_100;
    localparam 	XNOR  		= 8'b10000_100;
    localparam 	SH2ADD  	= 8'b01000_100;
	localparam	MIN			= 8'b00101_100;
    localparam 	SRL  		= 8'b00000_101;
    localparam 	SRA  		= 8'b10000_101;
	localparam	MINU		= 8'b00101_101;
    localparam 	ORCB   		= 8'b01100_101;
    localparam 	REV8  		= 8'b11100_101;
    localparam 	ROR 		= 8'b11000_101;
    localparam 	CZERO_EQZ 	= 8'b00111_101;
    localparam 	BEXT  		= 8'b10100_101;
    localparam 	OR   		= 8'b00000_110;
    localparam 	SH3ADD   	= 8'b01000_110;
    localparam 	ORN   		= 8'b10000_110;
	localparam	MAX			= 8'b00101_110;
    localparam 	AND  		= 8'b00000_111;
    localparam 	ANDN  		= 8'b10000_111;
	localparam	MAXU		= 8'b00101_111;
    localparam 	CZERO_NEZ 	= 8'b00111_111;
    localparam 	BYPASS_B 	= 8'b11111_111;

	// Adder
	reg		[31:0] 	oprandA;
	reg 	[31:0] 	oprandB;
	reg 		   	carryIn;
	wire 	[31:0] 	adderResult;
    wire        	carryOut;
	ALUAdder adder (
		.inA(oprandA),
		.inB(oprandB),
		.ci(carryIn),

		.out(adderResult),
		.co(carryOut)
	);


	// srcB invertor
	wire	[31:0]	srcBInv;
	assign	srcBInv	=	~srcB;

	// Adder Flag
	wire   neg;
	wire   zero;
	wire   overFlow;
	assign neg  		=  adderResult[31];
	assign zero 		= (adderResult == 32'b0);
	assign overFlow =	(oprandA[31] & oprandB[31] & ~adderResult[31]) |
      				   (~oprandA[31] & ~oprandB[31] & adderResult[31]);


	// Population Counter
	reg		[31:0]	popCountIn;
	wire	[31:0]	popCountOut;
	popCount populationCount(
		.in(popCountIn),
    	.count(popCountOut)
	);
	
	// count Zero
	reg		[31:0]	CTZIn;
	wire	[31:0]	CTZOut;
	reg		[31:0]	CLZIn;
	wire	[31:0]	CLZOut;
	CTZ countTrailingZero(
		.in(CTZIn),
		.count(CTZOut)
	);
	CLZ countLeadingZero(
		.in(CLZIn),
		.count(CLZOut)
	);

	// Barrel Shifter
	localparam	BARREL_OP_SLL		=	3'b001;
	localparam	BARREL_OP_SRL		=	3'b010;
	localparam	BARREL_OP_SRA		=	3'b011;
	localparam	BARREL_OP_ROR		=	3'b100;
	localparam	BARREL_OP_ROL		=	3'b101;
	reg		[ 2:0]	shifterOpcode;
	reg		[31:0]	shifterDataIn;
	wire	[31:0]	shifterDataOut;

	barrel_shifter BarrelShifter(
		.opcode(shifterOpcode),
		.dataIn(shifterDataIn),
		.shamt(srcB[4:0]),
		.dataOut(shifterDataOut)
	);


	//always @(srcA, srcB, srcBInv, ALUOpcode, adderResult, carryOut, popCountOut, CTZOut, CLZOut, shifterDataOut) begin
	always @(*) begin
		// ALU result
		result  		= 32'b0;	
	
		// Adder input
		oprandA 		= 32'b0;
		oprandB 		= 32'b0;
		carryIn 		= 1'b0;

		// one's counter
		popCountIn		=	32'b0;

		// count Zero
		CLZIn			=	32'b0;
		CTZIn			=	32'b0;

		// Barrel Shifter
		shifterDataIn	=	32'b0;
		shifterOpcode	= 	3'b0;

		case(ALUOpcode)
			BYPASS_B : begin
				result 			= srcB;
			end
			ADD : begin
				oprandA 		=  srcA;
				oprandB 		=  srcB;
				carryIn 		=  1'b0;
				result  		= adderResult;
			end
			SUB : begin
				oprandA 		=  srcA;
				oprandB 		=  srcBInv;
				carryIn 		=  1'b1;
				result  		=  adderResult;

			end
			SEXTB : begin
				result 			= {{24{srcA[7]}}, srcA[ 7:0]};
			end
			SEXTH : begin
				result 			= {{16{srcA[15]}}, srcA[15:0]};
			end
			SLL : begin
				shifterDataIn	= srcA;
				shifterOpcode	= BARREL_OP_SLL;
				result 			= shifterDataOut;
			end
			CLZ	: begin
				CLZIn			= srcA;
				result			= CLZOut;
			end
			ROR : begin
				shifterDataIn	= srcA;
				shifterOpcode	= BARREL_OP_ROR;
				result 			= shifterDataOut;
			end
			ROL : begin
				shifterDataIn	= srcA;
				shifterOpcode	= BARREL_OP_ROL;
				result 			= shifterDataOut;
			end
			CPOP: begin
				popCountIn		= srcA;
				result			= popCountOut;
			end
			CTZ	: begin
				CTZIn			= srcA;
				result			= CTZOut;
			end
			SLT : begin
                oprandA 		= srcA;
                oprandB 		= srcBInv;
                carryIn     	= 1'b1;
                result 			= {31'b0, neg ^ overFlow};
	
			end
			MIN : begin
                oprandA 		= srcA;
                oprandB 		= srcBInv;
                carryIn     	= 1'b1;
				result			= ((neg ^ overFlow) == 1'b1) ? srcA	: srcB;
			end
			MAX : begin
                oprandA 		= srcA;
                oprandB 		= srcBInv;
                carryIn     	= 1'b1;
				result			= ((neg ^ overFlow) == 1'b0) ? srcA	: srcB;
			end
			SH1ADD : begin
				oprandA 		=  srcA << 1;
				oprandB 		=  srcB;
				carryIn 		=  1'b0;
				result  		= adderResult;
			end
			SLTU: begin
                oprandA 		= srcA;
                oprandB 		= srcBInv;
                carryIn     	= 1'b1;
                result 			= {31'b0, ~carryOut};
	
			end
			MINU : begin
                oprandA 		= srcA;
                oprandB 		= srcBInv;
                carryIn     	= 1'b1;
				result			= (~carryOut == 1'b1) ? srcA	: srcB;
			end
			MAXU : begin
                oprandA 		= srcA;
                oprandB 		= srcBInv;
                carryIn     	= 1'b1;
				result			= (~carryOut == 1'b0) ? srcA	: srcB;
			end
			XOR : begin
				result 			= srcA ^ srcB;
			end
			XNOR : begin
				result 			= srcA ^ srcBInv;
			end
			SH2ADD : begin
				oprandA 		=  srcA << 2;
				oprandB 		=  srcB;
				carryIn 		= 1'b0;
				result  		= adderResult;
			end
			ZEXTH : begin
				result 			= {16'b0 , srcA[15:0]};
			end
			SRL : begin
				shifterDataIn	= srcA;
				shifterOpcode	= BARREL_OP_SRL;
				result 			= shifterDataOut;
			end
			SRA : begin
				shifterDataIn	= srcA;
				shifterOpcode	= BARREL_OP_SRA;
				result 			= shifterDataOut;
			end
			OR  : begin
				result 			= srcA | srcB;
			end
			CZERO_EQZ	:	begin
				result 			= ((|srcB) == 1'b0) 	?	32'b0 : srcA;
			end
			CZERO_NEZ	:	begin
				result 			= ((|srcB) == 1'b1) 	?	32'b0 : srcA;
			end
			ORCB: begin
				result[ 7: 0]	= (|srcA[ 7: 0])	?	8'hFF : 8'h00;
				result[15: 8]	= (|srcA[15: 8])	?	8'hFF : 8'h00;
				result[23:16]	= (|srcA[23:16])	?	8'hFF : 8'h00;
				result[31:24]	= (|srcA[31:24])	?	8'hFF : 8'h00;
			end
			ORN  : begin
				result 			= srcA | srcBInv;
			end
			SH3ADD : begin
				oprandA 		=  srcA << 3;
				oprandB 		=  srcB;
				carryIn 		=  1'b0;
				result  		=  adderResult;
			end
			AND : begin
				result 			= srcA & srcB;
			end
			ANDN : begin
				result 			= srcA & srcBInv;
			end
			REV8 : begin
				result			= {srcA[7: 0], srcA[15: 8], srcA[23:16], srcA[31:24]};
			end
			BCLR :	begin
				shifterDataIn	= 32'hFF_FF_FF_FE;
				shifterOpcode	= BARREL_OP_ROL;
				result 			= srcA & shifterDataOut;
			end
			BEXT :	begin
				shifterDataIn	= srcA;
				shifterOpcode	= BARREL_OP_SRL;
				result 			= 32'b1 & shifterDataOut;
			end
			BINV :	begin
				shifterDataIn	= 32'b1;
				shifterOpcode	= BARREL_OP_SLL;
				result 			= srcA ^ shifterDataOut;
			end
			BSET :	begin
				shifterDataIn	= 32'b1;
				shifterOpcode	= BARREL_OP_SLL;
				result 			= srcA | shifterDataOut;
			end
			default :
				result 			= 32'b0;
		endcase
	end

endmodule