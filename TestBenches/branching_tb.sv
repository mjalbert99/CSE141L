module testbench_1();

bit clk, reset;
wire done;
logic error[3];

top_level dut(
  .clk,
  .reset,
  .done);


always begin
  #5 clk = 1;
  #5 clk = 0;
end

initial begin

  #10 reset = 1;
  #10 reset = 0;
  #10 wait(done);
  #10 error[0] = (15) != dut.dm1.core[0];
  #10 error[1] = (4) != dut.dm1.core[1];
  #10 error[2] = (20) != dut.dm1.core[2];
  #10 $display(error[0],,,error[1],,,error[2]);
  $stop;
end    

endmodule