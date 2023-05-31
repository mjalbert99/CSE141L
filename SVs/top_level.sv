// sample top level design
module top_level(
  input        clk, reset,
  output logic done);
  parameter D = 10,             // program counter width
    A = 3;             		  // ALU command bit width
	
  wire[D-1:0] target, 			  // jump 
              prog_ctr;
  wire[7:0]   datA, datB, datLoop,		  // from RegFile
              muxA, 
              rslt,               // alu output
              immed,
              regWriteData,
              regDataIn,
              immediate,
              inA,
              inB;

  // Control Outputs
  wire  RegDst, 	       
        Branch, 			  
        MemWrite, 		  
        ALUSrc, 			  
        RegWrite, 		  
        MemtoReg,
        Add,
        branch_pc;
 		  
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


  reg_file #(.pw(3)) rf1(
              .dat_in(regDataIn),	   // loads, most ops 
              .clk         ,
              .wr_en   (RegWrite),
              .rd_addrA(inA),
              .rd_addrB(inB),
              .rd_addrC(mach_code[1:0]),    // reg that holds loop index
              .wr_addr (mach_code[5:4]),           // in place operation
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
Made a new module to control the bits intot he reg file and immediate vlaues for operations called 
reg_control.
Updated units to have more than one bit with (caused errors in moddel sim)
*/