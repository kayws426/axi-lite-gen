// Generated by AXI-Lite Generator
// GEN_TIME = 2016-02-29 01:53:39
// GEN_USER = kayws426
// MODULE = example

`timescale 1 ns / 1 ps

module axi_lite_slave_example #
    (
    //// Generate-time parameters:
    parameter MAGIC = 32'h21EAF,
    parameter VERSION = 32'h0,
    parameter FEATURE_FLAGS = 32'h0,
    parameter GIT_HASH = 32'h0,
    parameter BUILD_TIME = 64'h0,

    //// Register Default Parameters
    parameter DEFAULT_ENABLE = 1'h0,
    parameter DEFAULT_OUTPUT_EN = 33'h0,
    parameter DEFAULT_RING_COUNT = 16'h0,
    parameter DEFAULT_RING_COUNTA = 16'h0,
    parameter DEFAULT_RING_COUNTB = 16'h0,

    //// Parameters of Axi Slave Bus Interface S_AXI
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 16,
    parameter C_S_AXI_ADDR_MSB = 15,
    parameter C_S_AXI_ADDR_LSB = 2
    )
    (
    //// AXI I/O Signals
    input wire s_axi_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input wire [2:0] s_axi_awprot,
    input wire s_axi_awvalid,
    output wire s_axi_awready,
    input wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input wire [C_S_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output wire s_axi_wready,
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    input wire s_axi_bready,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input wire [2:0] s00_axi_arprot,
    input wire s_axi_arvalid,
    output wire s_axi_arready,
    output wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    input wire s_axi_rready,
    //// example register values
    output reg enable,
    output reg [32:0] output_en,
    output reg [15:0] ring_count,
    input wire [15:0] ring_counta,
    input wire [15:0] ring_countb,
    // s_axi_aclk is last to ensure no trailing comma
    input wire s_axi_aclk
);

//// Memory Mapped Register Initialization
initial begin
    enable = DEFAULT_ENABLE;
    output_en = DEFAULT_OUTPUT_EN;
    ring_count = DEFAULT_RING_COUNT;
end

//// AXI Internals
// TODO:
wire slv_reg_wren;
wire slv_reg_rden;
reg [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;
// reg [C_S_AXI_DATA_WIDTH-1:0] axi_wdata;
reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
reg [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;


// This block handles writes
assign slv_reg_wren = s_axi_wready && s_axi_wvalid && s_axi_awready && s_axi_awvalid;
always @(posedge s_axi_aclk) begin
    if (s_axi_aresetn == 1'b0) begin
        enable <= DEFAULT_ENABLE;
        output_en <= DEFAULT_OUTPUT_EN;
        ring_count <= DEFAULT_RING_COUNT;
    end else begin
        if (slv_reg_wren) begin
            casex (s_axi_awaddr[C_S_AXI_ADDR_MSB-1:C_S_AXI_ADDR_LSB])
            14'd1024: begin
                enable <= s_axi_wdata;
            end
            14'd1025: begin
                output_en[31:0] <= s_axi_wdata[31:0];
            end
            14'd1026: begin
                output_en[32:32] <= s_axi_wdata[32:32];
            end
            14'd1027: begin
                ring_count[15:0] <= s_axi_wdata[15:0];
            end
            default: begin
                // pass
            end
            endcase
        end else begin
            // TODO: doorbells
        end
    end
end

// This block handles reads
assign slv_reg_rden = axi_arready & s_axi_arvalid & ~axi_rvalid;
always @(posedge s_axi_aclk) begin
    if (s_axi_aresetn == 1'b0) begin
        reg_data_out <= 0;
    end else if (slv_reg_rden) begin
        // Read address mux
        casex ( axi_araddr[C_S_AXI_ADDR_MSB-1:C_S_AXI_ADDR_LSB] )
        14'd1024: begin
            reg_data_out <= {31'd0, enable};
        end
        14'd1025: begin
            reg_data_out <= output_en[31:0];
        end
        14'd1026: begin
            reg_data_out <= {31'd0, output_en[32:32]};
        end
        14'd1027: begin
            reg_data_out <= {16'd0, ring_count[15:0]};
        end
        14'd1028: begin
            reg_data_out <= {16'd0, ring_counta[15:0]};
        end
        14'd1029: begin
            reg_data_out <= {16'd0, ring_countb[15:0]};
        end
        default: begin
            // pass
        end
        endcase
    end
end


// Implement s_axi_awready generation
always @( posedge s_axi_aclk ) begin
    if ( s_axi_aresetn == 1'b0 ) begin
        s_axi_awready <= 1'b0;
    end else begin
        if (~s_axi_awready && s_axi_awvalid && s_axi_wvalid) begin
            // slave is ready to accept write address when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            s_axi_awready <= 1'b1;
        end else begin
            s_axi_awready <= 1'b0;
        end
    end
end

// // Implement axi_awaddr latching
// always @( posedge s_axi_aclk ) begin
//     if ( s_axi_aresetn == 1'b0 ) begin
//         axi_awaddr <= 0;
//     end else begin
//         if (~s_axi_awready && s_axi_awvalid && s_axi_wvalid) begin
//             // Write Address latching
//             axi_awaddr <= s_axi_awaddr;
//         end
//     end
// end

// Implement s_axi_wready generation
always @( posedge s_axi_aclk ) begin
    if ( s_axi_aresetn == 1'b0 ) begin
        s_axi_wready <= 1'b0;
    end else begin
        if (~s_axi_wready && s_axi_wvalid && s_axi_awvalid) begin
            // slave is ready to accept write data when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            s_axi_wready <= 1'b1;
        end else begin
            s_axi_wready <= 1'b0;
        end
    end
end

endmodule