`timescale 1ns / 1ps

module registers(
        input clk,
        input clk_en,
        input reset,
        input [1:0] instr,
        input signed [10:0] val_in,
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
            if (instr === INSTR_REG_SWP || instr === INSTR_REG_SAV)
            begin
                bak <= acc;
                if (instr === INSTR_REG_SWP)
                begin
                    acc <= bak;
                end
            end
            else if (instr === INSTR_REG_WRITE)
            begin
                acc <= val_in;
            end
        end
    end



endmodule
