module axi_lite_slave_logic (
	if_axi_lite.slave if_slave,

	output logic [if_slave.ADDR_WIDTH - 1: 0] reg_addr,
	input logic [if_slave.DATA_WIDTH - 1: 0] reg_rd_data,
	output logic reg_wr_en,
	output logic [if_slave.DATA_WIDTH - 1: 0] reg_wr_data
);
	// AXI4LITE signals
	logic [if_slave.ADDR_WIDTH - 1: 0] axi_awaddr;
	logic axi_awready;
	logic axi_wready;
	logic [1: 0] axi_bresp;
	logic axi_bvalid;
	logic [if_slave.ADDR_WIDTH - 1: 0] axi_araddr;
	logic axi_arready;
	logic [1: 0] axi_rresp;
	logic axi_rvalid;

	// if_axi_lite_reg_32_t #(.ADDRESS(100)) a;
	// integer a = a.ADDRESS;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit if_slave.DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (if_slave.DATA_WIDTH / 32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 4;
	
	// if_axi_lite_32_t #(.ADDR(10)) a();
	
	// a::DATA_WIDTH = 20;

	// I/O Connections assignments
	assign if_slave.awready	= axi_awready;
	assign if_slave.wready	= axi_wready;
	assign if_slave.bresp	= axi_bresp;
	assign if_slave.bvalid	= axi_bvalid;
	assign if_slave.arready	= axi_arready;
	assign if_slave.rresp	= axi_rresp;
	assign if_slave.rvalid	= axi_rvalid;


	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, if_slave.wvalid, axi_wready and if_slave.wvalid are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.

	always_comb begin
		reg_addr = (if_slave.awvalid) ? if_slave.awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS: ADDR_LSB]: axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS: ADDR_LSB];

		// WRITE TO SLV_REG
		for (integer byte_index = 0; byte_index <= (if_slave.DATA_WIDTH / 8) - 1; byte_index = byte_index + 1) begin
			reg_wr_en = if_slave.wvalid;

			if (if_slave.wstrb[byte_index] == 1) begin
				reg_wr_data[(byte_index * 8) +: 8] = if_slave.wdata[(byte_index * 8) +: 8];
			end else begin
				reg_wr_data = 0;
			end
		end

		// READ FROM SLV_REG
		if_slave.rdata = reg_rd_data;
	end


	//state machine varibles
	logic [1: 0] state_write;
	logic [1: 0] state_read;

	//State machine local parameters
	localparam Idle		= 0;
	localparam Raddr	= 2;
	localparam Rdata	= 3;
	localparam Waddr	= 2;
	localparam Wdata	= 3;

	// Implement Write state machine
	// Outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
	always @(posedge if_slave.aclk) begin
		if (if_slave.aresetn == 0) begin
			axi_awready <= 0;
			axi_wready <= 0;
			axi_bvalid <= 0;
			axi_bresp <= 0;
			axi_awaddr <= 0;
			state_write <= Idle;
		end else begin
			case (state_write)
				Idle: begin
					if (if_slave.aresetn == 1) begin
						axi_awready <= 1;
						axi_wready <= 1;
						state_write <= Waddr;
					end else begin
						state_write <= state_write;
					end
				end

				Waddr: begin	//At this state, slave is ready to receive address along with corresponding control signals and first data packet. Response valid is also handled at this state
					if (if_slave.awvalid && if_slave.awready) begin
						axi_awaddr <= if_slave.awaddr;
						
						if (if_slave.wvalid) begin
							axi_awready <= 1;
							state_write <= Waddr;
							axi_bvalid <= 1;
						end else begin
							axi_awready <= 0;
							state_write <= Wdata;

							if (if_slave.bready && axi_bvalid) begin
								axi_bvalid <= 0;
							end
						end
					end else begin
						state_write <= state_write;
						
						if (if_slave.bready && axi_bvalid) begin
							axi_bvalid <= 0;
						end
					end
				end

				Wdata: begin	//At this state, slave is ready to receive the data packets until the number of transfers is equal to burst length
					if (if_slave.wvalid) begin
						state_write <= Waddr;
						axi_bvalid <= 1;
						axi_awready <= 1;
					end else begin
						state_write <= state_write;

						if (if_slave.bready && axi_bvalid) begin
							axi_bvalid <= 0;
						end
					end
				end
			endcase
		end
	end

	// Implement read state machine
	always @(posedge if_slave.aclk) begin
		if (if_slave.aresetn == 0) begin
			axi_arready <= 0;
			axi_rvalid <= 0;
			axi_rresp <= 0;
			state_read <= Idle;
		end else begin
			case (state_read)
				Idle: begin		//Initial state inidicating reset is done and ready to receive read/write transactions
					if (if_slave.aresetn == 1) begin
						state_read <= Raddr;
						axi_arready <= 1;
					end else begin
						state_read <= state_read;
					end
				end

				Raddr: begin	//At this state, slave is ready to receive address along with corresponding control signals
					if (if_slave.arvalid && if_slave.arready) begin
						state_read <= Rdata;
						axi_araddr <= if_slave.araddr;
						axi_rvalid <= 1;
						axi_arready <= 0;
					end else begin
						state_read <= state_read;
					end
				end

				Rdata: begin	//At this state, slave is ready to send the data packets until the number of transfers is equal to burst length
					if (if_slave.rvalid && if_slave.rready) begin
						axi_rvalid <= 0;
						axi_arready <= 1;
						state_read <= Raddr;
					end else begin
						state_read <= state_read;
					end
				end
			endcase
		end
	end

	// Implement memory mapped register select and read logic generation
	// assign if_slave.rdata = slv_reg[axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS: ADDR_LSB]];
endmodule
