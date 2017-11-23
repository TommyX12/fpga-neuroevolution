`include "constants.h"

`define ANT_COLOUR 3'b010;

module AntDraw(
    input clock,
    input resetn,
    input start,
    output reg finished,
    
    input finished_dp,
    input [`RESULT_WIDTH-1:0] result_dp,
    output reg start_dp,
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp
    );
    
    reg [`X_COORD_WIDTH-1:0] frag_x;
	reg [`Y_COORD_WIDTH-1:0] frag_y;

    always @(posedge clock) begin
        if (!resetn) begin
            frag_x <= `X_COORD_WIDTH'd0;
            frag_y <= `Y_COORD_WIDTH'd0;

            x <= `X_COORD_WIDTH'd0;
            y <= `Y_COORD_WIDTH'd0;
            colour <= `COLOUR_WIDTH'd0;
            plot <= 0;
            finished <= 1;
        end
        else begin
            // setup registers on the first cycle
            if (finished && start) begin
                frag_x <= `X_COORD_WIDTH'd0;
                frag_y <= `Y_COORD_WIDTH'd0;
                     
                colour <= `COLOUR_WIDTH'b000;
                plot <= 1;
                finished <= 0;
            end
            // update positions as long as we are not finished drawing
            else if (!finished) begin
                     colour <= `COLOUR_WIDTH'b010;
                if (frag_x == `SCREEN_WIDTH - 1) begin
                    frag_x <= `X_COORD_WIDTH'd0;
                    if (frag_y == `SCREEN_HEIGHT - 1) begin
                        frag_y <= `Y_COORD_WIDTH'd0;
                        finished <= 1;
                    end
                    else begin
                        frag_y <= frag_y + 1;
                    end
                end
                else begin
                    frag_x <= frag_x + 1;
                end
            end
            else if (finished) begin
                plot <= 0;
            end
            x = frag_x;
            y = frag_y;
        end
    end

    endmodule

