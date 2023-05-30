module testbench_1();

bit clk, reset;
wire done;
logic error[5];

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
  #10 error[0] = (1) != dut.reg_file[0];
  #10 error[1] = (8) != dut.reg_file[1];
  #10 error[2] = (4) != dut.reg_file[2];
  #10 error[3] = (0) != dut.reg_file[3];
  #10 error[4] = (85) != dut.reg_file[4];
  #10 $display(error[0],,,error[1],,,error[2],,,error[3],,,error[4]);
  $stop;
end    

endmodule