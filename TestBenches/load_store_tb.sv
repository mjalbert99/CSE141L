module testbench_1();

bit clk, reset;
wire done;
logic error[2];

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
  #10 error[0] = (46) != dut.dm1.core[4];
  #10 error[1] = (32) != dut.reg_file[0];
  #10 $display(error[0],,,error[1]);
  $stop;
end    

endmodule