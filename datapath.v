
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
    output reg finished,
    
    input [`MEM_DATA_WIDTH-1:0] mem_output,
    output reg [`MEM_ADDR_WIDTH-1:0] mem_address,
    output reg [`MEM_DATA_WIDTH-1:0] mem_data,
    output reg mem_write
    );
    
    reg [1:0] delay;
    reg [`INSTRUCTION_WIDTH-1:0] instruction_buffer;
    
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
            instruction_buffer <= `INSTRUCTION_WIDTH'd0;
        end
        else begin
            if (finished) begin
                if (start) begin
                    finished = 0;
                    instruction_buffer = instruction;
                end
            end
            else begin
                case (instruction_buffer[`INSTRUCTION_WIDTH-1:`INSTRUCTION_WIDTH-`OPCODE_WIDTH])
                    `OPCODE_WIDTH'd1: begin
                        if (delay) begin
                            delay = delay - 1;
                            if (!delay) begin
                                finished = 1;
                            end
                        end
                        else begin
                            x = instruction_buffer[7:0];
                            y = instruction_buffer[14:8];
                            colour = instruction_buffer[17:15];
                            plot = instruction_buffer[18];
                            
                            delay = 1;
                        end
                    end
                    `OPCODE_WIDTH'd2: begin
                        if (delay) begin
                            // result = mem_output;
                            result = `RESULT_WIDTH'd15;
                            
                            delay = delay - 1;
                            if (!delay) begin
                                finished = 1;
                            end
                        end
                        else begin
                            mem_write = 0;
                            mem_address = instruction_buffer[15:0];
                            
                            delay = 2;
                        end
                    end
                    `OPCODE_WIDTH'd3: begin
                        if (delay) begin
                            delay = delay - 1;
                            if (!delay) begin
                                finished = 1;
                            end
                        end
                        else begin
                            mem_write = 1;
                            mem_address = instruction_buffer[15:0];
                            mem_data = instruction_buffer[27:16];
                            
                            delay = 2;
                        end
                    end
                    default: begin
                        finished = 1;
                    end
                endcase
            end
        end
    end
    
endmodule
