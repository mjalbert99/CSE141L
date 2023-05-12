// sample top level design
module top_level(
  input        clk, reset, //req, 
  output logic done);
  parameter D = 12,             // program counter width
    A = 3;             		  // ALU command bit width
	
  wire[D-1:0] target, 			  // jump 
              prog_ctr;
  wire[7:0]   datA,datB,		  // from RegFile
              muxB, 
			     rslt,               // alu output
              immed;
  //logic sc_in,   				  // shift/carry out from/to ALU
  // 		pariQ,              	  // registered parity flag from ALU
  //	zeroQ;                    // registered zero flag from ALU 
  //wire  relj;                     // from control to PC; relative jump enable
  
  // Control Outputs
  wire    RegDst, 	       
		  Branch, 			  
		  MemWrite, 		  
		  ALUSrc, 			  
		  RegWrite, 		  
		  MemtoReg;
  
		  //pari,
          //zero,
		  //sc_clr,
		  //sc_en,
 		  
  wire[A-1:0]	ALUOp;	
  //wire[A-1:0] alu_cmd;		  // Might not be necessary since ALUOp from Control~~~~~~~~
  
  wire[8:0]   mach_code;          // machine code
  wire[2:0]   rd_addrA, rd_adrB; // address pointers to reg_file

  // fetch subassembly
  PC #(.D(D)) 					  // D sets program counter width
     pc1 (.reset            ,
         .clk               ,
		 //.reljump_en (relj),
		 .absjump_en (Branch),
		 .target	         , 
		 .prog_ctr          
		 );
		 
	
  // lookup table to facilitate jumps/branches
  PC_LUT #(.D(D))
    pl1 (
		.addr  (rslt), 				// DOUBLE CHECK~~~~~~~~
		.branch (Branch),
        .target          
		);	 


  // contains machine code
  instr_ROM ir1(
				.prog_ctr,
                .mach_code
				);


  // control decoder
  Control ctl1(
			.instr(mach_code),   // Connect instruction UNSURE~~~~~~~~~
			.RegDst   , 
			.Branch   , 
			.MemWrite , 
			.ALUSrc   , 
			.RegWrite ,     
			.MemtoReg ,
			.ALUOp     
			);
			
			
  assign rd_addrA = mach_code[2:0];
  assign rd_addrB = mach_code[5:3];
  //assign alu_cmd  = mach_code[8:6]; // Might not be necessary since ALUOp from Control~~~~~~~~

  reg_file #(.pw(3)) rf1(.dat_in(rd_addrB),	   // loads, most ops DOUBLE CHECK Entire Module~~~~~~~
              .clk         ,
              .wr_en   (RegWrite),
              .rd_addrA(rd_addrA),
              .rd_addrB(rd_addrB),
              .wr_addr (rd_addrA),      // in place operation
              .datA_out(datA),
              .datB_out(datB)); 

  assign muxB = ALUSrc? immed : datB;		// Adds option for immediate values or double register values
  alu alu1(
		 .alu_cmd(ALUOp),
         .inA    (datA),
		 .inB    (muxB),
		 .rslt
		 //.sc_i   (sc),   // output from sc register
		 //.sc_o   (sc_o), // input to sc register
		 //.pari  
		 );

		  
  dat_mem dm1(.dat_in(datB)  ,  // from reg_file DOUBLE CHECK~~~~~~~~
             .clk           ,
			 .wr_en  (MemWrite), // stores
			 .addr   (datA),
          .dat_out()				// ADD CODE HERE  datB breaks it ~~~~~~~~~~~~
			 );		  


// registered flags from ALU
//  always_ff @(posedge clk) begin
//    pariQ <= pari;
//	zeroQ <= zero;
//    if(sc_clr)
//	  sc_in <= 'b0;
//    else if(sc_en)
//      sc_in <= sc_o;
//  end

  assign done = prog_ctr == 128;
 
endmodule