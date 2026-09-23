////////////////////////////////////////////////////////////////////////////////
// File      : CSRController.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-05-19 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_controller(
	// Control signal
	input  wire [ 2:0] 	funct3,
	input  wire 		systemInst,
	
	output reg  [ 1:0]	operation,
	output reg			PassCSRData,
	output reg 			PassCSRAddr,
	output reg			CSRDataSelect,
	output reg 			ecall,
	output reg			sret,
	output reg			mret,
	output reg			wfi,
	output reg			changeExeSrc,
	output reg			CSRAccess,
	output reg			illegalCSRAccess,

	// Data signal
	input  wire [11:0]	funct12,
	input  wire [ 1:0]  curPriv,
	input  wire [ 4:0]  rs1Addr
);

    localparam PRIV_U 			= 2'b00;
    localparam PRIV_S 			= 2'b01;
    localparam PRIV_M 			= 2'b11;

	// CSR Instructions
	localparam SystemInstr		= 	3'b000;
	localparam CSRRW 			= 	3'b001;
	localparam CSRRS 			= 	3'b010;
	localparam CSRRC 			= 	3'b011;

	localparam CSRRWI 			= 	3'b101;
	localparam CSRRSI 			= 	3'b110;
	localparam CSRRCI 			= 	3'b111;

	// X0 register
	localparam REG_X0			=	5'b00000;

	// operation
	localparam 	Write 			=	2'b01;
	localparam 	Set	 			=	2'b10;
	localparam 	Clear	 		=	2'b11;

	// CSR Data Select
	localparam 	RS1 			=	1'b0;
	localparam 	uimm	 		=	1'b1;

	// System Instructions
	localparam 	ECALL 			=	12'h0;
	localparam 	SRET	 		=	12'h102;
	localparam 	MRET	 		=	12'h302;
	localparam 	WFI		 		=	12'h105;
	
	
    wire [11:0] csrAddr;
    assign 		csrAddr 			= funct12;

    wire [1:0] 	csrPrivilege;
    assign 		csrPrivilege 		= csrAddr[9:8];
	
	wire 		csrPrivilegeAllowed;
    assign 		csrPrivilegeAllowed = csrPrivilege <= curPriv;

    wire 		csrReadOnly;
    assign 		csrReadOnly 		= (csrAddr[11:10] == 2'b11);

    reg csrWriteIntent;
    always @(funct3, rs1Addr) begin
        csrWriteIntent = 1'b0;
        case (funct3)
            CSRRW:
                csrWriteIntent = 1'b1;
            CSRRS:
                csrWriteIntent = (rs1Addr != REG_X0);
            CSRRC:
                csrWriteIntent = (rs1Addr != REG_X0);
            CSRRWI:
                csrWriteIntent = 1'b1;
            CSRRSI:
                csrWriteIntent = (rs1Addr != REG_X0);
            CSRRCI:
                csrWriteIntent = (rs1Addr != REG_X0);
        endcase
    end

    wire   csrWriteAllowed;
    assign csrWriteAllowed 		= !(csrReadOnly & csrWriteIntent);

	always @(funct3, systemInst, funct12, curPriv, csrPrivilegeAllowed, csrWriteAllowed) begin
		{operation, PassCSRData, PassCSRAddr, CSRDataSelect, ecall, mret, sret, wfi, changeExeSrc, CSRAccess, illegalCSRAccess} = 
		{2'b0	  , 1'b0	   , 1'b0		, 1'b0		   , 1'b0 , 1'b0, 1'b0,1'b0, 1'b0		 , 1'b0		, 1'b0				};
        if (systemInst) begin
            if (funct3 == SystemInstr) begin
                case (funct12)
                    ECALL: begin
                        ecall = 1'b1;
                    end
                    SRET: begin
                        if ((curPriv == PRIV_S) || (curPriv == PRIV_M)) begin
                            sret = 1'b1;
                        end else begin
                            illegalCSRAccess = 1'b1;
                        end
                    end
                    MRET: begin
                        if (curPriv == PRIV_M) begin
                            mret = 1'b1;
                        end else begin
                            illegalCSRAccess = 1'b1;
                        end
                    end
                    WFI: begin
                            wfi = 1'b1;
                    end
                    default: begin
                        illegalCSRAccess = 1'b1;
                    end
                endcase
            end else begin
                if (!csrPrivilegeAllowed | !csrWriteAllowed) begin
                    illegalCSRAccess = 1'b1;
                end
                else begin
					PassCSRData			= 1'b1;
					PassCSRAddr			= 1'b1;
					CSRAccess			= 1'b1;
                    case (funct3)
                        CSRRW: begin
                            operation     = Write;
                            CSRDataSelect = RS1;
                            changeExeSrc  = 1'b1;
                        end
                        CSRRS: begin
                            operation     = Set;
                            CSRDataSelect = RS1;
                            changeExeSrc  = 1'b1;
                        end
                        CSRRC: begin
                            operation     = Clear;
                            CSRDataSelect = RS1;
                            changeExeSrc  = 1'b1;
                        end
                        CSRRWI: begin
                            operation     = Write;
                            CSRDataSelect = uimm;
                            changeExeSrc  = 1'b1;
                        end
                        CSRRSI: begin
                            operation     = Set;
                            CSRDataSelect = uimm;
                            changeExeSrc  = 1'b1;
                        end
                        CSRRCI: begin
                            operation     = Clear;
                            CSRDataSelect = uimm;
                            changeExeSrc  = 1'b1;
                        end
                        default: begin
                            illegalCSRAccess = 1'b1;
                        end
                    endcase
                end
            end
        end
    end

endmodule