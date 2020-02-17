module registers_tb();
reg clk, reset, clk_en;
reg [1:0] instr;
reg signed [10:0] input_val, out_expected;
wire [10:0] out;
reg [31:0] vectornum, errors;
reg [24:0] testvectors [10000:0];

// instantiate device under test
registers dut(clk, clk_en, reset, instr, input_val, out);

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

// at start of test, load vectors
// and pulse reset
initial
begin
    $readmemb("registers_tv.mem", testvectors);
    vectornum = 0; errors = 0;
    clk_en = 0;
    reset = 1; #15; reset = 0;
    #12; clk_en = 1;
end

// check results at falling edge of clock
always @ (negedge clk)
begin
    if (clk_en) begin
         if (out !== out_expected) begin
            $display ("Error: input %d", vectornum);
            $display (" outputs = %d (%d expected)", out, out_expected);
            errors = errors + 1;
        end
        //$display (" %b %b %b %b %b ", a, b, c, d, yexpected);
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 25'bx) begin
            $display ("%d tests completed with %d errors", vectornum, errors);
            $finish;
        end
    end
    {instr, input_val, out_expected} = testvectors[vectornum];
end

endmodule