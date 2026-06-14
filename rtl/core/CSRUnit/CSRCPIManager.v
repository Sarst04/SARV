////////////////////////////////////////////////////////////////////////////////
// File      : CSRCPIManager.v
// Author(s) : Sayyid Amirreza Sayyid Torabi <sayyidtorabi@gmail.com>
// Date      : 2026-05-24 (last modified)
// Description:
//   
////////////////////////////////////////////////////////////////////////////////
module CSR_CPI_manager(
	input  wire			clk,
	input  wire			rst,

	input  wire	[ 1:0]	priv,
	input  wire	[ 3:0]	CPIRate,
	//input  wire	[ 3:0]	HWCPIRate,
	input  wire [ 7:0]  CPICTRL,
	//input  wire			forceStall,

	output wire			stallCore
);
	//CPICTRL						| 			3 	   | 2:1			|0     |
	//								| HW CPI control   | LeastPrivmode	|enable|

	//CPIRate											| 3:2			|1:0   |
	//													| ring2	    	|ring1 |

	wire	  ring1En;
	wire	  ring2En; 
	
	wire [5:0] 	ring1;
	wire [5:0] 	ring2;

	wire [1:0] 	rateRing1;
	wire [1:0] 	rateRing2;

	wire enable;
	//assign enable = CPICTRL[0] & (priv <= CPICTRL[2:1]) ;
	assign enable = CPICTRL[0];

	/*
	assign rateRing1 = CPICTRL[3] ? CPIRate[1:0] : HWCPIRate[1:0];	
	assign rateRing2 = CPICTRL[3] ? CPIRate[3:2] : HWCPIRate[3:2];
	*/	
	assign rateRing1 = CPIRate[1:0];	
	assign rateRing2 = CPIRate[3:2];


	assign	ring1En = enable;
	assign  ring2En = ring1[5] & enable;



	ringCounter6bit ringCounter1(
		.clk(clk),
		.rst(rst),
	
		.enable(ring1En),
		.parallelOut(ring1)
	);

	ringCounter6bit ringCounter2(
		.clk(clk),
		.rst(rst),
	
		.enable(ring2En),
		.parallelOut(ring2)
	);

    wire level1;
    assign level1 = (!enable) ? 1'b0 :
                    (rateRing1 == 2'd0) ? ring1[5] :
                    (rateRing1 == 2'd1) ? (ring1[5] | ring1[2]) :
                    (rateRing1 == 2'd2) ? (ring1[5] | ring1[3] | ring1[1]) :
                    (rateRing1 == 2'd3) ? 1'b1 : 1'b0;
    
    wire level2;
    assign level2 = (!enable) ? 1'b0 :
               		(rateRing2 == 2'd0) ? ring2[5] :                    
                	(rateRing2 == 2'd1) ? (ring2[5] | ring2[2]) :    
                	(rateRing2 == 2'd2) ? (ring2[5] | ring2[3] | ring2[1]) : 
                	(rateRing2 == 2'd3) ? ~(ring2[5] & ring2[2]) : 1'b0;
    

	//assign stallCore = (level2 & level1) | forceStall;
	assign stallCore = (level2 & level1);


endmodule

module ringCounter6bit(
	input  wire				clk,
	input  wire 			rst,

	input  wire				enable,
	output reg	[5:0] 		parallelOut
);
	always @(posedge clk, posedge rst) begin
		if (rst)
			parallelOut	<=	6'b000001;
		else if (enable)
			parallelOut <= {parallelOut[ 4:0], parallelOut[5]};
	end	
	
endmodule