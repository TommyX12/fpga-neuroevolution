// Part 2 skeleton



// !!!! TODO many times typo are the bug, especially when things don't match up (such as copy pasting but not replacing correctly). maybe use a preprocessor or use more parameterization.


`include "constants.h"

// TODO change prefix to be for this file specifically
// TODO for cur_state += 1 to work, this must also reflect the real execution order
`define MAIN_OP_WIDTH 6 // TODO this must be large enough
`define MAIN_OP_STANDBY               `MAIN_OP_WIDTH'd0
`define MAIN_OP_FPS_LIMITER_START     `MAIN_OP_WIDTH'd1
`define MAIN_OP_FPS_LIMITER_DELAY     `MAIN_OP_WIDTH'd2
`define MAIN_OP_FPS_LIMITER_DELAY2    `MAIN_OP_WIDTH'd3
`define MAIN_OP_EVOLVE_START          `MAIN_OP_WIDTH'd4
`define MAIN_OP_EVOLVE_DELAY          `MAIN_OP_WIDTH'd5
`define MAIN_OP_EVOLVE_WAIT           `MAIN_OP_WIDTH'd6
`define MAIN_OP_ANT_UPDATE_START      `MAIN_OP_WIDTH'd7
`define MAIN_OP_ANT_UPDATE_DELAY      `MAIN_OP_WIDTH'd8
`define MAIN_OP_ANT_UPDATE_WAIT       `MAIN_OP_WIDTH'd9
`define MAIN_OP_DRAW_BACKGROUND_START `MAIN_OP_WIDTH'd10
`define MAIN_OP_DRAW_BACKGROUND_DELAY `MAIN_OP_WIDTH'd11
`define MAIN_OP_DRAW_BACKGROUND_WAIT  `MAIN_OP_WIDTH'd12
`define MAIN_OP_ANT_DRAW_START        `MAIN_OP_WIDTH'd13
`define MAIN_OP_ANT_DRAW_DELAY        `MAIN_OP_WIDTH'd14
`define MAIN_OP_ANT_DRAW_WAIT         `MAIN_OP_WIDTH'd15
`define MAIN_OP_FOOD_DRAW_START       `MAIN_OP_WIDTH'd16
`define MAIN_OP_FOOD_DRAW_DELAY       `MAIN_OP_WIDTH'd17
`define MAIN_OP_FOOD_DRAW_WAIT        `MAIN_OP_WIDTH'd18
`define MAIN_OP_POISON_DRAW_START     `MAIN_OP_WIDTH'd19
`define MAIN_OP_POISON_DRAW_DELAY     `MAIN_OP_WIDTH'd20
`define MAIN_OP_POISON_DRAW_WAIT      `MAIN_OP_WIDTH'd21
`define MAIN_OP_FBDISP_START          `MAIN_OP_WIDTH'd22
`define MAIN_OP_FBDISP_DELAY          `MAIN_OP_WIDTH'd23
`define MAIN_OP_FBDISP_WAIT           `MAIN_OP_WIDTH'd24
`define MAIN_OP_FPS_LIMITER_WAIT      `MAIN_OP_WIDTH'd25


module main(
        CLOCK_50,						//	On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
        LEDR,
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,   						//	VGA Clock
        VGA_HS,							//	VGA H_SYNC
        VGA_VS,							//	VGA V_SYNC
        VGA_BLANK_N,						//	VGA BLANK
        VGA_SYNC_N,						//	VGA SYNC
        VGA_R,   						//	VGA Red[9:0]
        VGA_G,	 						//	VGA Green[9:0]
        VGA_B   						//	VGA Blue[9:0]
    );

    input			CLOCK_50;				//	50 MHz
    input   [9:0]   SW;
    output   [9:0]   LEDR;
    input   [3:0]   KEY;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // Declare your inputs and outputs here
    // Do not change the following outputs
    output			VGA_CLK;   				//	VGA Clock
    output			VGA_HS;					//	VGA H_SYNC
    output			VGA_VS;					//	VGA V_SYNC
    output			VGA_BLANK_N;				//	VGA BLANK
    output			VGA_SYNC_N;				//	VGA SYNC
    output	[9:0]	VGA_R;   				//	VGA Red[9:0]
    output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
    output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
    
    wire resetn;
    assign resetn = KEY[0];
    
    // assign LEDR = ~{(5){1'd0}};
    
    // Create the colour, x, y and writeEn wires that are inputs to the controller.
    wire [`COLOUR_WIDTH:0] colour;
    wire [`X_COORD_WIDTH:0] x;
    wire [`Y_COORD_WIDTH:0] y;
    wire writeEn;

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            // Signals for the DAC to drive the monitor.
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "black.mif";
            
    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
    
    wire clock;
    assign clock = CLOCK_50;
    
    reg [`MAIN_OP_WIDTH-1:0] next_state;
    reg [`MAIN_OP_WIDTH-1:0] cur_state;
    
    // TODO initialize other registers
    reg [`MEM_ADDR_WIDTH-1:0] cur_id;
    reg [23:0] debug;
    wire [23:0] debug_wire;
    wire [9:0] led_wire;
    
    assign LEDR[0] = led_wire > 0 ? 1 : 0;
    assign LEDR[1] = led_wire > 5 ? 1 : 0;
    assign LEDR[2] = led_wire > 10 ? 1 : 0;
    assign LEDR[3] = led_wire > 15 ? 1 : 0;
    assign LEDR[4] = led_wire > 20 ? 1 : 0;
    assign LEDR[5] = led_wire > 25 ? 1 : 0;
    assign LEDR[6] = led_wire > 30 ? 1 : 0;
    assign LEDR[7] = led_wire > 35 ? 1 : 0;
    assign LEDR[8] = led_wire > 40 ? 1 : 0;
    assign LEDR[9] = led_wire > 45 ? 1 : 0;
    
    // TODO declare start and finished signal for each subroutine.
    reg evolve_start;
    wire evolve_finished;
    
    reg ant_update_start;
    wire ant_update_finished;
    
    reg draw_background_start;
    wire draw_background_finished;
    
    reg ant_draw_start;
    wire ant_draw_finished;
    
    reg food_draw_start;
    wire food_draw_finished;
    
    reg poison_draw_start;
    wire poison_draw_finished;
    
    reg fb_display_start;
    wire fb_display_finished;
    
    reg fps_limiter_start;
    wire fps_limiter_finished;
    
    
    wire [`MEM_ADDR_WIDTH-1:0] num_food;
    assign num_food[4:0] = SW[9:5];
    
    
    wire finished_dp;
    wire [`RESULT_WIDTH-1:0] result_dp;
    wire start_dp;
    wire [`INSTRUCTION_WIDTH-1:0] instruction_dp;
    
    wire [`NNMEM_DATA_WIDTH-1 : 0] nnmem_data;
    wire [`NNMEM_DATA_WIDTH-1 : 0] nnmem_output;
    
    wire [`INSTRUCTION_WIDTH*ports-1:0] instruction;
    wire [ports-1:0] start;
    wire [`RESULT_WIDTH*ports-1:0] result;
    wire [ports-1:0] finished;
    
    wire [`RAND_WIDTH-1:0] rand;
    
    // TODO update this with the number of subroutines
    localparam ports = `NUM_ANT_CORES + 6;
    
    Random16 random16(
        .clock(clock),
        .resetn(resetn),
        .out(rand)
    );
    
    DatapathRouter datapath_router(
        
        .clock(clock),
        .resetn(resetn),
        
        .instruction(instruction),
        .start(start),
        .result(result),
        .finished(finished),
        
        .instruction_dp(instruction_dp),
        .start_dp(start_dp),
        .result_dp(result_dp),
        .finished_dp(finished_dp)
        
    );
    defparam datapath_router.ports = ports;
    
`define PORT_CONNECT(index) \
    .finished_dp(finished[index]), \
    .result_dp(result[`RESULT_WIDTH*((index) + 1)-1:`RESULT_WIDTH*(index)]), \
    .start_dp(start[index]), \
    .instruction_dp(instruction[`INSTRUCTION_WIDTH*((index) + 1)-1:`INSTRUCTION_WIDTH*(index)])
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    AntUpdate ant_update(
        .clock(clock),
        .resetn(resetn),
        .start(ant_update_start),
        .finished(ant_update_finished),
        
        .num_food(num_food),
        .id(cur_id),
        .rand(rand),
        
        .neural_net_weights(nnmem_output),
        
        // .debug(debug_wire),
        
        `PORT_CONNECT(0)
    );
    // genvar ant_i;
    // generate
        // for (ant_i = 0; ant_i < `NUM_ANT; ant_i = ant_i + 1) begin : gen_ant
            // AntUpdate ant_update(
                // .clock(clock),
                // .resetn(resetn),
                // .start(ant_update_start),
                // .finished(ant_update_finished[ant_i]),
                
                // .id(ant_i),
                // .rand(rand),
                
                // .neural_net_weights(neural_net_weights[
                    // (ant_i + 1) * (`NN_DATA_WIDTH * (`NN_WEIGHTS_SIZE)) - 1
                    // :
                    // (ant_i) * (`NN_DATA_WIDTH * (`NN_WEIGHTS_SIZE))
                // ]),
                
                // `PORT_CONNECT(ant_i)
            // );
        // end
    // endgenerate
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    AntDraw ant_draw(
        .clock(clock),
        .resetn(resetn),
        .start(ant_draw_start),
        .finished(ant_draw_finished),
        
        .id(cur_id),
        
        `PORT_CONNECT(`NUM_ANT_CORES + 0)
    );
    
    FoodDraw food_draw(
        .clock(clock),
        .resetn(resetn),
        .start(food_draw_start),
        .finished(food_draw_finished),
        
        .id(cur_id),
        
        `PORT_CONNECT(`NUM_ANT_CORES + 1)
    );
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    PoisonDraw poison_draw(
        .clock(clock),
        .resetn(resetn),
        .start(poison_draw_start),
        .finished(poison_draw_finished),
        
        .id(cur_id),
        .rand(rand),
        
        `PORT_CONNECT(`NUM_ANT_CORES + 2)
    );
    // genvar poison_i;
    // generate
        // for (poison_i = 0; poison_i < `NUM_POISON; poison_i = poison_i + 1) begin : generate_poison
        
            // // reg [`MEM_ADDR_WIDTH - 1:0] id_reg;
            // // initial 
                // // id_reg = poison_i;
        
            // PoisonDraw poison_draw(
                // .clock(clock),
                // .resetn(resetn),
                // .start(poison_draw_start),
                // .finished(poison_draw_finished[poison_i]),
                
                // .id(poison_i),
                // .rand(rand),
                
                // `PORT_CONNECT(2 * `NUM_ANT + `NUM_FOOD + poison_i)
            // );
        // end
    // endgenerate
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    DrawBackground draw_background(
        .start(draw_background_start),
        .clock(clock),
        .resetn(resetn),
        .finished(draw_background_finished),
        
        .debug(SW[9:4]),
        .neural_net_weights(nnmem_output),

        `PORT_CONNECT(`NUM_ANT_CORES + 3)
    );
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    FBDisplay fb_display(
        .start(fb_display_start),
        .clock(clock),
        .resetn(resetn),
        .finished(fb_display_finished),
        
        `PORT_CONNECT(`NUM_ANT_CORES + 4)
    );
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    Evolve evolve(
        .clock(clock),
        .resetn(resetn),
        .start(evolve_start),
        .finished(evolve_finished),
        
        .rand(rand),
        
        .neural_net_weights_in(nnmem_output),
        .neural_net_weights_out(nnmem_data),
        
        .gen_duration(`DELAY_GEN),
        
        .current_gen(debug_wire),
        .fitness_max_out(led_wire),
        
        `PORT_CONNECT(`NUM_ANT_CORES + 5)
    );

    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    FPSLimiter fps_limiter(
        .start(fps_limiter_start),
        .clock(clock),
        .resetn(resetn),
        
        .delay(SW[0] ? `DELAY_ACCEL : `DELAY_60FPS),
        // .delay(`DELAY_WIDTH'd50000000),
        
        .finished(fps_limiter_finished)
    );
    
    Datapath datapath(
        .start(start_dp),
        .clock(clock),
        .resetn(resetn),
        .instruction(instruction_dp),
        .result(result_dp),
        
        .nnmem_data(nnmem_data),
        .nnmem_output(nnmem_output),
        
        .x(x),
        .y(y),
        .colour(colour),
        .plot(writeEn),
        .finished(finished_dp)
    );
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `MAIN_OP_STANDBY;
            
            // TODO reset any register, namely, the start signal of subroutines
            debug <= 0;
            
            evolve_start <= 0;
            ant_update_start <= 0;
            draw_background_start <= 0;
            ant_draw_start <= 0;
            food_draw_start <= 0;
            poison_draw_start <= 0;
            fb_display_start <= 0;
            fps_limiter_start <= 0;
            
            cur_id <= 0;
        end
        else begin
            // TODO make sure this matches the order of state code, and make sure no typo.
            case (cur_state)
                `MAIN_OP_STANDBY: begin
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                    
                    debug = debug_wire;
                    
                    cur_id = 0;
                end
                
                // TODO make sure there is no typo and everything matches the subroutine name.
                `MAIN_OP_FPS_LIMITER_START: begin
                    fps_limiter_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_FPS_LIMITER_DELAY: begin
                    fps_limiter_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_FPS_LIMITER_DELAY2: begin
                    fps_limiter_start = 0;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                
                // TODO make sure there is no typo and everything matches the subroutine name.
                `MAIN_OP_EVOLVE_START: begin
                    evolve_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_EVOLVE_DELAY: begin
                    evolve_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_EVOLVE_WAIT: begin
                    evolve_start = 0;
                    
                    if (evolve_finished) begin
                        cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                    end
                end
                
                // TODO make sure there is no typo and everything matches the subroutine name.
                `MAIN_OP_ANT_UPDATE_START: begin
                    ant_update_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_ANT_UPDATE_DELAY: begin
                    ant_update_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_ANT_UPDATE_WAIT: begin
                    ant_update_start = 0;
                    
                    if (ant_update_finished) begin
                        if (cur_id == `NUM_ANT - `MEM_ADDR_WIDTH'd1) begin
                            cur_id = 0;
                            if (SW[0]) begin
                                cur_state = `MAIN_OP_STANDBY;
                            end
                            else begin
                                cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                            end
                        end
                        else begin
                            cur_id = cur_id + `MEM_ADDR_WIDTH'd1;
                            cur_state = `MAIN_OP_ANT_UPDATE_START;
                        end
                    end
                end
                
                // TODO make sure there is no typo and everything matches the subroutine name.
                `MAIN_OP_DRAW_BACKGROUND_START: begin
                    draw_background_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_DRAW_BACKGROUND_DELAY: begin
                    draw_background_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_DRAW_BACKGROUND_WAIT: begin
                    draw_background_start = 0;
                    
                    if (draw_background_finished) begin
                        cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                    end
                end
                
                // TODO make sure there is no typo and everything matches the subroutine name.
                `MAIN_OP_ANT_DRAW_START: begin
                    ant_draw_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_ANT_DRAW_DELAY: begin
                    ant_draw_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_ANT_DRAW_WAIT: begin
                    ant_draw_start = 0;
                    
                    if (ant_draw_finished) begin
                        if (cur_id == `NUM_ANT - `MEM_ADDR_WIDTH'd1) begin
                            cur_id = 0;
                            cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                        end
                        else begin
                            cur_id = cur_id + `MEM_ADDR_WIDTH'd1;
                            cur_state = `MAIN_OP_ANT_DRAW_START;
                        end
                    end
                end
                
                // TODO make sure there is no typo and everything matches the subroutine name.
                `MAIN_OP_FOOD_DRAW_START: begin
                    food_draw_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_FOOD_DRAW_DELAY: begin
                    food_draw_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_FOOD_DRAW_WAIT: begin
                    food_draw_start = 0;
                    
                    if (food_draw_finished) begin
                        if (cur_id >= num_food - `MEM_ADDR_WIDTH'd1) begin
                            cur_id = 0;
                            cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                        end
                        else begin
                            cur_id = cur_id + `MEM_ADDR_WIDTH'd1;
                            cur_state = `MAIN_OP_FOOD_DRAW_START;
                        end
                    end
                end
                
                // TODO make sure there is no typo and everything matches the subroutine name.
                `MAIN_OP_POISON_DRAW_START: begin
                    poison_draw_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_POISON_DRAW_DELAY: begin
                    poison_draw_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_POISON_DRAW_WAIT: begin
                    poison_draw_start = 0;
                    
                    if (poison_draw_finished) begin
                        if (cur_id == `NUM_POISON - `MEM_ADDR_WIDTH'd1) begin
                            cur_id = 0;
                            cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                        end
                        else begin
                            cur_id = cur_id + `MEM_ADDR_WIDTH'd1;
                            cur_state = `MAIN_OP_POISON_DRAW_START;
                        end
                    end
                end
                
                // TODO make sure there is no typo and everything matches the subroutine name.
                `MAIN_OP_FBDISP_START: begin
                    fb_display_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_FBDISP_DELAY: begin
                    fb_display_start = 1;
                    
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                end
                `MAIN_OP_FBDISP_WAIT: begin
                    fb_display_start = 0;
                    
                    if (fb_display_finished) begin
                        cur_state = cur_state + `MAIN_OP_WIDTH'd1;
                    end
                end
                
                `MAIN_OP_FPS_LIMITER_WAIT: begin
                    if (fps_limiter_finished) begin
                        cur_state = `MAIN_OP_STANDBY;
                    end
                end
            endcase
        end
    end
    
    HexDecoder hex0(
        .hex_digit(debug[0 * 4 +: 4]),
        .segments(HEX0)
    );

    HexDecoder hex1(
        .hex_digit(debug[1 * 4 +: 4]),
        .segments(HEX1)
    );

    HexDecoder hex2(
        .hex_digit(debug[2 * 4 +: 4]),
        .segments(HEX2)
    );

    HexDecoder hex3(
        .hex_digit(debug[3 * 4 +: 4]),
        .segments(HEX3)
    );

    HexDecoder hex4(
        .hex_digit(debug[4 * 4 +: 4]),
        .segments(HEX4)
    );

    HexDecoder hex5(
        .hex_digit(debug[5 * 4 +: 4]),
        .segments(HEX5)
    );

endmodule

module HexDecoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*) begin
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
    end
endmodule
