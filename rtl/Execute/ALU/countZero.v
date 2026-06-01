module CTZ(
	input  wire	[31:0]	in,
	output wire	[31:0]	count
);
    wire zero = ~|in;

    wire [ 4:0] 	stage;
    wire [15:0] 	s16;
    wire [ 7:0]  	s8;
    wire [ 3:0]  	s4;
    wire [ 1:0]  	s2;

    assign stage[4] = (in[15:0] == 16'b0);
    assign s16 		= stage[4] ? in[31:16] : in[15:0];

    assign stage[3] = (s16[7:0] == 8'b0);
    assign s8 		= stage[3] ? s16[15:8] : s16[7:0];

    assign stage[2] = (s8[3:0] == 4'b0);
    assign s4 		= stage[2] ? s8[7:4] : s8[3:0];

    assign stage[1] = (s4[1:0] == 2'b0);
    assign s2 		= stage[1] ? s4[3:2] : s4[1:0];

    assign stage[0] = ~s2[0];

    assign count 	= zero ? 6'd32 : {27'b0, stage};

endmodule

module CLZ(
	input  wire	[31:0]	in,
	output wire	[31:0]	count
);

    wire zero = ~|in;

    wire [ 4:0] stage;
    wire [15:0] s16;
    wire [ 7:0]  s8;
    wire [ 3:0]  s4;
    wire [ 1:0]  s2;

    assign stage[4] = (in[31:16] == 16'b0);
    assign s16 = stage[4] ? in[15:0] : in[31:16];

    assign stage[3] = (s16[15:8] == 8'b0);
    assign s8 = stage[3] ? s16[7:0] : s16[15:8];

    assign stage[2] = (s8[7:4] == 4'b0);
    assign s4 = stage[2] ? s8[3:0] : s8[7:4];

    assign stage[1] = (s4[3:2] == 2'b0);
    assign s2 = stage[1] ? s4[1:0] : s4[3:2];

    assign stage[0] = ~s2[1];

    assign count = zero ? 6'd32 : {27'b0, stage};

endmodule