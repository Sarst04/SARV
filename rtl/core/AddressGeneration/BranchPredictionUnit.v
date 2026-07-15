////////////////////////////////////////////////////////////////////////////////
// File      : BranchPredictionUnit.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-07-15 (updated)
// Description: Multi-entry Branch Target Buffer (BTB) featuring a 2-bit 
//              saturating counter state machine. Utilizes conditional 
//              generation to support a bypass configuration when 
//              ENTRY_INDEX_BITS is 0.
////////////////////////////////////////////////////////////////////////////////
module branch_prediction_unit #(
    parameter ENTRY_INDEX_BITS = 4
)(
    input  wire         clk,
    input  wire         rst,

    // Control signals
    input  wire         branch_E_o_A_i,
    input  wire         branchTakenDetect_E_o_A_i,
    input  wire         predictTaken_E_o_A_i,

    output reg          changePCSrcBranchUnitTarget,
    output reg          mispredictBranch,
    output reg          predictTaken_A_o,

    // Data signals
    input  wire [31:0]  PC_F_o_A_i,
    input  wire [31:0]  PC_E_o_A_i,
    input  wire [31:0]  nextPC_E_o_A_i,
    input  wire [31:0]  PCTarget_E_o_A_i,

    output reg  [31:0]  PCTargetBranchUnit
);

    localparam [1:0] STRONGLY_NOT_TAKEN = 2'b00;
    localparam [1:0] WEAKLY_NOT_TAKEN   = 2'b01;
    localparam [1:0] WEAKLY_TAKEN       = 2'b10;
    localparam [1:0] STRONGLY_TAKEN     = 2'b11;

    generate
        if (ENTRY_INDEX_BITS == 0) begin : gen_zero_index
            always @(*) begin
                changePCSrcBranchUnitTarget = branchTakenDetect_E_o_A_i;
                mispredictBranch            = branchTakenDetect_E_o_A_i;
                PCTargetBranchUnit          = PCTarget_E_o_A_i;
                predictTaken_A_o            = 1'b0;
            end
        end else begin : gen_normal_index
            localparam ENTRIES  = 1 << ENTRY_INDEX_BITS;
            localparam TAG_BITS = 32 - ENTRY_INDEX_BITS - 1; 

            reg [ENTRIES-1:0]  valid_array;
            reg [1:0]          history_array [ENTRIES-1:0];
            reg [TAG_BITS-1:0] tag_array [ENTRIES-1:0];
            reg [30:0]         targetPC_array [ENTRIES-1:0];

            wire [ENTRY_INDEX_BITS-1:0] fetch_idx;
            wire [ENTRY_INDEX_BITS-1:0] execute_idx;
            wire [TAG_BITS-1:0]         fetch_tag;
            wire [TAG_BITS-1:0]         execute_tag;

            assign fetch_idx   = PC_F_o_A_i[ENTRY_INDEX_BITS:1];
            assign execute_idx = PC_E_o_A_i[ENTRY_INDEX_BITS:1];

            assign fetch_tag   = PC_F_o_A_i[31:ENTRY_INDEX_BITS+1];
            assign execute_tag = PC_E_o_A_i[31:ENTRY_INDEX_BITS+1];

            wire    fetchHit;
            assign  fetchHit   = valid_array[fetch_idx] && (fetch_tag == tag_array[fetch_idx]);

            wire    execute_hit;
            assign  execute_hit = valid_array[execute_idx] && (execute_tag == tag_array[execute_idx]);

            integer i;
            always @(posedge clk, posedge rst) begin
                if(rst) begin
                    valid_array   <= {ENTRIES{1'b0}};
                    for (i = 0; i < ENTRIES; i = i + 1) begin
                        tag_array[i]      <= {TAG_BITS{1'b0}};
                        targetPC_array[i] <= 31'b0;
                        history_array[i]  <= WEAKLY_NOT_TAKEN;
                    end
                end else if(branch_E_o_A_i) begin
                    valid_array[execute_idx]    <= 1'b1;
                    tag_array[execute_idx]      <= execute_tag;
                    targetPC_array[execute_idx] <= PCTarget_E_o_A_i[31:1];

                    if (execute_hit) begin
                        case (history_array[execute_idx])
                            STRONGLY_NOT_TAKEN: begin
                                history_array[execute_idx] <= branchTakenDetect_E_o_A_i ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
                            end
                            WEAKLY_NOT_TAKEN: begin
                                history_array[execute_idx] <= branchTakenDetect_E_o_A_i ? WEAKLY_TAKEN     : STRONGLY_NOT_TAKEN;
                            end
                            WEAKLY_TAKEN: begin
                                history_array[execute_idx] <= branchTakenDetect_E_o_A_i ? STRONGLY_TAKEN   : WEAKLY_NOT_TAKEN;
                            end
                            STRONGLY_TAKEN: begin
                                history_array[execute_idx] <= branchTakenDetect_E_o_A_i ? STRONGLY_TAKEN   : WEAKLY_TAKEN;
                            end
                            default: begin
                                history_array[execute_idx] <= WEAKLY_NOT_TAKEN;
                            end
                        endcase
                    end else begin
                        history_array[execute_idx] <= branchTakenDetect_E_o_A_i ? WEAKLY_TAKEN : WEAKLY_NOT_TAKEN;
                    end
                end
            end

            always @(*) begin
                changePCSrcBranchUnitTarget = 1'b0;
                mispredictBranch            = 1'b0;
                PCTargetBranchUnit          = 32'b0;
                predictTaken_A_o            = 1'b0;

                if(fetchHit && history_array[fetch_idx][1]) begin
                    changePCSrcBranchUnitTarget = 1'b1;
                    PCTargetBranchUnit          = {targetPC_array[fetch_idx], 1'b0}; 
                    predictTaken_A_o            = 1'b1;
                end

                if(branch_E_o_A_i) begin
                    if (!predictTaken_E_o_A_i && branchTakenDetect_E_o_A_i) begin
                        mispredictBranch            = 1'b1;
                        changePCSrcBranchUnitTarget = 1'b1;
                        PCTargetBranchUnit          = PCTarget_E_o_A_i;
                    end 
                    else if (predictTaken_E_o_A_i && !branchTakenDetect_E_o_A_i) begin
                        mispredictBranch            = 1'b1;
                        changePCSrcBranchUnitTarget = 1'b1;
                        PCTargetBranchUnit          = nextPC_E_o_A_i;
                    end
                end
            end
        end
    endgenerate

endmodule
