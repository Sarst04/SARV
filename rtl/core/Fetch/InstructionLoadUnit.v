////////////////////////////////////////////////////////////////////////////////
// File      : InstructionLoadUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-08-14 (modified)
// Description:
////////////////////////////////////////////////////////////////////////////////
module instruction_load_unit(
    input  wire         clk,
    input  wire         rst,

    // Control signal
    input  wire         waitRequest_F_i,
    input  wire         disableInstLoad_F_i,
    input  wire         unAlignFetch_F_i,

    output wire         waitRequest_F_o,

    // Data signal
    input  wire [31:0]  PC_F_i,
    input  wire [31:0]  instructionMemoryData_F_i,

    output wire [31:0]  instructionMemoryAddress_F_o,
    output wire         instructionMemoryReadRequest_F_o,
    output wire [31:0]  instructionMemoryData
);

    wire [31:0] instructionAddress;
    wire [31:0] alignInstructionData;
    wire        unalign_wait;
    wire        fetchNext;

    unalign_handler UnalignHandler(
        .clk(clk),
        .rst(rst),

        .waitRequest_F_i(waitRequest_F_i),
        .unAlignFetch_F_i(unAlignFetch_F_i),

        .waitRequest(waitRequest),

        .instructionMemoryData_F_i(instructionMemoryData_F_i),
        .PC_F_i(PC_F_i),

        .alignInstructionData(alignInstructionData),
        .address(instructionAddress)
    );

    assign instructionMemoryAddress_F_o    	= instructionAddress;
    assign instructionMemoryData           	= alignInstructionData;
    assign instructionMemoryReadRequest_F_o = (disableInstLoad_F_i == 1'b0);
    assign waitRequest_F_o                 	= waitRequest_F_i | waitRequest;

endmodule