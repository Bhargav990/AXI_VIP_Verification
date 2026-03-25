class axi_xtn extends uvm_sequence_item;
	`uvm_object_utils(axi_xtn)

		//write address channel
	rand bit [3:0]  AWID;
 	rand bit [31:0] AWADDR;
	rand bit [3:0]  AWLEN;
	rand bit [2:0]  AWSIZE;
	rand bit [1:0]  AWBURST;
	logic           AWREADY;
 	bit             AWVALID;


	//write data channel
	rand bit [3:0] WID;
	rand bit [31:0] WDATA[];
        bit      [3:0]  WSTRB[];
	bit             WLAST;
	bit             WVALID;
	logic 		WREADY;


	//write response channel
	rand bit [3:0] BID;
	bit      [1:0] BRESP;
	bit            BVALID;
	logic          BREADY;


	//read address channel
	rand bit [3:0]  ARID;
 	rand bit [31:0] ARADDR;
	rand bit [3:0]  ARLEN;
	rand bit [2:0]  ARSIZE;
	rand bit [1:0]  ARBURST;
	logic           ARREADY;
 	bit             ARVALID;
	


	//read data channel
	rand bit [3:0]  RID;
	 bit [31:0] RDATA[];
        bit 	 [1:0]  RRESP;
	bit             RLAST;
	bit             RVALID;
	logic           RREADY;


	function new(string name = "axi_xtn");
		super.new(name);
	endfunction


	
	//logic vairables
	bit [31:0] waddr[];
	int        no_of_wbytes;
	int 	   aligned_waddr;
	int 	   start_waddr;

	//bit [31:0] rstrb[];
	bit [31:0] raddr[];
	int 	   no_of_rdbytes;
	int 	   aligned_raddr;
	int 	   start_raddr;



	constraint wdac       {WDATA.size()==(AWLEN+1);} //wdata size should be length+1
//	constraint ardac      {RDATA.size()==(ARLEN+1);} //rdata size should be length+1

	constraint write_id_c {(AWID == WID);(BID==WID);} // write data id and write response id and write address id should be same 
	constraint read_id_c {ARID==RID;} // read data id and read address id should be same 

	constraint awb {AWBURST dist{0:=10, 1:=10, 2:=10};} // burst 0 means fixed ,1 - incrementing, 2 - wrapping 
	constraint arb {ARBURST dist{0:=10, 1:=10, 2:=10};}

	constraint aws {AWSIZE dist{0:=10, 1:=10, 2:=10};} // suppose 2^0 =1 ,2^1 = 2, 2^2= 4, we take up to 4 heighest 
	constraint ars {ARSIZE dist{0:=10, 1:=10, 2:=10};}

	constraint awaddr_c {AWADDR < 4096;}
	constraint araddr_c {ARADDR < 4096;}

	constraint wrapping_len {if (AWBURST == 2'b10)
					(AWLEN + 1) inside {2,4,8,16};}

	constraint rrapping_len {if (ARBURST == 2'b10)
					(ARLEN + 1) inside {2,4,8,16};}

	

	//alignment
	 constraint awaddr_al1 { if (( AWBURST == 2'b10 || AWBURST == 2'b00) && ((AWSIZE == 0) ||  (AWSIZE == 1)))
                                  	  AWADDR%2 == 0;} 

      	constraint awaddr_al2  { if (( AWBURST == 2'b10 || AWBURST == 2'b00) && (AWSIZE == 2)) 
                                   	 AWADDR%4 == 0;}
    
      	constraint araddr_al1 { if (( ARBURST == 2'b10 || ARBURST == 2'b00) && (( ARSIZE == 0) || (ARSIZE == 1)))
                                   	 ARADDR%2 == 0;}

      	constraint araddr_al2 { if (( ARBURST == 2'b10 || ARBURST == 2'b00) && ( ARSIZE == 2))
                                  	  ARADDR%4 == 0;}
	



		function void wr_addr_cal();
		
		bit wb;
		int burst_len = AWLEN +1 ;
		int no_of_wbytes = 2**AWSIZE; // actual size of 1beat
		int N = burst_len;


		int wrap_boundary = (int '(AWADDR/(no_of_wbytes*burst_len)))*(no_of_wbytes*burst_len);	//where it shopuld wrap back after hitiing boundary
		int addr_n = (wrap_boundary + (no_of_wbytes*burst_len)); // actual boundary where it should start wrapping
		waddr = new[AWLEN+1];
		waddr[0] = AWADDR; // first address should be start_addr ,aligned or unaligned doesnt matter
		aligned_waddr = (int ' (AWADDR/no_of_wbytes))*no_of_wbytes; 
		start_waddr = AWADDR;
		


		for(int i=2;i<(burst_len+1);i++)
			begin
				if(AWBURST==0) //FIXED
					waddr[i-1] = AWADDR;
				
				if(AWBURST==1) //	INCR
					waddr[i-1]=aligned_waddr + (i-1)*no_of_wbytes;

				if(AWBURST==2) //WRAP
					begin
						if(wb==0)
							begin
								waddr[i-1] = aligned_waddr +(i-1)*no_of_wbytes;
								if(waddr[i-1] == (wrap_boundary+(no_of_wbytes*burst_len)))
								
								begin
									waddr[i-1]=wrap_boundary;
									wb++;
								end
							end
					else
						waddr[i-1]=start_waddr + ((i-1)*no_of_wbytes) - (no_of_wbytes * burst_len);
				end
		end
	endfunction : wr_addr_cal

//*********************************************************************************************************************************
	
	function void rd_addr_cal();
			bit wb;
			int burst_len = AWLEN + 1;
			int no_of_rdbytes = 2**ARSIZE;
			int N = burst_len;


		
	int wrap_boundary = (int'(ARADDR/(no_of_rdbytes * burst_len)))*(no_of_rdbytes*burst_len);
	int addr_n = (wrap_boundary+(no_of_rdbytes*burst_len));
	raddr = new[ARLEN + 1];
	raddr[0] = ARADDR;
	aligned_raddr = (int'(ARADDR/no_of_rdbytes))*no_of_rdbytes;
	start_raddr = ARADDR;



	for(int i=2;i<(burst_len + 1);i++)
		begin
			if(ARBURST==0)//FIXED
				raddr[i-1] = ARADDR;
			if(ARBURST == 1)//INCR
				raddr[i-1] = aligned_raddr + (i-1)*no_of_rdbytes;
			
			if(ARBURST==2)//WRAP
				begin
					if(wb==0)
						begin
							raddr[i-1] = aligned_raddr + (i-1)*no_of_rdbytes;
							if(raddr[i-1] == (wrap_boundary + (no_of_rdbytes * burst_len)) )
								begin
									raddr[i-1] = wrap_boundary;
									wb++;
								end
							end
						else
							raddr[i-1] = start_raddr + ((i-1)*no_of_rdbytes) - (no_of_rdbytes*burst_len);

					end
				end
		endfunction:rd_addr_cal


//******************************************************************************* *******************************************************


	function void strb_cal();

	  int data_bus_bytes=4;
       	int no_of_wbytes = 2**AWSIZE;

	  int lower_byte_lane, upper_byte_lane;

	  int lower_byte_lane_0=start_waddr-((int'(start_waddr/data_bus_bytes))*data_bus_bytes);

	  int upper_byte_lane_0=(aligned_waddr+(no_of_wbytes-1))-((int'(start_waddr/data_bus_bytes))*data_bus_bytes);
	
	for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
	begin
		WSTRB[0][j]=1;
	end

	for(int i=1;i<(AWLEN+1);i++)
	begin
		lower_byte_lane=waddr[i]-(int'(waddr[i]/data_bus_bytes))*data_bus_bytes;
		upper_byte_lane=lower_byte_lane+no_of_wbytes-1;
		
		for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
		begin
			WSTRB[i][j]=1;
		end
	end
		$display("lbl: %0d", lower_byte_lane);
		$display("ubl: %0d", upper_byte_lane);

		$display("lbl0: %0d", lower_byte_lane_0);
		$display("ubl0: %0d", upper_byte_lane_0);



	endfunction: strb_cal
			

//*******************************************************************************************************************
	
	function void post_randomize();
		WSTRB=new[AWLEN+1];
	//	rstrb=new[arlen+1];
		
		wr_addr_cal();
		strb_cal();

		rd_addr_cal();


	   $display("////////////////////// write_addr///////////////////\n wr_addr=%0p",waddr);
	   $display("////////////////////// write_addr_AWADDR///////////////////\n AWADDR=%0p",AWADDR);
	   $display("////////////////////// read_addr///////////////////\n rd_add=%0p",raddr);
	   $display("////////////////////// write_addr_ARADDR///////////////////\n ARADDR=%0p",ARADDR);

	endfunction


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


			
	function void do_print(uvm_printer printer);

		super.do_print(printer);

	//Write Address Signals
	printer.print_field("AWID",    this.AWID,    8, UVM_DEC);
	printer.print_field("AWADDR",  this.AWADDR,  32,UVM_DEC);
	printer.print_field("AWSIZE",  this.AWSIZE,  32,UVM_DEC);	
	printer.print_field("AWLEN",   this.AWLEN,   8, UVM_DEC);	
	printer.print_field("AWBURST", this.AWBURST, 2, UVM_DEC);	
	printer.print_field("AWVALID", this.AWVALID, 1, UVM_DEC);	
	printer.print_field("AWREADY", this.AWREADY, 1, UVM_DEC);	

	//Write Data Channels Signals	
	
	printer.print_field("WID",     this.WID,     8, UVM_DEC);
	
//	printer.print_field("WDATA",   this.WDATA,   32,UVM_DEC);'
	foreach(WDATA[i])
	
    	printer.print_field($sformatf("WDATA[%0d]",i),     this.WDATA[i], 32, UVM_DEC);

	foreach(WSTRB[i])
	printer.print_field($sformatf("WSTRB[%0d]",i),     this.WSTRB[i],  4, UVM_BIN);

//    	printer.print_generic("WSTRB", "logic",	$bits(WSTRB),WSTRB.name);
	

	printer.print_field("WLAST",   this.WLAST,   1, UVM_DEC);	
	printer.print_field("WREADY",  this.WREADY,  1, UVM_DEC);
	printer.print_field("WVALID",  this.WVALID,  1, UVM_DEC);	
	
	
	
	//Write Response Channel Signals		
      
	printer.print_field("BID",     this.BID,     8, UVM_DEC);	
	printer.print_field("BRESP",   this.BRESP,   2, UVM_DEC);	
	printer.print_field("BVALID",  this.BVALID,  1, UVM_DEC);	
	printer.print_field("BREADY",  this.BREADY,  1, UVM_DEC);	
	
	// Read Address Channel Signals	
	
	printer.print_field("ARID",    this.ARID,    8, UVM_DEC);	
	printer.print_field("ARADDR",  this.ARADDR,  32,UVM_DEC);	
	printer.print_field("ARLEN",   this.ARLEN,   8, UVM_DEC);	
	printer.print_field("ARSIZE",  this.ARSIZE,  3, UVM_DEC);	
	printer.print_field("ARBURST", this.ARBURST, 2, UVM_DEC);	
        printer.print_field("ARVALID", this.ARVALID, 1, UVM_DEC);	
	printer.print_field("ARREADY", this.ARREADY, 1, UVM_DEC);	

	//Read Data Channel Signals	
	
	printer.print_field("RID",     this.RID,     8, UVM_DEC);
	
	foreach(RDATA[i])
	begin
	printer.print_field($sformatf("RDATA[%0d]",i),   this.RDATA[i],   32,UVM_DEC);
//    	printer.print_generic("RDATA", "logic",	$bits(RDATA),RDATA.name);

	printer.print_field("RRESP",   this.RRESP[i],   2, UVM_DEC);
//    	printer.print_generic("RRESP", "logic",	$bits(RRESP),RRESP.name);
	end	
	printer.print_field("RLAST",   this.RLAST,   1, UVM_DEC);	
	printer.print_field("RVALID",  this.RVALID,  1, UVM_DEC);	
	printer.print_field("RREADY",  this.RREADY,  1, UVM_DEC);	

endfunction


	function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		axi_xtn rhs_;
		if(!$cast(rhs_, rhs))
		begin
			`uvm_fatal("do_compare", "failed");
			return 0;
		end
		return super.do_compare(rhs, comparer) &&
		AWID    == rhs_.AWID &&
		AWADDR  == rhs_.AWADDR &&
		AWSIZE  == rhs_.AWSIZE &&
		AWBURST == rhs_.AWBURST &&
		WID     == rhs_.WID &&
		WDATA   == rhs_.WDATA &&
		BID     == rhs_.BID &&
		BRESP   == rhs_.BRESP &&
		ARID    == rhs_.ARID &&
		ARADDR  == rhs_.ARADDR &&
		ARLEN   == rhs_.ARLEN &&
		ARSIZE  == rhs_.ARSIZE &&
		ARBURST == rhs_.ARBURST &&
		RID     == rhs_.RID &&
		RDATA   == rhs_.RDATA &&
		RRESP   == rhs_.RRESP;
	endfunction	


endclass
	
