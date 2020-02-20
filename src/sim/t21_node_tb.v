`timescale 1ns / 1ps

module t21_node_tb();
`include "my_params.vh"
reg clk, reset;
reg signed [10:0] left_in_data, right_in_data, up_in_data, down_in_data;
reg left_in_valid, right_in_valid, up_in_valid, down_in_valid;
wire left_in_ready, right_in_ready, up_in_ready, down_in_ready;
wire signed [10:0] left_out_data, right_out_data, up_out_data, down_out_data;
wire left_out_valid, right_out_valid, up_out_valid, down_out_valid;
reg left_out_ready, right_out_ready, up_out_ready, down_out_ready;

// instantiate device under test
t21_node #("test_mult.mem", 8) dut(
        clk,
        reset,
        left_in_data,
        left_in_valid,
        left_in_ready,
        right_in_data,
        right_in_valid,
        right_in_ready,
        up_in_data,
        up_in_valid,
        up_in_ready,
        down_in_data,
        down_in_valid,
        down_in_ready,
        left_out_data,
        left_out_valid,
        left_out_ready,
        right_out_data,
        right_out_valid,
        right_out_ready,
        up_out_data,
        up_out_valid,
        up_out_ready,
        down_out_data,
        down_out_valid,
        down_out_ready
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

    up_in_data = 11'd5;
    up_in_valid = 1'd1;
    down_out_ready = 1'd1;

    reset = 1;
    #23;
    reset = 0;
    #278;
    up_in_data = 11'd100;
    if (down_out_valid !== 1'b1) begin
        $display ("Error: down_out_valid not ready after first mult");
        $display ("1 tests completed with 1 errors");
        $finish;
    end
    if (down_out_data !== 11'd50) begin
        $display ("Error: 5x10 expected 50 got %d", down_out_data);
        $display ("2 tests completed with 1 errors");
        $finish;
    end
    #5040;
     if (down_out_valid !== 1'b1) begin
        $display ("Error: down_out_valid not ready after second mult");
        $display ("3 tests completed with 1 errors");
        $finish;
    end
    if (down_out_data !== 11'd999) begin
        $display ("Error: 5x10 expected 50 got %d", down_out_data);
        $display ("4 tests completed with 1 errors");
        $finish;
    end
    $display ("4 tests completed with 0 errors");
    $finish;
end


endmodule