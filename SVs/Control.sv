// control decoder
module Control #(parameter opwidth = 3, mcodebits = 9)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  output logic RegDst, Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite,
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations

always_comb begin
// defaults
  //logic[opwidth-1:0] op = instr[mcodebits-1:mcodebits-3];  // preserves the lower 6 bits of the machine code
  RegDst 	=   'b1;   // 1: not in place  just leave 0
  Branch 	=   'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  ALUOp	    =   'b111; // y = a+0;

case(instr[8:6])    // override defaults with exceptions
  3'b000: ALUOp 	  = 'b000;    				// and   

  3'b001: begin 								// add 
				ALUOp      = 'b001;
				ALUSrc 	  = 'b1;
		  end
  3'b010:  ALUOp 		= 'b010;  				// xor  
  3'b011:  begin				  				// bne
					ALUOp		  = 'b011; 
					Branch 		  = 'b1;    
					RegWrite 	  = 'b0;
			end
  3'b100:  begin				  				// ls
					ALUOp 		  = 'b100; 
					ALUSrc		  = 'b1;   
					RegDst 		  = 'b0; 
			end
  3'b101:  begin				  				// rs
					ALUOp 		  = 'b101; 
					ALUSrc		  = 'b1;  
					RegDst 		  = 'b0; 
			end
  3'b110:  begin				  				// load
					ALUOp 		  = 'b110; 
					MemtoReg 	  = 'b1;  
			end
  3'b111:  begin				  				// store
					ALUOp 		  = 'b111;
					RegWrite 	  = 'b0; 
					MemWrite 	  = 'b1; 
			end

  default: begin
				RegDst 	  = 'bx;  
				Branch 	  = 'bx;  
				MemWrite  =	'bx;  
				ALUSrc 	  =	'bx;  
				RegWrite  =	'bx;  
				MemtoReg  =	'bx;  
				ALUOp	  = 'bxxx;
			end
endcase

end
endmodule