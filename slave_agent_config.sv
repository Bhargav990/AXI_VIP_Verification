class slave_config extends uvm_object;
	`uvm_object_utils(slave_config)


	function new(string name = "slave_config");
		super.new(name);
	endfunction 

	uvm_active_passive_enum is_active ;
	virtual axi_if sif;

endclass