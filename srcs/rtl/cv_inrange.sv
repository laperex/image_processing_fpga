module cv_inrange #(
	parameter DATA_WIDTH = 34
)(
	input logic aclk,
	input logic aresetn,

	input logic s_tvalid,
	input logic s_tlast,
	
	input cv_pkt_pkg::pkt_hsv in,
	input cv_pkt_pkg::pkt_hsv lower,
	input cv_pkt_pkg::pkt_hsv upper,

	output logic mask,
	
	output logic m_tvalid,
	output logic m_tlast
);
	always_ff @(posedge aclk or negedge aresetn) begin
		if (aresetn == 0) begin
			mask <= 0;
			m_tvalid <= 0;
			m_tlast <= 0;
		end else begin
			mask <= (in.h >= lower.h) && (in.h <= upper.h) && (in.s >= lower.s) && (in.s <= upper.s) && (in.v >= lower.v) && (in.v <= upper.v);
			m_tvalid <= s_tvalid;
			m_tlast <= s_tlast;
		end
	end
endmodule
