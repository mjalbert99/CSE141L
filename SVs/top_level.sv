// sample top level design
module top_level(
  input        clk, reset, //req, 
  output logic done);
  parameter D = 10,             // program counter width
    A = 3;             		  // ALU command bit width
	
  wire[D-1:0] target, 			  // jump 
              prog_ctr;
  wire[7:0]   datA,datB,		  // from RegFile
              muxB, 
			  rslt,               // alu output
              immed,
			  regWriteData,
			regDataIn;
				  
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
		  MemtoReg,
      Add;
  
		  //pari,
          //zero,
		  //sc_clr,
		  //sc_en,
 		  
  wire[A-1:0]	ALUOp;	
  
  wire[8:0]   mach_code;          // machine code
  wire[2:0]   rd_addrA, rd_adrB; // address pointers to reg_file

  // fetch subassembly
  PC #(.D(D)) 					  // D sets program counter width
     pc1 (.reset            ,
         .clk               ,
		 .absjump_en (Branch),
		 .target	         , 
		 .prog_ctr          
		 );
		 
	
  // lookup table to facilitate jumps/branches
  PC_LUT #(.D(D))
    pl1 (
		.addr  (rslt), 	
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
			.instr(mach_code),
			.RegDst   , 
			.Branch   , 
			.MemWrite , 
			.ALUSrc   , 
			.RegWrite ,     
			.MemtoReg ,
      .Add,
			.ALUOp     
			);
			
			
  assign rd_addrA = mach_code[1:0];
  assign rd_addrB = mach_code[3:2];
  assign AddrA = RegDst ? rd_addrA : mach_code[3:0]; // 4 bit or 2 it immediate
  assign AddrB = RegDst ? rd_addrB : mach_code[5:4];

  assign inA = Branch ? mach_code[3:2] : AddrA;   // Handles branching
  assign inB = Branch ? mach_code[5:4] : AddrB;   // Handles branching

  assign wr_addr = mach_code[5:4];

  reg_file #(.pw(3)) rf1(.dat_in(regDataIn),	   // loads, most ops DOUBLE CHECK Entire Module~~~~~~~
              .clk         ,
              .wr_en   (RegWrite),
              .rd_addrA(inA),
              .rd_addrB(inB),
              .wr_addr (wr_addr),      // in place operation
              .datA_out(datA),
              .datB_out(datB)
				  ); 

  assign muxA = ALUSrc? AddrA : datA;		// Adds option for immediate values or double register values

  alu alu1(
		 .alu_cmd(ALUOp),
     .inA    (muxA),
		 .inB    (datB),
		 .rslt
		 //.sc_i   (sc),   // output from sc register
		 //.sc_o   (sc_o), // input to sc register
		 //.pari  
		 );

		  
  dat_mem dm1(
           .dat_in(datB)  ,  // from reg_file DOUBLE CHECK~~~~~~~~
           .clk           ,
			     .wr_en  (MemWrite), // stores
			     .addr   (rslt),
          .dat_out(regWriteData)				// ADD CODE HERE  datB breaks it ~~~~~~~~~~~~
			 );		  

assign regDataIn = ALUSrc ? rslt : regWriteData; 

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