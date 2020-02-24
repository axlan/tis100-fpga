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
// interrupt out port
wire irq;
reg [20:0] testinstrs [31:0];
reg [4:0] write_addr;
reg [31:0] errors;

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
		.S_AXI_RREADY(S_AXI_RREADY),
		.irq(irq)
    );

task write_reg;
input [3:0] reg_num;
input [C_S_AXI_DATA_WIDTH-1:0] reg_data;
begin
    S_AXI_AWADDR = {reg_num, 2'd0};
    S_AXI_AWVALID = 1'd1;
    S_AXI_WDATA = reg_data;
    S_AXI_WVALID = 1'd1;
    #20;
    S_AXI_AWVALID = 1'd0;
    S_AXI_WVALID = 1'd0;
    #10;
end
endtask

task read_reg;
input [3:0] reg_num;
begin
    S_AXI_ARADDR = {reg_num, 2'd0};
    S_AXI_ARVALID = 1'd1;
    #20;
    S_AXI_ARVALID = 1'd0;
    #10;
end
endtask

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

// at start of test, load vectors
// and pulse reset
initial
begin
    errors = 0;
    $readmemb("test_mult.mem", testinstrs);
    S_AXI_AWADDR = 6'd0;
    S_AXI_AWPROT = 3'd0;
    S_AXI_AWVALID = 1'd0;
    S_AXI_WDATA = 32'd0;
    S_AXI_WSTRB = 4'b1111;
    S_AXI_WVALID = 1'd0;
    S_AXI_BREADY = 1'd1;
    S_AXI_ARADDR = 6'd0;
    S_AXI_ARPROT = 3'd0;
    S_AXI_ARVALID = 1'd0;
    S_AXI_RREADY = 1'd1;

    reset = 0;

    #15;
    reset = 1;
    #10;
    // irq high on data out valid
    write_reg(4'd2, 2'b01);
    // load instructions into RAM
    for (write_addr=0; testinstrs[write_addr] !== 21'bx; write_addr = write_addr + 5'd1)
    begin
        write_reg(4'd3, {{C_S_AXI_DATA_WIDTH-5{1'b0}}, write_addr});
        write_reg(4'd4, {{C_S_AXI_DATA_WIDTH-21{1'b0}}, testinstrs[write_addr]});
    end
    #10;
    if (irq) begin
        $display ("Error: unexpected output irq");
        errors = errors + 1;
    end
    // irq high on data in ready
    write_reg(4'd2, 2'b10);
    if (!irq) begin
        $display ("Error: missing input irq");
        errors = errors + 1;
    end
    #10;
    // run 5 x 10
    write_reg(4'd0, 5);
    #10;
    if (irq) begin
        $display ("Error: unexpected input irq");
        errors = errors + 1;
    end
    #20;
    // irq high on data out valid
    write_reg(4'd2, 2'b01);
    #240;
    if (!irq) begin
        $display ("Error: missing output irq");
        errors = errors + 1;
    end
    // run 4 x 10
    write_reg(4'd0, 4);
    #10;
    // read 5 x 10 result
    read_reg(4'd0);
    if (S_AXI_RDATA !== 32'd50) begin
        $display ("Error: incorrect 5x10 output: %d", S_AXI_RDATA);
        errors = errors + 1;
    end
    $display ("5 tests completed with %d errors", errors);
    $finish;

end


endmodule
