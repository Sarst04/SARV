////////////////////////////////////////////////////////////////////////////////
// File      : unAlignHandler.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-08-14
// Description:
////////////////////////////////////////////////////////////////////////////////
module unalign_handler(
    input  wire         clk,
    input  wire         rst,
    
    // Control signal
    input  wire         waitRequest_F_i,
    input  wire         unAlignFetch_F_i,

    output reg 	        waitRequest,
    
    // Data signal
    input  wire [31:0]  instructionMemoryData_F_i,
    input  wire [31:0]  PC_F_i,
    
    output wire [31:0]  alignInstructionData,
    output wire [31:0]  address
);

	reg concatenate;
	reg fetchNext;

    reg         storeLastHalfWord;
    reg [15:0]  lastHalfWord;
    always @(posedge clk, posedge rst) begin
        if (rst)
            lastHalfWord <= 16'b0;
        else if (storeLastHalfWord)
            lastHalfWord <= instructionMemoryData_F_i[15:0];
    end

    wire fullInst = (instructionMemoryData_F_i[1:0] == 2'b11);


    parameter ALIGN = 0, MAKE_ALIGN = 1;
    reg ps, ns;
    
    always @(posedge clk, posedge rst) begin
        if (rst)
            ps = ALIGN;
        else
            ps = ns;
    end
    
    always @(ps, unAlignFetch_F_i, waitRequest_F_i, fullInst) begin
        ns = ps;
        case (ps)
            ALIGN : begin
                if (unAlignFetch_F_i & (!waitRequest_F_i) & fullInst)
                    ns = MAKE_ALIGN;
            end
            MAKE_ALIGN : begin
                if (!waitRequest_F_i)
                    ns = ALIGN;
            end
        endcase
    end
    
    always @(ps, unAlignFetch_F_i, waitRequest_F_i, fullInst) begin
        storeLastHalfWord = 1'b0;
        fetchNext         = 1'b0;
        concatenate       = 1'b0;
        waitRequest       = 1'b0;
        case (ps)
            ALIGN : begin
                if (unAlignFetch_F_i)
                    if (!waitRequest_F_i & fullInst) begin
                        storeLastHalfWord = 1'b1;
                        waitRequest       = 1'b1;
                    end
            end
            MAKE_ALIGN : begin
                fetchNext = 1'b1;
                if (!waitRequest_F_i)
                    concatenate = 1'b1;
            end
        endcase
    end
    
    assign address       			= fetchNext ? PC_F_i + 2 : PC_F_i;
    assign alignInstructionData 	= concatenate ? {instructionMemoryData_F_i[15:0], lastHalfWord} : instructionMemoryData_F_i;

endmodule