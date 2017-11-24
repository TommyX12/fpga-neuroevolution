

`include "constants.h"

module FPSLimiter(
    input start,
    input clock,
    input resetn,
    
    input [`DELAY_WIDTH-1:0] delay,
    
    output reg finished
    );

    // TODO declare any register
    reg [`DELAY_WIDTH-1:0] counter;
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `PREFIX_OP_STANDBY;
            finished <= 1;
            
            start_dp <= 0;
            instruction_dp <= 0;
            
            // TODO reset any register
            counter <= `DELAY_WIDTH'd0;
        end
        else begin
            // TODO make sure everything use blocking assignment
            if (start && finished) begin
                finished = 0;
                counter = delay;
            end
            else if (counter) begin
                counter = counter - `DELAY_WIDTH'd1;
            end
            else begin
                finished = 1;
            end
        end
    end

endmodule
