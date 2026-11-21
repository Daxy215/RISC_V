package opcodes;
  `define OP_ALU_IMM    7'b0010011 // AddI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
  `define OP_ALU_AUIPC  7'b0010111 // AUIPC
  `define OP_ALU_ARTH   7'b0110011 // SLLI, SRLI, SRAI, ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
  `define OP_ALU_BRANCH 7'b1100011 // BEQ, BNE, BLT, BGE, BLTU, BGEU
  `define OP_ALU_JALR   7'b1100111 // JALR
  `define OP_ALU_JAL    7'b1101111 // Jal

  // TODO;
  `define OP_ALU_AND    6'b011101 // Bitwise AND
  `define OP_ALU_OR     6'b011111 // Bitwise OR
  `define OP_ALU_XOR    6'b100001 // Bitwise XOR
  `define OP_ALU_SLT    6'b100011 // Set Less Than (signed)
  `define OP_ALU_SLTU   6'b100101 // Set Less Than (unsigned)
  `define OP_ALU_SLL    6'b100111 // Shift Left Logical
  `define OP_ALU_SRL    6'b101001 // Shift Right Logical
  `define OP_ALU_SRA    6'b101011 // Shift Right Arithmetic
endpackage
