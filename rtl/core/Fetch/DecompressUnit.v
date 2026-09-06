////////////////////////////////////////////////////////////////////////////////
// File      : DecompressUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-07-22 (last modified)
// Description:
// 	Zca + Zcb 
////////////////////////////////////////////////////////////////////////////////
module decompress_unit(
    input  wire [15:0] compressedInst,
    output reg  [31:0] decompressInst
);
    
    // Opcode quadrant constants
    localparam C0                        = 2'b00;    // Quadrant 0
    localparam C1                        = 2'b01;    // Quadrant 1
    localparam C2                        = 2'b10;    // Quadrant 2

    // Register constants
    localparam REG_ZERO                  = 5'b00000; // X0
    localparam REG_RA                    = 5'b00001; // X1
    localparam REG_SP                    = 5'b00010; // X2
    localparam REG_COMPRESSED_BASE       = 5'b01000; // X8 

    // Base RV32I Opcodes
    localparam IMM                       = 7'b0010011; // OP-IMM
    localparam LOAD                      = 7'b0000011; // LOAD
    localparam STORE                     = 7'b0100011; // STORE
    localparam REG_OP                    = 7'b0110011; // OP
    localparam JAL                       = 7'b1101111; // JAL
    localparam JALR                      = 7'b1100111; // JALR
    localparam BRANCH                    = 7'b1100011; // BRANCH
    localparam SYSTEM                    = 7'b1110011; // SYSTEM
    localparam LUI                       = 7'b0110111; // LUI

    // Funct3 constants
    localparam F3_ADDI                   = 3'b000;
    localparam F3_SLLI                   = 3'b001;
    localparam F3_XORI                   = 3'b100;
    localparam F3_SRLI_SRAI              = 3'b101;
    localparam F3_ORI                    = 3'b110;
    localparam F3_ANDI                   = 3'b111;
    localparam F3_LW                     = 3'b010;
    localparam F3_SW                     = 3'b010;
    localparam F3_BEQ                    = 3'b000;
    localparam F3_BNE                    = 3'b001;
    localparam F3_JALR                   = 3'b000;

    // Quadrant 0
    localparam C0_ADDI4SPN               = 3'b000;
    localparam C0_LW                     = 3'b010;
    localparam C0_SW                     = 3'b110;
    localparam C0_ZCB                    = 3'b100;

    // Quadrant 0
    localparam ZCB_LBU                   = 3'b000;
    localparam ZCB_LH_LHU                = 3'b001;
    localparam ZCB_SB                    = 3'b010;
    localparam ZCB_SH                    = 3'b011;

    // Byte/halfword LOAD/STORE funct3 constants
    localparam F3_LBU                    = 3'b100;
    localparam F3_LHU                    = 3'b101;
    localparam F3_LH                     = 3'b001;
    localparam F3_SB                     = 3'b000;
    localparam F3_SH                     = 3'b001;

    // Quadrant 1 funct3 constants
    localparam C1_ADDI                   = 3'b000;
    localparam C1_JAL                    = 3'b001;
    localparam C1_LI                     = 3'b010;
    localparam C1_LUI_ADDI16SP           = 3'b011;
    localparam C1_ALU_OPS                = 3'b100;
    localparam C1_J                      = 3'b101;
    localparam C1_BEQZ                   = 3'b110;
    localparam C1_BNEZ                   = 3'b111;

    // Quadrant 1 ALU sub op constants
    localparam C1_SRLI                   = 2'b00;
    localparam C1_SRAI                   = 2'b01;
    localparam C1_ANDI                   = 2'b10;

    localparam F2_ZCB_MISC               = 2'b11;
    localparam F2_ZCB_MUL                = 2'b10;
    localparam ZCB_ZEXTB                 = 3'b000;
    localparam ZCB_SEXTB                 = 3'b001;
    localparam ZCB_ZEXTH                 = 3'b010;
    localparam ZCB_SEXTH                 = 3'b011;
    localparam ZCB_NOT                   = 3'b101;

    localparam F3_UNARY_OPIMM            = 3'b001;
    localparam IMM12_SEXTB               = 12'b011000000100;
    localparam IMM12_SEXTH               = 12'b011000000101;
    localparam F3_PACK                   = 3'b100;
    localparam F7_PACK                   = 7'b0000100;
    localparam F3_MUL                    = 3'b000;
    localparam F7_MUL                    = 7'b0000001;

    // Quadrant 2 funct3 constants
    localparam C2_SLLI                   = 3'b000;
    localparam C2_LWSP                   = 3'b010;
    localparam C2_JR_MV_EBREAK_ADD       = 3'b100;
    localparam C2_SWSP                   = 3'b110;

    // ALU funct7 constants
    localparam F7_SRLI                   = 7'b0000000;
    localparam F7_SRAI                   = 7'b0100000;
    localparam F7_ADD                    = 7'b0000000;
    localparam F7_SUB                    = 7'b0100000;

    // Internal decode signals
    wire [1:0] opcode;
    wire [2:0] funct3;
    
    assign opcode = compressedInst[1:0];
    assign funct3 = compressedInst[15:13];

    reg [4:0]  rd_prim_rs2_prim;
    reg [4:0]  rs1_prim;
    reg [11:0] nzuimm;
    reg [11:0] imm;
    reg [4:0]  rd_rs1;
    reg [4:0]  rs1_prim_rd_prim;
    reg [4:0]  rs2_prim;
    reg [20:0] imm21;
    reg [12:0] imm13;
    reg [5:0]  uimm6;
    reg [1:0]  sub_select_rs1;
    reg [1:0]  sub_select_rs2;
    reg [4:0]  rs2;
    reg [5:0]  shamt6;

    always @(compressedInst) begin
        decompressInst   = 32'b0;
        rd_prim_rs2_prim = 5'b0;
        rs1_prim         = 5'b0;
        nzuimm           = 12'b0;
        imm              = 12'b0;
        rd_rs1           = 5'b0;
        rs1_prim_rd_prim = 5'b0;
        rs2_prim         = 5'b0;
        imm21            = 21'b0;
        imm13            = 13'b0;
        uimm6            = 6'b0;
        sub_select_rs1   = 2'b0;
        sub_select_rs2   = 2'b0;
        rs2              = 5'b0;
        shamt6           = 6'b0;

        case(opcode)
            C0: begin // Quadrant 0
                rd_prim_rs2_prim = compressedInst[4:2] + REG_COMPRESSED_BASE;
                rs1_prim         = compressedInst[9:7] + REG_COMPRESSED_BASE;

                case(funct3)
                    C0_ADDI4SPN: begin
                        // C.ADDI4SPN -> addi rd', x2, nzuimm
                        nzuimm[5:4]           = compressedInst[12:11];
                        nzuimm[9:6]           = compressedInst[10:7];
                        nzuimm[2]             = compressedInst[6];
                        nzuimm[3]             = compressedInst[5];
                        
                        decompressInst[6:0]   = IMM;
                        decompressInst[11:7]  = rd_prim_rs2_prim;
                        decompressInst[14:12] = F3_ADDI;
                        decompressInst[19:15] = REG_SP;
                        decompressInst[31:20] = nzuimm;
                    end
                    
                    C0_LW: begin
                        // C.LW -> lw rd', offset(rs1')
                        imm[5:3]              = compressedInst[12:10];
                        imm[2]                = compressedInst[6];
                        imm[6]                = compressedInst[5];
                        
                        decompressInst[6:0]   = LOAD;
                        decompressInst[11:7]  = rd_prim_rs2_prim;
                        decompressInst[14:12] = F3_LW;
                        decompressInst[19:15] = rs1_prim;
                        decompressInst[31:20] = imm;
                    end
                    
                    C0_SW: begin
                        // C.SW -> sw rs2', offset(rs1')
                        imm[5:3]              = compressedInst[12:10];
                        imm[2]                = compressedInst[6];
                        imm[6]                = compressedInst[5];
                        
                        decompressInst[6:0]   = STORE;
                        decompressInst[11:7]  = imm[4:0];
                        decompressInst[14:12] = F3_SW;
                        decompressInst[19:15] = rs1_prim;
                        decompressInst[24:20] = rd_prim_rs2_prim;
                        decompressInst[31:25] = imm[11:5];
                    end

                    C0_ZCB: begin // Zcb byte/halfword loads and stores
                        case(compressedInst[12:10])
                            ZCB_LBU: begin
                                // C.LBU -> lbu rd', uimm(rs1')
                                imm[1]                 = compressedInst[5];
                                imm[0]                 = compressedInst[6];

                                decompressInst[6:0]    = LOAD;
                                decompressInst[11:7]   = rd_prim_rs2_prim;
                                decompressInst[14:12]  = F3_LBU;
                                decompressInst[19:15]  = rs1_prim;
                                decompressInst[31:20]  = imm;
                            end

                            ZCB_LH_LHU: begin
                                // compressedInst[6] == 0 -> C.LHU, == 1 -> C.LH
                                imm[1]                 = compressedInst[5];

                                decompressInst[6:0]    = LOAD;
                                decompressInst[11:7]   = rd_prim_rs2_prim;
                                decompressInst[14:12]  = compressedInst[6] ? F3_LH : F3_LHU;
                                decompressInst[19:15]  = rs1_prim;
                                decompressInst[31:20]  = imm;
                            end

                            ZCB_SB: begin
                                // C.SB -> sb rs2', uimm(rs1')
                                imm[1]                 = compressedInst[5];
                                imm[0]                 = compressedInst[6];

                                decompressInst[6:0]    = STORE;
                                decompressInst[11:7]   = imm[4:0];
                                decompressInst[14:12]  = F3_SB;
                                decompressInst[19:15]  = rs1_prim;
                                decompressInst[24:20]  = rd_prim_rs2_prim;
                                decompressInst[31:25]  = imm[11:5];
                            end

                            ZCB_SH: begin
                                // C.SH -> sh rs2', uimm(rs1')
                                imm[1]                 = compressedInst[5];

                                decompressInst[6:0]    = STORE;
                                decompressInst[11:7]   = imm[4:0];
                                decompressInst[14:12]  = F3_SH;
                                decompressInst[19:15]  = rs1_prim;
                                decompressInst[24:20]  = rd_prim_rs2_prim;
                                decompressInst[31:25]  = imm[11:5];
                            end

                            default: decompressInst = 32'b0;
                        endcase
                    end
                    
                    default: decompressInst = 32'b0;
                endcase
            end
            
            C1: begin // Quadrant 1
                rd_rs1           = compressedInst[11:7];
                rs1_prim_rd_prim = compressedInst[9:7] + REG_COMPRESSED_BASE;
                rs2_prim         = compressedInst[4:2] + REG_COMPRESSED_BASE;

                case(funct3)
                    C1_ADDI: begin
                        // C.ADDI / C.NOP -> addi rd, rd, imm
                        imm[5]                = compressedInst[12];
                        imm[4:0]              = compressedInst[6:2];
                        if (imm[5] == 1'b1)
                            imm[11:6]         = 6'b111111;

                        decompressInst[6:0]   = IMM;
                        decompressInst[11:7]  = rd_rs1;
                        decompressInst[14:12] = F3_ADDI;
                        decompressInst[19:15] = rd_rs1;
                        decompressInst[31:20] = imm;
                    end
                    
                    C1_JAL: begin
                        // C.JAL -> jal x1, offset
                        imm21[11]             = compressedInst[12];
                        imm21[4]              = compressedInst[11];
                        imm21[9:8]            = compressedInst[10:9];
                        imm21[10]             = compressedInst[8];
                        imm21[6]              = compressedInst[7];
                        imm21[7]              = compressedInst[6];
                        imm21[3:1]            = compressedInst[5:3];
                        imm21[5]              = compressedInst[2];
                        if (imm21[11] == 1'b1)
                            imm21[20:12]      = 9'b111111111;
                        
                        decompressInst[6:0]   = JAL;
                        decompressInst[11:7]  = REG_RA;
                        decompressInst[31]    = imm21[20];
                        decompressInst[30:21] = imm21[10:1];
                        decompressInst[20]    = imm21[11];
                        decompressInst[19:12] = imm21[19:12];
                    end
                    
                    C1_LI: begin
                        // C.LI -> addi rd, x0, imm
                        imm[5]                = compressedInst[12];
                        imm[4:0]              = compressedInst[6:2];
                        if (imm[5] == 1'b1)
                            imm[11:6]         = 6'b111111;
                        
                        decompressInst[6:0]   = IMM;
                        decompressInst[11:7]  = rd_rs1;
                        decompressInst[14:12] = F3_ADDI;
                        decompressInst[19:15] = REG_ZERO;
                        decompressInst[31:20] = imm;
                    end
                    
                    C1_LUI_ADDI16SP: begin
                        if (rd_rs1 == REG_SP) begin
                            // C.ADDI16SP -> addi x2, x2, nzimm
                            imm[9]            = compressedInst[12];
                            imm[4]            = compressedInst[6];
                            imm[6]            = compressedInst[5];
                            imm[8:7]          = compressedInst[4:3];
                            imm[5]            = compressedInst[2];
                            if (imm[9] == 1'b1)
                                imm[11:10]    = 2'b11;
                            
                            decompressInst[6:0]   = IMM;
                            decompressInst[11:7]  = REG_SP;
                            decompressInst[14:12] = F3_ADDI;
                            decompressInst[19:15] = REG_SP;
                            decompressInst[31:20] = imm;
                        end else if (rd_rs1 != REG_ZERO) begin
                            // C.LUI -> lui rd, imm20
                            decompressInst[6:0]   = LUI;
                            decompressInst[11:7]  = rd_rs1;
                            decompressInst[31:12] = { {15{compressedInst[12]}}, compressedInst[6:2] };
                        end
                    end
                    
                    C1_ALU_OPS: begin
                        sub_select_rs1 = compressedInst[11:10];
                        sub_select_rs2 = compressedInst[6:5];
                        
                        case(sub_select_rs1)
                            C1_SRLI: begin
                                // C.SRLI -> srli rd', rd', shamt
                                uimm6[4:0] = compressedInst[6:2];
                                uimm6[5]   = compressedInst[12];

                                if (uimm6[5] == 1'b0) begin
                                    decompressInst[6:0]   = IMM;
                                    decompressInst[11:7]  = rs1_prim_rd_prim;
                                    decompressInst[14:12] = F3_SRLI_SRAI;
                                    decompressInst[19:15] = rs1_prim_rd_prim;
                                    decompressInst[24:20] = uimm6[4:0];
                                    decompressInst[31:25] = F7_SRLI;
                                end
                            end
                            
                            C1_SRAI: begin
                                // C.SRAI -> srai rd', rd', shamt
                                uimm6[4:0] = compressedInst[6:2];
                                uimm6[5]   = compressedInst[12];

                                if (uimm6[5] == 1'b0) begin
                                    decompressInst[6:0]   = IMM;
                                    decompressInst[11:7]  = rs1_prim_rd_prim;
                                    decompressInst[14:12] = F3_SRLI_SRAI;
                                    decompressInst[19:15] = rs1_prim_rd_prim;
                                    decompressInst[24:20] = uimm6[4:0];
                                    decompressInst[31:25] = F7_SRAI;
                                end
                            end
                            
                            C1_ANDI: begin
                                // C.ANDI -> andi rd', rd', imm
                                imm[4:0] = compressedInst[6:2];
                                imm[5]   = compressedInst[12];
                                if (imm[5] == 1'b1)
                                    imm[11:6] = 6'b111111;
                                
                                decompressInst[6:0]   = IMM;
                                decompressInst[11:7]  = rs1_prim_rd_prim;
                                decompressInst[14:12] = F3_ANDI;
                                decompressInst[19:15] = rs1_prim_rd_prim;
                                decompressInst[31:20] = imm;
                            end
                            
                            default: begin
                                if (compressedInst[12] == 1'b0) begin
                                    case(sub_select_rs2)
                                        2'b00: begin // C.SUB -> sub rd', rd', rs2'
                                            decompressInst[6:0]   = REG_OP;
                                            decompressInst[11:7]  = rs1_prim_rd_prim;
                                            decompressInst[14:12] = F3_ADDI;
                                            decompressInst[19:15] = rs1_prim_rd_prim;
                                            decompressInst[24:20] = rs2_prim;
                                            decompressInst[31:25] = F7_SUB;
                                        end
                                        
                                        2'b01: begin // C.XOR -> xor rd', rd', rs2'
                                            decompressInst[6:0]   = REG_OP;
                                            decompressInst[11:7]  = rs1_prim_rd_prim;
                                            decompressInst[14:12] = F3_XORI;
                                            decompressInst[19:15] = rs1_prim_rd_prim;
                                            decompressInst[24:20] = rs2_prim;
                                            decompressInst[31:25] = F7_ADD;
                                        end
                                        
                                        2'b10: begin // C.OR -> or rd', rd', rs2'
                                            decompressInst[6:0]   = REG_OP;
                                            decompressInst[11:7]  = rs1_prim_rd_prim;
                                            decompressInst[14:12] = F3_ORI;
                                            decompressInst[19:15] = rs1_prim_rd_prim;
                                            decompressInst[24:20] = rs2_prim;
                                            decompressInst[31:25] = F7_ADD;
                                        end
                                        
                                        2'b11: begin // C.AND -> and rd', rd', rs2'
                                            decompressInst[6:0]   = REG_OP;
                                            decompressInst[11:7]  = rs1_prim_rd_prim;
                                            decompressInst[14:12] = F3_ANDI;
                                            decompressInst[19:15] = rs1_prim_rd_prim;
                                            decompressInst[24:20] = rs2_prim;
                                            decompressInst[31:25] = F7_ADD;
                                        end
                                    endcase
                                end else begin
                                    case(sub_select_rs2)
                                        F2_ZCB_MISC: begin // 2'b11: unary ops on rd'/rs1'
                                            case(compressedInst[4:2])
                                                ZCB_ZEXTB: begin
                                                    // C.ZEXT.B -> andi rd'/rs1', rd'/rs1', 0xff
                                                    decompressInst[6:0]   = IMM;
                                                    decompressInst[11:7]  = rs1_prim_rd_prim;
                                                    decompressInst[14:12] = F3_ANDI;
                                                    decompressInst[19:15] = rs1_prim_rd_prim;
                                                    decompressInst[31:20] = 12'h0FF;
                                                end

                                                ZCB_SEXTB: begin
                                                    // C.SEXT.B -> sext.b rd'/rs1', rd'/rs1' (Zbb)
                                                    decompressInst[6:0]   = IMM;
                                                    decompressInst[11:7]  = rs1_prim_rd_prim;
                                                    decompressInst[14:12] = F3_UNARY_OPIMM;
                                                    decompressInst[19:15] = rs1_prim_rd_prim;
                                                    decompressInst[31:20] = IMM12_SEXTB;
                                                end

                                                ZCB_ZEXTH: begin
                                                    // C.ZEXT.H -> pack rd'/rs1', rd'/rs1', x0 (Zbb)
                                                    decompressInst[6:0]   = REG_OP;
                                                    decompressInst[11:7]  = rs1_prim_rd_prim;
                                                    decompressInst[14:12] = F3_PACK;
                                                    decompressInst[19:15] = rs1_prim_rd_prim;
                                                    decompressInst[24:20] = REG_ZERO;
                                                    decompressInst[31:25] = F7_PACK;
                                                end

                                                ZCB_SEXTH: begin
                                                    // C.SEXT.H -> sext.h rd'/rs1', rd'/rs1' (Zbb)
                                                    decompressInst[6:0]   = IMM;
                                                    decompressInst[11:7]  = rs1_prim_rd_prim;
                                                    decompressInst[14:12] = F3_UNARY_OPIMM;
                                                    decompressInst[19:15] = rs1_prim_rd_prim;
                                                    decompressInst[31:20] = IMM12_SEXTH;
                                                end

                                                // ZCB_ZEXTW (3'b100)

                                                ZCB_NOT: begin
                                                    // C.NOT -> xori rd'/rs1', rd'/rs1', -1
                                                    decompressInst[6:0]   = IMM;
                                                    decompressInst[11:7]  = rs1_prim_rd_prim;
                                                    decompressInst[14:12] = F3_XORI;
                                                    decompressInst[19:15] = rs1_prim_rd_prim;
                                                    decompressInst[31:20] = 12'hFFF;
                                                end

                                                default: decompressInst = 32'b0;
                                            endcase
                                        end

                                        F2_ZCB_MUL: begin // 2'b10: C.MUL -> mul rsd', rsd', rs2'
                                            decompressInst[6:0]   = REG_OP;
                                            decompressInst[11:7]  = rs1_prim_rd_prim;
                                            decompressInst[14:12] = F3_MUL;
                                            decompressInst[19:15] = rs1_prim_rd_prim;
                                            decompressInst[24:20] = rs2_prim;
                                            decompressInst[31:25] = F7_MUL;
                                        end

                                        default: decompressInst = 32'b0;
                                    endcase
                                end
                            end
                        endcase
                    end
                    
                    C1_J: begin
                        // C.J -> jal x0, offset
                        imm21[11]             = compressedInst[12];
                        imm21[4]              = compressedInst[11];
                        imm21[9:8]            = compressedInst[10:9];
                        imm21[10]             = compressedInst[8];
                        imm21[6]              = compressedInst[7];
                        imm21[7]              = compressedInst[6];
                        imm21[3:1]            = compressedInst[5:3];
                        imm21[5]              = compressedInst[2];
                        if (imm21[11] == 1'b1)
                            imm21[20:12]      = 9'b111111111;
                        
                        decompressInst[6:0]   = JAL;
                        decompressInst[11:7]  = REG_ZERO;
                        decompressInst[31]    = imm21[20];
                        decompressInst[30:21] = imm21[10:1];
                        decompressInst[20]    = imm21[11];
                        decompressInst[19:12] = imm21[19:12];
                    end
                    
                    C1_BEQZ: begin
                        // C.BEQZ -> beq rs1', x0, offset
                        imm13[8]              = compressedInst[12];
                        imm13[4:3]            = compressedInst[11:10];
                        imm13[7:6]            = compressedInst[6:5];
                        imm13[2:1]            = compressedInst[4:3];
                        imm13[5]              = compressedInst[2];
                        if (imm13[8] == 1'b1)
                            imm13[12:9]       = 4'b1111;
                        
                        decompressInst[6:0]   = BRANCH;
                        decompressInst[14:12] = F3_BEQ;
                        decompressInst[19:15] = rs1_prim_rd_prim;
                        decompressInst[24:20] = REG_ZERO;
                        decompressInst[7]     = imm13[11];
                        decompressInst[11:8]  = imm13[4:1];
                        decompressInst[30:25] = imm13[10:5];
                        decompressInst[31]    = imm13[12];
                    end
                    
                    C1_BNEZ: begin
                        // C.BNEZ -> bne rs1', x0, offset
                        imm13[8]              = compressedInst[12];
                        imm13[4:3]            = compressedInst[11:10];
                        imm13[7:6]            = compressedInst[6:5];
                        imm13[2:1]            = compressedInst[4:3];
                        imm13[5]              = compressedInst[2];
                        if (imm13[8] == 1'b1)
                            imm13[12:9]       = 4'b1111;
                        
                        decompressInst[6:0]   = BRANCH;
                        decompressInst[14:12] = F3_BNE;
                        decompressInst[19:15] = rs1_prim_rd_prim;
                        decompressInst[24:20] = REG_ZERO;
                        decompressInst[7]     = imm13[11];
                        decompressInst[11:8]  = imm13[4:1];
                        decompressInst[30:25] = imm13[10:5];
                        decompressInst[31]    = imm13[12];
                    end
                    
                    default: decompressInst = 32'b0;
                endcase
            end
            
            C2: begin // Quadrant 2
                rd_rs1 = compressedInst[11:7];
                rs2    = compressedInst[6:2];
                
                case(funct3)
                    C2_SLLI: begin
                        // C.SLLI -> slli rd, rd, shamt
                        shamt6[5]   = compressedInst[12];
                        shamt6[4:0] = compressedInst[6:2];
                        
                        if (shamt6[5] == 1'b0) begin
                            decompressInst[6:0]   = IMM;
                            decompressInst[11:7]  = rd_rs1;
                            decompressInst[14:12] = F3_SLLI;
                            decompressInst[19:15] = rd_rs1;
                            decompressInst[24:20] = shamt6[4:0];
                            decompressInst[31:25] = F7_ADD;
                        end
                    end
                    
                    C2_LWSP: begin
                        // C.LWSP -> lw rd, offset(x2)
                        if (rd_rs1 != REG_ZERO) begin
                            imm[5]   = compressedInst[12];
                            imm[4:2] = compressedInst[6:4];
                            imm[7:6] = compressedInst[3:2];
                            
                            decompressInst[6:0]   = LOAD;
                            decompressInst[11:7]  = rd_rs1;
                            decompressInst[14:12] = F3_LW;
                            decompressInst[19:15] = REG_SP;
                            decompressInst[31:20] = imm;
                        end
                    end
                    
                    C2_JR_MV_EBREAK_ADD: begin
                        if (compressedInst[12] == 1'b0) begin
                            if (rs2 == REG_ZERO) begin
                                // C.JR -> jalr x0, 0(rs1)
                                if (rd_rs1 != REG_ZERO) begin
                                    decompressInst[6:0]   = JALR;
                                    decompressInst[11:7]  = REG_ZERO;
                                    decompressInst[14:12] = F3_JALR;
                                    decompressInst[19:15] = rd_rs1;
                                    decompressInst[31:20] = 12'b0;
                                end
                            end else begin
                                // C.MV -> add rd, x0, rs2
                                decompressInst[6:0]   = REG_OP;
                                decompressInst[11:7]  = rd_rs1;
                                decompressInst[14:12] = F3_ADDI;
                                decompressInst[19:15] = REG_ZERO;
                                decompressInst[24:20] = rs2;
                                decompressInst[31:25] = F7_ADD;
                            end
                        end else begin
                            if (rs2 == REG_ZERO) begin
                                if (rd_rs1 == REG_ZERO) begin
                                    // C.EBREAK -> ebreak
                                    decompressInst[6:0]   = SYSTEM;
                                    decompressInst[11:7]  = REG_ZERO;
                                    decompressInst[14:12] = 3'b000;
                                    decompressInst[19:15] = REG_ZERO;
                                    decompressInst[31:20] = 12'h001;
                                end else begin
                                    // C.JALR -> jalr x1, 0(rs1)
                                    decompressInst[6:0]   = JALR;
                                    decompressInst[11:7]  = REG_RA;
                                    decompressInst[14:12] = F3_JALR;
                                    decompressInst[19:15] = rd_rs1;
                                    decompressInst[31:20] = 12'b0;
                                end
                            end else begin
                                // C.ADD -> add rd, rd, rs2
                                decompressInst[6:0]   = REG_OP;
                                decompressInst[11:7]  = rd_rs1;
                                decompressInst[14:12] = F3_ADDI;
                                decompressInst[19:15] = rd_rs1;
                                decompressInst[24:20] = rs2;
                                decompressInst[31:25] = F7_ADD;
                            end
                        end
                    end

                    C2_SWSP: begin
                        // C.SWSP -> sw rs2, offset(x2)
                        imm[5:2] = compressedInst[12:9];
                        imm[7:6] = compressedInst[8:7];
                        
                        decompressInst[6:0]   = STORE;
                        decompressInst[11:7]  = imm[4:0];
                        decompressInst[14:12] = F3_SW;
                        decompressInst[19:15] = REG_SP;
                        decompressInst[24:20] = rs2;
                        decompressInst[31:25] = imm[11:5];
                    end

                    default: decompressInst = 32'b0;
                endcase
            end

            default: decompressInst = 32'b0;
        endcase
    end

endmodule
