`timescale 1ns / 1ps

// Module to control storing values to BAK and ACC registers

module registers(
        // synchronize with posedge of clk
        input clk,
        // only update values when clk_en is high
        input clk_en,
        // active high reset
        input reset,
        // code to control what operation to perform. See my_params.vh
        input [1:0] instr,
        // new value to store in ACC during write operation
        input signed [10:0] val_in,
        // current value of ACC register
        output reg signed [10:0] acc
    );
    `include "my_params.vh"
    
    reg signed [10:0] bak;

    
    always @ (posedge clk)
    begin
        if (reset)
        begin
            acc <= 0;
            bak <= 0;
        end
        else if(clk_en)
        begin
            if (instr == INSTR_REG_SWP || instr == INSTR_REG_SAV)
            begin
                bak <= acc;
                if (instr == INSTR_REG_SWP)
                begin
                    acc <= bak;
                end
            end
            else if (instr == INSTR_REG_WRITE)
            begin
                acc <= val_in;
            end
        end
    end



endmodule
