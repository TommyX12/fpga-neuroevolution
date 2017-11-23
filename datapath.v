
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
    
    input [`MEM_DATA_WIDTH-1:0] mem_output,
    output reg [`MEM_ADDR_WIDTH-1:0] mem_address,
    output reg [`MEM_DATA_WIDTH-1:0] mem_data,
    output reg mem_write,
    );
    
    reg [1:0] delay;
    
    always @(posedge clock) begin
        if (!resetn) begin
            result <= `RESULT_WIDTH'd0;
            
            x <= `X_COORD_WIDTH'd0;
            y <= `Y_COORD_WIDTH'd0;
            colour <= `COLOUR_WIDTH'd0;
            plot <= 0;
            finished <= 1;
            
            mem_address <= `MEM_ADDR_WIDTH'd0;
            mem_data <= `MEM_DATA_WIDTH'd0;
            mem_write <= 0;
            
            delay <= 2'b0;
        end
        else begin
            if (finished) begin
                if (start) begin
                    finished = 0;
                end
            end
            else begin
                case (instruction[`INSTRUCTION_WIDTH-1:`INSTRUCTION_WIDTH-`OPCODE_WIDTH])
                    `OPCODE_WIDTH'd1: begin
                        if (delay) begin
                            delay = delay - 1;
                            finished = 1;
                        end
                        else begin
                            x = instruction[7:0];
                            y = instruction[14:8];
                            colour = instruction[17:15];
                            plot = instruction[18];
                            
                            delay = 1;
                        end
                    end
                    `OPCODE_WIDTH'd2: begin
                        if (delay) begin
                            result = mem_output;
                            
                            delay = delay - 1;
                            finished = 1;
                        end
                        else begin
                            mem_write = 0;
                            mem_address = instruction[15:0];
                            
                            delay = 2;
                        end
                    end
                    `OPCODE_WIDTH'd3: begin
                        if (delay) begin
                            delay = delay - 1;
                            finished = 1;
                        end
                        else begin
                            mem_write = 1;
                            mem_address = instruction[15:0];
                            mem_data = instruction[27:16];
                            
                            delay = 2;
                        end
                    end
                    default: begin
                        
                    end
                endcase
            end
        end
    end
    
endmodule
