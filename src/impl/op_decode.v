module op_decode(
        input [20:0] op_code,
        output signed [10:0] const,
        output [3:0] pc_instr,
        output [1:0] alu_instr,
        output [1:0] registers_instr,
        output [1:0] in_mux_sel,
        output out_mux_sel
    );
    `include "my_params.vh"

    wire [3:0] op;
    wire [2:0] src, dst;

    assign op = op_code[20:17];
    assign src = op_code[16:14];
    assign const = op_code[13:3];
    assign dst = op_code[2:0];

    assign pc_instr = op;

    assign alu_instr = (op == OP_ADD) ? INSTR_ALU_ADD :
                       (op == OP_SUB) ? INSTR_ALU_SUB :
                       (op == OP_NEG) ? INSTR_ALU_NEG :
                       2'bx;

    assign registers_instr = (op == OP_MOV
                              || op == OP_ADD
                              || op == OP_SUB
                              || op == OP_NEG) ? INSTR_REG_WRITE :
                             (op == OP_SWP) ? INSTR_REG_SWP :
                             (op == OP_SAV) ? INSTR_REG_SAV :
                             2'bx;

    assign in_mux_sel = (src == TARGET_NIL) ? IN_MUX_SEL_CONST :
                        (op == TARGET_ACC) ? IN_MUX_SEL_ACC :
                        IN_MUX_SEL_DIR;

    assign out_mux_sel = (op == OP_MOV) ? OUT_MUX_SEL_IN : OUT_MUX_SEL_ALU;

endmodule