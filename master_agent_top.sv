class master_agent_top extends uvm_env;
	`uvm_component_utils(master_agent_top)

	
	master_agent master_agt[];
	env_config env_cfg;


	function new(string name =  "master_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction


	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(env_config)::get(this,"","env_config",env_cfg))
			begin
				`uvm_fatal(get_type_name(),"Did you set it properly?")
			end

		master_agt = new[env_cfg.no_of_master_agents];
	
		foreach(master_agt[i])
			begin
				master_agt[i] = master_agent :: type_id :: create($sformatf("master_agt[%0d]",i),this);
		
				uvm_config_db#(master_config)::set(this,$sformatf("master_agt[%0d]*",i),"master_config",env_cfg.master_cfg[i]);
			end
		endfunction

	endclass

