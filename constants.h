
`define STD_WIDTH 32

`define S_WIDTH 3
`define X_COORD_WIDTH 8
`define Y_COORD_WIDTH 7
`define COLOUR_WIDTH   3
`define DELAY_WIDTH   32

`define DELAY_ACCEL   `DELAY_WIDTH'd1
`define DELAY_60FPS   `DELAY_WIDTH'd833333
`define DELAY_GEN     `DELAY_WIDTH'd1800 // this is the number of frames, not number of cycles

`define INSTRUCTION_WIDTH   32
`define RESULT_WIDTH   32

`define SCREEN_WIDTH  `X_COORD_WIDTH'd160
`define SCREEN_HEIGHT `Y_COORD_WIDTH'd120

`define ANT_WIDTH  `X_COORD_WIDTH'd3
`define ANT_HEIGHT `Y_COORD_WIDTH'd3

`define OPCODE_WIDTH 4
`define OPCODE_NULL     `OPCODE_WIDTH'd0
`define OPCODE_DRAW     `OPCODE_WIDTH'd1
`define OPCODE_MEMREAD  `OPCODE_WIDTH'd2
`define OPCODE_MEMWRITE `OPCODE_WIDTH'd3
`define OPCODE_DISPLAY  `OPCODE_WIDTH'd4

`define MEM_ADDR_WIDTH 16
`define MEM_DATA_WIDTH 12

`define FB_ADDR_WIDTH 15
`define FB_DATA_WIDTH `COLOUR_WIDTH

`define FITNESS_WIDTH 12

`define NN_GET_WEIGHTS_SIZE(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE) (`NN_GET_WEIGHTS_SIZE_1(`NN_INPUT_SIZE, `NN_HIDDEN_SIZE, `NN_OUTPUT_SIZE) + `NN_GET_WEIGHTS_SIZE_2(`NN_INPUT_SIZE, `NN_HIDDEN_SIZE, `NN_OUTPUT_SIZE))
`define NN_GET_WEIGHTS_SIZE_1(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE) ((INPUT_SIZE + 1) * HIDDEN_SIZE)
`define NN_GET_WEIGHTS_SIZE_2(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE) ((HIDDEN_SIZE + 1) * OUTPUT_SIZE)
`define NN_DATA_WIDTH 8
`define NN_INPUT_SIZE 8
`define NN_HIDDEN_SIZE 8
`define NN_OUTPUT_SIZE 4
`define NN_WEIGHTS_SIZE `NN_GET_WEIGHTS_SIZE(`NN_INPUT_SIZE, `NN_HIDDEN_SIZE, `NN_OUTPUT_SIZE)

`define COLOUR_BG     `COLOUR_WIDTH'b111
`define COLOUR_ANT    `COLOUR_WIDTH'b000
`define COLOUR_FOOD   `COLOUR_WIDTH'b010
`define COLOUR_POISON `COLOUR_WIDTH'b100

`define NUM_ANT_CORES `MEM_ADDR_WIDTH'd2
`define NUM_ANT       `MEM_ADDR_WIDTH'd15
`define NUM_FOOD      `MEM_ADDR_WIDTH'd15
`define NUM_POISON    `MEM_ADDR_WIDTH'd15

`define RAND_WIDTH 16

// TODO make sure the output with must be MEM_ADDR_WIDTH.
`define ADDR_FOOD_X(ID)           (ID)
`define ADDR_FOOD_Y(ID)           (ID + `NUM_FOOD)
`define ADDR_POISON_X(ID)         (ID + `MEM_ADDR_WIDTH'd2 * `NUM_FOOD)
`define ADDR_POISON_Y(ID)         (ID + `MEM_ADDR_WIDTH'd2 * `NUM_FOOD + `NUM_POISON)
`define ADDR_ANT_X(ID)            (ID + `MEM_ADDR_WIDTH'd2 * `NUM_FOOD + `MEM_ADDR_WIDTH'd2 * `NUM_POISON)
`define ADDR_ANT_Y(ID)            (ID + `MEM_ADDR_WIDTH'd2 * `NUM_FOOD + `MEM_ADDR_WIDTH'd2 * `NUM_POISON + `NUM_ANT)
`define ADDR_ANT_FITNESS(ID)      (ID + `MEM_ADDR_WIDTH'd2 * `NUM_FOOD + `MEM_ADDR_WIDTH'd2 * `NUM_POISON + `MEM_ADDR_WIDTH'd2 * `NUM_ANT)
