class slave_seqr extends uvm_sequencer #(axi_xtn);
	`uvm_component_utils(slave_seqr)

	slave_config slave_cfg;
	
	
	function new(string name = "slave_seqr",uvm_component parent );
		super.new(name,parent);
	endfunction 

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(slave_config)::get(this,"","slave_config",slave_cfg))
			`uvm_fatal(get_type_name(),"Did you set it?")

	endfunction 

endclass