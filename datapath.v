
`include "constants.h"

module Datapath(
    input start,
    input clock,
    input resetn,
    input [`INSTRUCTION_WIDTH-1:0] instruction,
    output reg [`RESULT_WIDTH-1:0] result,
    
    input [`NNMEM_DATA_WIDTH-1 : 0] nnmem_data,
    output [`NNMEM_DATA_WIDTH-1 : 0] nnmem_output,
    
    output reg [`X_COORD_WIDTH-1:0] x,
    output reg [`Y_COORD_WIDTH-1:0] y,
    output reg [`COLOUR_WIDTH-1:0] colour,
    output reg plot,
    output reg finished
    );
    
    reg [1:0] delay;
    reg [`INSTRUCTION_WIDTH-1:0] instruction_buffer;
    
    wire [`MEM_DATA_WIDTH-1:0] mem_output;
    reg [`MEM_ADDR_WIDTH-1:0] mem_address;
    reg [`MEM_DATA_WIDTH-1:0] mem_data;
    reg mem_write;
    
    reg [`NNMEM_ADDR_WIDTH-1:0] nnmem_address;
    reg nnmem_write;
    
    wire [`FB_DATA_WIDTH-1:0] fb_output;
    reg [`FB_ADDR_WIDTH-1:0] fb_address;
    reg [`FB_DATA_WIDTH-1:0] fb_data;
    reg fb_write;
    
    ram12x16 ram(
        .address(mem_address),
        .clock(clock),
        .data(mem_data),
        .wren(mem_write),
        .q(mem_output)
    );
    
    ram1024x6 nnram(
        .address(nnmem_address),
        .clock(clock),
        .data(nnmem_data),
        .wren(nnmem_write),
        .q(nnmem_output)
    );
    
    ram3x15 framebuffer(
        .address(fb_address),
        .clock(clock),
        .data(fb_data),
        .wren(fb_write),
        .q(fb_output)
    );
    
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
            
            nnmem_address <= `NNMEM_ADDR_WIDTH'd0;
            nnmem_write <= 0;
            
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
                case (instruction_buffer[`OPCODE_WIDTH-1:0])
                    `OPCODE_DRAW: begin
                        if (delay) begin
                            delay = delay - 1;
                            if (!delay) begin
                                finished = 1;
                            end
                        end
                        else begin
                            fb_address = instruction_buffer[18:12] * `SCREEN_WIDTH + instruction_buffer[11:4];
                            fb_data = instruction_buffer[21:19];
                            fb_write = instruction_buffer[22];
                            
                            delay = 1;
                        end
                    end
                    `OPCODE_MEMREAD: begin
                        if (delay) begin
                            delay = delay - 1;
                            if (!delay) begin
                                result = mem_output;
                                
                                finished = 1;
                            end
                        end
                        else begin
                            mem_write = 0;
                            mem_address = instruction_buffer[19:4];
                            
                            delay = 1;
                        end
                    end
                    `OPCODE_MEMWRITE: begin
                        if (delay) begin
                            delay = delay - 1;
                            if (!delay) begin
                                mem_write = 0;
                                
                                finished = 1;
                            end
                        end
                        else begin
                            mem_write = 1;
                            mem_address = instruction_buffer[19:4];
                            mem_data = instruction_buffer[31:20];
                            
                            delay = 1;
                        end
                    end
                    `OPCODE_DISPLAY: begin
                        if (delay) begin
                            delay = delay - 1;
                            
                            colour = fb_output;
                            plot = 1;
                            
                            if (!delay) begin
                                finished = 1;
                            end
                        end
                        else begin
                            x = instruction_buffer[11:4];
                            y = instruction_buffer[18:12];
                            fb_address = y * `SCREEN_WIDTH + x;
                            fb_write = 0;
                            
                            delay = 1;
                        end
                    end
                    `OPCODE_NNMEMREAD: begin
                        if (delay) begin
                            delay = delay - 1;
                            if (!delay) begin
                                finished = 1;
                            end
                        end
                        else begin
                            nnmem_write = 0;
                            nnmem_address = instruction_buffer[9:4];
                            
                            delay = 1;
                        end
                    end
                    `OPCODE_NNMEMWRITE: begin
                        if (delay) begin
                            delay = delay - 1;
                            if (!delay) begin
                                nnmem_write = 0;
                                
                                finished = 1;
                            end
                        end
                        else begin
                            nnmem_write = 1;
                            nnmem_address = instruction_buffer[9:4];
                            
                            delay = 1;
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
