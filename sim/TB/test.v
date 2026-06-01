`timescale 1ns/1ns
module tb;
    reg clk;
    reg rst;
	reg MEI;
	reg MSI;

   	SOC riscV(
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
		#200_000;
		$stop;
		#200_000;
		$stop;
		#800_000;
		$stop;
    end
	always @(posedge clk) begin
		//if (riscV.RiscV.RegFile.registers[28] == 73) begin
			//$display("its %d", riscV.RiscV.RegFile.registers[28]);
			//@(posedge clk);
			//$display("\n%d", clkCount/2);
			//$stop;
		//end
		if (riscV.instructionMem.dataOut1 === 32'bx) begin
			$display("x data");
			$stop;
		end
	end
	`define UART_ADDR 32'h1000_0000
	always @(posedge clk) begin
		if (riscV.MemoryWriteRequest && riscV.MemoryAddress == `UART_ADDR) begin
            //$display("[UART WRITE] Time: %0t ns, Data: 0x%h (ASCII: %c)", $time,riscV.MemoryWriteData,riscV.MemoryWriteData);
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