`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2020 05:35:21 PM
// Design Name: 
// Module Name: InstrRom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module instr_rom(
        input clk,
        input clk_en,
        input reset,
        input [3:0] instr,
        input signed [10:0] acc,
        input signed [10:0] jmp_off,
        output [20:0] opcode
    );
    `include "my_params.vh"
    parameter MEM_INIT_FILE = "";
    parameter NUM_ENTRIES = 5'd10;

    reg [20:0] ram[31:0];

    reg [4:0] pc;
    wire jmp_en;
    
    wire signed [11:0] pc_jmp;
    wire signed [5:0] pc_ext;
   
    assign jmp_en = (instr == OP_JMP) ||
                    (instr == OP_JRO) ||
                    (instr == OP_JEZ && acc == 0) ||
                    (instr == OP_JNZ && acc != 0) ||
                    (instr == OP_JGZ && acc > 0) ||
                    (instr == OP_JLZ && acc < 0);
    
    assign pc_ext = {1'b0, pc};
    assign pc_jmp = pc_ext + jmp_off;

    assign opcode = ram[pc];
    
    initial begin
        if (MEM_INIT_FILE != "") begin
            $readmemb(MEM_INIT_FILE, ram);
        end
    end

    always @ (posedge clk)
    begin
        if (reset)
        begin
            pc <= 0;
        end
        else if(clk_en)
        begin
            if (jmp_en)
            begin
                if (pc_jmp < 0)
                begin
                    pc <= 0;
                end
                else if (pc_jmp >= NUM_ENTRIES)
                begin
                    pc <= NUM_ENTRIES - 1;
                end
                else
                begin
                    pc <= pc_jmp;
                end
            end
            else
            begin
                if (pc == NUM_ENTRIES - 1)
                begin
                    pc <= 0;
                end
                else
                begin
                    pc <= pc + 1;
                end
            end
        end
    end
    
endmodule
