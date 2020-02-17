`timescale 1ns / 1ps

module alu(
        input [1:0] instr,
        input signed [10:0] acc,
        input signed [10:0] src,
        output signed [10:0] out
    );
    `include "my_params.vh"

    function [10:0] saturate;
        input signed [11:0] in;
        localparam MIN_VAL = -11'sd999;
        localparam MAX_VAL = 11'sd999;
        begin
            saturate = (in < MIN_VAL) ? MIN_VAL :
                       (in > MAX_VAL) ? MAX_VAL :
                       in;  
        end
    endfunction

    wire signed [10:0] neg_out;
    wire signed [11:0] add_tmp;
    wire signed [11:0] sub_tmp;
    wire signed [10:0] add_out;
    wire signed [10:0] sub_out;
    
    assign neg_out = -acc;
    assign add_tmp = acc + src;
    assign sub_tmp =  acc - src;
    
    assign add_out = saturate(add_tmp);
    assign sub_out = saturate(sub_tmp);
    
     assign out = (instr == INSTR_ALU_ADD) ? add_out :
          (instr == INSTR_ALU_SUB) ? sub_out :
          neg_out;
    
endmodule
