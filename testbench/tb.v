`timescale 1ns/1ns
module tb;
    reg clk;
    reg rst;
	reg MEI;
	reg MSI;

   	SOC soc(
		.clk(clk),
		.rst(rst),
		.MEI(MEI),
		.MSI(MSI)
	);

	integer clkCount = 0;
    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
			clkCount	=	clkCount +1;
        end
    end

    initial begin
        	rst = 1;
			MEI = 0;
	 		MSI = 0;
        #20 rst = 0; clkCount = 0;
		#400_000;
        $stop;
		#100_000_000;
		$stop;
    end
	always @(posedge clk) begin
		if (riscV.instructionMem.dataOut1 === 32'bx) begin
			$display("x data");
			$stop;
		end
	end
	`define UART_ADDR 32'h1000_0000
	always @(posedge clk) begin
		if (riscV.MemoryWriteRequest && riscV.MemoryAddress == `UART_ADDR) begin
            $write("%c",riscV.MemoryWriteData);
        
		end
	end
	`define SIMEND_ADDR 32'h2000_0000
	always @(posedge clk) begin
		if (riscV.MemoryWriteRequest && riscV.MemoryAddress == `SIMEND_ADDR) begin

            $write("\n Simulation Ended by Writing in End Address\n");
        	$stop;
		end
	end
		
endmodule