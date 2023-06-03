module reg_control(
  input RegDst, MemtoReg, MemWrite, Branch,
  input [8:0] mach_code,
  output logic[7:0] inA, inB, inC, write_adr, immediate
);

always_comb begin
	 inA = 0;
	 inB = 0;
	 immediate = 0;
     inC = mach_code[1:0];
     write_adr = mach_code[5:4];
    if(!RegDst) begin
        inA = mach_code[1:0];       // Doesnt matter the value
        inB = mach_code[5:4];
        immediate = mach_code[3:0];
    end
    else if(MemtoReg || MemWrite || Branch) begin
        inA = mach_code[3:2];
        inB = mach_code[5:4];
    end
    else begin
        inA = mach_code[1:0];
        inB = mach_code[3:2];
        immediate = mach_code[1:0];
    end

end
endmodule

  // Same logic as
  
  //assign rd_addrA = mach_code[1:0];
  //assign immediate = RegDst ? rd_addrA : mach_code[3:0]; // 4 bit or 2 it immediate
  //assign addrA = MemtoReg ? mach_code[3:2] : rd_addrA;  // Handles loads
  //assign str_addrA = MemWrite ? mach_code[3:2] : addrA;  // Handles stores
  //assign inA = Branch ? mach_code[3:2] : str_addrA;   // Handles branching
  
  //assign rd_addrB = mach_code[3:2];
  //assign AddrB = RegDst ? rd_addrB : mach_code[5:4]; // 4 bit or 2 it immediate
  //assign addrB = MemtoReg ? mach_code[5:4] : AddrB;  // Handles loads
  //assign str_addrB = MemWrite ? mach_code[5:4] : addrB;  // Handles stores
  //assign inB = Branch ? mach_code[5:4] : str_addrB;   // Handles branching