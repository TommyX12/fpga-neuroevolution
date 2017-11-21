// Part 2 skeleton



`include "constants.h"

`define MAIN_OP_WIDTH 5
`define MAIN_OP_DRAW_BACKGROUND_START `MAIN_OP_WIDTH'd0
`define MAIN_OP_DRAW_BACKGROUND_DELAY `MAIN_OP_WIDTH'd1
`define MAIN_OP_DRAW_BACKGROUND_WAIT `MAIN_OP_WIDTH'd2

module main(
        CLOCK_50,						//	On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
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
    
    reg draw_background_start;
    wire draw_background_finished;
    wire draw_background_drawing;
    
    wire clock;
    assign clock = CLOCK_50;
    
    DrawBackground draw_background(
       .start(draw_background_start),
       .clock(clock),
       .resetn(resetn),
       .drawing(draw_background_drawing),
       .x(x),
       .y(y),
       .colour(colour),
       .plot(writeEn),
       .finished(draw_background_finished)
    );
    
    reg [`MAIN_OP_WIDTH-1:0] next_state;
    reg [`MAIN_OP_WIDTH-1:0] cur_state;
    
    always @(*) begin
        case (cur_state)
            `MAIN_OP_DRAW_BACKGROUND_START: begin
                next_state <= `MAIN_OP_DRAW_BACKGROUND_DELAY;
            end
            `MAIN_OP_DRAW_BACKGROUND_DELAY: begin
                next_state <= `MAIN_OP_DRAW_BACKGROUND_WAIT;
            end
            `MAIN_OP_DRAW_BACKGROUND_WAIT: begin
                next_state <= draw_background_finished ? `MAIN_OP_DRAW_BACKGROUND_START : next_state;
            end
        endcase
    end
    
    always @(posedge clock) begin
        cur_state <= next_state;
    end
    
    always @(posedge clock) begin
        if (!resetn) begin
            draw_background_start = 0;
            next_state = `MAIN_OP_DRAW_BACKGROUND_START;
        end
        else begin
            case (cur_state)
                `MAIN_OP_DRAW_BACKGROUND_START: begin
                    draw_background_start <= 1;
                end
                `MAIN_OP_DRAW_BACKGROUND_DELAY: begin
                    draw_background_start <= 1;
                end
                `MAIN_OP_DRAW_BACKGROUND_WAIT: begin
                    draw_background_start <= 0;
                end
            endcase
        end
    end

endmodule
