// sample top level design
module top_level(
  input        clk, reset,  
  output logic done);
  logic[7:0]  inA, inB, inC, rslt;
  logic [2:0] OP;

  logic DM_write;
  logic[7:0]  DM_dat_in, DM_addr, DM_dat_out, reg_file[4];

   alu alu1(
     .alu_cmd(OP),
     .inA    (inA),
     .inB    (inA),
     .inC    (inC),
     .rslt   (rslt)    
		 );


  dat_mem dm1(
	     .dat_in(inB)  ,  // from reg_file
             .clk           ,
	     .wr_en  (DM_write), // stores
	     .addr   (rslt),
             .dat_out(DM_dat_out)
	      );

  initial begin
    	done = 0;
	DM_write = 0;
	
	
	wait(!reset);
	@(posedge clk) OP = 3'b000;
	@(posedge clk) inA = 0;
	@(posedge clk)inB = 0;
	@(posedge clk) inC = 0;

	@(posedge clk) OP = 3'b111; 
	@(posedge clk) inA = 10;
	@(posedge clk) inB = 32;
	@(posedge clk) inC = 0;

	@(posedge clk) DM_write = 1;

	@(posedge clk) OP = 3'b111;
	@(posedge clk) inA = 4;
	@(posedge clk) inB = 46;
	@(posedge clk) inC = 0;

	@(posedge clk) DM_write = 1;
    	@(posedge clk) DM_write = 0;

	@(posedge clk) OP = 3'b110;
	@(posedge clk) inA = 10;
	@(posedge clk)reg_file[0] <= DM_dat_out;
	@(posedge clk)inC = 0;
	
	@(posedge clk) done = 1;
  end

 
endmodule