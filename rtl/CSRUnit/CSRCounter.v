module CSR_counter #(parameter WIDTH = 8)(
    input  wire 			clk,
    input  wire 			rst,
    
    input  wire 			en,
    input  wire 			ce,
    input  wire 			stall,

    input  wire [31:0] dataIn,
    output wire [31:0] dataOut
);
	reg	[WIDTH-1:0]			count;
    always @(posedge clk, posedge rst) begin
        if (rst)
            count 		<= {WIDTH{1'b0}};
        else if (en) 
            count 		<= dataIn[WIDTH-1:0];
        else if (stall) 
            count		<= count;
        else if (ce) 
            count		<= count + 1;
    end
	
	assign dataOut 		= {{(32-WIDTH){1'b0}}, count};

endmodule