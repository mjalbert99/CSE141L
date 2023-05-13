////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:12:37 10/27/2011
// Design Name:   ALU
// Module Name:   /department/home/leporter/Xilinx/lab_basics/ALU_tb.v
// Project Name:  lab_basics
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ALU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
//import definitions::*;
module ALU_tb;
reg [7:0] mem [0:255];
// Inputs
  reg [2:0] ALUOp;
  reg [7:0] datA;
  reg [7:0] datB;

// Outputs
  wire [7:0] rslt;

	// Instantiate the Unit Under Test (UUT)
  alu alu1(
		 .alu_cmd(ALUOp),
       		  .inA    (datA),
		 .inB    (datB),
		 .rslt	  (rslt)
		 );

initial begin
// Wait 100 ns for global reset to finish
  #100ns;
        
// Add stimulus here
 datA = 8'h0;
 datB = 8'b0;
 #20ns;
 ALUOp = 3'b001;
 #20ns;
 datA = 8'h1;
 #100ns;

 datA = 8'h0;
 datB = 8'b01010101;
 #20ns;
 ALUOp = 3'b000;
 #20ns;
 datA = 8'b00000001;
 #100ns;


 datA = 8'h0;
 datB = 8'b01010101;
 #20ns;
 ALUOp = 3'b010;
 #20ns;
 datA = 8'b10101010;
 #100ns;


 datB = 8'h1;
 datA = 8'h0;
 #20ns;
 ALUOp = 3'b100;
 #20ns;
 datA = 8'h3;
 #100ns;


 datB = 8'h8;
 datA = 8'h0;
 #20ns;
 ALUOp = 3'b101;
 #20ns;
 datA = 8'h3;
 #100ns;


 datB = 8'h5;
 datA = 8'h3;
 #20ns;
 ALUOp = 3'b110;
 #20ns;
 mem[rslt] = datB;
 $display("mem[%d] = %h", rslt, mem[rslt]);
 #100ns;

 datB = 8'h0;
 datA = 8'h0;
 #20ns;
 ALUOp = 3'b111;
 #20ns;
 datA = 8'h8;
  #20ns;
  datB = mem[rslt];
 #100ns;

 

end

endmodule

