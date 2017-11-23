
`include "constants.h"

module Datapath(
    input start,
    input clock,
    input resetn,
    input [`INSTRUCTION_WIDTH-1:0] instruction,
    output reg [`RESULT_WIDTH-1:0] result,
    
    output reg [`X_COORD_WIDTH-1:0] x,
    output reg [`Y_COORD_WIDTH-1:0] y,
    output reg [`COLOUR_WIDTH-1:0] colour,
    output reg plot,
    output reg finished
    );
    
    reg delay;
    
    always @(posedge clock) begin
        if (!resetn) begin
            result <= `RESULT_WIDTH'd0;
            
            x <= `X_COORD_WIDTH'd0;
            y <= `Y_COORD_WIDTH'd0;
            colour <= `COLOUR_WIDTH'd0;
            plot <= 0;
            finished <= 1;
            
            delay <= 0;
            waiting <= 0;
        end
        else begin
            if (finished) begin
                if (start) begin
                    finished = 0;
                end
            end
            else begin
                if (delay) begin
                    delay = 0;
                    finished = 1;
                end
                case (instruction[`INSTRUCTION_WIDTH-1:`INSTRUCTION_WIDTH-`OPCODE_WIDTH])
                    `OPCODE_WIDTH'd1: begin
                        x = instruction[7:0];
                        y = instruction[14:8];
                        colour = instruction[17:15];
                        plot = instruction[18];
                        
                        delay = 1;
                    end
                    default: begin
                        
                    end
                endcase
            end
        end
    end
    
endmodule
