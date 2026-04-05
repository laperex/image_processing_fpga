module ip_inrange_wrapper #(
	parameter integer M_AXIS_TDATA_WIDTH = 64,
	parameter integer M_AXIS_START_COUNT = 32,
	parameter integer S_AXIS_TDATA_WIDTH = 64,
	parameter integer S_AXIS_START_COUNT = 32,
	parameter integer S_AXIL_START_DATA_VALUE = 32'hAA000000,
	parameter integer S_AXIL_TARGET_SLAVE_BASE_ADDR = 32'h40000000,
	parameter integer S_AXIL_ADDR_WIDTH = 32,
	parameter integer S_AXIL_DATA_WIDTH = 32,
	parameter integer S_AXIL_TRANSACTIONS_NUM = 4
) (
	input logic m_axis_aclk,
	input logic m_axis_aresetn,
	output logic [M_AXIS_TDATA_WIDTH - 1: 0] m_axis_tdata,
	output logic [(M_AXIS_TDATA_WIDTH/8) - 1: 0] m_axis_tstrb,
	output logic m_axis_tvalid,
	input logic m_axis_tready,
	output logic m_axis_tlast,
	input logic s_axis_aclk,
	input logic s_axis_aresetn,
	input logic [S_AXIS_TDATA_WIDTH - 1: 0] s_axis_tdata,
	input logic [(S_AXIS_TDATA_WIDTH/8) - 1: 0] s_axis_tstrb,
	input logic s_axis_tvalid,
	output logic s_axis_tready,
	input logic s_axis_tlast,
	input logic s_axil_aclk,
	input logic s_axil_aresetn,
	input logic [S_AXIL_ADDR_WIDTH - 1: 0] s_axil_awaddr,
	input logic [2: 0] s_axil_awprot,
	input logic s_axil_awvalid,
	output logic s_axil_awready,
	input logic [S_AXIL_DATA_WIDTH - 1: 0] s_axil_wdata,
	input logic [(S_AXIL_DATA_WIDTH / 8) - 1: 0] s_axil_wstrb,
	input logic s_axil_wvalid,
	output logic s_axil_wready,
	output logic [1: 0] s_axil_bresp,
	output logic s_axil_bvalid,
	input logic s_axil_bready,
	input logic [S_AXIL_ADDR_WIDTH - 1: 0] s_axil_araddr,
	input logic [2: 0] s_axil_arprot,
	input logic s_axil_arvalid,
	output logic s_axil_arready,
	output logic [S_AXIL_DATA_WIDTH - 1: 0] s_axil_rdata,
	output logic [1: 0] s_axil_rresp,
	output logic s_axil_rvalid,
	input logic s_axil_rready
);
	if_axi_stream #(
		.TDATA_WIDTH (M_AXIS_TDATA_WIDTH),
		.START_COUNT (M_AXIS_START_COUNT)
	) m_axis ();

	if_axi_stream #(
		.TDATA_WIDTH (S_AXIS_TDATA_WIDTH),
		.START_COUNT (S_AXIS_START_COUNT)
	) s_axis ();

	if_axi_lite #(
		.START_DATA_VALUE (S_AXIL_START_DATA_VALUE),
		.TARGET_SLAVE_BASE_ADDR (S_AXIL_TARGET_SLAVE_BASE_ADDR),
		.ADDR_WIDTH (S_AXIL_ADDR_WIDTH),
		.DATA_WIDTH (S_AXIL_DATA_WIDTH),
		.TRANSACTIONS_NUM (S_AXIL_TRANSACTIONS_NUM)
	) s_axil ();

	ip_inrange #() u_ip_inrange (
		.s_axil  (s_axil),
		.s_axis  (s_axis),
		.m_axis  (m_axis)
	);

	assign m_axis.aclk = m_axis_aclk;
	assign m_axis.aresetn = m_axis_aresetn;
	assign m_axis_tdata = m_axis.tdata;
	assign m_axis_tstrb = m_axis.tstrb;
	assign m_axis_tvalid = m_axis.tvalid;
	assign m_axis.tready = m_axis_tready;
	assign m_axis_tlast = m_axis.tlast;
	assign s_axis.aclk = s_axis_aclk;
	assign s_axis.aresetn = s_axis_aresetn;
	assign s_axis.tdata = s_axis_tdata;
	assign s_axis.tstrb = s_axis_tstrb;
	assign s_axis.tvalid = s_axis_tvalid;
	assign s_axis_tready = s_axis.tready;
	assign s_axis.tlast = s_axis_tlast;
	assign s_axil.aclk = s_axil_aclk;
	assign s_axil.aresetn = s_axil_aresetn;
	assign s_axil.awaddr = s_axil_awaddr;
	assign s_axil.awprot = s_axil_awprot;
	assign s_axil.awvalid = s_axil_awvalid;
	assign s_axil_awready = s_axil.awready;
	assign s_axil.wdata = s_axil_wdata;
	assign s_axil.wstrb = s_axil_wstrb;
	assign s_axil.wvalid = s_axil_wvalid;
	assign s_axil_wready = s_axil.wready;
	assign s_axil_bresp = s_axil.bresp;
	assign s_axil_bvalid = s_axil.bvalid;
	assign s_axil.bready = s_axil_bready;
	assign s_axil.araddr = s_axil_araddr;
	assign s_axil.arprot = s_axil_arprot;
	assign s_axil.arvalid = s_axil_arvalid;
	assign s_axil_arready = s_axil.arready;
	assign s_axil_rdata = s_axil.rdata;
	assign s_axil_rresp = s_axil.rresp;
	assign s_axil_rvalid = s_axil.rvalid;
	assign s_axil.rready = s_axil_rready;
endmodule