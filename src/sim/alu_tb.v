module alu_tb();
reg signed [10:0] acc, src, out_expected;
reg [1:0] instr;
wire [10:0] out;
reg [31:0] vectornum, errors;
reg [34:0] testvectors [10000:0];

// instantiate device under test
alu dut(instr, acc, src, out);

// at start of test, load vectors
// and pulse reset
initial
begin
    $readmemb("alu_tv.mem", testvectors);
    vectornum = 0; errors = 0;
end


always
begin
    #1; {instr, acc, src, out_expected} = 
          testvectors[vectornum];
    #1;    if (out !== out_expected) begin
        $display ("Error: input %d", vectornum);
        $display (" outputs = %d (%d expected)", out, out_expected);
        errors = errors + 1;
    end
    //$display (" %b %b %b %b %b ", a, b, c, d, yexpected);
    vectornum = vectornum + 1;
    if (testvectors[vectornum] === 35'bx) begin
        $display ("%d tests completed with %d errors", vectornum, errors);

        $finish;
    end

end

endmodule