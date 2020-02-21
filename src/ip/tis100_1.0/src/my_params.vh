localparam OP_NOP = 4'd0;
localparam OP_MOV = 4'd1;
localparam OP_SWP = 4'd2;
localparam OP_SAV = 4'd3;
localparam OP_ADD = 4'd4;
localparam OP_SUB = 4'd5;
localparam OP_NEG = 4'd6;
localparam OP_JMP = 4'd7;
localparam OP_JEZ = 4'd8;
localparam OP_JNZ = 4'd9;
localparam OP_JGZ = 4'd10;
localparam OP_JLZ = 4'd11;
localparam OP_JRO = 4'd12;

localparam TARGET_NIL = 3'd0;
localparam TARGET_ACC = 3'd1;
localparam TARGET_UP = 3'd2;
localparam TARGET_DOWN = 3'd3;
localparam TARGET_LEFT = 3'd4;
localparam TARGET_RIGHT = 3'd5;
localparam TARGET_ANY = 3'd6;
localparam TARGET_LAST = 3'd7;

localparam IN_MUX_SEL_CONST = 2'd0;
localparam IN_MUX_SEL_ACC = 2'd1;
localparam IN_MUX_SEL_DIR = 2'd2;

localparam OUT_MUX_SEL_IN = 1'd0;
localparam OUT_MUX_SEL_ALU = 1'd1;

localparam INSTR_ALU_ADD = 2'b00;
localparam INSTR_ALU_SUB = 2'b01;
localparam INSTR_ALU_NEG = 2'b10;

localparam INSTR_REG_READ = 2'b00;
localparam INSTR_REG_WRITE = 2'b01;
localparam INSTR_REG_SWP = 2'b10;
localparam INSTR_REG_SAV = 2'b11;
