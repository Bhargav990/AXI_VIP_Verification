class master_monitor extends uvm_monitor ;
	`uvm_component_utils(master_monitor)

	master_config master_cfg;
	virtual axi_if.MST_MON_MP mif;
	
	uvm_analysis_port#(axi_xtn) monitor_port;


	axi_xtn xtn,xtn1,xtn2,xtn3,xtn4;

	axi_xtn q1[$], q2[$], q3[$], q4[$], q5[$];
	
	semaphore sem_aw = new(1); 	//Write address channel
	semaphore sem_w  = new(1); 	//Write data channel
	semaphore sem_b  = new(1); 	//Write response channel
	semaphore sem_ar = new(1); 	//Read address channel
	semaphore sem_r  = new(1); 	//Read data channel
 	
	
	function new(string name = "master_monitor",uvm_component parent );
		super.new(name,parent);
	endfunction 

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		monitor_port = new ("monitor_port",this);

		if(!uvm_config_db#(master_config)::get(this,"","master_config",master_cfg))
			`uvm_fatal(get_type_name(),"Did you set it?")
	endfunction 

	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
			mif = master_cfg.mif;

	endfunction

	task run_phase(uvm_phase phase);
		forever 
			begin
				//xtn  = axi_xtn :: type_id :: create("xtn");

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

		`uvm_info("MASTER MONITOR","Write Address Channel(Master-side) sampling starts...\n", UVM_HIGH);
					
	begin	
		wait(mif.mst_mon_cb.AWVALID && mif.mst_mon_cb.AWREADY)
	
		xtn.AWADDR 	= mif.mst_mon_cb.AWADDR;
		xtn.AWSIZE 	= mif.mst_mon_cb.AWSIZE;
		xtn.AWLEN 	= mif.mst_mon_cb.AWLEN;
		xtn.AWID 	= mif.mst_mon_cb.AWID;
		xtn.AWBURST 	= mif.mst_mon_cb.AWBURST;
		
		q1.push_back(xtn);
		monitor_port.write(xtn);

			$display("\nAligned Write Address: %p",xtn.AWADDR);

		    @(mif.mst_mon_cb);
		    
	end
		`uvm_info("MASTER MONITOR WDATA ", $sformatf("Master Monitor is recieving AWADDR: %s", xtn.sprint()), UVM_LOW);
	`uvm_info("MASTER MONITOR","...end of Write Address Channel(Master side) sample.\n", UVM_HIGH);
	
		
	endtask : sample_aw
	
	task sample_w(axi_xtn xtn);

         xtn1 = axi_xtn::type_id::create("xtn1");

	xtn1 = xtn;
		`uvm_info("MASTER MONITOR","Write data Channel(Master-side) sampling starts...\n", UVM_HIGH);
		
	//	int mem[int];
	
		xtn1.WDATA = new [xtn1.AWLEN+1];
		xtn1.WSTRB = new [xtn1.AWLEN+1];

		$display("size of wdata =%0d",xtn1.WDATA.size());
		$display("size of WSTRB =%0d",xtn1.WSTRB.size());

		xtn1.wr_addr_cal();
		xtn1.strb_cal();


		for(int i=0; i<xtn1.AWLEN+1;i++)
		begin
			wait(mif.mst_mon_cb.WVALID && mif.mst_mon_cb.WREADY)
		
				xtn1.WID 	= mif.mst_mon_cb.WID;

				if(mif.mst_mon_cb.WSTRB == 4'b1111)
					xtn1.WDATA[i] = mif.mst_mon_cb.WDATA[31:0];

					xtn1.WSTRB[i] = mif.mst_mon_cb.WSTRB;

				
				if(mif.mst_mon_cb.WSTRB == 1110)
					xtn1.WDATA[i]  = mif.mst_mon_cb.WDATA[31:8];
					xtn1.WSTRB[i] = mif.mst_mon_cb.WSTRB;


				if(mif.mst_mon_cb.WSTRB == 1100)
					xtn1.WDATA[i] = mif.mst_mon_cb.WDATA[31:16];
					xtn1.WSTRB[i] = mif.mst_mon_cb.WSTRB;


				if(mif.mst_mon_cb.WSTRB == 1000)
					xtn1.WDATA[i] = mif.mst_mon_cb.WDATA[31:24];
					xtn1.WSTRB[i] = mif.mst_mon_cb.WSTRB;


				if(mif.mst_mon_cb.WSTRB == 0100)
					xtn1.WDATA[i] = mif.mst_mon_cb.WDATA[23:0];
					xtn1.WSTRB[i] = mif.mst_mon_cb.WSTRB;


				if(mif.mst_mon_cb.WSTRB == 0011)
					xtn1.WDATA[i] = mif.mst_mon_cb.WDATA[15:0];
					xtn1.WSTRB[i] = mif.mst_mon_cb.WSTRB;


				if(mif.mst_mon_cb.WSTRB == 0010)
					xtn1.WDATA[i] = mif.mst_mon_cb.WDATA[15:8];
					xtn1.WSTRB[i] = mif.mst_mon_cb.WSTRB;


				if(mif.mst_mon_cb.WSTRB == 0001)
					xtn1.WDATA[i] = mif.mst_mon_cb.WDATA[7:0];
					xtn1.WSTRB[i] = mif.mst_mon_cb.WSTRB;
				
					xtn1.WLAST 	= mif.mst_mon_cb.WLAST;
					
					@(mif.mst_mon_cb);
				end

		monitor_port.write(xtn1);


			     	
			

					
		`uvm_info("MASTER Monitor","...end of Write Data Channel(Master side) drive.\n", UVM_HIGH);

		`uvm_info("MASTER MONITOR WDATA ", $sformatf("Master Monitor is recieving data and strobe: %s", xtn1.sprint()), UVM_LOW);



	endtask : sample_w




	task sample_b();

		xtn2 = axi_xtn::type_id::create("xtn2");
		
		xtn2 = xtn;

		`uvm_info("MASTER MONITOR","Write Response Channel(Master-side) sampling starts...\n", UVM_HIGH);


			wait(mif.mst_mon_cb.BVALID && mif.mst_mon_cb.BREADY)

			xtn2.BID 	= mif.mst_mon_cb.BID;
			xtn2.BRESP 	= mif.mst_mon_cb.BRESP;
			
		monitor_port.write(xtn2);


		`uvm_info("MASTER MONITOR","Write Response Channel(Master-side) sampling starts...\n", UVM_HIGH);

		`uvm_info("MASTER MONITOR RESP", $sformatf("Master Monitor is recieving data and strobe: %s", xtn2.sprint()), UVM_LOW);


			
	endtask : sample_b


	task sample_ar();
		
		`uvm_info("MASTER MONITOR","Read address Channel(Master-side) sampling starts...\n", UVM_HIGH);

         	xtn3 = axi_xtn::type_id::create("xtn3");
		xtn3 = xtn;

		wait (mif.mst_mon_cb.ARVALID && mif.mst_mon_cb.ARREADY)
		xtn3.ARID	 = mif.mst_mon_cb.ARID;
		xtn3.ARADDR	 = mif.mst_mon_cb.ARADDR;
		xtn3.ARLEN	 = mif.mst_mon_cb.ARLEN;
		xtn3.ARSIZE	 = mif.mst_mon_cb.ARSIZE;
		xtn3.ARBURST	 = mif.mst_mon_cb.ARBURST;
		 
		q2.push_back (xtn3);
		monitor_port.write(xtn3);


			
		`uvm_info("MASTER MONITOR","...end of Read address Channel(Master side) .\n", UVM_HIGH);

		@(mif.mst_mon_cb);


		`uvm_info("MASTER MONITOR WRESP ", $sformatf("Master Monitor is recieving data and strobe: %s", xtn3.sprint()), UVM_LOW);


	endtask :sample_ar

	task sample_r(axi_xtn xtn);

	xtn4 = axi_xtn::type_id::create("xtn4");

	xtn4 = xtn;

		`uvm_info("MASTER MONITOR","Read data Channel(Master-side) sampling starts...\n", UVM_HIGH);

		
	    	 xtn4.RDATA = new[xtn4.ARLEN+1];
		for(int i=0; i<xtn4.ARLEN+1; i++)
			begin
				wait(mif.mst_mon_cb.RVALID && mif.mst_mon_cb.RREADY)
				xtn4.RDATA[i] 	= mif.mst_mon_cb.RDATA;

				xtn4.RID 	= mif.mst_mon_cb.RID;
			
				xtn4.RRESP[i] 	= mif.mst_mon_cb.RRESP;

				if(i == (xtn4.RDATA.size()-1))
				begin
					xtn4.RLAST = mif.mst_mon_cb.RLAST;
				end
			@(mif.mst_mon_cb);

			end
			monitor_port.write(xtn4);


				`uvm_info("MASTER MONITOR","...end of Read data Channel(Master side) .\n", UVM_HIGH);
				`uvm_info("MASTER MONITOR", $sformatf("Master Monitor is recieving: %s", xtn4.sprint()), UVM_LOW);


	endtask : sample_r


endclass
