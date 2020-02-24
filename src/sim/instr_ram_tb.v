`timescale 1ns / 1ps

module instr_ram_tb();
reg clk, reset, clk_en;
reg write_en;
reg [4:0] write_addr;
reg [20:0] write_data;
reg [3:0] op;
reg signed [10:0] acc, jmp_off;
reg [20:0] out_expected;
wire [20:0] out;
reg [31:0] vectornum, errors;
reg [20:0] testinstrs [31:0];
reg [46:0] testvectors [10000:0];

// instantiate device under test
instr_ram dut(clk, clk_en, reset, op, acc, jmp_off, write_en, write_addr, write_data, out);

// generate clock
always
    begin
        clk = 1; #5; clk = 0; #5;
    end

// at start of test, load vectors
// and pulse reset
initial
begin
    $readmemb("instr_rom_tv.mem", testvectors);
    $readmemb("test_opcodes.mem", testinstrs);
    vectornum = 0; errors = 0;

    write_en = 0;
    #5;
    write_addr = 0;
    write_en = 1;

    for (write_addr=0; testinstrs[write_addr] !== 21'bx; write_addr = write_addr + 5'd1)
    begin
        write_data = testinstrs[write_addr];
        #10;
    end
    write_en = 0;

    clk_en = 0;
    reset = 1;
    #10; reset = 0;
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
        if (testvectors[vectornum] === 47'bx) begin
            $display ("%d tests completed with %d errors", vectornum, errors);
            $finish;
        end
    end
    {op, acc, jmp_off, out_expected} = testvectors[vectornum];
end

endmodule