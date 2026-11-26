package types_pkg;

  // 38 -> 64 (26 more needed)
  typedef struct packed {
    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] shamt;
    logic [6:0] funct7;
    logic [31:0] imm16; // 16 bits sign extended to 32
  } instruction_fields_t;

endpackage
