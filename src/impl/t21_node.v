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
        input signed left_in_ready,
        input signed [10:0] right_in_data,
        input signed right_in_ready,
        input signed [10:0] up_in_data,
        input signed up_in_ready,
        input signed [10:0] down_in_data,
        input signed down_in_ready,
        output signed [10:0] left_out_data,
        output signed left_out_ready,
        output signed [10:0] right_out_data,
        output signed right_out_ready,
        output signed [10:0] up_out_data,
        output signed up_out_ready,
        output signed [10:0] down_out_data,
        output signed down_out_ready
    );
    `include "my_params.vh"

    wire clk_en;

    wire [20:0] op_code;

    wire [3:0] pc_instr;
    wire [1:0] alu_instr;
    wire [1:0] registers_instr;
    wire [1:0] in_mux_sel;
    wire [1:0] out_mux_sel;
    wire signed [10:0] const;

    wire signed [10:0] acc_reg, alu_output;

    wire signed [10:0] src_input;
    wire signed [10:0] dst_output;

    wire signed [10:0] dir_output;

    assign clk_en = 1;
    assign dir_output = {11{1'b1}};

    op_decode op_decode_0(op_code, const, pc_instr, alu_instr, registers_instr, in_mux_sel, out_mux_sel);

    alu alu_0(alu_instr, acc_reg, src_input, alu_output);
    instr_rom instr_rom_0(clk, clk_en, reset, pc_instr, acc_reg, jmp_off, op_code);
    registers registers_0(clk, clk_en, reset, registers_instr, dst_output, acc_reg);

    assign src_input = (in_mux_sel == IN_MUX_SEL_CONST) ? const :
                        (in_mux_sel == IN_MUX_SEL_ACC) ? acc :
                        dir;

    assign dst_output = (out_mux_sel == OUT_MUX_SEL_IN) ? src_input :
                        alu_output;



endmodule
