// combinational -- no clock
// sample -- change as desired
module alu(
  input[2:0] alu_cmd,    // ALU instructions
  input[7:0] inA, inB,	 // 8-bit wide data path
  output logic[7:0] rslt
);

always_comb begin 
  rslt = 'b0;

  case(alu_cmd)
	3'b000	: rslt = inA & inB;  						// AND
	3'b001	: rslt = inA + inB;							// ADD
	3'b010	: rslt = inA ^ inB; 						// XOR
	3'b011	: rslt = (inA != inB) ? 8'b1 : 8'b0;   		// BNE
	3'b100	: rslt = inA << inB;  						// LS
	3'b101	: rslt = inA >> inB;  						// RS
	3'b110	: rslt = inA + inB;  				    	// LW
	3'b111	: rslt = inA + inB;  			
	default	: rslt = 8'bx;  								// FALL THROUGH
															// x's so we know it fell through
  endcase
end
   
endmodule