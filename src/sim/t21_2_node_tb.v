`timescale 1ns / 1ps

module t21_2_node_tb();
`include "my_params.vh"
reg clk, reset;

reg signed [10:0] ina [12:0];
reg [31:0] a_idx;
reg signed [10:0] inb [12:0];
reg [31:0] b_idx;
reg signed [10:0] out_expected [38:0];
reg [31:0] out_expected_idx;

reg in_a_stream_down_out_valid;
wire in_a_stream_down_out_ready;

reg in_b_stream_down_out_valid;
wire in_b_stream_down_out_ready;

wire signed [10:0] out_stream_up_in_data;   
wire out_stream_up_in_valid;
reg out_stream_up_in_ready;

wire [10:0] node1_up_in_data;
wire node1_up_in_valid;
wire node1_up_in_ready;
wire [10:0] node1_right_in_data;
wire node1_right_in_valid;
wire node1_right_in_ready;
wire [10:0] node1_right_out_data;
wire node1_right_out_valid;
wire node1_right_out_ready;
wire [10:0] node2_up_in_data;
wire node2_up_in_valid;
wire node2_up_in_ready;
wire [10:0] node2_left_out_data;
wire node2_left_out_valid;
wire node2_left_out_ready;
wire [10:0] node2_left_in_data;
wire node2_left_in_valid;
wire node2_left_in_ready;
wire [10:0] node2_down_out_data;
wire node2_down_out_valid;
wire node2_down_out_ready;

assign node1_up_in_data = ina[a_idx];
assign node1_up_in_valid = in_a_stream_down_out_valid;
assign in_a_stream_down_out_ready = node1_up_in_ready;
assign node2_up_in_data = inb[b_idx];
assign node2_up_in_valid = in_b_stream_down_out_valid;
assign in_b_stream_down_out_ready = node2_up_in_ready;
assign node2_left_in_data = node1_right_out_data;
assign node2_left_in_valid = node1_right_out_valid;
assign node1_right_out_ready = node2_left_in_ready;
assign node1_right_in_data = node2_left_out_data;
assign node1_right_in_valid = node2_left_out_valid;
assign node2_left_out_ready = node1_right_in_ready;
assign out_stream_up_in_data = node2_down_out_data;
assign out_stream_up_in_valid = node2_down_out_valid;
assign node2_down_out_ready = out_stream_up_in_ready;

t21_node #("seq_gen_node1.mem", 3) node1(
    .clk(clk),
    .reset(reset),
    .up_in_data(node1_up_in_data),
    .up_in_valid(node1_up_in_valid),
    .up_in_ready(node1_up_in_ready),
    .right_in_data(node1_right_in_data),
    .right_in_valid(node1_right_in_valid),
    .right_in_ready(node1_right_in_ready),
    .right_out_data(node1_right_out_data),
    .right_out_valid(node1_right_out_valid),
    .right_out_ready(node1_right_out_ready),
    .write_en(0)
);

t21_node #("seq_gen_node2.mem", 12) node2(
    .clk(clk),
    .reset(reset),
    .up_in_data(node2_up_in_data),
    .up_in_valid(node2_up_in_valid),
    .up_in_ready(node2_up_in_ready),
    .left_out_data(node2_left_out_data),
    .left_out_valid(node2_left_out_valid),
    .left_out_ready(node2_left_out_ready),
    .left_in_data(node2_left_in_data),
    .left_in_valid(node2_left_in_valid),
    .left_in_ready(node2_left_in_ready),
    .down_out_data(node2_down_out_data),
    .down_out_valid(node2_down_out_valid),
    .down_out_ready(node2_down_out_ready),
    .write_en(0)
);

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

always @ (posedge clk)
begin
    if (!reset)
    begin
        if (in_a_stream_down_out_ready)
        begin
            a_idx = a_idx + 1;
        end
        if (in_b_stream_down_out_ready)
        begin
            b_idx = b_idx + 1;
        end
        if (out_stream_up_in_valid)
        begin
            if (out_stream_up_in_data !== out_expected[out_expected_idx])
            begin
                $display ("%d tests completed with 1 errors", out_expected_idx);
                $finish;
            end
            out_expected_idx = out_expected_idx + 1;
            if (out_expected_idx == 39)
            begin
                $display ("39 tests completed with 0 errors");
                $finish;
            end
        end
    end
end

// at start of test, load vectors
// and pulse reset
initial
begin
    $readmemh("seq_gen_ina.mem", ina);
    $readmemh("seq_gen_inb.mem", inb);
    $readmemh("seq_gen_result.mem", out_expected);

    a_idx = 0;
    b_idx = 0;
    out_expected_idx = 0;
    in_a_stream_down_out_valid = 1'd1;
    in_b_stream_down_out_valid = 1'd1;
    out_stream_up_in_ready = 1'd1;


    reset = 1;
    #23;
    reset = 0;
    
end


endmodule