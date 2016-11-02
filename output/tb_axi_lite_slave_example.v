`timescale 1 ns / 1 ps

module tb_axi_lite_slave_example #
    (
    parameter axi_data_width = 32,
    parameter axi_addr_width = 16
    );
    /* ------------------------------------------------------------------------
    ** axi_data_width and axi_addr_width will be overidden by chiptools.
    ** Icarus does not support Parameter overrides, but other tools do. We work
    ** around this by providing a Parameter for tools that do support them and 
    ** then create a `define for each parameter of the same name so that tools
    ** that do not support parameter overrides can overload the `define
    ** instead. 
    ** ----------------------------------------------------------------------*/
    `ifndef axi_data_width
        `define axi_data_width axi_data_width
    `endif

    `ifndef axi_addr_width
        `define axi_addr_width axi_addr_width
    `endif

    //// Parameters of Axi Slave Bus Interface S_AXI
    parameter C_S_AXI_DATA_WIDTH = `axi_data_width;
    parameter C_S_AXI_ADDR_WIDTH = `axi_addr_width;
    parameter C_S_AXI_ADDR_MSB = `axi_addr_width - 1;
    parameter C_S_AXI_ADDR_LSB = 2;

    /* ------------------------------------------------------------------------
    ** Registers / Wires
    ** ----------------------------------------------------------------------*/
    reg clock = 1, reset = 0;
    integer fileid;
    integer readCount;
    integer outFileId;
    integer firstCall = 1;
    integer lastCycle = 0;
    reg [`axi_data_width-1:0] inData = 0;

    reg [`axi_data_width-1:0] opArg2 = 0;
    reg [`axi_data_width-1:0] opArg1 = 0;
    reg[32*8:0] opCodeString;

    reg start_tb = 0;
    reg axi_bus_free = 0;
    reg [1:0] cs_signals = 'b00;

    wire  s_axi_aclk;
    wire  s_axi_aresetn;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr;
    reg [2 : 0] s_axi_awprot;
    reg  s_axi_awvalid;
    wire  s_axi_awready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata;
    reg [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb;
    reg  s_axi_wvalid;
    wire  s_axi_wready;
    wire [1 : 0] s_axi_bresp;
    wire  s_axi_bvalid;
    reg  s_axi_bready;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr;
    reg [2 : 0] s_axi_arprot;
    reg  s_axi_arvalid;
    wire  s_axi_arready;
    wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata;
    wire [1 : 0] s_axi_rresp;
    wire  s_axi_rvalid;
    reg  s_axi_rready;

    assign s_axi_aclk = clock;
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

        s_axi_awaddr = 'hz;
        s_axi_awprot = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 'hz;
        s_axi_wstrb = 0;
        s_axi_wvalid = 0;
        // s_axi_wready = 'hz;
        // s_axi_bresp = 'hz;
        // s_axi_bvalid = 0;
        s_axi_bready = 'hz;
        s_axi_araddr = 'hz;
        s_axi_arprot = 'hz;
        s_axi_arvalid = 0;
        // s_axi_arready = 'hz;
        // s_axi_rdata = 'hz;
        // s_axi_rresp = 0;
        // s_axi_rvalid = 0;
        s_axi_rready = 0;

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
        $display("axi_data_width is %0d, axi_addr_width is %0d", `axi_data_width, `axi_addr_width);
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
        readCount = $fscanf(fileid, "%s %X %X\n", opCodeString, opArg1, opArg2);
        if (readCount == 2) begin
            opArg2 = 0;
        end else if (readCount == 1) begin
            opArg1 = 0;
            opArg2 = 0;
        end else if (readCount == 0) begin
            opCodeString = "nop";
            opArg1 = 0;
            opArg2 = 0;
        end
        // $display("readCount %d, opCodeString %s, opArg1 %d, opArg2 %d", readCount, opCodeString, opArg1, opArg2);


        if (opCodeString == "write") begin
            task_write_addr(opArg1, opArg2); // addr data
        end else if (opCodeString == "read") begin
            task_read_addr(opArg1, opArg2); // addr data
            $fwrite(outFileId, "%X\n", opArg2);
        end else if (opCodeString == "wait") begin
            task_wait(opArg1, opArg2); // repeat_count step_time(ns)
        end else if (opCodeString == "wait_clock") begin
            task_wait_clock(opArg1, opArg2); // clock_count
        end

        if ($feof(fileid)) begin
            $fflush();
            $fclose(fileid);
            $fclose(outFileId);
            $display("(%16t) finishing the simulation", $time);
            $finish;
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
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
        .C_S_AXI_ADDR_MSB(C_S_AXI_ADDR_MSB),
        .C_S_AXI_ADDR_LSB(C_S_AXI_ADDR_LSB)
    ) axi_lite_slave_example_i_00 (
        //// AXI I/O Signals
        // NB: s_axi_aclk comes at end
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_awaddr(s_axi_awaddr[C_S_AXI_ADDR_WIDTH-1:0]),
        .s_axi_awprot(s_axi_awprot[2:0]),
        .s_axi_awvalid(s_axi_awvalid & cs_signals[0]),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata[C_S_AXI_DATA_WIDTH-1:0]),
        .s_axi_wstrb(s_axi_wstrb[C_S_AXI_DATA_WIDTH/8-1:0]),
        .s_axi_wvalid(s_axi_wvalid & cs_signals[0]),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp[1:0]),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr[C_S_AXI_ADDR_WIDTH-1:0]),
        .s_axi_arprot(s_axi_arprot[2:0]),
        .s_axi_arvalid(s_axi_arvalid & cs_signals[0]),
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

/* ------------------------------------------------------------------------
** task_read_addr
** ----------------------------------------------------------------------*/
task task_read_addr;
    input [C_S_AXI_ADDR_WIDTH:0] reg_addr;
    output [C_S_AXI_DATA_WIDTH:0] reg_data;

    begin
        wait (axi_bus_free);
        axi_bus_free = 0;
        @ (posedge s_axi_aclk);
        #1;
        cs_signals[0] = 1;
        s_axi_araddr = reg_addr;
        s_axi_arvalid = 1;
        s_axi_rready = 1;
        // wait (s_axi_arready);
        wait (s_axi_rvalid);
        $display("(%16t) Reading address [%0d] = 0x%0x", $time, s_axi_araddr, s_axi_rdata);
        reg_data = s_axi_rdata;
        @ (posedge s_axi_aclk);
        #1;
        s_axi_araddr = 'hz;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        cs_signals[0] = 0;
        axi_bus_free = 1;
    end
endtask

/* ------------------------------------------------------------------------
** task_write_addr
** ----------------------------------------------------------------------*/
task task_write_addr;
    input [C_S_AXI_ADDR_WIDTH:0] reg_addr;
    input [C_S_AXI_DATA_WIDTH:0] reg_data;

    begin
        wait (axi_bus_free);
        axi_bus_free = 0;
        @ (posedge s_axi_aclk);
        $display("(%16t) Writing address [%0d] = 0x%0x", $time, reg_addr, reg_data);
        #1;
        cs_signals[0] = 1;
        s_axi_awaddr = reg_addr;
        s_axi_wdata = reg_data;
        s_axi_wstrb = ~0;
        s_axi_awvalid = 1;
        s_axi_wvalid = 1;
        s_axi_bready = 1;
        // wait (s_axi_wready);
        wait (s_axi_bvalid);
        @ (posedge s_axi_aclk);
        #1;
        s_axi_awaddr = 'hz;
        s_axi_wdata = 'hz;
        s_axi_wstrb = 'h0;
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        cs_signals[0] = 0;
        axi_bus_free = 1;
    end
endtask

/* ------------------------------------------------------------------------
** task_wait
** ----------------------------------------------------------------------*/
task task_wait;
    input [C_S_AXI_DATA_WIDTH:0] repeat_count;
    input [C_S_AXI_DATA_WIDTH:0] step_time;

    begin
        if (step_time == 0) begin step_time = 1; end
        $display("(%16t) Waiting for %d ns", $time, step_time * repeat_count);
        repeat (repeat_count) begin
            #(step_time); // unit: ns
        end
    end
endtask

/* ------------------------------------------------------------------------
** task_wait_clock
** ----------------------------------------------------------------------*/
task task_wait_clock;
    input [C_S_AXI_DATA_WIDTH:0] clock_count;
    input [C_S_AXI_DATA_WIDTH:0] arg2;

    begin
        $display("(%16t) Waiting %d clocks", $time, clock_count);
        repeat (clock_count) begin
            @ (posedge s_axi_aclk);
        end
    end
endtask


endmodule
