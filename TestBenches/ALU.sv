// sample top level design
module top_level(
  input        clk, reset,  
  output logic done);
  logic[7:0]  inA, inB, inC, rslt;
  logic [2:0] OP;

  logic DM_write;
  logic [7:0] reg_file[5];

   alu alu1(
     .alu_cmd(OP),
     .inA    (inA),
     .inB    (inB),
     .inC    (inC),
     .rslt   (rslt)    
		 );


  initial begin
    	done = 0;
        DM_write = 0;
        OP = 3'b000;
        inA = 0;
        inB = 0;
        inC = 0;

	wait(!reset);
	@(posedge clk) OP = 3'b000;
	@(posedge clk) inA = 0;
	@(posedge clk)inB = 0;
	@(posedge clk) inC = 0;

    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    
    @(posedge clk) begin            // ADD  1
                    OP = 3'b001;
                    inA = 1;
		    
                   end
    @(posedge clk) begin 
			inB = rslt;
			reg_file[0] = rslt;
		   end    

    @(posedge clk) begin            // LS   8
                    OP = 3'b100;
                    inA = 3;
                   end   
    @(posedge clk) begin 
			inB = rslt;
			reg_file[1] = rslt;
		   end

    @(posedge clk) begin            // RS  4
                    OP = 3'b101;
                    inA = 1;
                   end 
    @(posedge clk) begin 
			inB = rslt;
			reg_file[2] = rslt;
		   end


    @(posedge clk) begin         // AND  0
                    OP = 3'b000;
                    inA = 128;
                   end                    
    @(posedge clk) begin 
			inB = rslt;
			reg_file[3] = rslt;
		   end

    @(posedge clk) begin        // XOR
                    OP = 3'b010;
                    inA = 255;
                    inB = 170; 
                   end                    
    @(posedge clk) begin 
			inB = rslt;
			reg_file[4] = rslt;
		   end

	@(posedge clk) done = 1;
  end

 
endmodule