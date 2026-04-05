`ifndef AXI_TYPES
`define AXI_TYPES

interface if_axi_stream #(
	parameter integer TDATA_WIDTH	= 64,
	parameter integer START_COUNT	= 32
);
	logic							aclk;
	logic							aresetn;
	logic [TDATA_WIDTH - 1: 0]		tdata;
	logic [(TDATA_WIDTH/8) - 1: 0]	tstrb;
	logic                   		tvalid;
	logic                   		tready;
	logic                   		tlast;

	modport slave (
		input aclk, aresetn,
		input tdata, tstrb, tvalid,
		output tready,
		input tlast
	);

	modport master (
		input aclk, aresetn,
		output tdata, tstrb, tvalid,
		input tready,
		output tlast
	);
endinterface: if_axi_stream


interface if_axi_full #(
	parameter integer TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
	parameter integer BURST_LEN			= 16,

	parameter integer ID_WIDTH			= 1,
	parameter integer DATA_WIDTH		= 32,
	parameter integer ADDR_WIDTH		= 10,
	parameter integer AWUSER_WIDTH		= 0,
	parameter integer ARUSER_WIDTH		= 0,
	parameter integer WUSER_WIDTH		= 0,
	parameter integer RUSER_WIDTH		= 0,
	parameter integer BUSER_WIDTH		= 0
);
	logic  aclk;
	logic  aresetn;
	logic [ID_WIDTH-1 : 0] awid;
	logic [ADDR_WIDTH-1 : 0] awaddr;
	logic [7 : 0] awlen;
	logic [2 : 0] awsize;
	logic [1 : 0] awburst;
	logic  awlock;
	logic [3 : 0] awcache;
	logic [2 : 0] awprot;
	logic [3 : 0] awqos;
	logic [3 : 0] awregion;
	logic [AWUSER_WIDTH-1 : 0] awuser;
	logic  awvalid;
	logic  awready;
	logic [DATA_WIDTH-1 : 0] wdata;
	logic [(DATA_WIDTH/8)-1 : 0] wstrb;
	logic  wlast;
	logic [WUSER_WIDTH-1 : 0] wuser;
	logic  wvalid;
	logic  wready;
	logic [ID_WIDTH-1 : 0] bid;
	logic [1 : 0] bresp;
	logic [BUSER_WIDTH-1 : 0] buser;
	logic  bvalid;
	logic  bready;
	logic [ID_WIDTH-1 : 0] arid;
	logic [ADDR_WIDTH-1 : 0] araddr;
	logic [7 : 0] arlen;
	logic [2 : 0] arsize;
	logic [1 : 0] arburst;
	logic  arlock;
	logic [3 : 0] arcache;
	logic [2 : 0] arprot;
	logic [3 : 0] arqos;
	logic [3 : 0] arregion;
	logic [ARUSER_WIDTH-1 : 0] aruser;
	logic  arvalid;
	logic  arready;
	logic [ID_WIDTH-1 : 0] rid;
	logic [DATA_WIDTH-1 : 0] rdata;
	logic [1 : 0] rresp;
	logic  rlast;
	logic [RUSER_WIDTH-1 : 0] ruser;
	logic  rvalid;
	logic  rready;
	
	modport slave (
		input aclk, aresetn,
		input awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid,
		output awready,
		input wdata, wstrb, wlast, wuser, wvalid,
		output wready, bid, bresp, buser, bvalid,
		input bready, arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid,
		output arready, rid, rdata, rresp, rlast, ruser, rvalid,
		input rready
	);
	
	modport master (
		input aclk, aresetn,
		output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid,
		input awready,
		output wdata, wstrb, wlast, wuser, wvalid,
		input wready, bid, bresp, buser, bvalid,
		output bready, arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid,
		input arready, rid, rdata, rresp, rlast, ruser, rvalid,
		output rready
	);
endinterface: if_axi_full


interface if_axi_lite #(	
	parameter integer START_DATA_VALUE			= 32'hAA000000,
	parameter integer TARGET_SLAVE_BASE_ADDR	= 32'h1000,
	parameter integer ADDR_WIDTH		= 32,
	parameter integer DATA_WIDTH		= 32,
	parameter integer TRANSACTIONS_NUM	= 4
);
	logic							aclk;
	logic							aresetn;
	logic [ADDR_WIDTH - 1: 0]		awaddr;
	logic [2: 0] 					awprot;
	logic							awvalid;
	logic							awready;
	logic [DATA_WIDTH - 1: 0] 		wdata;
	logic [(DATA_WIDTH / 8) - 1: 0]	wstrb;
	logic							wvalid;
	logic							wready;
	logic [1: 0] 					bresp;
	logic							bvalid;
	logic							bready;
	logic [ADDR_WIDTH - 1: 0] 		araddr;
	logic [2: 0] 					arprot;
	logic							arvalid;
	logic							arready;
	logic [DATA_WIDTH - 1: 0] 		rdata;
	logic [1: 0] 					rresp;
	logic							rvalid;
	logic							rready;

	modport slave (
		input aclk, aresetn,
		input awaddr, awprot, awvalid,
		output awready,
		input wdata, wstrb, wvalid,
		output wready, bresp, bvalid,
		input bready, araddr, arprot, arvalid,
		output arready, rdata, rresp, rvalid,
		input rready
	);

	modport master (
		input aclk, aresetn,
		output awaddr, awprot, awvalid,
		input awready,
		output wdata, wstrb, wvalid,
		input wready, bresp, bvalid,
		output bready, araddr, arprot, arvalid,
		input arready, rdata, rresp, rvalid,
		output rready
	);
endinterface: if_axi_lite

`endif // AXI_TYPES
