////////////////////////////////////////////////////////////////////////////////
// File      : RegisterFile.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-05-28 (last modified)
// Description:
//   RegisterFile with forwarding logic
////////////////////////////////////////////////////////////////////////////////
module register_file #(parameter DATA_WIDTH = 64, parameter ADDR_WIDTH = 5, parameter REG_NUMBER = 32)(
    input wire clk,
    input wire rst,
    
    input wire [ADDR_WIDTH-1:0] rs1_addr,
    output wire [DATA_WIDTH-1:0] rs1_data,
    
    input wire [ADDR_WIDTH-1:0] rs2_addr,
    output wire [DATA_WIDTH-1:0] rs2_data,
    
    input wire [ADDR_WIDTH-1:0] rd_addr,
    input wire [DATA_WIDTH-1:0] rd_data,
    input wire rd_write_enable
);

    reg [DATA_WIDTH-1:0] registers [0:REG_NUMBER-1];

	wire forwardRs1;
	wire forwardRs2;

	assign forwardRs1	=	rd_write_enable & (rs1_addr != 0) & (rd_addr == rs1_addr);	
	assign forwardRs2	=	rd_write_enable & (rs2_addr != 0) & (rd_addr == rs2_addr);
    
    assign rs1_data = forwardRs1 ? rd_data : registers[rs1_addr];
    assign rs2_data = forwardRs2 ? rd_data : registers[rs2_addr];
    
    integer i;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            for ( i = 0; i < REG_NUMBER; i = i + 1) begin
                registers[i] <= {DATA_WIDTH{1'b0}};
            end
        end
        else if (rd_write_enable && (rd_addr != 0)) begin
            registers[rd_addr] <= rd_data;
        end
    end
    
endmodule