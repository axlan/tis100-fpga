`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2020 09:59:22 AM
// Design Name: 
// Module Name: axi_tis_rw_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module axi_tis_rw_tb();
`include "my_params.vh"
localparam integer C_S_AXI_DATA_WIDTH	= 32;
localparam integer C_S_AXI_ADDR_WIDTH	= 6;

reg clk, reset;

// Write address (issued by master, acceped by Slave)
reg [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR;
// Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
reg [2 : 0] S_AXI_AWPROT;
// Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
reg  S_AXI_AWVALID;
// Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
wire  S_AXI_AWREADY;
// Write data (issued by master, acceped by Slave) 
reg [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA;
// Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
reg [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB;
// Write valid. This signal indicates that valid write
    // data and strobes are available.
reg  S_AXI_WVALID;
// Write ready. This signal indicates that the slave
    // can accept the write data.
wire  S_AXI_WREADY;
// Write response. This signal indicates the status
    // of the write transaction.
wire [1 : 0] S_AXI_BRESP;
// Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
wire  S_AXI_BVALID;
// Response ready. This signal indicates that the master
    // can accept a write response.
reg  S_AXI_BREADY;
// Read address (issued by master, acceped by Slave)
reg [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR;
// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
reg [2 : 0] S_AXI_ARPROT;
// Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
reg  S_AXI_ARVALID;
// Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
wire  S_AXI_ARREADY;
// Read data (issued by slave)
wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA;
// Read response. This signal indicates the status of the
    // read transfer.
wire [1 : 0] S_AXI_RRESP;
// Read valid. This signal indicates that the channel is
    // signaling the required read data.
wire  S_AXI_RVALID;
// Read ready. This signal indicates that the master can
    // accept the read data and response information.
reg  S_AXI_RREADY;

// instantiate device under test
tis100_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) dut(
        .S_AXI_ACLK(clk),
		.S_AXI_ARESETN(reset),
		.S_AXI_AWADDR(S_AXI_AWADDR),
		.S_AXI_AWPROT(S_AXI_AWPROT),
		.S_AXI_AWVALID(S_AXI_AWVALID),
		.S_AXI_AWREADY(S_AXI_AWREADY),
		.S_AXI_WDATA(S_AXI_WDATA),
		.S_AXI_WSTRB(S_AXI_WSTRB),
		.S_AXI_WVALID(S_AXI_WVALID),
		.S_AXI_WREADY(S_AXI_WREADY),
		.S_AXI_BRESP(S_AXI_BRESP),
		.S_AXI_BVALID(S_AXI_BVALID),
		.S_AXI_BREADY(S_AXI_BREADY),
		.S_AXI_ARADDR(S_AXI_ARADDR),
		.S_AXI_ARPROT(S_AXI_ARPROT),
		.S_AXI_ARVALID(S_AXI_ARVALID),
		.S_AXI_ARREADY(S_AXI_ARREADY),
		.S_AXI_RDATA(S_AXI_RDATA),
		.S_AXI_RRESP(S_AXI_RRESP),
		.S_AXI_RVALID(S_AXI_RVALID),
		.S_AXI_RREADY(S_AXI_RREADY)
    );

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

// at start of test, load vectors
// and pulse reset
initial
begin

    S_AXI_AWADDR = 6'd0;
    S_AXI_AWPROT = 3'd0;
    S_AXI_AWVALID = 1'd0;
    S_AXI_WDATA = 32'd0;
    S_AXI_WSTRB = 4'b1111;
    S_AXI_WVALID = 1'd0;
    S_AXI_BREADY = 1'd0;
    S_AXI_ARADDR = 6'd0;
    S_AXI_ARPROT = 3'd0;
    S_AXI_ARVALID = 1'd0;
    S_AXI_RREADY = 1'd0;

    reset = 0;
    S_AXI_AWADDR = 6'd0;
    S_AXI_AWVALID = 1'd1;
    S_AXI_WDATA = 32'd5;
    S_AXI_WVALID = 1'd1;


    #23;
    reset = 1;
    
end


endmodule
