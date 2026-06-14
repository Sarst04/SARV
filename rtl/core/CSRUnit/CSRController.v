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
	output reg			mret,
	output reg			wfi,
	output reg			changeExeSrc,
	output reg			CSRAccess,

	// Data signal
	input  wire [11:0]	funct12,
	input  wire [ 4:0] 	rdAddr
);

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
	localparam 	MRET	 		=	12'h302;
	localparam 	WFI		 		=	12'h105;
	
	


	always @(funct3, systemInst, funct12, rdAddr) begin
		{operation, PassCSRData, PassCSRAddr, CSRDataSelect, ecall, mret, wfi, changeExeSrc, CSRAccess} = {2'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
		if (systemInst) begin
			PassCSRData			= 1'b1;
			PassCSRAddr			= 1'b1;
			CSRAccess			= 1'b1;
			case (funct3)
				SystemInstr : begin	
					CSRAccess				= 	1'b0;
					case (funct12)
						ECALL	:	ecall	=	1'b1;
						MRET	:	mret	=	1'b1;
						WFI		:	wfi		=	1'b1;
					endcase

				end
				CSRRW 		:	begin
					operation 		= Write;
					CSRDataSelect	= RS1;
					changeExeSrc	= 1'b1;
				end
				CSRRS		:	begin
					operation 		= Set;
					CSRDataSelect	= RS1;
					changeExeSrc	= 1'b1;
				end
				CSRRC 		:	begin
					operation 		= Clear;
					CSRDataSelect	= RS1;
					changeExeSrc	= 1'b1;
				end
				CSRRWI 		:	begin
					operation 		= Write;
					CSRDataSelect	= uimm;
					changeExeSrc	= 1'b1;
				end
				CSRRSI		:	begin
					operation 		= Set;
					CSRDataSelect	= uimm;
					changeExeSrc	= 1'b1;
				end
				CSRRCI 		:	begin
					operation 		= Clear;
					CSRDataSelect	= uimm;
					changeExeSrc	= 1'b1;
				end
			endcase
		end
	end
endmodule