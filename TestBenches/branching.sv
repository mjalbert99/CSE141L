// sample top level design
module top_level(
  input        clk, reset,  
  output logic done);
  logic[7:0]  inA, inB, inC, rslt;
  logic [2:0] OP;

  logic Branch, branch_pc;
  logic[9:0]  target;
  logic[9:0] prog_ctr;

  logic DM_write;
  logic[7:0]  DM_dat_in, DM_addr, DM_dat_out;

   alu alu1(
     .alu_cmd(OP),
     .inA    (inA),
     .inB    (inB),
     .inC    (inC),
     .rslt   (rslt),
     .branch_pc (branch_pc)    
		 );

     PC #(.D(10))
          pc1 (
                .reset            ,
                .clk               ,
		.absjump_en (branch_pc),
		.target	         , 
		.prog_ctr          
	   );

  // lookup table to facilitate jumps/branches
  PC_LUT #(.D(10))
           pl1 (
		.addr  (rslt), 	
		.branch (Branch),
                .target          
		);	
		 

  dat_mem dm1(
	     .dat_in(DM_dat_in)  ,  // from reg_file
             .clk           ,
	     .wr_en  (DM_write), // stores
	     .addr   (DM_addr),
             .dat_out(DM_dat_out)
	      );


  initial begin
    	done = 0;
	Branch = 0;
	DM_write = 0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	
	wait(!reset);
	@(posedge clk) begin		// Wont branch
				inB = 3;
				inA = 3;
				inC = 0;
				OP = 3'b011;
				Branch = 1;
			end
	@(posedge clk);
	@(posedge clk) begin
			Branch = 0;
			DM_addr = 0;
			DM_dat_in = prog_ctr;
			DM_write = 1;
			end

	@(posedge clk) DM_write = 0;
	@(posedge clk);
	@(posedge clk);

	@(posedge clk) begin		// Will branch
				inB = 2;
				inA = 3;
				inC = 0;
				OP = 3'b011;
				Branch = 1;
			end
 	@(posedge clk);
	@(posedge clk) begin
			Branch = 0;
			DM_addr = 1;
			DM_dat_in = prog_ctr;
			DM_write = 1;
			end
	@(posedge clk);
	@(posedge clk);

	@(posedge clk) begin		// Will branch
				inB = 2;
				inA = 3;
				inC = 1;
				OP = 3'b011;
				Branch = 1;
			end
	@(posedge clk);
	@(posedge clk)  begin
			Branch = 0;
			DM_addr = 2;
			DM_dat_in = prog_ctr;
			DM_write = 1;
			end

	@(posedge clk) done = 1;
  end

 
endmodule