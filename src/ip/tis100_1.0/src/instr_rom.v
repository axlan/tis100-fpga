`timescale 1ns / 1ps

// module to read instructions from rom and control program counter jumps

module instr_rom(
        // synchronize with posedge of clk
        input clk,
        // only update values when clk_en is high
        input clk_en,
        // active high reset
        input reset,
        // code for whether to perform a jump
        input [3:0] instr,
        // current ACC register value
        input signed [10:0] acc,
        // address to jump to if jump is performed
        input signed [10:0] jmp_off,
        // instruction at current program counter
        output [20:0] opcode
    );
    `include "my_params.vh"
    // memory file to initialize ROM with
    parameter MEM_INIT_FILE = "";
    // number of valid instructions in ROM
    parameter NUM_ENTRIES = 5'd10;

    // memory for storing instructinos
    reg [20:0] ram[31:0];

    // program counter pointing to current instruction
    reg [4:0] pc;
    // does the current operation code for a jump
    wire jmp_en;
    // address to jump to if jump is to be performed
    wire signed [11:0] pc_jmp;
    // sign extended pc to avoid signed arithmetic issue
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
