module PC_LUT #(parameter D=10, A = 8)(
  input        [A-1:0] addr,	   		// target 4 values
  input 			branch,
  output logic[D-1:0] target);

  // Added cases for 
  always_comb begin
	if(branch) begin
		case(addr)
			0: target = 4;   		// Program 1 Loop  		
			default: target = 'b0;  // hold PC  
		endcase
	end
	else begin
		target = 'b0;
	end
  end

endmodule

