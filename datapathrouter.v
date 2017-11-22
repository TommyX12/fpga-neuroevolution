
`include "constants.h"

`define THREADS_WIDTH 16
// might need to be smaller than 32 or else comparisons in for loop might not work

module DatapathRouter(
    
    clock,
    resetn,
    
    instruction,
    start,
    result,
    finished,
    
    instruction_dp,
    start_dp,
    result_dp,
    finished_dp
    
    );
    
    parameter ports;
    
    input clock;
    input resetn;
    
    input [`INSTRUCTION_WIDTH*ports-1:0] instruction;
    input [ports-1:0] start;
    output reg [`RESULT_WIDTH*ports-1:0] result;
    output reg [ports-1:0] finished;
    
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp;
    output reg start_dp;
    input [`RESULT_WIDTH-1:0] result_dp;
    input finished_dp;
    
    
    reg [ports-1:0] ptr_mask;
    reg [`THREADS_WIDTH-1:0] ptr;
    reg [`THREADS_WIDTH-1:0] index;
    reg waiting;
    reg delay;
    reg loop;
    
    always @(posedge clock) begin
        if (!resetn) begin
            result <= `RESULT_WIDTH*ports'd0;
            finished <= ~(ports'd0);
            
            instruction_dp = `INSTRUCTION_WIDTH'd0;
            start_dp = 0;
            
            ptr_mask <= ports'd1;
            ptr <= `THREADS_WIDTH'd0;
            index <= `THREADS_WIDTH'd0;
            waiting <= 0;
            delay <= 0;
            loop <= 0;
        end
        else begin
            finished = finished & ~(start);
            if (delay) begin
                delay = 0;
                start_dp = 1;
                waiting = 1;
            end
            else if (waiting) begin
                start_dp = 0;
                if (finished_dp) begin
                    // receive
                    for (int i = 0; i < ports; ++i) begin
                        if (ptr == i) begin
                            result[`THREADS_WIDTH * (i+1):`THREADS_WIDTH * i] = result_dp;
                        end
                    end
                    finished = finished | ptr_mask;
                    
                    waiting = 0;
                end
            end
            else begin // find new ones to check
                loop = 1;
                index = 0;
                while (index < ports && loop) begin
                    if (ptr_mask & ~(finished)) begin
                        // send
                        for (int i = 0; i < ports; ++i) begin
                            if (ptr == i) begin
                                instruction_dp = instruction[`THREADS_WIDTH * (i+1):`THREADS_WIDTH * i];
                            end
                        end
                        start_dp = 1;
                        
                        delay = 1;
                        loop = 0;
                    end
                    else begin
                        index = index + 1;
                        if (ptr == ports - 1) begin
                            ptr = 0;
                            ptr_mask = ports'd1;
                        end
                        else begin
                            ptr = ptr + 1;
                            ptr_mask = ptr_mask << 1;
                        end
                    end
                end
            end
        end
    end
    
endmodule
