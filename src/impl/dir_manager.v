module dir_manager(
        input clk,
        input reset,
        input [2:0] src,
        input [2:0] dst,
        input signed [10:0] left_in_data,
        input left_in_valid,
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
        output signed [10:0] left_out_data,
        output left_out_valid,
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
        output clk_en,
        output signed [10:0] dir_src_data,
        input signed [10:0] dir_dst_data
    );
    `include "my_params.vh"

    localparam STATE_SRC = 1'd0;
    localparam STATE_DST = 1'd1;

    function is_dir_target;
    input [2:0] target;
    begin
        // See definitions in my_params.vh
        is_dir_target = target >= TARGET_UP;
    end
    endfunction

    reg state;

    wire perform_in;
    wire perform_out;
    reg signed [10:0] dir_src_data_reg;
    wire signed [10:0] dir_dst_data_internal;
    wire signed [10:0] dir_src_data_internal;

    wire [2:0] src_sel;
    wire src_waiting;

    wire stall_read;

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