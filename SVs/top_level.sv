// sample top level design
module top_level(
  input        clk, reset,
  output logic done);
  parameter D = 10,             // program counter width
    A = 3;             		  // ALU command bit width
	
  wire[D-1:0] target, 			  // jump 
              prog_ctr;
  wire[7:0]   datA,datB,datLoop,		  // from RegFile
              muxB, 
              rslt,               // alu output
              immed,
              regWriteData,
              regDataIn;
				  
  //logic sc_in,   				  // shift/carry out from/to ALU
  // 		pariQ,              	  // registered parity flag from ALU
  //	zeroQ;                    // registered zero flag from ALU 
  // Control Outputs
  wire  RegDst, 	       
        Branch, 			  
        MemWrite, 		  
        ALUSrc, 			  
        RegWrite, 		  
        MemtoReg,
        Add,
        branch_pc;
  
		  //pari,
      //zero,
		  //sc_clr,
		  //sc_en,
 		  
  wire[A-1:0]	ALUOp;	
  
  wire[8:0]   mach_code;          // machine code
  wire[2:0]   rd_addrA, rd_adrB; // address pointers to reg_file

  // fetch subassembly
  PC #(.D(D)) 					  // D sets program counter width
     pc1 (
     .reset            ,
     .clk               ,
		 .absjump_en (branch_pc),
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
			.ALUOp     
			);
			
			
  assign rd_addrA = mach_code[1:0];
  assign immediate = RegDst ? rd_addrA : mach_code[3:0]; // 4 bit or 2 it immediate
  assign addrA = MemtoReg ? mach_code[3:2] : rd_addrA;  // Handles loads
  assign str_addrA = MemWrite ? mach_code[3:2] : addrA;  // Handles stores
  assign inA = Branch ? mach_code[3:2] : str_addrA;   // Handles branching
  
  assign rd_addrB = mach_code[3:2];
  assign AddrB = RegDst ? rd_addrB : mach_code[5:4]; // 4 bit or 2 it immediate
  assign addrB = MemtoReg ? mach_code[5:4] : AddrB;  // Handles loads
  assign str_addrB = MemWrite ? mach_code[5:4] : addrB;  // Handles loads
  assign inB = Branch ? mach_code[5:4] : str_addrB;   // Handles branching

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

  assign muxA = ALUSrc? immediate : datA;		// Adds option for immediate values or double register values

  alu alu1(
		 .alu_cmd(ALUOp),
     .inA    (muxA),
		 .inB    (datB),
     .inC    (datLoop),   // provides reg for LUT index 
		 .rslt,
     .branch_pc
		 //.sc_i   (sc),   // output from sc register
		 //.sc_o   (sc_o), // input to sc register
		 //.pari  
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

// registered flags from ALU
//  always_ff @(posedge clk) begin
//    pariQ <= pari;
//	zeroQ <= zero;
//    if(sc_clr)
//	  sc_in <= 'b0;
//    else if(sc_en)
//      sc_in <= sc_o;
//  end

  assign done = prog_ctr == 381;
 
endmodule

/*
Added more muxes that handle machine bits for loads/stores and branching.
  - Fixed the mux logic for ADD, LS/RS, and BNE
Added a 3 reg input and output for reg_file 
  - this is solely used to get the 3rd register for branching
Redid formatting diagram for reg_file and top_level
Added branch_pc wire as an output to the ALU and an input to 
the PC. Acts as a bool to cause brnahcing to occur

*/