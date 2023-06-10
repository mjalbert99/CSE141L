module PC_LUT #(parameter D=10, A = 8)(
  input        [A-1:0] addr,	   		// target 4 values
  input 			branch,
  output logic[D-1:0] target);

  // Added cases for 
  always_comb begin
	if(branch) begin
		case(addr)
			0: target = 0;   		// Program 2 Loop
			1: target = 3;   		
			2: target = 11;
			3: target = 12;
			4: target = 47;
			5: target = 86;
			6: target = 89;
			7: target = 99;
			8: target = 100;
			9: target = 138;
			10: target = 153;
			11: target = 178;
			12: target = 189;
			13: target = 231;
			14: target = 281;
			15: target = 323;
			default: target = 'b0;  // hold PC  
		endcase
	end
	else begin
		target = 'b0;
	end
  end

endmodule

