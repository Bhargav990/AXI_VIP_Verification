class master_config extends uvm_object;
	`uvm_object_utils(master_config)


	function new(string name = "master_config");
		super.new(name);
	endfunction 

	uvm_active_passive_enum is_active ;
	virtual axi_if mif;

endclass
