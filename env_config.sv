class env_config extends uvm_object;
	`uvm_object_utils(env_config)


	function new(string name = "env_config");
		super.new(name);
	endfunction


	master_config master_cfg[];
	slave_config slave_cfg[];

	int no_of_agents;
	int no_of_master_agents;
	int no_of_slave_agents;

//	bit has_virtual_sequencer;

endclass
