class slave_seqs extends uvm_sequence;
	`uvm_object_utils(slave_seqs)
	
	function new(string name = "slave_seqs");
		super.new(name);
	endfunction

/*	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction*/
	
endclass
