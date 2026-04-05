module ip_inrange (
	if_axi_lite.slave s_axil,

	if_axi_stream.slave s_axis,
	if_axi_stream.master m_axis
);
	logic [s_axil.ADDR_WIDTH - 1: 0]	reg_addr;
	logic [s_axil.DATA_WIDTH - 1: 0]	reg_rd_data;
	logic 								reg_wr_en;
	logic [s_axil.DATA_WIDTH - 1: 0]	reg_wr_data;

	axi_lite_slave_logic u_axi_lite_slave_logic (
		.if_slave       (s_axil),
		.reg_addr       (reg_addr),
		.reg_rd_data    (reg_rd_data),
		.reg_wr_en      (reg_wr_en),
		.reg_wr_data    (reg_wr_data)
	);

	cv_pkt_pkg::pkt_hsv lower;
	cv_pkt_pkg::pkt_hsv upper;

	always_ff @(posedge s_axil.aclk or negedge s_axil.aresetn) begin
		if (s_axil.aresetn == 0) begin
			lower <= 0;
			upper <= 0;
		end else begin
			if (reg_wr_en) begin
				if (reg_addr == 'h0) begin
					lower.h <= reg_wr_data[8 * (0 + 0)+: 8];
					lower.s <= reg_wr_data[8 * (0 + 1)+: 8];
					lower.v <= reg_wr_data[8 * (0 + 2)+: 8];
				end

				if (reg_addr == 'h1) begin
					upper.h <= reg_wr_data[8 * (0 + 0)+: 8];
					upper.s <= reg_wr_data[8 * (0 + 1)+: 8];
					upper.v <= reg_wr_data[8 * (0 + 2)+: 8];
				end
			end
		end
	end

	cv_pkt_pkg::pkt_hsv in_0;
	assign in_0.h = s_axis.tdata[8 * (0 + 0)+: 8];
	assign in_0.s = s_axis.tdata[8 * (0 + 1)+: 8];
	assign in_0.v = s_axis.tdata[8 * (0 + 2)+: 8];

	cv_pkt_pkg::pkt_hsv in_1;
	assign in_1.h = s_axis.tdata[8 * (4 + 0)+: 8];
	assign in_1.s = s_axis.tdata[8 * (4 + 1)+: 8];
	assign in_1.v = s_axis.tdata[8 * (4 + 2)+: 8];

	logic mask_0;
	assign m_axis.tdata[8 * (0 + 0)+: 8] = mask_0 ? 255: 0;
	assign m_axis.tdata[8 * (0 + 1)+: 8] = mask_0 ? 255: 0;
	assign m_axis.tdata[8 * (0 + 2)+: 8] = mask_0 ? 255: 0;
	assign m_axis.tdata[8 * (0 + 3)+: 8] = 255;

	logic mask_1;
	assign m_axis.tdata[8 * (4 + 0)+: 8] = mask_1 ? 255: 0;
	assign m_axis.tdata[8 * (4 + 1)+: 8] = mask_1 ? 255: 0;
	assign m_axis.tdata[8 * (4 + 2)+: 8] = mask_1 ? 255: 0;
	assign m_axis.tdata[8 * (4 + 3)+: 8] = 255;

	assign s_axis.tready = m_axis.tready;


	cv_inrange u_cv_inrange_0 (
		.aclk        (s_axis.aclk),
		.aresetn     (s_axis.aresetn),
		.s_tvalid    (s_axis.tvalid),
		.s_tlast     (s_axis.tlast),
		.in          (in_0),
		.lower       (lower),
		.upper       (upper),
		.mask        (mask_0),
		.m_tvalid    (m_axis.tvalid),
		.m_tlast     (m_axis.tlast)
	);

	cv_inrange u_cv_inrange_1 (
		.aclk        (s_axis.aclk),
		.aresetn     (s_axis.aresetn),
		// .s_tvalid    (s_axis.tvalid),
		// .s_tlast     (s_axis.tlast),
		.in          (in_1),
		.lower       (lower),
		.upper       (upper),
		.mask        (mask_1)
		// .m_tvalid    (m_axis_tvalid),
		// .m_tlast     (m_axis_tlast)
	);
endmodule
