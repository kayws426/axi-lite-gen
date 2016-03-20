    wire enable;
    wire [32:0] output_en;
    wire [15:0] ring_count;
    reg [15:0] ring_counta = 16'h0;
    reg [15:0] ring_countb = 16'h0;
    //// Static Memory Map Values
    parameter MAGIC = 32'h21EAF;
    parameter VERSION = 32'h0;
    parameter FEATURE_FLAGS = 32'h0;
    parameter GIT_HASH = 32'h0;
    parameter BUILD_TIME = 64'h0;
    axi_lite_slave_example #
    (
        //// Generate-time parameters:
        .MAGIC(MAGIC),
        .VERSION(VERSION),
        .FEATURE_FLAGS(FEATURE_FLAGS),
        .GIT_HASH(GIT_HASH),
        .BUILD_TIME(BUILD_TIME),
        //// Register Default Parameters
        .DEFAULT_ENABLE(1'h0),
        .DEFAULT_OUTPUT_EN(33'h0),
        .DEFAULT_RING_COUNT(16'h0),
        .DEFAULT_RING_COUNTA(16'h0),
        .DEFAULT_RING_COUNTB(16'h0),
        //// Parameters of Axi Slave Bus Interface S_AXI
        .C_S_AXI_DATA_WIDTH(32),
        .C_S_AXI_ADDR_WIDTH(16),
        .C_S_AXI_ADDR_MSB(15),
        .C_S_AXI_ADDR_LSB(2)
    ) axi_lite_slave_example_i_00 (
        //// AXI I/O Signals
        // NB: s_axi_aclk comes at end
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_awaddr(s_axi_awaddr[C_S_AXI_ADDR_WIDTH-1:0]),
        .s_axi_awprot(s_axi_awprot[2:0]),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata[C_S_AXI_DATA_WIDTH-1:0]),
        .s_axi_wstrb(s_axi_wstrb[C_S_AXI_DATA_WIDTH/8-1:0]),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp[1:0]),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr[C_S_AXI_ADDR_WIDTH-1:0]),
        .s_axi_arprot(s_axi_arprot[2:0]),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata[C_S_AXI_DATA_WIDTH-1:0]),
        .s_axi_rresp(s_axi_rresp[1:0]),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        //// Memory Map
        .enable(enable),
        .output_en(output_en),
        .ring_count(ring_count),
        .ring_counta(ring_counta),
        .ring_countb(ring_countb),
        .s_axi_aclk(s_axi_aclk) // s_axi_aclk is last to ensure no trailing comma
    );