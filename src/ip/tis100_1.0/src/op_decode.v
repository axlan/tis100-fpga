`timescale 1ns / 1ps

// Module for decoding binary instructions

module op_decode(
        // binary instruction loaded from memory
        input [20:0] op_code,
        // the source port to load from (only used for some instructions)
        output [2:0] src,
        // the constant value store in the instruction (only used for some instructions)
        output signed [10:0] const,
        // the destination port to write to (only used for some instructions)
        output [2:0] dst,
        // code to control program counter with jump operations
        output [3:0] pc_instr,
        // code to select arithmatic opterations
        output [1:0] alu_instr,
        // code to control writing to ACC and BAK registers
        output [1:0] registers_instr,
        // code to control routing input values
        output [1:0] in_mux_sel,
        // code to control routing output values
        output out_mux_sel
    );
    `include "my_params.vh"

    wire [3:0] op;

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
                             INSTR_REG_READ;

    assign in_mux_sel = (src == TARGET_NIL) ? IN_MUX_SEL_CONST :
                        (src == TARGET_ACC) ? IN_MUX_SEL_ACC :
                        IN_MUX_SEL_DIR;

    assign out_mux_sel = (op == OP_MOV) ? OUT_MUX_SEL_IN : OUT_MUX_SEL_ALU;

endmodule