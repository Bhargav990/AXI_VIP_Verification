interface axi_if(input bit ACLK);

	logic [3:0] AWID;
	logic [31:0]AWADDR;
	logic [3:0]AWLEN;
	logic [2:0]AWSIZE;    //write address channel
	logic [1:0]AWBURST;
	logic AWVALID;
	logic AWREADY;

	//write data channel
	logic [3:0]WID;
	logic[31:0] WDATA;
	logic [3:0]WSTRB;
	logic WLAST;
	logic WVALID;
	logic WREADY;
	

	//write response channel
	logic [3:0]BID;
	logic [1:0]BRESP;
	logic BVALID;
	logic BREADY;


	//read address channel
	logic [3:0]ARID;
	logic [31:0]ARADDR;
	logic [3:0]ARLEN;
	logic [2:0]ARSIZE;
	logic [1:0]ARBURST;
	logic ARVALID;
	logic ARREADY;
	

	//read data channel
	logic [3:0]RID;
	logic [31:0]RDATA;
	logic RLAST;
	logic RVALID;
	logic RREADY;
	logic [1:0]RRESP;


	// write driver clocking block 
	clocking mst_drv_cb @(posedge ACLK);
		default input #1 output #1;
		output 	AWID; 
		output	AWADDR;
		output AWLEN;
		output AWSIZE;
		output AWBURST;
		output AWVALID;
		output WID;
		output WDATA;
		output WSTRB;
		output WLAST;
		output WVALID;
		output ARID;
		output ARADDR;
		output ARLEN;
		output ARSIZE;
		output ARBURST;
		output ARVALID;
		output RREADY;
		output BREADY;

		input BID;
		input BRESP;
		input BVALID;
		input ARREADY;
		input RID;
		input RDATA;
		input RVALID;
		input RRESP;
		input RLAST;
		input AWREADY;
		input WREADY;
	endclocking

	
	clocking mst_mon_cb @(posedge ACLK);
		default input #1 output #1;
		input AWID;
		input AWADDR;
		input AWLEN;
		input AWSIZE;
		input AWBURST;
		input AWVALID;
		input WID;
		input WDATA;
		input WSTRB;
		input WLAST;
		input WVALID;
		input ARID; 
		input ARADDR;
		input ARLEN;
		input ARSIZE;
		input ARBURST;
		input ARVALID;
		input RREADY;
		input BREADY;


		input BID;
		input BRESP;
		input BVALID;
		input ARREADY;
		input RID;
		input RDATA;
		input RVALID;
		input RRESP;
		input RLAST;
		input AWREADY;
		input WREADY;

	endclocking

	clocking slv_drv_cb @(posedge ACLK);
		default input #1 output #1;
		output BID;
		output BRESP;
		output BVALID;
		output ARREADY;
		output RID;
		output RDATA;
		output RVALID;
		output RRESP;
		output RLAST;
		output AWREADY;
		output WREADY;

	
		input AWID;
		input AWADDR;
		input AWLEN;
		input AWSIZE;
		input AWBURST;
		input AWVALID;
		input WID;
		input WDATA;
		input WSTRB;
		input WLAST;
		input WVALID;
		input ARID;
		input ARADDR;
		input ARLEN;
		input ARSIZE;	
		input ARBURST ;
		input ARVALID;
		input RREADY;
		input BREADY;

	endclocking 

	clocking slv_mon_cb @(posedge ACLK);
		default input #1 output #1;
		input BID;
		input BRESP;
		input BVALID;
		input ARREADY;
		input RID;
		input RDATA;
		input RVALID;
		input RRESP;
		input RLAST;
		input AWREADY;
		input WREADY;


	
		input AWID;
		input AWADDR;
		input AWLEN;
		input AWSIZE;
		input AWBURST;
		input AWVALID;
		input WID;
		input WDATA;
		input WSTRB;
		input WLAST;
		input WVALID;
		input ARID;
		input ARADDR;
		input ARLEN;
		input ARSIZE;
		input ARBURST;
		input ARVALID;
		input RREADY;
		input BREADY;

	endclocking 


	modport MST_DRV_MP (clocking mst_drv_cb);
	modport MST_MON_MP (clocking mst_mon_cb);
	modport SLV_DRV_MP (clocking slv_drv_cb);
	modport SLV_MON_MP (clocking slv_mon_cb);


	property aw_ctrl_stable_when_waiting;
 			 @(posedge ACLK) 
    				(AWVALID && !AWREADY) |-> ##1
     								 ($stable(AWADDR) &&
      								 $stable(AWSIZE) &&
      					 			$stable(AWBURST) &&
      					 			$stable(AWLEN));
	endproperty

	AW_CTRL_STABLE_P: assert property (aw_ctrl_stable_when_waiting);


endinterface




