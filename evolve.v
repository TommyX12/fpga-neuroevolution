// template for an FSM


`include "constants.h"

// TODO change prefix to be for this file specifically
// TODO for cur_state += 1 to work, this must also reflect the real execution order
`define EVOLVE_OP_WIDTH 6 // TODO this must be large enough
`define EVOLVE_OP_STANDBY          `EVOLVE_OP_WIDTH'd0
`define EVOLVE_OP_TIMER_CHECK      `EVOLVE_OP_WIDTH'd1
`define EVOLVE_OP_FOOD_SET_X_START `EVOLVE_OP_WIDTH'd2
`define EVOLVE_OP_FOOD_SET_X_DELAY `EVOLVE_OP_WIDTH'd3
`define EVOLVE_OP_FOOD_SET_X_WAIT  `EVOLVE_OP_WIDTH'd4
`define EVOLVE_OP_FOOD_SET_Y_START `EVOLVE_OP_WIDTH'd5
`define EVOLVE_OP_FOOD_SET_Y_DELAY `EVOLVE_OP_WIDTH'd6
`define EVOLVE_OP_FOOD_SET_Y_WAIT  `EVOLVE_OP_WIDTH'd7
`define EVOLVE_OP_FINISHED         `EVOLVE_OP_WIDTH'd8

// TODO change to your module name.
module Evolve(
    input start,
    input clock,
    input resetn,
    
    output reg finished,
    
    input [`RAND_WIDTH-1:0] rand,
    
    output reg [`NN_DATA_WIDTH * (`NN_WEIGHTS_SIZE) - 1 : 0] neural_net_weights,
    
    input [`DELAY_WIDTH-1:0] gen_duration,
    
    input finished_dp,
    input [`RESULT_WIDTH-1:0] result_dp,
    output reg start_dp,
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp
    );

    reg [`EVOLVE_OP_WIDTH-1:0] cur_state;
    
    // TODO declare any register
    reg [`NN_DATA_WIDTH * (`NN_WEIGHTS_SIZE) - 1 : 0] weights_buffer;
    
    reg [`DELAY_WIDTH-1:0] gen_counter;
    reg [`MEM_ADDR_WIDTH-1:0] food_index;
    reg [`X_COORD_WIDTH-1:0] food_x;
    reg [`Y_COORD_WIDTH-1:0] food_y;
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `EVOLVE_OP_STANDBY;
            finished <= 1;
            
            start_dp <= 0;
            instruction_dp <= 0;
            
            // TODO reset any register
            neural_net_weights <= {(`NN_DATA_WIDTH * (`NN_WEIGHTS_SIZE)){1'b0}};
            weights_buffer <= {(`NN_DATA_WIDTH * (`NN_WEIGHTS_SIZE)){1'b0}};
            
            gen_counter <= `DELAY_WIDTH'd0;
            food_index <= `MEM_ADDR_WIDTH'd0;
            food_x <= `X_COORD_WIDTH'd0;
            food_y <= `Y_COORD_WIDTH'd0;
        end
        else begin
            // TODO make sure everything use blocking assignment
            
            case (cur_state)
                `EVOLVE_OP_STANDBY: begin
                    finished = 1;
                    
                    // usually do nothing
                    
                    if (start) begin
                        // TODO register initialization on start
                        food_index = `MEM_ADDR_WIDTH'd0;
                        food_x = `X_COORD_WIDTH'd0;
                        food_y = `Y_COORD_WIDTH'd0;
                        
                        cur_state = cur_state + `EVOLVE_OP_WIDTH'd1; // this jumps to the next instruction in sequence
                        finished = 0;
                    end
                end
                `EVOLVE_OP_TIMER_CHECK: begin
                    if (gen_counter) begin
                        gen_counter = gen_counter - `DELAY_WIDTH'd1;
                        cur_state = `EVOLVE_OP_STANDBY;
                    end
                    else begin
                        gen_counter = gen_duration;
                        
                        cur_state = cur_state + `EVOLVE_OP_WIDTH'd1; // this jumps to the next instruction in sequence
                    end
                end
                
                `EVOLVE_OP_FOOD_SET_X_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {rand, `ADDR_FOOD_X(food_index), `OPCODE_MEMWRITE};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `EVOLVE_OP_WIDTH'd1;
                end
                `EVOLVE_OP_FOOD_SET_X_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `EVOLVE_OP_WIDTH'd1;
                end
                `EVOLVE_OP_FOOD_SET_X_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        food_x = result_dp;
                        
                        cur_state = cur_state + `EVOLVE_OP_WIDTH'd1;
                    end
                end
                
                `EVOLVE_OP_FOOD_SET_Y_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {rand, `ADDR_FOOD_Y(food_index), `OPCODE_MEMWRITE};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `EVOLVE_OP_WIDTH'd1;
                end
                `EVOLVE_OP_FOOD_SET_Y_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `EVOLVE_OP_WIDTH'd1;
                end
                `EVOLVE_OP_FOOD_SET_Y_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        food_y = result_dp;
                        if (food_index == `NUM_FOOD - 1) begin
                            food_index = `MEM_ADDR_WIDTH'd0;
                            cur_state = cur_state + `EVOLVE_OP_WIDTH'd1;
                        end
                        else begin
                            food_index = food_index + `MEM_ADDR_WIDTH'd1;
                            cur_state = `EVOLVE_OP_FOOD_SET_X_START;
                        end
                        
                    end
                end
                
                `EVOLVE_OP_FINISHED: begin
                    cur_state = `EVOLVE_OP_STANDBY;
                end
            endcase
        end
    end

endmodule
