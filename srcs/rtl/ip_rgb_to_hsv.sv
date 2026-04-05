module ip_rgb_to_hsv (
	if_axi_stream.slave s_axis,
	if_axi_stream.master m_axis
);
	assign s_axis.tready = m_axis.tready;

	cv_pkt_pkg::pkt_rgb m0_in;
	cv_pkt_pkg::pkt_hsv m0_out;
	logic m0_s_tvalid;
	logic m0_s_tlast;
	cv_pkt_pkg::pkt_rgb m1_in;
	cv_pkt_pkg::pkt_hsv m1_out;
	logic m1_s_tvalid;
	logic m1_s_tlast;

	assign m0_in.r = s_axis.tdata[8 * (0 + 0)+: 8];
	assign m0_in.g = s_axis.tdata[8 * (0 + 1)+: 8];
	assign m0_in.b = s_axis.tdata[8 * (0 + 2)+: 8];
	assign m0_s_tvalid = s_axis.tvalid;
	assign m0_s_tlast = s_axis.tlast;
	assign m_axis.tdata[8 * (0 + 0)+: 8] = m0_out.h;
	assign m_axis.tdata[8 * (0 + 1)+: 8] = m0_out.s;
	assign m_axis.tdata[8 * (0 + 2)+: 8] = m0_out.v;

	assign m1_in.r = s_axis.tdata[8 * (4 + 0)+: 8];
	assign m1_in.g = s_axis.tdata[8 * (4 + 1)+: 8];
	assign m1_in.b = s_axis.tdata[8 * (4 + 2)+: 8];
	assign m1_s_tvalid = s_axis.tvalid;
	assign m1_s_tlast = s_axis.tlast;
	assign m_axis.tdata[8 * (4 + 0)+: 8] = m1_out.h;
	assign m_axis.tdata[8 * (4 + 1)+: 8] = m1_out.s;
	assign m_axis.tdata[8 * (4 + 2)+: 8] = m1_out.v;

	assign m_axis.tvalid = m0_m_tvalid | m1_m_tvalid;
	assign m_axis.tlast = m0_m_tlast | m1_m_tlast;

	cv_rgb_to_hsv u_cv_rgb_to_hsv_0 (
		.aclk         (aclk),
		.aresetn     (aresetn),
		
		.in          (m0_in),
		.s_tvalid    (m0_s_tvalid),
		.s_tlast     (m0_s_tlast),

		.out         (m0_out),
		.m_tvalid    (m0_m_tvalid),
		.m_tlast     (m0_m_tlast)
	);

	cv_rgb_to_hsv u_cv_rgb_to_hsv_1 (
		.aclk         (aclk),
		.aresetn     (aresetn),
		
		.in          (m1_in),
		.s_tvalid    (m1_s_tvalid),
		.s_tlast     (m1_s_tlast),

		.out         (m1_out),
		.m_tvalid    (m1_m_tvalid),
		.m_tlast     (m1_m_tlast)
	);
endmodule
