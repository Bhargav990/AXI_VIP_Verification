class slave_agent_top extends uvm_env;
	`uvm_component_utils(slave_agent_top)

	
	slave_agent slave_agt[];
	env_config env_cfg;


	function new(string name =  "slave_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction


	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(env_config)::get(this,"","env_config",env_cfg))
			begin
				`uvm_fatal(get_type_name(),"Did you set it properly?")
			end

		slave_agt = new[env_cfg.no_of_slave_agents];
	
		foreach(slave_agt[i])
			begin
				slave_agt[i] = slave_agent :: type_id :: create($sformatf("slave_agt[%0d]",i),this);
		
				uvm_config_db#(slave_config)::set(this,$sformatf("slave_agt[%0d]*",i),"slave_config",env_cfg.slave_cfg[i]);
			end
		endfunction
	endclass

	
