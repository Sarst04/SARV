////////////////////////////////////////////////////////////////////////////////
// File      : ControlUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-08-18 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module control_unit (
    input wire [ 6:0] opcode,
	input wire [ 2:0] funct3,
	input wire [ 4:0] funct5,
	input wire [ 6:0] funct7,
	input wire [11:0] funct12,


	output reg [ 2:0] immExtendSelect,
	output reg        ALUSrcAType,
	output reg        ALUSrcBType,
	output reg [ 7:0] ALUOpcode,
	output reg 	      memWrite,
	output reg 	      memRead,
	output reg        regWrite,	
	output reg        branch,  
	output reg        jump,
	output reg [ 1:0] writeBackSrcSelect,
	output reg		  system,
	output reg		  pause,
	output reg [ 1:0] mulOpCode,
	output reg		  mulEn
);
	// ALU SrcA Type
	localparam	RS1 		= 1'b0;
	localparam	PC		  	= 1'b1; 

	
	// ALU SrcB Type
	localparam	RS2 		= 1'b0;
	localparam	Immediate   = 1'b1; 

	// Write Back Source
	localparam	NEXT_PC		= 2'b00; 
	localparam	EXE_RESULT 	= 2'b01; 
	localparam	MemDataOut	= 2'b10; 
	localparam	MUL_RESULT	= 2'b11; 
	
	// Immediate Extend
	localparam	I_TYPE		= 3'b000;
	localparam	S_TYPE		= 3'b001;
	localparam	B_TYPE		= 3'b010;
	localparam	J_TYPE		= 3'b011;
	localparam	U_TYPE		= 3'b100;

    // ALU Opcodes 
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
	localparam 	CLMUL  		= 8'b00101_001;
    localparam 	SH1ADD  	= 8'b01000_010;
    localparam 	SLT  		= 8'b00000_010;
	localparam 	CLMULR  	= 8'b00101_010;
    localparam 	SLTU 		= 8'b00000_011;
	localparam 	CLMULH 		= 8'b00101_011;
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


    // funct3 OP_IMM / OP
    localparam F3_ADD 		= 3'b000;
    localparam F3_SUB  		= 3'b000;
	localparam F3_MUL		= 3'b000;
	localparam F3_SEXTB		= 3'b001;
	localparam F3_SEXTH		= 3'b001;
    localparam F3_SLL      	= 3'b001;
    localparam F3_CLZ      	= 3'b001;
    localparam F3_CPOP      = 3'b001;
    localparam F3_CTZ      	= 3'b001;
    localparam F3_ROL      	= 3'b001;
    localparam F3_BCLR     	= 3'b001;
    localparam F3_BINV     	= 3'b001;
    localparam F3_BSET     	= 3'b001;
	localparam F3_MULH		= 3'b001;
	localparam F3_CLMUL		= 3'b001;
    localparam F3_SLT		= 3'b010;
    localparam F3_SH1ADD	= 3'b010;
	localparam F3_MULHSU	= 3'b010;
	localparam F3_CLMULR	= 3'b010;
    localparam F3_SLTU     	= 3'b011;
	localparam F3_MULHU		= 3'b011;
	localparam F3_CLMULH	= 3'b011;
    localparam F3_ZEXTH		= 3'b100;
    localparam F3_XOR		= 3'b100;
    localparam F3_XNOR		= 3'b100;
    localparam F3_SH2ADD	= 3'b100;
	localparam F3_MIN		= 3'b100;
    localparam F3_SRL 		= 3'b101;
    localparam F3_SRA  		= 3'b101;
	localparam F3_MINU		= 3'b101;
	localparam F3_ORCB		= 3'b101;
	localparam F3_REV8		= 3'b101;
	localparam F3_ROR		= 3'b101;
	localparam F3_CZERO_EQZ	= 3'b101;
	localparam F3_BEXT		= 3'b101;
    localparam F3_OR	    = 3'b110;
    localparam F3_SH3ADD 	= 3'b110;
    localparam F3_ORN 		= 3'b110;
	localparam F3_MAX		= 3'b110;
    localparam F3_AND		= 3'b111;
    localparam F3_ANDN  	= 3'b111; 
	localparam F3_MAXU		= 3'b111; 
	localparam F3_CZERO_NEZ = 3'b111;  

	// funct7 OP_IMM / OP
    localparam 	F7_ADD     	= 7'b0000000;
    localparam 	F7_SUB     	= 7'b0100000;
    localparam 	F7_SLL     	= 7'b0000000;
    localparam 	F7_SLT     	= 7'b0000000;
    localparam 	F7_SLTU    	= 7'b0000000;
    localparam 	F7_XOR     	= 7'b0000000;
    localparam 	F7_SRL     	= 7'b0000000;
    localparam 	F7_SRA     	= 7'b0100000;
    localparam 	F7_OR      	= 7'b0000000;
    localparam 	F7_AND     	= 7'b0000000;
    localparam 	F7_SH1ADD  	= 7'b0010000;
    localparam 	F7_SH2ADD  	= 7'b0010000;
    localparam 	F7_SH3ADD  	= 7'b0010000;
    localparam 	F7_XNOR    	= 7'b0100000;
    localparam 	F7_ORN     	= 7'b0100000;
    localparam 	F7_ANDN    	= 7'b0100000;
    localparam 	F7_MAX    	= 7'b0000101;
    localparam 	F7_MAXU    	= 7'b0000101;
    localparam 	F7_MIN    	= 7'b0000101;
    localparam 	F7_MINU    	= 7'b0000101;
    localparam 	F7_CLMUL   	= 7'b0000101;
    localparam 	F7_CLMULH   = 7'b0000101;
    localparam 	F7_CLMULR   = 7'b0000101;
	localparam	F7_ROL		= 7'b0110000;
	localparam	F7_ROR		= 7'b0110000;
	localparam 	F7_ORCB		= 7'b0010100;
	localparam 	F7_REV8		= 7'b0110100;
	localparam 	F7_CZERO	= 7'b0000111;
	localparam 	F7_ZEXTH	= 7'b0000100;
	localparam 	F7_BCLR		= 7'b0100100;
	localparam 	F7_BEXT		= 7'b0100100;
	localparam 	F7_BINV		= 7'b0110100;
	localparam 	F7_BSET		= 7'b0010100;
	localparam 	F7_MUL		= 7'b0000001;
	localparam 	F7_MULH		= 7'b0000001;
	localparam 	F7_MULHSU	= 7'b0000001;
	localparam 	F7_MULU		= 7'b0000001;
	
	// funct12 OP_IMM / OP
	localparam 	F12_CLZ		= 12'b0110000_00000;
	localparam 	F12_CPOP	= 12'b0110000_00010;
	localparam 	F12_CTZ		= 12'b0110000_00001;

	localparam 	F12_SEXTB	= 12'b0110000_00100;
	localparam 	F12_SEXTH	= 12'b0110000_00101;
	
	
	// Opcode
	localparam LOAD 			= 7'b00_000_11;
	localparam STORE 			= 7'b01_000_11;
	localparam BRANCH 			= 7'b11_000_11;
	localparam JALR 			= 7'b11_001_11;
	localparam JAL 				= 7'b11_011_11;
	localparam OP_IMM 			= 7'b00_100_11;
	localparam OP	 			= 7'b01_100_11;
	localparam AUIPC 			= 7'b00_101_11;
	localparam LUI 				= 7'b01_101_11;
	localparam SYSTEM			= 7'b11_100_11;
	localparam MISC_MEM			= 7'b00_011_11;


	always @(opcode, funct3, funct5, funct7, funct12) begin
		{immExtendSelect, ALUSrcAType, ALUSrcBType  , ALUOpcode, memWrite, memRead, regWrite, jump, branch, writeBackSrcSelect, system, pause, mulEn, mulOpCode} = 
		{ 3'b000		, 1'b0		 , 1'b0		    , 8'b0	   , 1'b0	 , 1'b0	  , 1'b0	, 1'b0, 1'b0  , 2'b0			  , 1'b0  , 1'b0 , 1'b0 , 2'b0     } ;

        case (opcode)
            LOAD : begin
                immExtendSelect = I_TYPE;
				ALUSrcAType		= RS1;
                ALUSrcBType	    = Immediate;
                ALUOpcode       = ADD;
                memRead         = 1'b1;
                regWrite        = 1'b1;
                writeBackSrcSelect = MemDataOut;
            end
            STORE : begin
                immExtendSelect = S_TYPE;
				ALUSrcAType		= RS1;
                ALUSrcBType	    = Immediate;
                ALUOpcode       = ADD;
                memWrite        = 1'b1;
            end
            BRANCH : begin
                immExtendSelect = B_TYPE;
				ALUSrcAType		= PC;
                ALUSrcBType	    = Immediate;
                ALUOpcode       = ADD;
                branch          = 1'b1;
            end

            JALR : begin
                immExtendSelect = I_TYPE;
				ALUSrcAType		= RS1;
                ALUSrcBType	    = Immediate;
                ALUOpcode       = ADD;
                jump            = 1'b1;
                regWrite        = 1'b1;
                writeBackSrcSelect = NEXT_PC;
            end

            JAL : begin
                immExtendSelect = J_TYPE;
				ALUSrcAType		= PC;
                ALUSrcBType	    = Immediate;
                ALUOpcode       = ADD;
                jump            = 1'b1;
                regWrite        = 1'b1;
                writeBackSrcSelect = NEXT_PC;
            end
            OP_IMM : begin
                immExtendSelect = I_TYPE;
				ALUSrcAType		= RS1;
                ALUSrcBType     = Immediate;
                regWrite        = 1'b1;
                writeBackSrcSelect = EXE_RESULT;
                
                case (funct3)
                    F3_ADD	   : ALUOpcode = ADD;
                    F3_SLT     : ALUOpcode = SLT;
                    F3_SLTU    : ALUOpcode = SLTU;
                    F3_AND     : ALUOpcode = AND;
                    F3_OR      : ALUOpcode = OR;
                    F3_XOR	   : ALUOpcode = XOR;
					F3_SEXTB, F3_SEXTH, F3_SLL, F3_CLZ, F3_CPOP, F3_CTZ, F3_BCLR, F3_BINV, F3_BSET	: begin
						case (funct12)
							F12_SEXTB	: ALUOpcode = SEXTB;
							F12_SEXTH	: ALUOpcode = SEXTH;
							F12_CLZ		: ALUOpcode = CLZ;
							F12_CPOP	: ALUOpcode = CPOP;
							F12_CTZ		: ALUOpcode = CTZ;
						endcase	
						case (funct7)
							F7_BCLR		: ALUOpcode = BCLR;
							F7_BINV		: ALUOpcode = BINV;
							F7_BSET		: ALUOpcode = BSET;
							F7_SLL		: ALUOpcode = SLL;
						endcase
					end
                    F3_SRL, F3_SRA, F3_ROR, F3_REV8, F3_ORCB, F3_BEXT : begin
						case (funct7)
							F7_SRA	: ALUOpcode = SRA;
							F7_SRL	: ALUOpcode = SRL;
							F7_ROR	: ALUOpcode = ROR;
							F7_REV8	: ALUOpcode = REV8;
							F7_ORCB	: ALUOpcode = ORCB;
							F7_BEXT	: ALUOpcode = BEXT;
						endcase
                    end
                    default: ALUOpcode = ADD;
                endcase
            end
            OP : begin
				ALUSrcAType			= RS1;
                ALUSrcBType     	= RS2;
                regWrite        	= 1'b1;
                writeBackSrcSelect = EXE_RESULT;
                
				if (funct7 == F7_MUL) begin
					mulEn				= 1'b1;
					mulOpCode			= funct3[1:0];
                	writeBackSrcSelect 	= MUL_RESULT;
				end 
				else begin
                case (funct3)
                    F3_ADD, F3_SUB, F3_MUL 		: begin
						case (funct7)
							F7_SUB		: ALUOpcode = SUB;
							F7_ADD		: ALUOpcode = ADD;
							F7_MUL		: 	begin 	
												mulEn				= 1'b1;
												mulOpCode			= funct3[1:0];
                								writeBackSrcSelect 	= MUL_RESULT;
										  	end
						endcase
                    end
                    F3_SLL, F3_ROL, F3_BCLR, F3_BINV, F3_BSET, F3_MULH, F3_CLMUL: begin    
						case (funct7)
							F7_SLL		: ALUOpcode = SLL;
							F7_ROL		: ALUOpcode = ROL;
							F7_BCLR		: ALUOpcode = BCLR;
							F7_BINV		: ALUOpcode = BINV;
							F7_BSET		: ALUOpcode = BSET;
							F7_CLMUL	: ALUOpcode = CLMUL;
							F7_MULH		: 	begin 	
												mulEn				= 1'b1;
												mulOpCode			= funct3[1:0];
                								writeBackSrcSelect 	= MUL_RESULT;
										  	end
						endcase
					end
                    F3_SLT, F3_SH1ADD, F3_MULHSU, F3_CLMULR: begin
						case (funct7)
							F7_SLT		: ALUOpcode = SLT;
							F7_SH1ADD	: ALUOpcode = SH1ADD;
							F7_CLMULR	: ALUOpcode = CLMULR;
							F7_MULHSU	: 	begin 	
												mulEn				= 1'b1;
												mulOpCode			= funct3[1:0];
                								writeBackSrcSelect 	= MUL_RESULT;
										  	end
						endcase
                    end
                    F3_SLTU, F3_MULHU, F3_CLMULH    : begin
						case (funct7) 
							F7_SLTU	 	: ALUOpcode = SLTU;
							F7_CLMULH 	: ALUOpcode = CLMULH;
							F7_MULHSU	: 	begin 	
												mulEn				= 1'b1;
												mulOpCode			= funct3[1:0];
                								writeBackSrcSelect 	= MUL_RESULT;
										  	end
						endcase
					end
                    F3_XOR, F3_SH2ADD, F3_XNOR, F3_MIN, F3_ZEXTH : begin
						case (funct7)
							F7_XNOR		: ALUOpcode = XNOR;
							F7_XOR		: ALUOpcode = XOR;
							F7_SH2ADD	: ALUOpcode = SH2ADD;
							F7_MIN		: ALUOpcode = MIN;
							F7_ZEXTH	: ALUOpcode = ZEXTH;
						endcase
                    end
                    F3_SRL, F3_SRA, F3_MINU, F3_ROR, F3_CZERO_EQZ, F3_BEXT : begin
						case (funct7)
							F7_SRA		: ALUOpcode = SRA;
							F7_SRL		: ALUOpcode = SRL;
							F7_MINU		: ALUOpcode = MINU;
							F7_ROR		: ALUOpcode = ROR;
							F7_BEXT		: ALUOpcode = BEXT;
							F7_CZERO	: ALUOpcode = CZERO_EQZ;
						endcase
                    end
                    F3_OR, F3_SH3ADD, F3_ORN, F3_MAX 	: begin
						case (funct7)
							F7_ORN		: ALUOpcode = ORN;
							F7_SH3ADD	: ALUOpcode = SH3ADD;
							F7_OR		: ALUOpcode = OR;
							F7_MAX		: ALUOpcode = MAX;
						endcase
                    end
                    F3_AND, F3_ANDN, F3_MAXU, F3_CZERO_NEZ : begin
						case (funct7)
							F7_AND		: ALUOpcode = AND;
							F7_ANDN		: ALUOpcode = ANDN;
							F7_MAXU		: ALUOpcode = MAXU;
							F7_CZERO	: ALUOpcode = CZERO_NEZ;
						endcase
                    end

                    default: ALUOpcode = ADD;
                endcase
				end
            end

            AUIPC : begin
                immExtendSelect 	= U_TYPE;
				ALUSrcAType			= PC;
                ALUOpcode       	= ADD;
                ALUSrcBType     	= Immediate;
                regWrite        	= 1'b1;
                writeBackSrcSelect 	= EXE_RESULT;
            end

            LUI : begin
                immExtendSelect 	= U_TYPE;
                ALUSrcBType     	= Immediate;
                ALUOpcode       	= BYPASS_B;
                regWrite        	= 1'b1;
                writeBackSrcSelect 	= EXE_RESULT;
            end
			SYSTEM :begin
				system 				= 1'b1;
                regWrite        	= 1'b1;
                writeBackSrcSelect 	= EXE_RESULT;
			end
			MISC_MEM:begin
				if (funct12[4]) begin
					pause				= 1'b1;
				end
			end
		endcase
	end

endmodule