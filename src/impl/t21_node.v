`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2020 05:34:23 PM
// Design Name: 
// Module Name: T21Node
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


module t21_node(
        input clk,
        input reset,
        input signed [10:0] left_in_data,
        input left_in_valid,
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
        output signed [10:0] left_out_data,
        output left_out_valid,
        input signed left_out_ready,
        output signed [10:0] right_out_data,
        output right_out_valid,
        input signed right_out_ready,
        output signed [10:0] up_out_data,
        output up_out_valid,
        input signed up_out_ready,
        output signed [10:0] down_out_data,
        output down_out_valid,
        input signed down_out_ready
    );
    `include "my_params.vh"
    parameter MEM_INIT_FILE = "test_mult.mem";
    parameter NUM_ENTRIES = 5'd8;

    wire clk_en;

    wire [20:0] op_code;

    wire [3:0] pc_instr;
    wire [2:0] src, dst;
    wire [1:0] alu_instr;
    wire [1:0] registers_instr;
    wire [1:0] in_mux_sel;
    wire out_mux_sel;
    wire signed [10:0] const;

    wire signed [10:0] acc_reg, alu_output;

    wire signed [10:0] src_input;
    wire signed [10:0] dst_output;

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
    instr_rom #(MEM_INIT_FILE, NUM_ENTRIES)  instr_rom_0(clk, clk_en, reset, pc_instr, acc_reg, src_input, op_code);
    registers registers_0(clk, clk_en, reset, registers_instr, dst_output, acc_reg);

    assign src_input = (in_mux_sel == IN_MUX_SEL_CONST) ? const :
                        (in_mux_sel == IN_MUX_SEL_ACC) ? acc_reg :
                        dir_output;

    assign dst_output = (out_mux_sel == OUT_MUX_SEL_IN) ? src_input :
                        alu_output;

endmodule
