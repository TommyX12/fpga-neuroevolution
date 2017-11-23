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
    
    reg [`X_COORD_WIDTH-1:0] x;
    reg [`Y_COORD_WIDTH-1:0] y;
    reg [`COLOUR_WIDTH-1:0] colour; // WE'RE CANADIAN
    reg plot;
	
    reg delay;
    reg waiting;
    
    always @(posedge clock) begin
        if (!resetn) begin
            finished <= 1;
            x <= `X_COORD_WIDTH'd0;
            y <= `Y_COORD_WIDTH'd0;
            colour <= `COLOUR_WIDTH'd0;
            plot <= 0;
            
            start_dp <= 0;
            instruction_dp <= 0;
            
            delay <= 0;
            waiting <= 0;
        end
        else begin
            colour <= `COLOUR_WIDTH'b111;
            
            // setup registers on the first cycle
            if (finished) begin
                if (start) begin
                    x <= `X_COORD_WIDTH'd0;
                    y <= `Y_COORD_WIDTH'd0;
                    
                    plot <= 1;
                    finished <= 0;
                    start_dp <= 1;
                    instruction_dp <= {4'd1, 9'd0, plot, colour, y, x};
                    delay <= 1;
                    waiting = 0;
                end
                else begin
                    start_dp <= 0;
                    plot <= 0;
                end
            end
            
            // update positions as long as we are not finished drawing
            else begin
                if (delay) begin
                    start_dp = 1;
                    waiting = 1;
                end
                else if (waiting) begin
                    start_dp = 0;
                    if (finished_dp) begin
                        if (x == `SCREEN_WIDTH - 1) begin
                            x = `X_COORD_WIDTH'd0;
                            if (y == `SCREEN_HEIGHT - 1) begin
                                y = `Y_COORD_WIDTH'd0;
                                finished <= 1;
                            end
                            else begin
                                y = y + 1;
                            end
                        end
                        else begin
                            x = x + 1;
                        end
                        if (!finished) begin
                            start_dp = 1;
                            instruction_dp = {4'd1, 9'd0, plot, colour, y, x};
                            delay = 1;
                            waiting = 0;
                        end
                    end
                end
            end
        end
    end

endmodule

