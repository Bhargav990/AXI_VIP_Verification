class base_test extends uvm_test;
	`uvm_component_utils(base_test)

	
	env_config env_cfg;
	master_config master_cfg[];
	slave_config slave_cfg[];

//	bit has_virtual_sequencer = 1;
	env envh;
//	virtual_seq virtual_seqh;
	
	int no_of_agents = 2;
	int no_of_master_agents = 1;
	int no_of_slave_agents = 1;
//	int has_vitual_sequencer = 1;

	
	function new (string name = "base_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void config_test();
		master_cfg = new[no_of_master_agents];
		slave_cfg = new[no_of_slave_agents]; 
		

		foreach(master_cfg[i])
			begin
				master_cfg[i] = master_config :: type_id :: create($sformatf("master_cfg[%0d]",i));
			
				//virtual_interface get 
			if(!uvm_config_db#(virtual axi_if)::get(this,"","axi_if",master_cfg[i].mif))
					begin
						`uvm_fatal(get_type_name(),"not able to get it ,Have you set it ?")
					end

	     			master_cfg[i].is_active = UVM_ACTIVE;

			end

		foreach(slave_cfg[i])
			begin
				slave_cfg[i] = slave_config :: type_id :: create($sformatf("slave_cfg[%0d]",i));
				//vitual_interface get
				if(!uvm_config_db#(virtual axi_if)::get(this,"","axi_if",slave_cfg[i].sif))
					begin
						`uvm_fatal(get_type_name(),"Have you set it properly")
					end


				slave_cfg[i].is_active = UVM_ACTIVE;

			end
		env_cfg.master_cfg = master_cfg;
		env_cfg.slave_cfg = slave_cfg;
		env_cfg.no_of_agents = no_of_agents;
		env_cfg.no_of_master_agents = no_of_master_agents;
		env_cfg.no_of_slave_agents = no_of_slave_agents;
	//	env_cfg.has_virtual_sequencer = has_virtual_sequencer;


	endfunction 

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		env_cfg =env_config :: type_id :: create("env_cfg");
	
		config_test();
		
		uvm_config_db#(env_config) ::set(this ,"*","env_config",env_cfg);
		
		envh = env :: type_id :: create("envh",this);
	
	//	virtual_seqh = virtual_seq :: type_id :: create("virtual_seqh ",this);

	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);

		uvm_top.print_topology();
	endfunction

endclass

	
class fixed_test extends base_test;
	`uvm_component_utils(fixed_test)

	fixed_seqs fixed_h;	

	function new(string name = "fixed_test",uvm_component parent);
		super.new(name ,parent);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
			
		phase.raise_objection(this);
		fixed_h = fixed_seqs :: type_id :: create("fixed_h");
		fixed_h.start(envh.mtop.master_agt[0].master_seqrh);
		#1000;
		phase.drop_objection(this);
	endtask 

endclass



////////////////////////////////////////////////////////////////////////
//Incr type test

class incr_test extends base_test;
	`uvm_component_utils(incr_test)

	inc_seqs incr_h;

	function new (string name = "incr_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		
		phase.raise_objection(this);
		incr_h = inc_seqs :: type_id :: create("incr_h");
		incr_h.start(envh.mtop.master_agt[0].master_seqrh);
		#1000;
		phase.drop_objection (this);
	endtask 

endclass

////////////////////////////////////////////////////////////////////
//wrapping type test

class wrap_test extends base_test;
	`uvm_component_utils(wrap_test)
	
	wrap_seqs wrap_h;

	function new (string name = "wrap_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		
		phase.raise_objection(this);
		wrap_h = wrap_seqs :: type_id :: create("wrap_h");
		wrap_h.start(envh.mtop.master_agt[0].master_seqrh);
		#1000;
		phase.drop_objection (this);
	endtask 

endclass


/////////////////////////////////////////////////////////////////////////
//random test all run

class random_test extends base_test;
	`uvm_component_utils(random_test)

	master_seq_random rand_h;

	function new(string name = "random_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
	

		phase.raise_objection(this);
		rand_h = master_seq_random :: type_id :: create("rand_h");
		rand_h.start(envh.mtop.master_agt[0].master_seqrh);
		#1000;
		phase.drop_objection(this);
	endtask

endclass




