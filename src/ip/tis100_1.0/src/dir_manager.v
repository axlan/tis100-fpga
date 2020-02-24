`timescale 1ns / 1ps

// Module to control comunication with adjacent nodes

module dir_manager(
        // synchronize with posedge of clk
        input clk,
        // active high reset
        input reset,
        // source port for current operation
        input [2:0] src,
        // destination port for current operation
        input [2:0] dst,
        // data incoming from node to the left
        input signed [10:0] left_in_data,
        // is that incoming data valid
        input left_in_valid,
        // will this node be able to read the data this cycle
        output left_in_ready,
        input signed [10:0] right_in_data,
        input right_in_valid,
        output right_in_ready,
        input signed [10:0] up_in_data,
        input up_in_valid,
        output up_in_ready,
        input signed [10:0] down_in_data,
        input down_in_valid,
        output down_in_ready,
        // data to send from this node to the node to the left
        output signed [10:0] left_out_data,
        // is the output data valid this cycle
        output left_out_valid,
        // will the other node read the data this cycle
        input left_out_ready,
        output signed [10:0] right_out_data,
        output right_out_valid,
        input right_out_ready,
        output signed [10:0] up_out_data,
        output up_out_valid,
        input up_out_ready,
        output signed [10:0] down_out_data,
        output down_out_valid,
        input down_out_ready,
        // clk_en goes low if this node needs to stall to wait for another node
            // to read or write data
        output clk_en,
        // data read from another node as a source for an operation
        output signed [10:0] dir_src_data,
        // data to write to another as the destination of an operation
        input signed [10:0] dir_dst_data
    );
    `include "my_params.vh"

    // idle, or waiting to source data from another node
    localparam STATE_SRC = 1'd0;
    // waiting to write data to another node
    localparam STATE_DST = 1'd1;

    // does the targert source or destination port require communicating with
    // another node?
    function is_dir_target;
    input [2:0] target;
    begin
        // See definitions in my_params.vh
        is_dir_target = target >= TARGET_UP;
    end
    endfunction

    // the state of internode communication
    reg state;

    // does the current operation require input from another node
    wire perform_in;
    // does the current operation require output to another node
    wire perform_out;
    // register source data in case it needs to be buffered for a move operation
        // between direction ports (ie. MOV UP DOWN)
    reg signed [10:0] dir_src_data_reg;
    // use dir_src_data_reg instead of input dir_dst_data if performing move
        // between direction ports (ie. MOV UP DOWN)
    wire signed [10:0] dir_dst_data_internal;
    // the result choosing the source input from the different directions
    wire signed [10:0] dir_src_data_internal;
    // when reading from another node, which direction should be selected
    wire [2:0] src_sel;
    // is this module looking for an input from another node this cycle
    wire src_waiting;
    // does the current read operation need to wait for another node
    wire stall_read;
    // is the correct adjacent node ready to receive this node's write data
    wire dst_available;

    assign clk_en = (!stall_read && state == STATE_SRC && !perform_out) || (state == STATE_DST && dst_available);

    assign perform_in = is_dir_target(src);
    assign src_waiting = state == STATE_SRC && perform_in;
    assign left_in_ready = src_waiting && src == TARGET_LEFT;
    assign right_in_ready = src_waiting && src == TARGET_RIGHT;
    assign up_in_ready = src_waiting && src == TARGET_UP;
    assign down_in_ready = src_waiting && src == TARGET_DOWN;
    assign src_sel = (src == TARGET_LEFT && left_in_valid) ? 3'b100 :
                     (src == TARGET_RIGHT && right_in_valid) ? 3'b101 :
                     (src == TARGET_UP && up_in_valid) ? 3'b110 :
                     (src == TARGET_DOWN && down_in_valid) ? 3'b111 :
                     3'b0;
    assign dir_src_data_internal = (src_sel[1:0] == 2'b00) ? left_in_data :
                                   (src_sel[1:0] == 2'b01) ? right_in_data :
                                   (src_sel[1:0] == 2'b10) ? up_in_data :
                                   down_in_data;
    assign stall_read = src_waiting && !src_sel[2];
    assign dir_src_data = (state == STATE_SRC) ? dir_src_data_internal : dir_src_data_reg;

    assign dir_dst_data_internal = (!perform_in) ? dir_dst_data : dir_src_data_reg;
    assign perform_out = is_dir_target(dst);
    assign left_out_data = dir_dst_data_internal;
    assign left_out_valid = state == STATE_DST && dst == TARGET_LEFT;
    assign right_out_data = dir_dst_data_internal;
    assign right_out_valid = state == STATE_DST && dst == TARGET_RIGHT;
    assign up_out_data = dir_dst_data_internal;
    assign up_out_valid = state == STATE_DST && dst == TARGET_UP;
    assign down_out_data = dir_dst_data_internal;
    assign down_out_valid = state == STATE_DST && dst == TARGET_DOWN;

    assign dst_available = (dst == TARGET_LEFT && left_out_ready) ||
                           (dst == TARGET_RIGHT && right_out_ready) ||
                           (dst == TARGET_UP && up_out_ready) ||
                           (dst == TARGET_DOWN && down_out_ready);

    always @ (posedge clk)
    begin
        if (reset)
        begin
            state <= STATE_SRC;
            dir_src_data_reg <= 'd0;
        end
        else
        begin
            if (state == STATE_SRC && perform_out && !stall_read)
            begin
                state <= STATE_DST;
                dir_src_data_reg <= dir_src_data_internal;
            end
            else if (state == STATE_DST && dst_available)
            begin
                state <= STATE_SRC;
            end
        end
    end
endmodule