class slave_monitor extends uvm_monitor ;
	`uvm_component_utils(slave_monitor)

	slave_config slave_cfg;
	virtual axi_if.SLV_MON_MP sif;

	uvm_analysis_port#(axi_xtn) monitor_port;
	
	axi_xtn xtn,xtn1,xtn2,xtn3,xtn4;

	axi_xtn q1[$], q2[$], q3[$], q4[$], q5[$];
	
	semaphore sem_aw = new(1); 	//Write address channel
	semaphore sem_w  = new(1); 	//Write data channel
	semaphore sem_b  = new(1); 	//Write response channel
	semaphore sem_ar = new(1); 	//Read address channel
	semaphore sem_r  = new(1); 	//Read data channel

	function new(string name = "slave_monitor",uvm_component parent );
		super.new(name,parent);
	endfunction 

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		monitor_port = new ("monitor_port",this);

		if(!uvm_config_db#(slave_config)::get(this,"","slave_config",slave_cfg))
			`uvm_fatal(get_type_name(),"Did you set it?")

	endfunction 

		function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
			sif = slave_cfg.sif;

	endfunction

	task run_phase(uvm_phase phase);
		forever 
			begin

				collect_data();
			end
	endtask

	task collect_data();
		

	fork
	
		begin
			sem_aw.get(1);
			sample_aw();
			sem_aw.put(1); 			
			
			sem_w.put(1);
			
		end
		  
		begin
			sem_w.get(2);			// Here it ensures that only after one burst is done, will the subsequent bursts be done,
							// This makes sure that interleaving won't happen.
			sample_w(q1.pop_front());
			sem_w.put(1);

			sem_b.put(1);
						
		end	
		
		begin			
			sem_b.get(2);			// Here it ensures that only in-order transactions takes place. 
			sample_b();
			sem_b.put(1);
			
		end
		
		begin
			sem_ar.get(1);
			sample_ar();
			sem_ar.put(1);
			
			sem_r.put(1);
			
		end
		begin			
			sem_r.get(2);
			sample_r(q2.pop_front());
			sem_r.put(1);

		end

	join_any
	
endtask: collect_data


	task sample_aw(); //............................../sampling of write addr channel siganls 

	xtn = axi_xtn::type_id::create("xtn");

		`uvm_info("SLAVE MONITOR","Write Address Channel(Slave-side) sampling starts...\n", UVM_HIGH);
					
	begin	
		wait(sif.slv_mon_cb.AWVALID && sif.slv_mon_cb.AWREADY)
	
		xtn.AWADDR 	= sif.slv_mon_cb.AWADDR;
		xtn.AWSIZE 	= sif.slv_mon_cb.AWSIZE;
		xtn.AWLEN 	= sif.slv_mon_cb.AWLEN;
		xtn.AWID 	= sif.slv_mon_cb.AWID;
		xtn.AWBURST 	= sif.slv_mon_cb.AWBURST;
		
		q1.push_back(xtn);
		monitor_port.write(xtn);
			$display("\nAligned Write Address: %p",xtn.AWADDR);

		    @(sif.slv_mon_cb);
		    
	end
		`uvm_info("SLAVE MONITOR WDATA ", $sformatf("Slave Monitor is recieving AWADDR: %s", xtn.sprint()), UVM_LOW);

		`uvm_info("SLAVE MONITOR","...end of Write Address Channel(Slave side) sample.\n", UVM_HIGH);
	
		
	endtask : sample_aw
	
	task sample_w(axi_xtn xtn);

         xtn1 = axi_xtn::type_id::create("xtn1");

	xtn1 = xtn;
		`uvm_info("SLAVE MONITOR","Write data Channel(Slave-side) sampling starts...\n", UVM_HIGH);
		
	
		xtn1.WDATA = new [xtn1.AWLEN+1];
		xtn1.WSTRB = new [xtn1.AWLEN+1];

		$display("size of wdata =%0d",xtn1.WDATA.size());
		$display("size of WSTRB =%0d",xtn1.WSTRB.size());

		xtn1.wr_addr_cal();
		xtn1.strb_cal();


		for(int i=0; i<xtn1.AWLEN+1;i++)
		begin
			wait(sif.slv_mon_cb.WVALID && sif.slv_mon_cb.WREADY)
		
				xtn1.WID 	= sif.slv_mon_cb.WID;

				if(sif.slv_mon_cb.WSTRB == 4'b1111)
					xtn1.WDATA[i] = sif.slv_mon_cb.WDATA[31:0];

					xtn1.WSTRB[i] = sif.slv_mon_cb.WSTRB;

				
				if(sif.slv_mon_cb.WSTRB == 1110)
					xtn1.WDATA[i] = sif.slv_mon_cb.WDATA[31:8];
					xtn1.WSTRB[i] = sif.slv_mon_cb.WSTRB;


				if(sif.slv_mon_cb.WSTRB == 1100)
					xtn1.WDATA[i] = sif.slv_mon_cb.WDATA[31:16];
					xtn1.WSTRB[i] = sif.slv_mon_cb.WSTRB;


				if(sif.slv_mon_cb.WSTRB == 1000)
					xtn1.WDATA[i] = sif.slv_mon_cb.WDATA[31:24];
					xtn1.WSTRB[i] = sif.slv_mon_cb.WSTRB;


				if(sif.slv_mon_cb.WSTRB == 0100)
					xtn1.WDATA[i] = sif.slv_mon_cb.WDATA[23:0];
					xtn1.WSTRB[i] = sif.slv_mon_cb.WSTRB;


				if(sif.slv_mon_cb.WSTRB == 0011)
					xtn1.WDATA[i] = sif.slv_mon_cb.WDATA[15:0];
					xtn1.WSTRB[i] = sif.slv_mon_cb.WSTRB;


				if(sif.slv_mon_cb.WSTRB == 0010)
					xtn1.WDATA[i] = sif.slv_mon_cb.WDATA[15:8];
					xtn1.WSTRB[i] = sif.slv_mon_cb.WSTRB;


				if(sif.slv_mon_cb.WSTRB == 0001)
					xtn1.WDATA[i] = sif.slv_mon_cb.WDATA[7:0];
					xtn1.WSTRB[i] = sif.slv_mon_cb.WSTRB;
				
					xtn1.WLAST 	= sif.slv_mon_cb.WLAST;
					
					@(sif.slv_mon_cb);
				end
			monitor_port.write(xtn1);

						     	
			

					
		`uvm_info("SLAVE Monitor","...end of Write Data Channel(Slave side) drive.\n", UVM_HIGH);

		`uvm_info("SLAVE MONITOR WDATA ", $sformatf("Slave Monitor is recieving data and strobe: %s", xtn1.sprint()), UVM_LOW);



	endtask : sample_w




	task sample_b();

		xtn2 = axi_xtn::type_id::create("xtn2");
		
		xtn2 = xtn;

			`uvm_info("SLAVE MONITOR","Write Response Channel(Slave-side) sampling starts...\n", UVM_HIGH);


			wait(sif.slv_mon_cb.BVALID && sif.slv_mon_cb.BREADY)

			xtn2.BID 	= sif.slv_mon_cb.BID;
			xtn2.BRESP 	= sif.slv_mon_cb.BRESP;
			
			monitor_port.write(xtn2);

		`uvm_info("SLAVE MONITOR","Write Response Channel(Slave-side) sampling starts...\n", UVM_HIGH);

		`uvm_info("SLAVE MONITOR RESP", $sformatf("Slave Monitor is recieving data and strobe: %s", xtn2.sprint()), UVM_LOW);


			
	endtask : sample_b


	task sample_ar();
		
		`uvm_info("SLAVE MONITOR","Read address Channel(Slave-side) sampling starts...\n", UVM_HIGH);

         	xtn3 = axi_xtn::type_id::create("xtn3");
		xtn3 = xtn;

		wait (sif.slv_mon_cb.ARVALID && sif.slv_mon_cb.ARREADY)
		xtn3.ARID	 = sif.slv_mon_cb.ARID;
		xtn3.ARADDR	 = sif.slv_mon_cb.ARADDR;
		xtn3.ARLEN	 = sif.slv_mon_cb.ARLEN;
		xtn3.ARSIZE	 = sif.slv_mon_cb.ARSIZE;
		xtn3.ARBURST	 = sif.slv_mon_cb.ARBURST;
		 
		q2.push_back (xtn3);
		monitor_port.write(xtn3);
			
		`uvm_info("SLAVE MONITOR","...end of Read address Channel(Slave side) .\n", UVM_HIGH);

		@(sif.slv_mon_cb);


		`uvm_info("SLAVE MONITOR WRESP ", $sformatf("Slave Monitor is recieving data and strobe: %s", xtn3.sprint()), UVM_LOW);


	endtask :sample_ar

	task sample_r(axi_xtn xtn);

	xtn4 = axi_xtn::type_id::create("xtn4");

	xtn4 = xtn;

	`uvm_info("SLAVE MONITOR","Read data Channel(Slave-side) sampling starts...\n", UVM_HIGH);

		
	    	 xtn4.RDATA = new[xtn4.ARLEN+1];
		for(int i=0; i<xtn4.ARLEN+1; i++)
			begin
				wait(sif.slv_mon_cb.RVALID && sif.slv_mon_cb.RREADY)
				xtn4.RDATA[i] 	= sif.slv_mon_cb.RDATA;

				xtn4.RID 	= sif.slv_mon_cb.RID;
			
	

				xtn4.RRESP[i]	= sif.slv_mon_cb.RRESP;

				if(i == (xtn4.RDATA.size()-1))
				begin
					xtn4.RLAST = sif.slv_mon_cb.RLAST;
				end
			@(sif.slv_mon_cb);
			end
			monitor_port.write(xtn4);
	

				`uvm_info("SLAVE MONITOR","...end of Read data Channel(Slave side) .\n", UVM_HIGH);
				`uvm_info("SLAVE MONITOR", $sformatf("Slave Monitor is recieving: %s", xtn4.sprint()), UVM_LOW);


	endtask : sample_r




endclass