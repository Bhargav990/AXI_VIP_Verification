class master_seqs extends uvm_sequence#(axi_xtn);
	`uvm_object_utils(master_seqs)
	
	function new(string name = "master_seqs");
		super.new(name);
	endfunction

	
endclass

//Fixed type of burst 
class fixed_seqs extends master_seqs;
	`uvm_object_utils(fixed_seqs)
		
	function new(string name = "fixed_seqs");
		super.new(name);
	endfunction


	task body();
		repeat(5)
		begin	
			req = axi_xtn :: type_id :: create("req");
			start_item(req);
			assert(req.randomize() with {AWBURST==0;ARBURST == 0;});
			finish_item(req);
		end
		#1000;
	endtask : body

endclass

//increment type of burst
class inc_seqs extends master_seqs;
	`uvm_object_utils(inc_seqs)
		
	function new(string name = "inc_seqs");
		super.new(name);
	endfunction


	task body();
		repeat(5)

		begin	
			req = axi_xtn :: type_id :: create("req");
			start_item(req);
			assert(req.randomize() with {AWBURST== 1;ARBURST ==1;});
			finish_item(req);
		end
	#1000;
	endtask : body

endclass

//wrap type of burst 
class wrap_seqs extends master_seqs;
	`uvm_object_utils(wrap_seqs)
		
	function new(string name = "wrap_seqs");
		super.new(name);
	endfunction


	task body();
		repeat(5)
		begin	
			req = axi_xtn :: type_id :: create("req");
			start_item(req);
			assert(req.randomize() with {AWBURST == 2; ARBURST == 2;});
			finish_item(req);
		end
		#1000;
	endtask : body

endclass

//random sequence
class master_seq_random extends master_seqs;
	`uvm_object_utils(master_seq_random)
	
	function new(string name = "master_seq_random");
		super.new(name);
	endfunction
	
	task body();
		repeat(5)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
		
		repeat(5)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {AWBURST == 0; ARBURST == 0;});
			finish_item(req);
		end
		
		repeat(5)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {AWBURST == 1; ARBURST == 1;});
			finish_item(req);
		end
		
		repeat(5)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {AWBURST == 2; ARBURST == 2;});
			finish_item(req);
		end

		repeat(5)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {AWBURST == 0; ARBURST == 0; AWLEN == 2;AWSIZE == 0;});
			finish_item(req);
		end

		repeat(5)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {AWBURST == 0; ARBURST == 0; AWLEN == 2;AWSIZE == 1;});
			finish_item(req);
		end

		#1000;
	endtask 
endclass


