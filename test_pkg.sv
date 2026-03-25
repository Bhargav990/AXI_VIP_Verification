package test_pkg;

	`include "uvm_macros.svh"
	import uvm_pkg::*;


		
		`include "master_agent_config.sv"
		`include "slave_agent_config.sv"
		`include "env_config.sv"

		`include "axi_trans.sv"
		`include "master_driver.sv"
		`include "master_monitor.sv"
		`include "master_seqr.sv"
		`include "master_agent.sv"
		`include "master_agent_top.sv"
		
		`include "master_seqs.sv"



	//	`include "slave_trans.sv"
		`include "slave_driver.sv"
		`include "slave_monitor.sv"
		`include "slave_seqr.sv"
		`include "slave_agent.sv"
		`include "slave_agent_top.sv"

		`include "slave_seqs.sv"
		
		

		`include "scoreboard.sv"
	//	`include "virtual_sequencer.sv"	

		`include "env.sv"
	//	`include "virtual_seq.sv"
	
		`include "test.sv"


endpackage



		

