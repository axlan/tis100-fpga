`timescale 1ns / 1ps

module alu(
        input [1:0] instr,
        input signed [10:0] acc,
        input signed [10:0] src,
        output signed [10:0] out
    );
    `include "my_params.vh"

    wire signed [10:0] neg_out;
    wire signed [11:0] add_tmp;
    wire signed [11:0] sub_tmp;
    wire signed [10:0] add_out;
    wire signed [10:0] sub_out;
    
    assign neg_out = -acc;
    assign add_tmp = acc + src;
    assign sub_tmp =  acc - src;
    
    rounder round_add(
        .in(add_tmp),
        .out(add_out)
    );
    rounder round_sub(
        .in(sub_tmp),
        .out(sub_out)
    );
    
     assign out = (instr == INSTR_ALU_ADD) ? add_out :
          (instr == INSTR_ALU_SUB) ? sub_out :
          neg_out;
    
endmodule
