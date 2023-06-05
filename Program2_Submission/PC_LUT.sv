module PC_LUT #(parameter D=10, A = 8)(
  input        [A-1:0] addr,	   		// target 4 values
  input 			branch,
  output logic[D-1:0] target);

  // Added cases for 
  always_comb begin
	if(branch) begin
		case(addr)
			0: target = 0;   		// Program 2 Loop
			1: target = 26;   		
			2: target = 89;
			3: target = 141;
			4: target = 159;
			5: target = 270;
			6: target = 298; 
			7: target = 304;
			8: target = 306;
			9: target = 356;
			10: target = 361;
			11: target = 375; 
			12: target = 381; 
			13: target = 385;
			default: target = 'b0;  // hold PC  
		endcase
	end
	else begin
		target = 'b0;
	end
  end

endmodule

