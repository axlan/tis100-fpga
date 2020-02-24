`timescale 1ns / 1ps

// Module to perform arithmatic operations

module alu(
        // Code to control the operation the ALU should perform. See my_params.vh
        input [1:0] instr,
        // The current value of the acc register
        input signed [10:0] acc,
        // The value to add/sub from the acc register
        input signed [10:0] src,
        // Result from the ALU operation
        output signed [10:0] out
    );
    `include "my_params.vh"

    // Saturate a 12 bit signed integer so it saturates at +-999
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
