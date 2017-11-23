`include "constants.h"

module DrawBackground(
    input start,
    input clock,
    input resetn,
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
    reg wait;
    
    always @(posedge clock) begin
        if (!resetn) begin
            finished <= 1;
            x <= `X_COORD_WIDTH'd0;
            y <= `Y_COORD_WIDTH'd0;
            colour <= `COLOUR_WIDTH'd0;
            plot <= 0;
            
            start_dp <= 0;
            instruction_dp <= 0;
        end
        else begin
            // setup registers on the first cycle
            if (finished && start) begin
                x <= `X_COORD_WIDTH'd0;
                y <= `Y_COORD_WIDTH'd0;
                
                colour <= `COLOUR_WIDTH'b000;
                plot <= 1;
                finished <= 0;
                start_dp <= 1;
                wait = 1;
            end
            // update positions as long as we are not finished drawing
            else if (!finished && finished_dp) begin
                if (delay) {
                    start_dp = 1;
                    wait = 1;
                }
                else if (wait) {
                    start_dp = 0;
                    if (finished_dp) {
                        ...
                        start_dp = 1;
                        delay = 1;
                    }
                }
				colour <= `COLOUR_WIDTH'b010;
                if (x == `SCREEN_WIDTH - 1) begin
                    x <= `X_COORD_WIDTH'd0;
                    if (y == `SCREEN_HEIGHT - 1) begin
                        y <= `Y_COORD_WIDTH'd0;
                        finished <= 1;
                    end
                    else begin
                        y <= y + 1;
                    end
                end
                elss
            end
            else if (finished) begin
                start_dp <= 0;
                plot <= 0;
            end
        end
        instuction_dp <= {4'd1, 9'd0, plot, colour, y, x};
    end

endmodule
