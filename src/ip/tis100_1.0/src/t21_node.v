`timescale 1ns / 1ps

// TIS100 T21 processing node

module t21_node(
        // synchronize with posedge of clk
        input clk,
        // active high reset
        input reset,
        // data incoming from node to the left
        input signed [10:0] left_in_data,
        // is that incoming data valid
        input left_in_valid,
        // will this node be able to read the data this cycle
        output signed left_in_ready,
        input signed [10:0] right_in_data,
        input right_in_valid,
        output signed right_in_ready,
        input signed [10:0] up_in_data,
        input up_in_valid,
        output signed up_in_ready,
        input signed [10:0] down_in_data,
        input down_in_valid,
        output signed down_in_ready,
        // data to send from this node to the node to the left
        output signed [10:0] left_out_data,
        // is the output data valid this cycle
        output left_out_valid,
        // will the other node read the data this cycle
        input signed left_out_ready,
        output signed [10:0] right_out_data,
        output right_out_valid,
        input signed right_out_ready,
        output signed [10:0] up_out_data,
        output up_out_valid,
        input signed up_out_ready,
        output signed [10:0] down_out_data,
        output down_out_valid,
        input signed down_out_ready,
        // controls whether to write a new instruction
        input write_en,
        // address to write new instruction
        input [4:0] write_addr,
        // new instruction to write.
            //Writes must end with highest address instruction.
        input [20:0] write_data
    );
    `include "my_params.vh"
    parameter MEM_INIT_FILE = "";
    parameter NUM_ENTRIES = 5'd0;

    // clk_en goes low to stall if dir_manager_0 needs to wait for an adjacent
        // node
    wire clk_en;

    // current instruction to decode
    wire [20:0] op_code;
    // code to control jumps
    wire [3:0] pc_instr;
    // which source and destination port does the current operation use
    wire [2:0] src, dst;
    // what arithmatic operation should be performed
    wire [1:0] alu_instr;
    // how should the BAK and ACC registers be updated
    wire [1:0] registers_instr;
    // controls source mux
    wire [1:0] in_mux_sel;
    // controls destination mux
    wire out_mux_sel;
    // constant value loaded from current instruction
    wire signed [10:0] const;

    wire signed [10:0] acc_reg, alu_output;
    // data from selected source (ACC, direction port, or constant)
    wire signed [10:0] src_input;
    // data to write to move destination (ALU output, or src_input)
    wire signed [10:0] dst_output;
    // data read from direction source port
    wire signed [10:0] dir_output;

    dir_manager dir_manager_0(
        clk, reset,
        src, dst,
        left_in_data, left_in_valid, left_in_ready,
        right_in_data, right_in_valid, right_in_ready,
        up_in_data, up_in_valid, up_in_ready,
        down_in_data, down_in_valid, down_in_ready,
        left_out_data, left_out_valid, left_out_ready,
        right_out_data, right_out_valid, right_out_ready,
        up_out_data, up_out_valid, up_out_ready,
        down_out_data, down_out_valid, down_out_ready,
        clk_en,
        dir_output, dst_output
    );

    op_decode op_decode_0(op_code, src, const, dst, pc_instr, alu_instr, registers_instr, in_mux_sel, out_mux_sel);

    alu alu_0(alu_instr, acc_reg, src_input, alu_output);
    instr_ram #(MEM_INIT_FILE, NUM_ENTRIES)  instr_ram_0(clk, clk_en, reset, pc_instr, acc_reg, src_input, write_en, write_addr, write_data, op_code);
    registers registers_0(clk, clk_en, reset, registers_instr, dst_output, acc_reg);

    assign src_input = (in_mux_sel == IN_MUX_SEL_CONST) ? const :
                        (in_mux_sel == IN_MUX_SEL_ACC) ? acc_reg :
                        dir_output;

    assign dst_output = (out_mux_sel == OUT_MUX_SEL_IN) ? src_input :
                        alu_output;

endmodule
