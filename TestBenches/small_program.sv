// sample top level design
module top_level(
  input        clk, reset,  
  output logic done);
  logic[7:0]  inA, inB, datA, datB, datLoop, immediate, wr_addr, regDataIn, rslt, regWriteData;
  logic [2:0] ALUOp;
  logic [8:0] mach_code;
  logic [9:0] prog_ctr;
  logic [7:0] muxA;

  logic RegDst, Branch, MemWrite, ALUSrc, RegWrite, MemtoReg;


  instr_ROM ir1(
	.prog_ctr,
        .mach_code
	);


  Control ctl1(
			.instr(mach_code),
			.RegDst   , 
			.Branch   , 
			.MemWrite , 
			.ALUSrc   , 
			.RegWrite ,     
			.MemtoReg ,
			.ALUOp     
			);

   reg_control rg1(
      .RegDst     ,
      .MemtoReg   ,
      .MemWrite   ,
      .Branch     ,
      .mach_code  ,
      .inA        ,
      .inB        ,
      .immediate  
    );

  assign wr_addr = mach_code[5:4];


  reg_file #(.pw(3)) rf1(
              .dat_in(regDataIn),	   // loads, most ops 
              .clk         ,
              .wr_en   (RegWrite),
              .rd_addrA(inA),
              .rd_addrB(inB),
              .rd_addrC(mach_code[1:0]),    // reg that holds loop index
              .wr_addr (wr_addr),           // in place operation
              .datA_out(datA),
              .datB_out(datB),
              .datC_out(datLoop)
				  ); 

assign muxA = ALUSrc? immediate : datA;

   alu alu1(
     .alu_cmd(ALUOp),
     .inA    (muxA),
     .inB    (datB),
     .inC    (datLoop),
     .rslt   (rslt)    
		 );


  dat_mem dm1(
           .dat_in(datB)  ,  // from reg_file
           .clk           ,
	   .wr_en  (MemWrite), // stores
           .rd_en (MemtoReg),
	   .addr   (rslt),
           .dat_out(regWriteData)				
			 );
assign regDataIn = MemtoReg ? regWriteData : rslt; 	

  initial begin
    	done = 0;
	mach_code = 0;
	prog_ctr = 0;
	for(int i = 0; i < 256; i++) begin
		dm1.core[i] = 0;
	end

	for(int i = 0; i < 2**2; i++) begin
		rf1.core[i] = 8'h0;
	end
	
	wait(!reset);
	@(posedge clk) begin
			mach_code = 9'b000000001;	// AND r0, r0, r1
			
		end
	@(posedge clk) begin
			mach_code = 9'b000000110;
			
	end
	@(posedge clk) begin
			mach_code = 9'b001000011;
			
	end
	@(posedge clk) begin
		mach_code = 9'b001011001;
		
	end
	@(posedge clk) begin
			mach_code = 9'b010000001;
			
	end
	@(posedge clk) begin
			mach_code = 9'b010100100;
			
	end	
	@(posedge clk) begin
			mach_code = 9'b011000110;
			
	end
	@(posedge clk) begin
			mach_code = 9'b101011000;
			
	end
	@(posedge clk) begin
		mach_code = 9'b100100001;
		
	end
	@(posedge clk) begin
			mach_code = 9'b111100100;
			
	end
	@(posedge clk) begin
			mach_code = 9'b110010100;
			
	end

	
	@(posedge clk) done = 1;
  end

 
endmodule