module top();

	`include "uvm_macros.svh"
	import test_pkg::*;


	import uvm_pkg::*;
		
	bit ACLK;
	
	
	
	axi_if in0(ACLK);

	initial
		begin
			ACLK = 0;
		end
	always #5 ACLK =~ ACLK;

	initial
		begin
			`ifdef VCS
			$fsdbDumpvars(0,top);
			`endif
			uvm_config_db#(virtual axi_if)::set(null,"*","axi_if",in0);
			//uvm_config_db#(virtual axi_if) ::set(null,"*","axi_if",sif);

		
	

			run_test();
		end 
endmodule