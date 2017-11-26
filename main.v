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
`define MAIN_OP_ANT_UPDATE_START      `MAIN_OP_WIDTH'd4
`define MAIN_OP_ANT_UPDATE_DELAY      `MAIN_OP_WIDTH'd5
`define MAIN_OP_ANT_UPDATE_WAIT       `MAIN_OP_WIDTH'd6
`define MAIN_OP_DRAW_BACKGROUND_START `MAIN_OP_WIDTH'd7
`define MAIN_OP_DRAW_BACKGROUND_DELAY `MAIN_OP_WIDTH'd8
`define MAIN_OP_DRAW_BACKGROUND_WAIT  `MAIN_OP_WIDTH'd9
`define MAIN_OP_ANT_DRAW_START        `MAIN_OP_WIDTH'd10
`define MAIN_OP_ANT_DRAW_DELAY        `MAIN_OP_WIDTH'd11
`define MAIN_OP_ANT_DRAW_WAIT         `MAIN_OP_WIDTH'd12
`define MAIN_OP_FOOD_DRAW_START       `MAIN_OP_WIDTH'd13
`define MAIN_OP_FOOD_DRAW_DELAY       `MAIN_OP_WIDTH'd14
`define MAIN_OP_FOOD_DRAW_WAIT        `MAIN_OP_WIDTH'd15
`define MAIN_OP_POISON_DRAW_START     `MAIN_OP_WIDTH'd16
`define MAIN_OP_POISON_DRAW_DELAY     `MAIN_OP_WIDTH'd17
`define MAIN_OP_POISON_DRAW_WAIT      `MAIN_OP_WIDTH'd18
`define MAIN_OP_FBDISP_START          `MAIN_OP_WIDTH'd19
`define MAIN_OP_FBDISP_DELAY          `MAIN_OP_WIDTH'd20
`define MAIN_OP_FBDISP_WAIT           `MAIN_OP_WIDTH'd21
`define MAIN_OP_FPS_LIMITER_WAIT      `MAIN_OP_WIDTH'd22


module main(
        CLOCK_50,						//	On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
        LEDR,
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
    
    assign LEDR = ~{(5){1'd0}};
    
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
    
    // TODO declare start and finished signal for each subroutine.
    reg ant_update_start;
    wire ant_update_finished;
    
    reg draw_background_start;
    wire draw_background_finished;
    
    reg ant_draw_start;
    wire ant_draw_finished;
    
    reg food_draw_start;
    wire food_draw_finished;
    
    reg poison_draw_start;
    wire [`NUM_POISON-1:0] poison_draw_finished;
    
    reg fb_display_start;
    wire fb_display_finished;
    
    reg fps_limiter_start;
    wire fps_limiter_finished;
    
    
    wire finished_dp;
    wire [`RESULT_WIDTH-1:0] result_dp;
    wire start_dp;
    wire [`INSTRUCTION_WIDTH-1:0] instruction_dp;
    
    wire [`INSTRUCTION_WIDTH*ports-1:0] instruction;
    wire [ports-1:0] start;
    wire [`RESULT_WIDTH*ports-1:0] result;
    wire [ports-1:0] finished;
    
    wire [15:0] rand;
    
    // TODO update this with the number of subroutines
    localparam ports = 2 * `NUM_ANT + `NUM_FOOD + `NUM_POISON + 2;
    
    Random16 random16(
        .clock(clock),
        .resetn(resetn),
        .data(rand),
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
        defparam
            datapath_router.ports = ports;
    
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
        
        .id(`MEM_ADDR_WIDTH'd0),
        
        `PORT_CONNECT(0)
    );
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    AntDraw ant_draw(
        .clock(clock),
        .resetn(resetn),
        .start(ant_draw_start),
        .finished(ant_draw_finished),
        
        .id(`MEM_ADDR_WIDTH'd0),
        
        `PORT_CONNECT(1)
    );
    
    FoodDraw food_draw(
        .clock(clock),
        .resetn(resetn),
        .start(food_draw_start),
        .finished(food_draw_finished),
        
        .id(`MEM_ADDR_WIDTH'd0),
        
        `PORT_CONNECT(2)
    );
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    // genvar poison_i;
    // generate
        // for (poison_i = 0; poison_i < `NUM_POISON; poison_i = poison_i + 1) begin : generate_poison
        
            // reg [`MEM_ADDR_WIDTH - 1:0] id_reg;
            // initial 
                // id_reg = poison_i;
        
            // PoisonDraw poison_draw(
                // .clock(clock),
                // .resetn(resetn),
                // .start(poison_draw_start),
                // .finished(poison_draw_finished[poison_i]),
                
                // .id(id_reg),
                
                // `PORT_CONNECT(2 * `NUM_ANT + `NUM_FOOD + poison_i)
            // );
        // end
    // endgenerate
    PoisonDraw poison_draw(
        .clock(clock),
        .resetn(resetn),
        .start(poison_draw_start),
        .finished(poison_draw_finished),
        
        .id(`MEM_ADDR_WIDTH'd0),
        
        `PORT_CONNECT(3)
    );
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    DrawBackground draw_background(
        .start(draw_background_start),
        .clock(clock),
        .resetn(resetn),
        .finished(draw_background_finished),
        
        `PORT_CONNECT(2 * `NUM_ANT + `NUM_FOOD + `NUM_POISON + 0)
    );
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    FBDisplay fb_display(
        .start(fb_display_start),
        .clock(clock),
        .resetn(resetn),
        .finished(fb_display_finished),

        `PORT_CONNECT(2 * `NUM_ANT + `NUM_FOOD + `NUM_POISON + 1)
    );
    
    // TODO make sure the start and finish signal identifier match the current module, and make sure datapath access signal are in the correct stream.
    FPSLimiter fps_limiter(
        .start(fps_limiter_start),
        .clock(clock),
        .resetn(resetn),
        
        .delay(`DELAY_WIDTH'd833333),
        // .delay(`DELAY_WIDTH'd50000000),
        
        .finished(fps_limiter_finished)
    );
    
    Datapath datapath(
        .start(start_dp),
        .clock(clock),
        .resetn(resetn),
        .instruction(instruction_dp),
        .result(result_dp),
        
        .x(x),
        .y(y),
        .colour(colour),
        .plot(writeEn),
        .finished(finished_dp),
    );
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `MAIN_OP_STANDBY;
            
            // TODO reset any register, namely, the start signal of subroutines
            
            ant_update_start <= 0;
            draw_background_start <= 0;
            ant_draw_start <= 0;
            food_draw_start <= 0;
            poison_draw_start <= 0;
            fb_display_start <= 0;
            fps_limiter_start <= 0;
        end
        else begin
            // TODO make sure this matches the order of state code, and make sure no typo.
            case (cur_state)
                `MAIN_OP_STANDBY: begin
                    cur_state = cur_state + `MAIN_OP_WIDTH'd1;
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
                        cur_state = cur_state + `MAIN_OP_WIDTH'd1;
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
                        cur_state = cur_state + `MAIN_OP_WIDTH'd1;
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
                        cur_state = cur_state + `MAIN_OP_WIDTH'd1;
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
                    
                    if (&poison_draw_finished) begin
                        cur_state = cur_state + `MAIN_OP_WIDTH'd1;
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

endmodule
