// cache memory/register file
// default address pointer width = 4, for 16 registers
module reg_file #(parameter pw=2)(
  input[7:0] 		dat_in,
  input      		clk,
  input      		wr_en,           		// write enable
  input[pw-1:0] 	wr_addr,	  		// write address pointer
					rd_addrA,		  		// read address pointers
					rd_addrB,
					rd_addrC,
  output logic[7:0] datA_out, 		// read data
                    datB_out,
					datC_out);

  logic[7:0] 		core[2**pw];    		// 2-dim array  8 wide  16 deep
  initial							    // load initial register values 
    $readmemb("registers.txt",core);
    
// reads are combinational
  assign datA_out = core[rd_addrA];
  assign datB_out = core[rd_addrB];
  assign datC_out = core[rd_addrC];

// writes are sequential (clocked)
  always_ff @(posedge clk)
    if(wr_en)				   		// anything but stores or no ops
      core[wr_addr] <= dat_in; 

endmodule
