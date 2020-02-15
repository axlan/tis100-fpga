module op_decode_tb();
reg [20:0] op_code;
wire signed [10:0] const;
wire [3:0] pc_instr;
wire [1:0] alu_instr;
wire [1:0] registers_instr;
wire [1:0] in_mux_sel;
wire out_mux_sel;
reg signed [10:0] const_expected;
reg [3:0] pc_instr_expected;
reg [1:0] alu_instr_expected;
reg [1:0] registers_instr_expected;
reg [1:0] in_mux_sel_expected;
reg out_mux_sel_expected;
reg [31:0] vectornum, errors;
// 21 + 11 + 4 + 2 + 2 + 2 + 1
reg [42:0] testvectors [10000:0];

// instantiate device under test
op_decode dut(op_code, const, pc_instr, alu_instr, registers_instr, in_mux_sel, out_mux_sel);

// at start of test, load vectors
// and pulse reset
initial
begin
    $readmemb("op_decode_tv.mem", testvectors);
    vectornum = 0; errors = 0;
end

task check_output;
input [8*32:0] name;
input [31:0] out, out_expected;
begin
    if (out !== out_expected) begin
        $display ("Error line: %d", vectornum);
        $display ("%s = %d (%d expected)", name, out, out_expected);
        errors = errors + 1;
    end
end
endtask

always
begin
    #1; {op_code, const_expected, pc_instr_expected, alu_instr_expected, registers_instr_expected, in_mux_sel_expected, out_mux_sel_expected} = 
          testvectors[vectornum];
    #1;
    check_output("const", const, const_expected);
    check_output("pc_instr", pc_instr, pc_instr_expected);
    check_output("alu_instr", alu_instr, alu_instr_expected);
    check_output("registers_instr", registers_instr, registers_instr_expected);
    check_output("in_mux_sel", in_mux_sel, in_mux_sel_expected);
    check_output("out_mux_sel", out_mux_sel, out_mux_sel_expected);
    //$display (" %b %b %b %b %b ", a, b, c, d, yexpected);
    vectornum = vectornum + 1;
    if (testvectors[vectornum] === 'bx) begin
        $display ("%d tests completed with %d errors", vectornum, errors);

        $finish;
    end

end

endmodule