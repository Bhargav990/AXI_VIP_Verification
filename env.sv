class env extends uvm_env;
	`uvm_component_utils(env)

	master_agent_top mtop;
	slave_agent_top slvtop;
	scoreboard sb;
//	virtual_seqr virtual_seqrh;

	env_config env_cfg;

	function new(string name="env",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		sb= scoreboard ::type_id::create("sb",this);

		if(!uvm_config_db #(env_config)::get(this,"","env_config",env_cfg))
			`uvm_fatal(get_type_name,"Have you set the config?")

		if(env_cfg.no_of_master_agents !== 0)
			mtop = master_agent_top::type_id::create("mtop",this);

		if(env_cfg.no_of_slave_agents !== 0)
			slvtop = slave_agent_top::type_id::create("slvtop",this);

	/*	if(env_cfg.has_virtual_sequencer == 1)
			virtual_seqrh = virtual_seqr::type_id::create("virtual_seqrh",this);*/
	endfunction

	function void connect_phase(uvm_phase phase);
	/*	if(env_cfg.has_virtual_sequencer == 1)
			foreach(virtual_seqrh.master_seqrh[i])
				virtual_seqrh.master_seqrh[i] = mtop.master_agt[i].master_seqrh;

			foreach(virtual_seqrh.slave_seqrh[i])
				virtual_seqrh.slave_seqrh[i] = slvtop.slave_agt[i].slave_seqrh;*/
			
		foreach(mtop.master_agt[i])
			mtop.master_agt[i].master_monh.monitor_port.connect(sb.fifo_master[i].analysis_export);

		foreach(slvtop.slave_agt[i])
			slvtop.slave_agt[i].slave_monh.monitor_port.connect(sb.fifo_slave[i].analysis_export); 
	endfunction
endclass
