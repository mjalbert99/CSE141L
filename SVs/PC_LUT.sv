module PC_LUT #(parameter D=12, A = 8)(
  input        [A-1:0] addr,	   		// target 4 values
  input 			branch,
  output logic[D-1:0] target);

  // Added cases for 
  always_comb begin
	if(branch) begin
		case(addr)
			0: target = -5;   		// go back 5 spaces
			1: target = 20;   		// go ahead 20 spaces
			2: target = '1;   		// go back 1 space   1111_1111_1111
			default: target = 'b0;  // hold PC  
		endcase
	end
	else begin
		target = 'b0;
	end
  end

endmodule

