class master_seqr extends uvm_sequencer#(axi_xtn);
	`uvm_component_utils(master_seqr)

	master_config master_cfg;
	
	function new(string name = "master_seqr",uvm_component parent );
		super.new(name,parent);
	endfunction 

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(master_config)::get(this,"","master_config",master_cfg))
			`uvm_fatal(get_type_name(),"Did you set it?")

	endfunction 

endclass

