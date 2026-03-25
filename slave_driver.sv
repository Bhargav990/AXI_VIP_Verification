class slave_driver extends uvm_driver #(axi_xtn);
      	`uvm_component_utils(slave_driver)
   
      	slave_config slave_cfg;
        virtual axi_if.SLV_DRV_MP sif;
 
  	function new(string name="slave_driver",uvm_component parent);
        	super.new(name,parent);
  	endfunction	
	
	axi_xtn xtn_write, xtn_read;
	axi_xtn q_w[$], q_b[$], q_r[$];
	
	semaphore sem_aw = new(1);	//Write Address Channel
	semaphore sem_w  = new(1);	//Write Data Channel
	semaphore sem_b  = new(1);	//Write Response Channel
	
	semaphore sem_ar = new(1);	//Read Address Channel
	semaphore sem_r  = new(1);	//Read Data Channel
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(slave_config)::get(this, "", "slave_config", slave_cfg))
			`uvm_fatal(get_type_name(), "Have you set the config()...?")
		super.build_phase(phase);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		sif = slave_cfg.sif;
	endfunction
		
	


task run_phase(uvm_phase phase);
	forever
		begin
	             //seq_item_port.get_next_item(req); Since we are not sending the sequence to the slave agent.
		     drive();
		     //seq_item_port.item_done();
		end
		
endtask: run_phase

task drive();

	xtn_write = axi_xtn::type_id::create("xtn_write");
	xtn_read  = axi_xtn::type_id::create("xtn_read");	
	
	fork
		begin
			sem_aw.get(1);
			catch_aw(xtn_write);
			sem_aw.put(1);
			
			sem_w.put(1);
		end
		
		begin
			sem_w.get(2);
			catch_w(q_w.pop_front());
			sem_w.put(1);
			
			sem_b.put(1);
		end
		
		begin
			sem_b.get(2);
			drive_b(q_b.pop_front());
			sem_b.put(1);
		end
		
		begin
			sem_ar.get(1);
			catch_ar(xtn_read);
			sem_ar.put(1);
			
			sem_r.put(1);
		end
		begin
			sem_r.get(2);
			drive_r(q_r.pop_front());
			sem_r.put(1);
		end
		
	join_any
	
endtask: drive

task catch_aw(axi_xtn xtn_write);//********************To catch the Write Address and it's control signal so that we can work on the NEXT ADDRESS.
	
	`uvm_info("SLAVE DRIVER","Write Address Channel(Slave-side) driving starts...\n", UVM_HIGH);

	@(sif.slv_drv_cb);
	sif.slv_drv_cb.AWREADY <= 1;
	
	@(sif.slv_drv_cb);
	wait(sif.slv_drv_cb.AWVALID);

	xtn_write.AWID 			= sif.slv_drv_cb.AWID;
	xtn_write.AWLEN 		= sif.slv_drv_cb.AWLEN;
	xtn_write.AWSIZE 		= sif.slv_drv_cb.AWSIZE;
	xtn_write.AWADDR 		= sif.slv_drv_cb.AWADDR;
	xtn_write.AWBURST 		= sif.slv_drv_cb.AWBURST;
		
	q_w.push_back(xtn_write);
	
	sif.slv_drv_cb.AWREADY 		<= 0;
	
	repeat($urandom_range(1, 5))
		@(sif.slv_drv_cb);
	
	`uvm_info("SLAVE DRIVER","...end of Write Address Channel(Slave-side) drive.\n", UVM_HIGH);	
	
endtask: catch_aw

task catch_w(axi_xtn xtn_write);//*********************To drive the Write Data READY.
	
	xtn_write.wr_addr_cal();
	
	`uvm_info("SLAVE DRIVER","Write Data Channel(Slave-side) driving starts...\n", UVM_HIGH);
	
	$display("\nAligned Write Address: %h", xtn_write.aligned_waddr);
	$displayh("Write Addresses calculated in Slave-Side are %p\n", xtn_write.waddr);
	
	for(int i = 0; i<(xtn_write.AWLEN+1); i++)
	    	begin
		     $display("Catched Beat Number: %0d", i+1);
		     
		     sif.slv_drv_cb.WREADY 	<= 1;

	     	     @(sif.slv_drv_cb);
		     wait(sif.slv_drv_cb.WVALID)
		          sif.slv_drv_cb.WREADY <= 0;	          
		          xtn_write.WID	        = sif.slv_drv_cb.WID;
		          
		     q_b.push_back(xtn_write);
		        
		     $display("WSTRB in Slave Driver is: %p", sif.slv_drv_cb.WSTRB);
	
		     repeat($urandom_range(1, 5))
		            @(sif.slv_drv_cb);

 	        end

	`uvm_info("SLAVE DRIVER","...end of Write Data Channel(Slave-side) drive.\n", UVM_HIGH);

endtask: catch_w

task drive_b(axi_xtn xtn_write);

	`uvm_info("SLAVE DRIVER","Write Response Channel(Slave-side) driving starts...\n", UVM_HIGH);
	
	xtn_write.BID 		= xtn_write.AWID;
	
	sif.slv_drv_cb.BVALID 	<= 1;
	sif.slv_drv_cb.BRESP 	<= 0; //OKAY Response.
	sif.slv_drv_cb.BID 	<= xtn_write.BID;
	
	@(sif.slv_drv_cb);
	wait(sif.slv_drv_cb.BREADY)
	     
	sif.slv_drv_cb.BVALID 	<= 0;
	sif.slv_drv_cb.BRESP 	<= 'hx; //No response at all.
	sif.slv_drv_cb.BID 	<= 'hx;
	
	repeat($urandom_range(1, 5))
	       @(sif.slv_drv_cb);
		
	`uvm_info("SLAVE DRIVER", $sformatf("Slave-WRITE is driving: %s", xtn_write.sprint()), UVM_LOW);		

	`uvm_info("SLAVE DRIVER","...end of Write Response Channel(Slave-side) drive.\n", UVM_HIGH);
	
endtask: drive_b

task catch_ar(axi_xtn xtn_read);

	//xtn_read.RDATA = new[xtn_read.ARLEN+1];
		
	`uvm_info("SLAVE DRIVER","Read Address Channel(Slave-side) driving starts...\n", UVM_HIGH);	

	sif.slv_drv_cb.ARREADY 	<= 1;
	
	@(sif.slv_drv_cb);
	wait(sif.slv_drv_cb.ARVALID)
	
	xtn_read.ARID 		= sif.slv_drv_cb.ARID;
	xtn_read.ARLEN 		= sif.slv_drv_cb.ARLEN;
	xtn_read.ARSIZE 	= sif.slv_drv_cb.ARSIZE;
	xtn_read.ARADDR 	= sif.slv_drv_cb.ARADDR;
	xtn_read.ARBURST 	= sif.slv_drv_cb.ARBURST;
	
	sif.slv_drv_cb.ARREADY <= 0;
	
	q_r.push_back(xtn_read); 
		
	repeat($urandom_range(1, 5))
		@(sif.slv_drv_cb);
		`uvm_info("SLAVE DRIVER","...end of Read Address Channel(Slave-side) drive.\n", UVM_HIGH);
	
endtask: catch_ar

task drive_r(axi_xtn xtn_read);

	xtn_read.RDATA = new[xtn_read.ARLEN + 1];
	
	xtn_read.rd_addr_cal();
	
	`uvm_info("SLAVE DRIVER","Read Data Channel(Slave-side) driving starts...\n", UVM_HIGH);
	
	$display("\nAligned Read Address: %h", xtn_read.aligned_raddr);
	$displayh("Read Addresses calculated in Slave-Side are %p\n", xtn_read.raddr);
			
	for(int i = 0; i<xtn_read.ARLEN+1; i++)
		begin
		     xtn_read.RDATA[i]		= $urandom;
		     xtn_read.RID		= xtn_read.ARID; 
		     
		     sif.slv_drv_cb.RDATA	<= xtn_read.RDATA[i];
		     sif.slv_drv_cb.RVALID 	<= 1;
		     sif.slv_drv_cb.RID 	<= xtn_read.RID;
		     sif.slv_drv_cb.RRESP 	<= 0;
		     
		     if(i == (xtn_read.ARLEN))
			sif.slv_drv_cb.RLAST 	<= 1;
		     else
			sif.slv_drv_cb.RLAST 	<= 0;

		     @(sif.slv_drv_cb);
		     wait(sif.slv_drv_cb.RREADY)
		     	  
		     sif.slv_drv_cb.RVALID 	<= 0;
		     sif.slv_drv_cb.RLAST 	<= 0;
		     sif.slv_drv_cb.RRESP 	<= 'hx;
		     sif.slv_drv_cb.RID		<= 'hx;
		     sif.slv_drv_cb.RDATA	<= 'hx;
		     
		    		     		
		     repeat($urandom_range(1, 5))
		     	    @(sif.slv_drv_cb);
		     	    
		end
	 `uvm_info("SLAVE DRIVER", $sformatf("Slave-READ is driving: %s", xtn_read.sprint()), UVM_LOW);
	
	`uvm_info("SLAVE DRIVER","...end of Read Data Channel(Slave-side) drive.\n", UVM_HIGH);
	
endtask: drive_r

endclass

	