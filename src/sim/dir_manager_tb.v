module dir_manager_tb();
`include "my_params.vh"
reg clk, reset;
reg [2:0] src, dst;
reg signed [10:0] left_in_data, right_in_data, up_in_data, down_in_data;
reg left_in_valid, right_in_valid, up_in_valid, down_in_valid;
wire left_in_ready, right_in_ready, up_in_ready, down_in_ready;
wire signed [10:0] left_out_data, right_out_data, up_out_data, down_out_data;
wire left_out_valid, right_out_valid, up_out_valid, down_out_valid;
reg left_out_ready, right_out_ready, up_out_ready, down_out_ready;
wire clk_en;
wire signed [10:0] dir_src_data, dir_dst_data;

reg signed [10:0] left_out_data_expected, right_out_data_expected, up_out_data_expected, down_out_data_expected;
reg left_in_ready_expected, right_in_ready_expected, up_in_ready_expected, down_in_ready_expected;
reg left_out_valid_expected, right_out_valid_expected, up_out_valid_expected, down_out_valid_expected;
reg clk_en_expected;
reg signed [10:0] dir_src_data_expected;

reg [31:0] vectornum, errors;
reg [77:0] testvectors [10000:0];


assign dir_dst_data = (src == TARGET_NIL) ? 999 : dir_src_data;

// instantiate device under test
dir_manager dut(
        clk,
        reset,
        src,
        dst,
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
        down_out_ready,
        clk_en,
        dir_src_data,
        dir_dst_data
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
    $readmemb("dir_manager_tv.mem", testvectors);
    vectornum = 0;
    errors = 0;

    left_in_data = 11'd1;
    right_in_data = 11'd2;
    up_in_data = 11'd3;
    down_in_data = 11'd4;

    reset = 1;
    #23;
    reset = 0;
end

task check_output;
input [8*32:0] name;
input [31:0] out, out_expected;
begin
    if (out_expected !== 'dx && out !== out_expected) begin
        $display ("Error line: %d", vectornum);
        $display ("%s = %d (%d expected)", name, out, out_expected);
        errors = errors + 1;
    end
end
endtask



// check results at falling edge of clock
always @ (negedge clk)
begin
    {
        src,
        dst,
        left_in_valid,
        right_in_valid,
        up_in_valid,
        down_in_valid,
        left_out_ready,
        right_out_ready,
        up_out_ready,
        down_out_ready,

        left_in_ready_expected,
        right_in_ready_expected,
        up_in_ready_expected,
        down_in_ready_expected,
        left_out_data_expected,
        right_out_data_expected,
        up_out_data_expected,
        down_out_data_expected,
        left_out_valid_expected,
        right_out_valid_expected,
        up_out_valid_expected,
        down_out_valid_expected,
        clk_en_expected,
        dir_src_data_expected} = testvectors[vectornum];

     #2; 
     if (!reset) begin
        check_output("left_in_ready", left_in_ready, left_in_ready_expected);
        check_output("right_in_ready", right_in_ready, right_in_ready_expected);
        check_output("up_in_ready", up_in_ready, up_in_ready_expected);
        check_output("down_in_ready", down_in_ready, down_in_ready_expected);
        check_output("clk_en", clk_en, clk_en_expected);
        check_output("left_out_data", left_out_data, left_out_data_expected);
        check_output("right_out_data", right_out_data, right_out_data_expected);
        check_output("up_out_data", up_out_data, up_out_data_expected);
        check_output("down_out_data", down_out_data, down_out_data_expected);
        check_output("left_out_valid", left_out_valid, left_out_valid_expected);
        check_output("right_out_valid", right_out_valid, right_out_valid_expected);
        check_output("up_out_valid", up_out_valid, up_out_valid_expected);
        check_output("down_out_valid", down_out_valid, down_out_valid_expected);
        check_output("dir_src_data", dir_src_data, dir_src_data_expected);
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 78'bx) begin
            $display ("%d tests completed with %d errors", vectornum, errors);
            $finish;
        end
    end

end






endmodule