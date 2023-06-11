// 8-bit wide, 256-word (byte) deep memory array
module dat_mem (
  input[7:0] dat_in,
  input      clk,
  input      wr_en,	          // write enable
  input 	 rd_en,			  // read enable
  input[7:0] addr,		      // address pointer inA + inB
  output logic[7:0] dat_out);

  logic[7:0] core[256];       // 2-dim array  8 wide  256 deep
  initial							    // load initial memory values 
    $readmemb("prog3-memory.txt",core);

// reads are combinational; no enable or clock required

	assign dat_out = core[addr];

// writes are sequential (clocked) -- occur on stores or pushes 
  always_ff @(posedge clk)
    if(wr_en) begin			  // wr_en usually = 0; = 1 		
//		$display("Writing %D to memory %D\n", dat_in, addr); 
      core[addr] <= dat_in; 
	end 
	
//	always @*
//    $display("Value read from memory is %D", dat_out); 
endmodule