import types_pkg::*;
import opcodes::*;

module instruction_decoder(
  input [31:0] data,

  output instruction_fields_t instruction_fields
);

  always_comb begin
    instruction_fields = '0;

    instruction_fields.opcode = data[6:0];
    instruction_fields.rd     = data[11:7];
    instruction_fields.funct3 = data[14:12];
    instruction_fields.rs1    = data[19:15];
    instruction_fields.rs2    = data[24:20];

    // R-Type
    if (instruction_fields.opcode == `OP_ALU_ARTH) begin
      instruction_fields.funct7 = data[31:25];
    end

    // I-Types
    else if (instruction_fields.opcode == `OP_ALU_IMM) begin
      // Sign extended to 16 from 12
      instruction_fields.shamt = data[24:20];
      instruction_fields.imm16 = $signed(data[31:20]);
    end

    // U-Type
    else if (instruction_fields.opcode == `OP_ALU_JAL) begin
      // A special case
      // imm[20|10:1|11|19:12]
      instruction_fields.imm16 = {
        {11{data[31]}},
        data[31],
        data[19:12],
        data[20],
        data[30:21],
        1'b0
      };
    end

    else begin
      $fatal(1, "Decoder unhandled opcode=0b%0b func3=0b%0b", instruction_fields.opcode, instruction_fields.funct3);
    end
  end

endmodule: instruction_decoder
