module ip_rgb_to_hsv_wrapper #(
	parameter integer M_AXIS_TDATA_WIDTH = 64,
	parameter integer M_AXIS_START_COUNT = 32,
	parameter integer S_AXIS_TDATA_WIDTH = 64,
	parameter integer S_AXIS_START_COUNT = 32
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
	input logic s_axis_tlast
);
	if_axi_stream #(
		.TDATA_WIDTH (M_AXIS_TDATA_WIDTH),
		.START_COUNT (M_AXIS_START_COUNT)
	) m_axis ();

	if_axi_stream #(
		.TDATA_WIDTH (S_AXIS_TDATA_WIDTH),
		.START_COUNT (S_AXIS_START_COUNT)
	) s_axis ();

	ip_rgb_to_hsv #() u_ip_rgb_to_hsv (
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
endmodule