module tb_axi_lite_slave_example #(parameter data_width = 3);
    /* ------------------------------------------------------------------------
    ** data_width will be overidden by chiptools.
    ** Icarus does not support Parameter overrides, but other tools do. We work
    ** around this by providing a Parameter for tools that do support them and 
    ** then create a `define for each parameter of the same name so that tools
    ** that do not support parameter overrides can overload the `define
    ** instead. 
    ** ----------------------------------------------------------------------*/
    `ifndef data_width
        `define data_width data_width
    `endif

    //// Parameters of Axi Slave Bus Interface S_AXI
    parameter C_S_AXI_DATA_WIDTH = 32;
    parameter C_S_AXI_ADDR_WIDTH = 16;
    parameter C_S_AXI_ADDR_MSB = 15;
    parameter C_S_AXI_ADDR_LSB = 2;

    /* ------------------------------------------------------------------------
    ** Registers / Wires
    ** ----------------------------------------------------------------------*/
    reg clock = 1, reset = 0;
    reg [`data_width-1:0] data;
    reg [`data_width-1:0] read_data;
    integer fileid;
    integer readCount;
    integer outFileId;
    integer firstCall = 1;
    integer lastCycle = 0;
    reg [`data_width-1:0] inData = 0;

    reg start_tb = 0;
    reg axi_bus_free = 0;
    reg [1:0] cs_signals = 'b00;

    wire  axi_aclk;
    wire  s_axi_aresetn;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_slave1_awaddr;
    reg [2 : 0] axi_slave1_awprot;
    reg  axi_slave1_awvalid;
    wire  axi_slave1_awready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_slave1_wdata;
    reg [(C_S_AXI_DATA_WIDTH/8)-1 : 0] axi_slave1_wstrb;
    reg  axi_slave1_wvalid;
    wire  axi_slave1_wready;
    wire [1 : 0] axi_slave1_bresp;
    wire  axi_slave1_bvalid;
    reg  axi_slave1_bready;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_slave1_araddr;
    reg [2 : 0] axi_slave1_arprot;
    reg  axi_slave1_arvalid;
    wire  axi_slave1_arready;
    wire [C_S_AXI_DATA_WIDTH-1 : 0] axi_slave1_rdata;
    wire [1 : 0] axi_slave1_rresp;
    wire  axi_slave1_rvalid;
    reg  axi_slave1_rready;

    assign axi_aclk = clock;
    assign s_axi_aresetn = reset;

    /* ------------------------------------------------------------------------
    ** Clock Generation: 100 MHz
    ** ----------------------------------------------------------------------*/
    initial
    begin
        clock = 1;
        forever #5 clock = ~clock;
    end

    initial
    begin
        start_tb = 0;
        axi_bus_free = 0;
        cs_signals = 'b00;

        axi_slave1_awaddr = 'hz;
        axi_slave1_awprot = 0;
        axi_slave1_awvalid = 0;
        axi_slave1_wdata = 'hz;
        axi_slave1_wstrb = 0;
        axi_slave1_wvalid = 0;
        // axi_slave1_wready = 'hz;
        // axi_slave1_bresp = 'hz;
        // axi_slave1_bvalid = 0;
        axi_slave1_bready = 'hz;
        axi_slave1_araddr = 'hz;
        axi_slave1_arprot = 'hz;
        axi_slave1_arvalid = 0;
        // axi_slave1_arready = 'hz;
        // axi_slave1_rdata = 'hz;
        // axi_slave1_rresp = 0;
        // axi_slave1_rvalid = 0;
        axi_slave1_rready = 0;

        reset = 0;
        #50 reset = 1;
        #50 axi_bus_free = 1;
        #100 start_tb = 1;
    end

    /* ------------------------------------------------------------------------
    ** Open File Handles
    ** ----------------------------------------------------------------------*/
    initial begin
        fileid = $fopen("input.txt", "r");
        outFileId = $fopen("output.txt", "w");
        $display("data_width is%d", `data_width);
        if (fileid == 0) begin
            $display("Could not open file.");
            $finish;
        end
    end

    /* ------------------------------------------------------------------------
    ** Waveform File Dump 
    ** ----------------------------------------------------------------------*/
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, tb_axi_lite_slave_example);
    end
    /* ------------------------------------------------------------------------
    ** Stimulus Generation and Logging
    ** ----------------------------------------------------------------------*/
    always begin
        wait (start_tb);
        if (!lastCycle) begin
            readCount = $fscanf(fileid, "%b\n", inData);
        end
        data <= inData;

        @(posedge clock);
        write_register({14'd1025, 2'b00}, data); // reg 0
        read_register({14'd1025, 2'b00}, read_data); // reg 0

        @(posedge clock);
        if (firstCall) begin
            firstCall = 0;
        end else begin
            if (!lastCycle) begin
                $fwrite(outFileId, "%b\n", read_data);
                if ($feof(fileid)) begin
                    $fclose(fileid);
                    lastCycle = 1;
                end
            end else begin
                $fwrite(outFileId, "%b\n", read_data);
                $fflush();
                $fclose(outFileId);
                $finish;
            end
        end
    end

    /* ------------------------------------------------------------------------
    ** UUT Instance
    ** ----------------------------------------------------------------------*/
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
    axi_lite_slave_example # (
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
    ) axi_lite_slave_example_i (
        //// AXI I/O Signals
        // NB: s_axi_aclk comes at end
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_awaddr(axi_slave1_awaddr[C_S_AXI_ADDR_WIDTH-1:0]),
        .s_axi_awprot(axi_slave1_awprot[2:0]),
        .s_axi_awvalid(axi_slave1_awvalid & cs_signals[0]),
        .s_axi_awready(axi_slave1_awready),
        .s_axi_wdata(axi_slave1_wdata[C_S_AXI_DATA_WIDTH-1:0]),
        .s_axi_wstrb(axi_slave1_wstrb[C_S_AXI_DATA_WIDTH/8-1:0]),
        .s_axi_wvalid(axi_slave1_wvalid & cs_signals[0]),
        .s_axi_wready(axi_slave1_wready),
        .s_axi_bresp(axi_slave1_bresp[1:0]),
        .s_axi_bvalid(axi_slave1_bvalid),
        .s_axi_bready(axi_slave1_bready),
        .s_axi_araddr(axi_slave1_araddr[C_S_AXI_ADDR_WIDTH-1:0]),
        .s_axi_arprot(axi_slave1_arprot[2:0]),
        .s_axi_arvalid(axi_slave1_arvalid & cs_signals[0]),
        .s_axi_arready(axi_slave1_arready),
        .s_axi_rdata(axi_slave1_rdata[C_S_AXI_DATA_WIDTH-1:0]),
        .s_axi_rresp(axi_slave1_rresp[1:0]),
        .s_axi_rvalid(axi_slave1_rvalid),
        .s_axi_rready(axi_slave1_rready),
        //// Memory Map
        .enable(enable),
        .output_en(output_en),
        .ring_count(ring_count),
        .ring_counta(ring_counta),
        .ring_countb(ring_countb),
        .s_axi_aclk(axi_aclk) // s_axi_aclk is last to ensure no trailing comma
    );

task read_register;
    input [C_S_AXI_ADDR_WIDTH:0] reg_addr;
    output [C_S_AXI_DATA_WIDTH:0] data;

    begin
        // wait (axi_bus_free);
        // axi_bus_free = 0;
        @ (posedge axi_aclk);
        #1;
        cs_signals[0] = 1;
        axi_slave1_araddr = reg_addr;
        axi_slave1_arvalid = 1;
        axi_slave1_rready = 1;
        // wait (axi_slave1_arready);
        wait (axi_slave1_rvalid);
        $display("(%0t) Reading register [%0d] = 0x%0x", $time, axi_slave1_araddr, axi_slave1_rdata);
        data = axi_slave1_rdata;
        @ (posedge axi_aclk);
        #1;
        axi_slave1_araddr = 'hz;
        axi_slave1_arvalid = 0;
        axi_slave1_rready = 0;
        cs_signals[0] = 0;
        // axi_bus_free = 1;
    end
endtask


task write_register;
    input [C_S_AXI_ADDR_WIDTH:0] reg_addr;
    input [C_S_AXI_DATA_WIDTH:0] reg_data;

    begin
        // wait (axi_bus_free);
        // axi_bus_free = 0;
        @ (posedge axi_aclk);
        $display("(%0t) Writing register [%0d] = 0x%0x", $time, reg_addr, reg_data);
        #1;
        cs_signals[0] = 1;
        axi_slave1_awaddr = reg_addr;
        axi_slave1_wdata = reg_data;
        axi_slave1_wstrb = ~0;
        axi_slave1_awvalid = 1;
        axi_slave1_wvalid = 1;
        axi_slave1_bready = 1;
        wait (axi_slave1_wready);
        // wait (axi_slave1_bvalid);
        @ (posedge axi_aclk);
        #1;
        axi_slave1_awaddr = 'hz;
        axi_slave1_wdata = 'hz;
        axi_slave1_wstrb = 'h0;
        axi_slave1_awvalid = 0;
        axi_slave1_wvalid = 0;
        axi_slave1_bready = 0;
        cs_signals[0] = 0;
        // axi_bus_free = 1;
    end
endtask

endmodule
