class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)


	uvm_tlm_analysis_fifo#(axi_xtn) fifo_master[];
	uvm_tlm_analysis_fifo#(axi_xtn) fifo_slave[];

	env_config env_cfg;
	axi_xtn m_data,s_data;
	axi_xtn wr_xtn,rd_xtn;


	
	
	covergroup write_cg;
		
		option.per_instance = 1;
		
		AWADDR_CP 	: coverpoint wr_xtn.AWADDR {
								bins awaddr_bin		= {[0:'hffff_ffff]};}
	
		AWBURST_CP 	: coverpoint wr_xtn.AWBURST {
								bins awburst_bin[] 	= {[0:2]};}

		AWSIZE_CP	: coverpoint wr_xtn.AWSIZE {				
								bins awsize_bin[]	= {[0:2]};}
		
		AWLEN_CP 	: coverpoint wr_xtn.AWLEN {	bins awlen_bin		= {[0:11]};}


		BRESP_CP 	: coverpoint wr_xtn.BRESP {	bins bresp_bins		= {0};}

		WRITE_ADDRESS_CROSS : cross AWBURST_CP,AWSIZE_CP,AWLEN_CP;

	endgroup : write_cg

	
	covergroup write_cg1 with function sample(int i);
		option.per_instance = 1;
		
		WSTRB_CP : coverpoint wr_xtn.WSTRB[i]{
			bins wstrb1 = {4'b1111};
			bins wstrb2 = {4'b1100};
			bins wstrb3 = {4'b0011};
			bins wstrb4 = {4'b1000};
			bins wstrb5 = {4'b0010};
			bins wstrb6 = {4'b0001};
			bins wstrb7 = {4'b1110};}
		endgroup : write_cg1



	covergroup read_cg;
		option.per_instance = 1;
		
		ARDDR_CP 	: coverpoint rd_xtn.ARADDR {
								bins araddr_bin		= {[0:'hffff_ffff]};}
	
		ARBURST_CP 	: coverpoint rd_xtn.ARBURST {
								bins arburst_bin[] 	= {[0:2]};}

		ARSIZE_CP	: coverpoint rd_xtn.ARSIZE {				
								bins arsize_bin[]	= {[0:2]};}
		
		ARLEN_CP 	: coverpoint rd_xtn.ARLEN {	bins arlen_bin		= {[0:11]};}

	endgroup  : read_cg

	
	covergroup read_cg1 with function sample(int i);
		option.per_instance = 1;

		RRESP_CP : coverpoint rd_xtn.RRESP[i]{bins rresp_bin 	= {0};}
	
	endgroup : read_cg1	


	
	function new(string name = "scoreboard",uvm_component parent);
		super.new(name,parent);
		
		write_cg = new();
		write_cg1 = new();
		read_cg = new();
		read_cg1 = new();
	endfunction

	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(env_config)::get(this,"","env_config",env_cfg))
			begin
				`uvm_fatal(get_type_name(),"Did you get the config?")
			end
	
			fifo_master 	= new[env_cfg.no_of_master_agents];
	
			fifo_slave 	= new[env_cfg.no_of_slave_agents];

		foreach (fifo_master[i])
			begin
				fifo_master[i] = new($sformatf("fifo_master[%0d]",i),this);
			end
	
		foreach(fifo_slave[i])
			begin
				fifo_slave[i] = new($sformatf("fifo_slave[%0d]",i),this);
			end
	endfunction 


	task run_phase(uvm_phase phase);
	
			forever		
				begin
					$display("start fetching the data from the master_monitor ");
					fifo_master[0].get(m_data);
					m_data.print();
			
					fifo_slave[0].get(s_data);
					s_data.print(); 
					$display("data getting completed");


					if(m_data.compare(s_data))
						begin
							`uvm_info("get_type_name()",$sformatf("Master Packet \n %s ",m_data.sprint()),UVM_LOW);
							`uvm_info("get_type_name()",$sformatf("Slave Packet \n %s ",s_data.sprint()),UVM_LOW);

						$display("SCOREBOARD........................Comparision Successfull");

						wr_xtn = m_data;
						write_cg.sample();
						rd_xtn = s_data;
						read_cg.sample();
						
						if(m_data)
							begin
								foreach(m_data.WDATA[i])
									begin
										write_cg1.sample(i);
									end
							end
						if(m_data)
							begin	
								foreach(m_data.RDATA[i])
									begin
										read_cg1.sample(i);
									end
							end
						end
				else
					begin
	
						`uvm_info("get_type_name()",$sformatf("Master Packet \n %s ",m_data.sprint()),UVM_LOW);
						`uvm_info("get_type_name()",$sformatf("Slave Packet \n %s ",s_data.sprint()),UVM_LOW);
						$display("SCOREBOARD ..................COMPARISION	FAILED");				
					end	

	

				end 
	endtask : run_phase
	
	
endclass


	
		