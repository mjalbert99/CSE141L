module PC_LUT #(parameter D=10, A = 8)(
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
			3: target  = 0;
			4:target = 0;
			5:target = 0;
			6:target = 0;
			7:target = 0;
			8:target = 0;
			9:target = 0;
			10:target  = 0;
			11:target  = 0;
			12:target  = 0;
			13:target  = 0;
			14:target  = 0;
			15:target  = 0;
			16:target  = 0;
			17:target  = 0;
			18:target  = 0;
			19:target  = 0;
			20:target  = 0;
			default: target = 'b0;  // hold PC  
		endcase
	end
	else begin
		target = 'b0;
	end
  end

endmodule

