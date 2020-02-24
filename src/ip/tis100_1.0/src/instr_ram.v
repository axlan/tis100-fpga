`timescale 1ns / 1ps

// module to read/write instructions from ram and control program counter jumps

module instr_ram(
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
        // controls whether to write a new instruction
        input write_en,
        // address to write new instruction
        input [4:0] write_addr,
        // new instruction to write.
            //Writes must end with highest address instruction.
        input [20:0] write_data,
        // instruction at current program counter
        output [20:0] opcode
    );
    `include "my_params.vh"
    // memory file to initialize RAM with
    parameter MEM_INIT_FILE = "";
    // number of valid instructions in MEM_INIT_FILE
    parameter NUM_ENTRIES = 5'd10;

    // memory for storing instructinos
    reg [20:0] ram[31:0];
    // number of valid instructions in RAM
    reg [4:0] num_entries;

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
            num_entries = NUM_ENTRIES;
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
                else if (pc_jmp >= num_entries)
                begin
                    pc <= num_entries - 1;
                end
                else
                begin
                    pc <= pc_jmp;
                end
            end
            else
            begin
                if (pc == num_entries - 1)
                begin
                    pc <= 0;
                end
                else
                begin
                    pc <= pc + 1;
                end
            end
        end
        if (write_en)
        begin
            ram[write_addr] <= write_data;
            num_entries <= write_addr + 5'd1;
        end
    end
    
endmodule
