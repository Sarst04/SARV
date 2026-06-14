////////////////////////////////////////////////////////////////////////////////
// File      : DecompressUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-02-04 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module decompress_unit(
    input  wire [15:0] compressedInst,
    output reg  [31:0] decompressInst
);
    
    // Opcode constants
    localparam C0                        = 2'b00;    // Quadrant 0
    localparam C1                        = 2'b01;    // Quadrant 1
    localparam C2                        = 2'b10;    // Quadrant 2

    // Register constants
    localparam REG_ZERO                  = 5'b00000; // X0
    localparam REG_RA                    = 5'b00001; // X1
    localparam REG_SP                    = 5'b00010; // X2
    localparam REG_COMPRESSED_BASE       = 5'b01000;

    // Instruction type
    localparam IMM                       = 7'b0010011;
    localparam LOAD                      = 7'b0000011;
    localparam STORE                     = 7'b0100011;
    localparam REG_OP                    = 7'b0110011;
    localparam JAL                       = 7'b1101111;
    localparam JALR                      = 7'b1100111;
    localparam BRANCH                    = 7'b1100011;
    localparam SYSTEM                    = 7'b1110011;
    localparam LUI                       = 7'b0110111;

    // Funct3 constants
    localparam F3_ADDI                   = 3'b000;
    localparam F3_SLLI                   = 3'b001;
    localparam F3_SLTI                   = 3'b010;
    localparam F3_SLTIU                  = 3'b011;
    localparam F3_XORI                   = 3'b100;
    localparam F3_SRLI_SRAI              = 3'b101;
    localparam F3_ORI                    = 3'b110;
    localparam F3_ANDI                   = 3'b111;
    localparam F3_LW                     = 3'b010;
    localparam F3_SW                     = 3'b010;
    localparam F3_BEQ                    = 3'b000;
    localparam F3_BNE                    = 3'b001;
    localparam F3_JALR                   = 3'b000;

    // Quadrant 0 funct3 constants
    localparam C0_ADDI4SPN               = 3'b000;
    localparam C0_LW                     = 3'b010;
    localparam C0_SW                     = 3'b110;

    // Quadrant 1 funct3 constants
    localparam C1_ADDI                   = 3'b000;
    localparam C1_JAL                    = 3'b001;
    localparam C1_LI                     = 3'b010;
    localparam C1_LUI_ADDI16SP           = 3'b011;
    localparam C1_ALU_OPS                = 3'b100;
    localparam C1_J                      = 3'b101;
    localparam C1_BEQZ                   = 3'b110;
    localparam C1_BNEZ                   = 3'b111;

    // Quadrant 1 ALU sub-op constants
    localparam C1_SRLI                   = 2'b00;
    localparam C1_SRAI                   = 2'b01;
    localparam C1_ANDI                   = 2'b10;

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

    // Internal wires
    wire [1:0] opcode;
    wire [2:0] funct3;
    
    assign opcode    = compressedInst[ 1: 0];
    assign funct3    = compressedInst[15:13];
    

    reg [ 4:0] rd_prim_rs2_prim;
    reg [ 4:0] rs1_prim;
    reg [11:0] nzuimm;
    reg [11:0] imm;
    reg [ 4:0] rd_rs1;
    reg [ 4:0] rs1_prim_rd_prim;
    reg [ 4:0] rs2_prim;
    reg [20:0] imm21;
    reg [12:0] imm13;
    reg [19:0] imm20;
    reg [ 5:0] uimm6;
    reg [ 1:0] sub_select_rs1;
    reg [ 1:0] sub_select_rs2;
    reg [ 4:0] rs2;
    reg [11:0] uimm12;
    reg [ 5:0] shamt6;

    always @(compressedInst) begin
        decompressInst       = 32'b0;
        rd_prim_rs2_prim     = 5'b0;
        rs1_prim             = 5'b0;
        nzuimm               = 12'b0;
        imm                  = 12'b0;
        rd_rs1               = 5'b0;
        rs1_prim_rd_prim     = 5'b0;
        rs2_prim             = 5'b0;
        imm21                = 21'b0;
        imm13                = 13'b0;
        imm20                = 20'b0;
        uimm6                = 6'b0;
        sub_select_rs1       = 2'b0;
        sub_select_rs2       = 2'b0;
        rs2                  = 5'b0;
        uimm12               = 12'b0;
        shamt6               = 6'b0;

        case(opcode)
            C0: begin
                // Quadrant 0
                rd_prim_rs2_prim     = compressedInst[4:2] + REG_COMPRESSED_BASE;
                rs1_prim             = compressedInst[9:7] + REG_COMPRESSED_BASE;

                case(funct3)
                    C0_ADDI4SPN: begin
                        // C.ADDI4SPN -> Add immediate to SP
                        nzuimm[5:4]             = compressedInst[12:11];
                        nzuimm[9:6]             = compressedInst[10:7];
                        nzuimm[2]               = compressedInst[6];
                        nzuimm[3]               = compressedInst[5];
                        
                        // ADDI rd', x2, nzuimm
                        decompressInst[ 6: 0]   = IMM;
                        decompressInst[11: 7]   = rd_prim_rs2_prim;
                        decompressInst[14:12]   = F3_ADDI;
                        decompressInst[19:15]   = REG_SP;
                        decompressInst[31:20]   = nzuimm;
                    end
                    
                    C0_LW: begin
                        // C.LW -> Load word
                        imm[5:3]                = compressedInst[12:10];
                        imm[2]                  = compressedInst[6];
                        imm[6]                  = compressedInst[5];
                        
                        // LW rd', offset(rs1')
                        decompressInst[ 6: 0]   = LOAD;
                        decompressInst[11: 7]   = rd_prim_rs2_prim;
                        decompressInst[14:12]   = F3_LW;
                        decompressInst[19:15]   = rs1_prim;
                        decompressInst[31:20]   = imm;
                    end
                    
                    C0_SW: begin
                        // C.SW -> Store word
                        imm[5:3]                = compressedInst[12:10];
                        imm[2]                  = compressedInst[6];
                        imm[6]                  = compressedInst[5];
                        
                        // SW rs2', offset(rs1')
                        decompressInst[ 6: 0]   = STORE;
                        decompressInst[11: 7]   = imm[ 4:0];
                        decompressInst[14:12]   = F3_SW;
                        decompressInst[19:15]   = rs1_prim;
                        decompressInst[24:20]   = rd_prim_rs2_prim;
                        decompressInst[31:25]   = imm[11:5];
                    end
                    
                    default: begin
                        // Unsupported Quadrant 0 instruction
                        decompressInst = 32'b0;
                    end
                endcase
            end
            
            C1: begin
                // Quadrant 1
                rd_rs1               = compressedInst[11: 7];
                rs1_prim_rd_prim     = compressedInst[ 9: 7] + REG_COMPRESSED_BASE;
                rs2_prim             = compressedInst[ 4: 2] + REG_COMPRESSED_BASE;

                case(funct3)
                    C1_ADDI: begin
                        // C.ADDI -> Add immediate
                        imm[5]                  = compressedInst[12];
                        imm[4:0]                = compressedInst[6:2];
                        if (imm[5] == 1'b1)
                            imm[11:6]           = 6'b111111;

                        // ADDI rd, rd, imm
                        decompressInst[ 6: 0]   = IMM;
                        decompressInst[11: 7]   = rd_rs1;
                        decompressInst[14:12]   = F3_ADDI;
                        decompressInst[19:15]   = rd_rs1;
                        decompressInst[31:20]   = imm;
                    end
                    
                    C1_JAL: begin
                        // C.JAL -> Jump and link
                        imm21[11]               = compressedInst[12];
                        imm21[4]                = compressedInst[11];
                        imm21[9:8]              = compressedInst[10:9];
                        imm21[10]               = compressedInst[8];
                        imm21[6]                = compressedInst[7];
                        imm21[7]                = compressedInst[6];
                        imm21[3:1]              = compressedInst[5:3];
                        imm21[5]                = compressedInst[2];
                        if (imm21[11] == 1'b1)
                            imm21[20:12]        = 9'b111111111;
                        
                        // JAL x1, offset
                        decompressInst[ 6: 0]   = JAL;
                        decompressInst[11: 7]   = REG_RA;

                        // Encode immediate for JAL instruction
                        decompressInst[31]      = imm21[20];
                        decompressInst[30:21]   = imm21[10:1];
                        decompressInst[20]      = imm21[11];
                        decompressInst[19:12]   = imm21[19:12];
                    end
                    
                    C1_LI: begin
                        // C.LI -> Load immediate
                        if (rd_rs1 != REG_ZERO) begin
                            imm[5]                  = compressedInst[12];
                            imm[4:0]                = compressedInst[6:2];
                            if (imm[5] == 1'b1)
                                imm[11:6]           = 6'b111111;
                            
                            // ADDI rd, x0, imm
                            decompressInst[ 6: 0]   = IMM;
                            decompressInst[11: 7]   = rd_rs1;
                            decompressInst[14:12]   = F3_ADDI;
                            decompressInst[19:15]   = REG_ZERO;
                            decompressInst[31:20]   = imm;
                        end
                    end
                    
                    C1_LUI_ADDI16SP: begin
                        // C.LUI / C.ADDI16SP
                        if (rd_rs1 == REG_SP) begin
                            // C.ADDI16SP
                            imm = 12'b0;
                            imm[9]                  = compressedInst[12];
                            imm[4]                  = compressedInst[6];
                            imm[6]                  = compressedInst[5];
                            imm[8:7]                = compressedInst[4:3];
                            imm[5]                  = compressedInst[2];
                            if (imm[9] == 1'b1)
                                imm[11:10]          = 2'b11;
                            
                            // ADDI x2, x2, nzimm
                            decompressInst[ 6: 0]   = IMM;
                            decompressInst[11: 7]   = REG_SP;
                            decompressInst[14:12]   = F3_ADDI;
                            decompressInst[19:15]   = REG_SP;
                            decompressInst[31:20]   = imm;
                        end else if (rd_rs1 != REG_ZERO && rd_rs1 != REG_SP) begin
                            // C.LUI
                            imm20[17]               = compressedInst[12];
                            imm20[16:12]            = compressedInst[6:2];
                            if (imm20[17] == 1'b1)
                                imm20[19:18]        = 2'b11;
                            
                            // LUI rd, imm
                            decompressInst[ 6: 0]   = LUI;
                            decompressInst[11: 7]   = rd_rs1;
                            decompressInst[31:12]   = imm20 >> 12;
                        end
                    end
                    
                    C1_ALU_OPS: begin
                        sub_select_rs1 = compressedInst[11:10];
                        sub_select_rs2 = compressedInst[ 6: 5];
                        
                        case(sub_select_rs1)
                            C1_SRLI: begin
                                // C.SRLI -> Shift right logical immediate
                                uimm6[4:0]          = compressedInst[6:2];
                                uimm6[5]            = compressedInst[12];

                                if (uimm6[5] == 1'b0) begin
                                    // SRLI rd', rd', shamt
                                    decompressInst[ 6: 0]   = IMM;
                                    decompressInst[11: 7]   = rs1_prim_rd_prim;
                                    decompressInst[14:12]   = F3_SRLI_SRAI;
                                    decompressInst[19:15]   = rs1_prim_rd_prim;
                                    decompressInst[24:20]   = uimm6[4:0];
                                    decompressInst[31:25]   = F7_SRLI;
                                end
                            end
                            
                            C1_SRAI: begin
                                // C.SRAI -> Shift right arithmetic immediate
                                uimm6[4:0]          = compressedInst[6:2];
                                uimm6[5]            = compressedInst[12];

                                if (uimm6[5] == 1'b0) begin
                                   // SRAI rd', rd', shamt
                                    decompressInst[ 6: 0]   = IMM;
                                    decompressInst[11: 7]   = rs1_prim_rd_prim;
                                    decompressInst[14:12]   = F3_SRLI_SRAI;
                                    decompressInst[19:15]   = rs1_prim_rd_prim;
                                    decompressInst[24:20]   = uimm6[4:0];
                                    decompressInst[31:25]   = F7_SRAI;
                                end
                            end
                            
                            C1_ANDI: begin
                                // C.ANDI -> And immediate
                                imm[4:0]            = compressedInst[6:2];
                                imm[5]              = compressedInst[12];
                                if (imm[5] == 1'b1)
                                    imm[11:6]       = 6'b111111;
                                
                                // ANDI rd', rd', imm
                                decompressInst[ 6: 0]   = IMM;
                                decompressInst[11: 7]   = rs1_prim_rd_prim;
                                decompressInst[14:12]   = F3_ANDI;
                                decompressInst[19:15]   = rs1_prim_rd_prim;
                                decompressInst[31:20]   = imm;
                            end
                            
                            default: begin
                                // ALU operations
                                case(sub_select_rs2)
                                    2'b00: begin // C.SUB
                                        decompressInst[ 6: 0]   = REG_OP;
                                        decompressInst[11: 7]   = rs1_prim_rd_prim;
                                        decompressInst[14:12]   = F3_ADDI;
                                        decompressInst[19:15]   = rs1_prim_rd_prim;
                                        decompressInst[24:20]   = rs2_prim;
                                        decompressInst[31:25]   = F7_SUB;
                                    end
                                    
                                    2'b01: begin // C.XOR
                                        decompressInst[ 6: 0]   = REG_OP;
                                        decompressInst[11: 7]   = rs1_prim_rd_prim;
                                        decompressInst[14:12]   = F3_XORI;
                                        decompressInst[19:15]   = rs1_prim_rd_prim;
                                        decompressInst[24:20]   = rs2_prim;
                                        decompressInst[31:25]   = F7_ADD;
                                    end
                                    
                                    2'b10: begin // C.OR
                                        decompressInst[ 6: 0]   = REG_OP;
                                        decompressInst[11: 7]   = rs1_prim_rd_prim;
                                        decompressInst[14:12]   = F3_ORI;
                                        decompressInst[19:15]   = rs1_prim_rd_prim;
                                        decompressInst[24:20]   = rs2_prim;
                                        decompressInst[31:25]   = F7_ADD;
                                    end
                                    
                                    2'b11: begin // C.AND
                                        decompressInst[ 6: 0]   = REG_OP;
                                        decompressInst[11: 7]   = rs1_prim_rd_prim;
                                        decompressInst[14:12]   = F3_ANDI;
                                        decompressInst[19:15]   = rs1_prim_rd_prim;
                                        decompressInst[24:20]   = rs2_prim;
                                        decompressInst[31:25]   = F7_ADD;
                                    end
                                endcase
                            end
                        endcase
                    end
                    
                    C1_J: begin
                        // C.J - Jump
                        imm21[11]               = compressedInst[12];
                        imm21[4]                = compressedInst[11];
                        imm21[9:8]              = compressedInst[10:9];
                        imm21[10]               = compressedInst[8];
                        imm21[6]                = compressedInst[7];
                        imm21[7]                = compressedInst[6];
                        imm21[3:1]              = compressedInst[5:3];
                        imm21[5]                = compressedInst[2];
                        if (imm21[11] == 1'b1)
                            imm21[20:12]        = 9'b111111111;
                        
                        // JAL x0, offset
                        decompressInst[ 6: 0]   = JAL;
                        decompressInst[11: 7]   = REG_ZERO;

                        // Encode immediate for JAL instruction
                        decompressInst[31]      = imm21[20];
                        decompressInst[30:21]   = imm21[10:1];
                        decompressInst[20]      = imm21[11];
                        decompressInst[19:12]   = imm21[19:12];
                    end
                    
                    C1_BEQZ: begin
                        // C.BEQZ - Branch if equal to zero
                        imm13 = 13'b0;
                        imm13[8]                = compressedInst[12];
                        imm13[4:3]              = compressedInst[11:10];
                        imm13[7:6]              = compressedInst[6:5];
                        imm13[2:1]              = compressedInst[4:3];
                        imm13[5]                = compressedInst[2];
                        if (imm13[8] == 1'b1)
                            imm13[12:9]         = 4'b1111;
                        
                        // BEQ rs1', x0, offset
                        decompressInst[ 6: 0]   = BRANCH;
                        decompressInst[14:12]   = F3_BEQ;
                        decompressInst[19:15]   = rs1_prim_rd_prim;
                        decompressInst[24:20]   = REG_ZERO;
                        
                        // Encode immediate for branch instruction
                        decompressInst[7]       = imm13[11];
                        decompressInst[11: 8]   = imm13[4:1];
                        decompressInst[30:25]   = imm13[10:5];
                        decompressInst[31]      = imm13[12];
                    end
                    
                    C1_BNEZ: begin
                        // C.BNEZ - Branch if not equal to zero
                        imm13[8]                = compressedInst[12];
                        imm13[4:3]              = compressedInst[11:10];
                        imm13[7:6]              = compressedInst[6:5];
                        imm13[2:1]              = compressedInst[4:3];
                        imm13[5]                = compressedInst[2];
                        if (imm13[8] == 1'b1)
                            imm13[12:9]         = 4'b1111;
                        
                        // BNE rs1', x0, offset
                        decompressInst[ 6: 0]   = BRANCH;
                        decompressInst[14:12]   = F3_BNE;
                        decompressInst[19:15]   = rs1_prim_rd_prim;
                        decompressInst[24:20]   = REG_ZERO;
                        
                        // Encode immediate for branch instruction
                        decompressInst[7]       = imm13[11];
                        decompressInst[11: 8]   = imm13[4:1];
                        decompressInst[30:25]   = imm13[10:5];
                        decompressInst[31]      = imm13[12];
                    end
                    
                    default: begin
                        // Unsupported Quadrant 1 instruction
                        decompressInst = 32'b0;
                    end
                endcase
            end
            
            C2: begin
                // Quadrant 2
                rd_rs1 = compressedInst[11:7];
                rs2    = compressedInst[6:2];
                
                case(funct3)
                    C2_SLLI: begin
                        // C.SLLI -> Shift left logical immediate
                        shamt6[5]               = compressedInst[12];
                        shamt6[4:0]             = compressedInst[6:2];
                        
                        if (shamt6[5] == 1'b0 && rd_rs1 != REG_ZERO) begin
                            // SLLI rd, rd, shamt
                            decompressInst[ 6: 0]   = IMM;
                            decompressInst[11: 7]   = rd_rs1;
                            decompressInst[14:12]   = F3_SLLI;
                            decompressInst[19:15]   = rd_rs1;
                            decompressInst[24:20]   = shamt6[4:0];
                            decompressInst[31:25]   = F7_ADD;
                        end
                    end
                    
                    C2_LWSP: begin
                        // C.LWSP -> Load word
                        if (rd_rs1 != REG_ZERO) begin
                            imm[5]                  = compressedInst[12];
                            imm[4:2]                = compressedInst[6:4];
                            imm[7:6]                = compressedInst[3:2];
                            
                            // LW rd, offset(x2)
                            decompressInst[ 6: 0]   = LOAD;
                            decompressInst[11: 7]   = rd_rs1;
                            decompressInst[14:12]   = F3_LW;
                            decompressInst[19:15]   = REG_SP;
                            decompressInst[31:20]   = imm;
                        end
                    end
                    
                    C2_JR_MV_EBREAK_ADD: begin
                        if (compressedInst[12] == 1'b0) begin
                            if (rs2 == REG_ZERO) begin
                                // C.JR -> Jump register
                                if (rd_rs1 != REG_ZERO) begin
                                    // JALR x0, 0(rs1)
                                    decompressInst[ 6: 0]   = JALR;
                                    decompressInst[11: 7]   = REG_ZERO;
                                    decompressInst[14:12]   = F3_JALR;
                                    decompressInst[19:15]   = rd_rs1;
                                    decompressInst[31:20]   = 12'b0;
                                end
                            end else begin
                                // C.MV -> Move
                                if (rd_rs1 != REG_ZERO) begin
                                    // ADD rd, x0, rs2
                                    decompressInst[ 6: 0]   = REG_OP;
                                    decompressInst[11: 7]   = rd_rs1;
                                    decompressInst[14:12]   = F3_ADDI;
                                    decompressInst[19:15]   = REG_ZERO;
                                    decompressInst[24:20]   = rs2;
                                    decompressInst[31:25]   = F7_ADD;
                                end
                            end
                        end 
                        if (compressedInst[12] == 1'b1) begin
                            if (rs2 == REG_ZERO) begin
                                if (rd_rs1 == REG_ZERO) begin
                                    // C.EBREAK
                                    decompressInst[ 6: 0]   = SYSTEM;
                                    decompressInst[11: 7]   = REG_ZERO;
                                    decompressInst[14:12]   = F3_ADDI;
                                    decompressInst[19:15]   = REG_ZERO;
                                    decompressInst[31:20]   = 12'b000000000001;
                                end else begin
                                    // C.JALR -> Jump and link register
                                    // JALR x1, 0(rs1)
                                    decompressInst[ 6: 0]   = JALR;
                                    decompressInst[11: 7]   = REG_RA;
                                    decompressInst[14:12]   = F3_JALR;
                                    decompressInst[19:15]   = rd_rs1;
                                    decompressInst[31:20]   = 12'b0;
                                end
                            end else begin
                                // C.ADD -> Add
                                if (rd_rs1 != REG_ZERO) begin
                                    // ADD rd, rd, rs2
                                    decompressInst[ 6: 0]   = REG_OP;
                                    decompressInst[11: 7]   = rd_rs1;
                                    decompressInst[14:12]   = F3_ADDI;
                                    decompressInst[19:15]   = rd_rs1;
                                    decompressInst[24:20]   = rs2;
                                    decompressInst[31:25]   = F7_ADD;
                                end
                            end
                        end
                    end
                    
                    C2_SWSP: begin
                        // C.SWSP - Store word
                        uimm12[5:2]             = compressedInst[12:9];
                        uimm12[7:6]             = compressedInst[8:7];
                        
                        // SW rs2, offset(x2)
                        decompressInst[ 6: 0]   = STORE;
                        decompressInst[11: 7]   = uimm12[4:0];
                        decompressInst[14:12]   = F3_SW;
                        decompressInst[19:15]   = REG_SP;
                        decompressInst[24:20]   = rs2;
                        decompressInst[31:25]   = uimm12[11:5];
                    end
                    
                    default: begin
                        // Unsupported Quadrant 2 instruction
                        decompressInst = 32'b0;
                    end
                endcase
            end
            
            default: begin
                // Unknown opcode
                decompressInst = 32'b0;
            end
        endcase
    end

endmodule
