// combinational -- no clock
// sample -- change as desired
module alu(
  input[2:0] alu_cmd,    // ALU instructions
  input[7:0] inA, inB, inC,	 // 8-bit wide data path
  output logic[7:0] rslt,
  output logic branch_pc
);

always_comb begin 
  rslt = 'b0;
  branch_pc = 'b0;

  case(alu_cmd)
	3'b000	: rslt = inB & inA;  						// AND
	3'b001	: rslt = inB + inA;							// ADD
	3'b010	: rslt = inB ^ inA; 						// XOR
	3'b011	: begin 
			rslt = (inB != inA) ? inC : 8'b0;   				// BNE
			branch_pc = (inB != inA) ? 1'b1 : 1'b0;
		end
	3'b100	: rslt = inB << inA;  						// LS
	3'b101	: rslt = inB >> inA;  						// RS
	3'b110	: rslt = inA;  				    			// LW
	3'b111	: rslt = inA;  								// STR
	default	: rslt = 8'bx;  								// FALL THROUGH
															// x's so we know it fell through
  endcase
end
   
endmodule