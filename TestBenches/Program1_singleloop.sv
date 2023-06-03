// CSE141L  Winter 2023
// test bench for programs 1
// flip probabilities:
// 75% one error bit
//    condition: flip2[5:4] != 2'b00;
// 25 * (255/256)%  two error bits
//    condition: flip2[5:4] == 2'b00 && flip2[3:0] != flip;
// 25 * (1/256)% no errors (flip2[5:4] == 2'b00 && flip2[3:0] == flip)
//    
module test_bench();

bit   clk    ,                   // clock source -- drives DUT input of same name
	  reset  ;	                 // req -- start program -- drives DUT input
wire  done;		    	         // ack -- from DUT -- done w/ program

// program 1-specific variables
bit  [3:0] score1;

// your device goes here
// change "top_level" if you called your device something different
// explicitly list ports if your names differ from test bench's
// if you used any parameters, override them here
top_level DUT(.clk, .reset, .done);            // replace "proc" with the name of your top level module

initial begin

    DUT.dm1.core[1]  = 8'b00000101;  //5       // p8 = 0, p4 = 1, p2 = 0, p1 = 1, p0 = 0
    DUT.dm1.core[0]    =  8'b01010101; //85
    for(int i = 0; i < 4; i++) begin
	DUT.rf1.core[i] = 0;
	end
  #10ns reset   = 1'b1;          // pulse request to DUT
  #10ns reset   = 1'b0;
  wait(done);                   // wait for ack from DUT
// generate parity for each message; display result and that of DUT
  $display("start program 1");
  $display();

  if(DUT.dm1.core[65] != 0) score1++;
  $display("program 1 score = %d out of %d",score1, 1);
  #10ns $stop;
end

always begin
  #5ns clk = 1;            // tic
  #5ns clk = 0;			   // toc
end										

endmodule
										   