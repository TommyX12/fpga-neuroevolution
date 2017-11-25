
`define S_WIDTH 3
`define X_COORD_WIDTH 8
`define Y_COORD_WIDTH 7
`define COLOUR_WIDTH   3
`define DELAY_WIDTH   32

`define INSTRUCTION_WIDTH   32
`define RESULT_WIDTH   32

`define SCREEN_WIDTH  `X_COORD_WIDTH'd160
`define SCREEN_HEIGHT `Y_COORD_WIDTH'd120

`define BLOCK_WIDTH  `X_COORD_WIDTH'd1
`define BLOCK_HEIGHT `Y_COORD_WIDTH'd1

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


`defined NUM_ANT    20
`defined NUM_FOOD   15
`defined NUM_POISON 15

`define ADDR_ANT_X(ID)            0
`define ADDR_ANT_Y(ID)            0
`define ADDR_ANT_FOOD_EATEN(ID)   0
`define ADDR_ANT_POISON_EATEN(ID) 0
`define ADDR_ANT_FITNESS(ID)      0
`define ADDR_FOOD_X(ID)           0
`define ADDR_FOOD_Y(ID)           0
`define ADDR_POISON_X(ID)         0
`define ADDR_POISON_Y(ID)         0
