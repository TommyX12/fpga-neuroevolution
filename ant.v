`include "constants.h"

//  change prefix to be for this file specifically
`define ANTD_OP_WIDTH 5 // TODO this must be large enough
`define ANTD_OP_STANDBY            `ANTD_OP_WIDTH'd0
`define ANTD_OP_LOAD_X_START       `ANTD_OP_WIDTH'd1
`define ANTD_OP_LOAD_X_DELAY       `ANTD_OP_WIDTH'd2
`define ANTD_OP_LOAD_X_WAIT        `ANTD_OP_WIDTH'd3
`define ANTD_OP_LOAD_Y_START       `ANTD_OP_WIDTH'd4
`define ANTD_OP_LOAD_Y_DELAY       `ANTD_OP_WIDTH'd5
`define ANTD_OP_LOAD_Y_WAIT        `ANTD_OP_WIDTH'd6
`define ANTD_OP_LOAD_FITNESS_START `ANTD_OP_WIDTH'd7
`define ANTD_OP_LOAD_FITNESS_DELAY `ANTD_OP_WIDTH'd8
`define ANTD_OP_LOAD_FITNESS_WAIT  `ANTD_OP_WIDTH'd9
`define ANTD_OP_DRAW_START         `ANTD_OP_WIDTH'd10
`define ANTD_OP_DRAW_DELAY         `ANTD_OP_WIDTH'd11
`define ANTD_OP_DRAW_WAIT          `ANTD_OP_WIDTH'd12

module AntDraw(
    input clock,
    input resetn,
    input start,
    output reg finished,
    
    input [`MEM_ADDR_WIDTH-1:0] id,
    
    input finished_dp,
    input [`RESULT_WIDTH-1:0] result_dp,
    output reg start_dp,
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp
    );
    
    reg [`ANTD_OP_WIDTH-1:0] cur_state;
    
    // TODO declare any register
    reg [`X_COORD_WIDTH-1:0] x;
    reg [`Y_COORD_WIDTH-1:0] y;
    reg [`X_COORD_WIDTH-1:0] dx;
    reg [`Y_COORD_WIDTH-1:0] dy;
    reg [`COLOUR_WIDTH-1:0] colour; // WE'RE CANADIAN
    reg [`FITNESS_WIDTH-1:0] fitness;
    reg plot;
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `ANTD_OP_STANDBY;
            finished <= 1;
            
            start_dp <= 0;
            instruction_dp <= 0;
            
            // TODO reset any register
            x <= `X_COORD_WIDTH'd0;
            y <= `Y_COORD_WIDTH'd0;
            dx <= `X_COORD_WIDTH'd0;
            dy <= `Y_COORD_WIDTH'd0;
            colour <= `COLOUR_WIDTH'd0;
            fitness <= `FITNESS_WIDTH'd0;
            plot <= 0;
        end
        else begin
            // TODO make sure everything use blocking assignment
            case (cur_state)
                
                `ANTD_OP_STANDBY: begin
                    finished = 1;
                    
                    if (start) begin
                        // TODO register initialization on start
                        dx <= `X_COORD_WIDTH'd0;
                        dy <= `Y_COORD_WIDTH'd0;
                        
                        cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                        finished = 0;
                    end
                end
                `ANTD_OP_LOAD_X_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_ANT_X(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_X_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_X_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        x = result_dp - 1;
                        
                        cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                    end
                end
                `ANTD_OP_LOAD_Y_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_ANT_Y(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_Y_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_Y_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        y = result_dp - 1;
                        
                        cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                    end
                end
                `ANTD_OP_LOAD_FITNESS_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_ANT_FITNESS(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_FITNESS_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_FITNESS_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        fitness = result_dp;
                        
                        cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                    end
                end
                
                `ANTD_OP_DRAW_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    if (fitness >= `ANT_FITNESS_MARK2) begin
                        colour = `COLOUR_ANT3;
                    end
                    else if (fitness >= `ANT_FITNESS_MARK1) begin
                        colour = `COLOUR_ANT2;
                    end
                    else begin
                        colour = `COLOUR_ANT1;
                    end
                    instruction_dp = {1'b1, colour, y + dy, x + dx, `OPCODE_DRAW};
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_DRAW_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_DRAW_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        if (dx == `ANT_WIDTH - 1) begin
                            dx = `X_COORD_WIDTH'd0;
                            if (dy == `ANT_HEIGHT - 1) begin
                                dy = `Y_COORD_WIDTH'd0;
                                finished = 1;
                            end
                            else begin
                                dy = dy + 1;
                            end
                        end
                        else begin
                            dx = dx + 1;
                        end
                        
                        if (finished) begin
                            cur_state = `ANTD_OP_STANDBY;
                        end
                        else begin
                            cur_state = `ANTD_OP_DRAW_START;
                        end
                    end
                end
            endcase
        end
    end

endmodule

// TODO change prefix to be for this file specifically
`define ANTU_OP_WIDTH 6 // TODO this must be large enough
`define ANTU_OP_STANDBY            `ANTU_OP_WIDTH'd0
                                                   
`define ANTU_OP_LOAD_X_START       `ANTU_OP_WIDTH'd1
`define ANTU_OP_LOAD_X_DELAY       `ANTU_OP_WIDTH'd2
`define ANTU_OP_LOAD_X_WAIT        `ANTU_OP_WIDTH'd3
`define ANTU_OP_LOAD_Y_START       `ANTU_OP_WIDTH'd4
`define ANTU_OP_LOAD_Y_DELAY       `ANTU_OP_WIDTH'd5
`define ANTU_OP_LOAD_Y_WAIT        `ANTU_OP_WIDTH'd6
`define ANTU_OP_LOAD_FITNESS_START `ANTU_OP_WIDTH'd7
`define ANTU_OP_LOAD_FITNESS_DELAY `ANTU_OP_WIDTH'd8
`define ANTU_OP_LOAD_FITNESS_WAIT  `ANTU_OP_WIDTH'd9
                                                   
`define ANTU_OP_FOOD_X_START       `ANTU_OP_WIDTH'd10
`define ANTU_OP_FOOD_X_DELAY       `ANTU_OP_WIDTH'd11
`define ANTU_OP_FOOD_X_WAIT        `ANTU_OP_WIDTH'd12
`define ANTU_OP_FOOD_Y_START       `ANTU_OP_WIDTH'd13
`define ANTU_OP_FOOD_Y_DELAY       `ANTU_OP_WIDTH'd14
`define ANTU_OP_FOOD_Y_WAIT        `ANTU_OP_WIDTH'd15
`define ANTU_OP_FOOD_SET_X_START   `ANTU_OP_WIDTH'd16
`define ANTU_OP_FOOD_SET_X_DELAY   `ANTU_OP_WIDTH'd17
`define ANTU_OP_FOOD_SET_X_WAIT    `ANTU_OP_WIDTH'd18
`define ANTU_OP_FOOD_SET_Y_START   `ANTU_OP_WIDTH'd19
`define ANTU_OP_FOOD_SET_Y_DELAY   `ANTU_OP_WIDTH'd20
`define ANTU_OP_FOOD_SET_Y_WAIT    `ANTU_OP_WIDTH'd21
                                                   
`define ANTU_OP_POISON_X_START     `ANTU_OP_WIDTH'd22
`define ANTU_OP_POISON_X_DELAY     `ANTU_OP_WIDTH'd23
`define ANTU_OP_POISON_X_WAIT      `ANTU_OP_WIDTH'd24
`define ANTU_OP_POISON_Y_START     `ANTU_OP_WIDTH'd25
`define ANTU_OP_POISON_Y_DELAY     `ANTU_OP_WIDTH'd26
`define ANTU_OP_POISON_Y_WAIT      `ANTU_OP_WIDTH'd27
`define ANTU_OP_POISON_SET_X_START `ANTU_OP_WIDTH'd28
`define ANTU_OP_POISON_SET_X_DELAY `ANTU_OP_WIDTH'd29
`define ANTU_OP_POISON_SET_X_WAIT  `ANTU_OP_WIDTH'd30
`define ANTU_OP_POISON_SET_Y_START `ANTU_OP_WIDTH'd31
`define ANTU_OP_POISON_SET_Y_DELAY `ANTU_OP_WIDTH'd32
`define ANTU_OP_POISON_SET_Y_WAIT  `ANTU_OP_WIDTH'd33
                                                   
`define ANTU_OP_NN_LOAD_START      `ANTU_OP_WIDTH'd34
`define ANTU_OP_NN_LOAD_DELAY      `ANTU_OP_WIDTH'd35
`define ANTU_OP_NN_LOAD_WAIT       `ANTU_OP_WIDTH'd36
`define ANTU_OP_NN_DELAY           `ANTU_OP_WIDTH'd37
`define ANTU_OP_NN_WAIT            `ANTU_OP_WIDTH'd38
                                                   
`define ANTU_OP_SET_X_START        `ANTU_OP_WIDTH'd39
`define ANTU_OP_SET_X_DELAY        `ANTU_OP_WIDTH'd40
`define ANTU_OP_SET_X_WAIT         `ANTU_OP_WIDTH'd41
`define ANTU_OP_SET_Y_START        `ANTU_OP_WIDTH'd42
`define ANTU_OP_SET_Y_DELAY        `ANTU_OP_WIDTH'd43
`define ANTU_OP_SET_Y_WAIT         `ANTU_OP_WIDTH'd44
`define ANTU_OP_SET_FITNESS_START  `ANTU_OP_WIDTH'd45
`define ANTU_OP_SET_FITNESS_DELAY  `ANTU_OP_WIDTH'd46
`define ANTU_OP_SET_FITNESS_WAIT   `ANTU_OP_WIDTH'd47


module AntUpdate(
    input clock,
    input resetn,
    input start,
    output reg finished,
    
    input [`MEM_ADDR_WIDTH-1:0] id,
    input [`RAND_WIDTH-1:0] rand,
    
    input [`NN_DATA_WIDTH * (`NN_WEIGHTS_SIZE) - 1 : 0] neural_net_weights,
    
    output reg [23:0] debug,

    input finished_dp,
    input [`RESULT_WIDTH-1:0] result_dp,
    output reg start_dp,
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp
    );
    
    
    
    reg [`ANTU_OP_WIDTH-1:0] cur_state;
    
    // TODO declare any register
    reg [`X_COORD_WIDTH-1:0] x;
    reg [`Y_COORD_WIDTH-1:0] y;
    reg [`FITNESS_WIDTH-1:0] fitness;
    
    reg [`X_COORD_WIDTH-1:0] dx;
    reg [`Y_COORD_WIDTH-1:0] dy;
    
    reg colliding;
    reg [`MEM_ADDR_WIDTH-1:0] food_index;
    reg [`X_COORD_WIDTH-1:0] food_x;
    reg [`Y_COORD_WIDTH-1:0] food_y;
    reg [`MEM_ADDR_WIDTH-1:0] food_index_closest;
    reg [`STD_WIDTH-1:0] food_distance_closest;
    reg [`X_COORD_WIDTH-1:0] food_x_closest;
    reg [`Y_COORD_WIDTH-1:0] food_y_closest;
    reg [`MEM_ADDR_WIDTH-1:0] poison_index;
    reg [`X_COORD_WIDTH-1:0] poison_x;
    reg [`Y_COORD_WIDTH-1:0] poison_y;
    reg [`MEM_ADDR_WIDTH-1:0] poison_index_closest;
    reg [`STD_WIDTH-1:0] poison_distance_closest;
    reg [`X_COORD_WIDTH-1:0] poison_x_closest;
    reg [`Y_COORD_WIDTH-1:0] poison_y_closest;
    // TODO tip: store closest food position and distance here.
    
    
    // neural net related stuff
    // neural net input
    reg [`NN_DATA_WIDTH-1:0] food_left;
    reg [`NN_DATA_WIDTH-1:0] food_right;
    reg [`NN_DATA_WIDTH-1:0] food_up;
    reg [`NN_DATA_WIDTH-1:0] food_down;
    reg [`NN_DATA_WIDTH-1:0] poison_left;
    reg [`NN_DATA_WIDTH-1:0] poison_right;
    reg [`NN_DATA_WIDTH-1:0] poison_up;
    reg [`NN_DATA_WIDTH-1:0] poison_down;
    // neural net output
    wire [`NN_DATA_WIDTH-1:0] move_left;
    wire [`NN_DATA_WIDTH-1:0] move_right;
    wire [`NN_DATA_WIDTH-1:0] move_up;
    wire [`NN_DATA_WIDTH-1:0] move_down;
    
    NeuralNet neural_net(
        .input_data({
            food_left,
            food_right,
            food_up,
            food_down,
            poison_left,
            poison_right,
            poison_up,
            poison_down
        }),
        .weights(neural_net_weights),
        .output_data({
            move_left,
            move_right,
            move_up,
            move_down
        })
    );
    defparam neural_net.data_width = `NN_DATA_WIDTH;
    defparam neural_net.input_size = `NN_INPUT_SIZE;
    defparam neural_net.hidden_size = `NN_HIDDEN_SIZE;
    defparam neural_net.output_size = `NN_OUTPUT_SIZE;
	 
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `ANTU_OP_STANDBY;
            finished <= 1;
            
            start_dp <= 0;
            instruction_dp <= 0;
            
            // TODO reset any register
            x <= `X_COORD_WIDTH'd10;
            y <= `Y_COORD_WIDTH'd10;
            fitness <= `FITNESS_WIDTH'd0;
            
            dx <= `X_COORD_WIDTH'd1;
            dy <= `Y_COORD_WIDTH'd1;
            
            colliding <= 0;
            food_index <= `MEM_ADDR_WIDTH'd0;
            food_x <= `X_COORD_WIDTH'd0;
            food_y <= `Y_COORD_WIDTH'd0;
            food_index_closest <= `MEM_ADDR_WIDTH'd0;
            food_distance_closest <= ~(`STD_WIDTH'd0);
            food_x_closest <= `X_COORD_WIDTH'd0;
            food_y_closest <= `Y_COORD_WIDTH'd0;
            poison_index <= `MEM_ADDR_WIDTH'd0;
            poison_x <= `X_COORD_WIDTH'd0;
            poison_y <= `Y_COORD_WIDTH'd0;
            poison_index_closest <= `MEM_ADDR_WIDTH'd0;
            poison_distance_closest <= ~(`STD_WIDTH'd0);
            poison_x_closest <= `X_COORD_WIDTH'd0;
            poison_y_closest <= `Y_COORD_WIDTH'd0;
            
            // neural net related stuff
            // TODO make this right once testing finishes
            food_left <= `NN_DATA_WIDTH'b00010000;
            food_right <= `NN_DATA_WIDTH'b00010000;
            food_up <= `NN_DATA_WIDTH'b00010000;
            food_down <= `NN_DATA_WIDTH'b00010000;
            poison_left <= `NN_DATA_WIDTH'b00010000;
            poison_right <= `NN_DATA_WIDTH'b00010000;
            poison_up <= `NN_DATA_WIDTH'b00010000;
            poison_down <= `NN_DATA_WIDTH'b00010000;
        end
        else begin
            // TODO make sure everything use blocking assignment
            case (cur_state)
                
                `ANTU_OP_STANDBY: begin
                    finished = 1;
                    
                    if (start) begin
                        // TODO register initialization on start
                        food_index <= `MEM_ADDR_WIDTH'd0;
                        food_x <= `X_COORD_WIDTH'd0;
                        food_y <= `Y_COORD_WIDTH'd0;
                        food_index_closest <= `MEM_ADDR_WIDTH'd0;
                        food_distance_closest <= ~(`STD_WIDTH'd0);
                        food_x_closest <= `X_COORD_WIDTH'd0;
                        food_y_closest <= `Y_COORD_WIDTH'd0;
                        poison_index <= `MEM_ADDR_WIDTH'd0;
                        poison_x <= `X_COORD_WIDTH'd0;
                        poison_y <= `Y_COORD_WIDTH'd0;
                        poison_index_closest <= `MEM_ADDR_WIDTH'd0;
                        poison_distance_closest <= ~(`STD_WIDTH'd0);
                        poison_x_closest <= `X_COORD_WIDTH'd0;
                        poison_y_closest <= `Y_COORD_WIDTH'd0;
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                        finished = 0;
                        
                        colliding = 0;
                    end
                end
                
                `ANTU_OP_LOAD_X_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_ANT_X(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_LOAD_X_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_LOAD_X_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        x = result_dp;
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                `ANTU_OP_LOAD_Y_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_ANT_Y(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_LOAD_Y_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_LOAD_Y_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        y = result_dp;
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                `ANTU_OP_LOAD_FITNESS_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_ANT_FITNESS(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_LOAD_FITNESS_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_LOAD_FITNESS_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        fitness = result_dp;
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                
                // TODO
                // I added extra states for writing the modified food location back to memory
                
                `ANTU_OP_FOOD_X_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_FOOD_X(food_index), `OPCODE_MEMREAD};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_FOOD_X_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_FOOD_X_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        food_x = result_dp;
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                
                `ANTU_OP_FOOD_Y_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_FOOD_Y(food_index), `OPCODE_MEMREAD};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_FOOD_Y_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_FOOD_Y_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        food_y = result_dp;
                        
                        // process the food
                        `define DISTANCE(X1, Y1, X2, Y2) ({1'b0, (X2 > X1 ? X2 - X1 : X1 - X2)} + {1'b0, (Y2 > Y1 ? Y2 - Y1 : Y1 - Y2)})
                        if (`DISTANCE(food_x, food_y, x, y) < food_distance_closest) begin
                            food_index_closest = food_index;
                            food_distance_closest = `DISTANCE(food_x, food_y, x, y);
                            food_x_closest = food_x;
                            food_y_closest = food_y;
                        end
                        
                        if (food_index == `NUM_FOOD - 1) begin
                            food_index = `MEM_ADDR_WIDTH'd0;
                            if (food_distance_closest <= `EAT_RADIUS) begin
                                fitness = fitness + `FOOD_FITNESS;
                                cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                            end
                            else begin
                                cur_state = `ANTU_OP_POISON_X_START;
                            end
                        end
                        else begin
                            food_index = food_index + `MEM_ADDR_WIDTH'd1;
                            cur_state = `ANTU_OP_FOOD_X_START;
                        end
                        
                    end
                end
                
                `ANTU_OP_FOOD_SET_X_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {rand / (`RAND_MAX / `SCREEN_WIDTH), `ADDR_FOOD_X(food_index_closest), `OPCODE_MEMWRITE};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_FOOD_SET_X_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_FOOD_SET_X_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                
                `ANTU_OP_FOOD_SET_Y_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {rand / (`RAND_MAX / `SCREEN_HEIGHT), `ADDR_FOOD_Y(food_index_closest), `OPCODE_MEMWRITE};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_FOOD_SET_Y_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_FOOD_SET_Y_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end

                `ANTU_OP_POISON_X_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_POISON_X(poison_index), `OPCODE_MEMREAD};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_POISON_X_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_POISON_X_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        poison_x = result_dp;
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                
                `ANTU_OP_POISON_Y_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_POISON_Y(poison_index), `OPCODE_MEMREAD};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_POISON_Y_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_POISON_Y_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        poison_y = result_dp;
                        
                        // process the poison
                        `define DISTANCE(X1, Y1, X2, Y2) ({1'b0, (X2 > X1 ? X2 - X1 : X1 - X2)} + {1'b0, (Y2 > Y1 ? Y2 - Y1 : Y1 - Y2)})
                        if (`DISTANCE(poison_x, poison_y, x, y) < poison_distance_closest) begin
                            poison_index_closest = poison_index;
                            poison_distance_closest = `DISTANCE(poison_x, poison_y, x, y);
                            poison_x_closest = poison_x;
                            poison_y_closest = poison_y;
                        end
                        
                        if (poison_index == `NUM_POISON - 1) begin
                            poison_index = `MEM_ADDR_WIDTH'd0;
                            if (poison_distance_closest <= `EAT_RADIUS) begin
                                if (fitness >= `POISON_FITNESS) begin
                                    fitness = fitness - `POISON_FITNESS;
                                end
                                cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                            end
                            else begin
                                cur_state = `ANTU_OP_NN_LOAD_START;
                            end
                        end
                        else begin
                            poison_index = poison_index + `MEM_ADDR_WIDTH'd1;
                            cur_state = `ANTU_OP_POISON_X_START;
                        end
                        
                    end
                end
                
                `ANTU_OP_POISON_SET_X_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {rand / (`RAND_MAX / `SCREEN_WIDTH), `ADDR_POISON_X(poison_index_closest), `OPCODE_MEMWRITE};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_POISON_SET_X_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_POISON_SET_X_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                
                `ANTU_OP_POISON_SET_Y_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {rand / (`RAND_MAX / `SCREEN_HEIGHT), `ADDR_POISON_Y(poison_index_closest), `OPCODE_MEMWRITE};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_POISON_SET_Y_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_POISON_SET_Y_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end

                
                // `ANTU_OP_NN_START: begin
                    // x = x + dx;
                    // y = y + dy;
                    // if (x < `X_COORD_WIDTH'd0) begin
                        // dx = -dx;
                    // end
                    // else if (x >= `SCREEN_WIDTH - `ANT_WIDTH) begin
                        // dx = -dx;
                    // end
                    // if (y < `Y_COORD_WIDTH'd0) begin
                        // dy = -dy;
                    // end
                    // else if (y >= `SCREEN_HEIGHT - `ANT_HEIGHT) begin
                        // dy = -dy;
                    // end
                    
                    // cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                // end
                `ANTU_OP_NN_LOAD_START: begin
                    start_dp = 1;
                    
                    // process input info
                    if (food_x_closest > x) begin
                        food_left = `NN_DATA_WIDTH'd0;
                        food_right = food_x_closest - x;
                    end
                    else begin
                        food_right = `NN_DATA_WIDTH'd0;
                        food_left = x - food_x_closest;
                    end
                    if (food_y_closest > y) begin
                        food_up = `NN_DATA_WIDTH'd0;
                        food_down = food_y_closest - y;
                    end
                    else begin
                        food_down = `NN_DATA_WIDTH'd0;
                        food_up = y - food_y_closest;
                    end
                    if (poison_x_closest > x) begin
                        poison_left = `NN_DATA_WIDTH'd0;
                        poison_right = poison_x_closest - x;
                    end
                    else begin
                        poison_right = `NN_DATA_WIDTH'd0;
                        poison_left = x - poison_x_closest;
                    end
                    if (poison_y_closest > y) begin
                        poison_up = `NN_DATA_WIDTH'd0;
                        poison_down = poison_y_closest - y;
                    end
                    else begin
                        poison_down = `NN_DATA_WIDTH'd0;
                        poison_up = y - poison_y_closest;
                    end
                    // food_left = `NN_DATA_WIDTH'd3;
                    // food_right = `NN_DATA_WIDTH'd0;
                    // food_up = `NN_DATA_WIDTH'd4;
                    // food_down = `NN_DATA_WIDTH'd0;
                    
                    debug = {
                        food_up, food_down, food_left
                    };
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {id, `OPCODE_NNMEMREAD};
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_NN_LOAD_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_NN_LOAD_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                
                `ANTU_OP_NN_DELAY: begin
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                
                `ANTU_OP_NN_WAIT: begin
                    if (move_left && move_right) begin
                        
                    end
                    else if (move_left) begin
                        if (x > (`ANT_WIDTH / 2)) begin
                            x = x - `X_COORD_WIDTH'd1;
                        end
                        else begin
                            x = `SCREEN_WIDTH - (`ANT_WIDTH / 2) - 1;
                        end
                    end
                    else if (move_right) begin
                        if (x < (`SCREEN_WIDTH - (`ANT_WIDTH / 2) - 1)) begin
                            x = x + `X_COORD_WIDTH'd1;
                        end
                        else begin
                            x = `ANT_WIDTH / 2;
                        end
                    end
                    
                    if (move_up && move_down) begin
                        
                    end
                    if (move_up) begin
                        if (y > (`ANT_HEIGHT / 2)) begin
                            y = y - `Y_COORD_HEIGHT'd1;
                        end
                        else begin
                            y = `SCREEN_HEIGHT - (`ANT_HEIGHT / 2) - 1;
                        end
                    end
                    else if (move_down) begin
                        if (y < (`SCREEN_HEIGHT - (`ANT_HEIGHT / 2) - 1)) begin
                            y = y + `Y_COORD_HEIGHT'd1;
                        end
                        else begin
                            y = `ANT_HEIGHT / 2;
                        end
                    end
                    
                    // if (move_up && y > (`ANT_HEIGHT / 2)) begin
                        // y = y - `Y_COORD_WIDTH'd1;
                    // end
                    // else if (move_down && y < (`SCREEN_HEIGHT - (`ANT_HEIGHT / 2) - 1)) begin
                        // y = y + `Y_COORD_WIDTH'd1;
                    // end
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                
                `ANTU_OP_SET_X_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {x, `ADDR_ANT_X(id), `OPCODE_MEMWRITE};
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_X_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_X_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                
                `ANTU_OP_SET_Y_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {y, `ADDR_ANT_Y(id), `OPCODE_MEMWRITE};
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_Y_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_Y_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                `ANTU_OP_SET_FITNESS_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {fitness, `ADDR_ANT_FITNESS(id), `OPCODE_MEMWRITE};
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_FITNESS_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_FITNESS_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = `ANTU_OP_STANDBY;
                    end
                end
                
            endcase
        end
    end

endmodule
