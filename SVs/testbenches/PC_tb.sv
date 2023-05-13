////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:12:37 10/27/2011
// Design Name:   ALU
// Module Name:   /department/home/leporter/Xilinx/lab_basics/PC_tb.v
// Project Name:  lab_basics
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PC
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
//import definitions::*;
module PC_tb;

// Inputs
  reg reset, jump;
  reg clk = 0;
  reg[9:0] tar;

// Outputs
  reg [9:0] ctr = 0;

	// Instantiate the Unit Under Test (UUT)
  PC pc1(
  .reset(reset),
  .clk(clk),
  .absjump_en(jump),
  .target(tar),
  .prog_ctr(ctr)	
);

always #1000 clk = ~clk;
initial begin
// Wait 100 ns for global reset to finish
  #20ns;
  tar = 0;
  jump = 0;
  reset = 1;
  #20ns;
  reset = 0;
   
  #50ns;
  reset = 1;

  #20ns;
  reset = 0;
  jump = 1;
  tar = 8;

  #20ns;
  jump = 0;
  tar = 100;

  #20ns;
 
$stop;
end

endmodule

