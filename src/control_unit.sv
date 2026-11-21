import types_pkg::*;
import opcodes::*;
import control_unit_write_source::*;
import alu_arithmetic_types::*;

module control_unit(
  input instruction_fields_t instruction_fields,

  input logic [31:0] gpr [31:0],
  input logic [31:0] pc,

  output logic [31:0] alu_data1, alu_data2,
  output  arithmetic_types arithmetic_type,

  output bit          reg_write,
  output logic [4:0]  reg_write_addr,
  output write_source reg_write_source,

  output bit is_branch,
  output logic [31:0] pc_data
);

  // A useful source:
  // https://projectf.io/posts/riscv-cheat-sheet/
  //

  always_comb begin
    reg_write        = 1'b0;
    reg_write_addr   = 4'b000;
    reg_write_source = ALU;

    alu_data1 = 32'b0;
    alu_data2 = 32'b0;

    is_branch = 1'b0;
    pc_data   = 32'b0;

    case (instruction_fields.opcode)
      `OP_ALU_IMM : begin
        case (instruction_fields.funct3)
          // ADDI - ADD Immediate
          3'b000 : begin
            // imm[11:0], rs1, 000, rd, 0b0010011, ADDI
            // rd = rs1 + imm

            reg_write      = 1'b1;
            reg_write_addr = instruction_fields.rd;

            arithmetic_type = ADD;
            reg_write_source = ALU;

            alu_data1 = gpr[instruction_fields.rs1];
            alu_data2 = instruction_fields.imm16;
          end

          // SLLI - Shift Left Logical Immediate
          3'b001 : begin
            // 0000000, shamt, rs1, 001, rd, 0b0010011, SLLI
            // rd = rs1 << shamt

            if (instruction_fields.funct7 != 7'b0000000)
              $fatal(1, "Unhandled SLLI instruction funct7: 0b%0b", instruction_fields.funct7);

            reg_write      = 1'b1;
            reg_write_addr = instruction_fields.rd;

            arithmetic_type = LOGICAL_LEFT;
            reg_write_source = ALU;

            alu_data1 = gpr[instruction_fields.rs1];
            alu_data2 = instruction_fields.shamt;
          end

          // SLTI - Set Less Than Immediate
          3'b010 : begin
            // imm[11:0], rs1, 010, rd, 0b0010011, SLTI
            // rd = (rs1 < imm)

            reg_write      = 1'b1;
            reg_write_addr = instruction_fields.rd;

            arithmetic_type = SIGNED_LESS_THAN;
            reg_write_source = ALU;

            alu_data1 = gpr[instruction_fields.rs1];
            alu_data2 = instruction_fields.imm16;
          end

          // SLTIU - Set Less Than Immediate Unsigned
          3'b011 : begin
            // imm[11:0], rs1, 011, rd, 0b0010011, SLTIU
            // rd = (rs1 < imm)

            reg_write      = 1'b1;
            reg_write_addr = instruction_fields.rd;

            arithmetic_type = LESS_THAN;
            reg_write_source = ALU;

            alu_data1 = gpr[instruction_fields.rs1];
            alu_data2 = instruction_fields.imm16;
          end

          // XORI - XOR Immediate
          3'b100 : begin
            // imm[11:0], rs1, 100, rd, 0b0010011, ADDI
            // rd = rs1 ^ imm

            reg_write      = 1'b1;
            reg_write_addr = instruction_fields.rd;

            arithmetic_type = XOR;
            reg_write_source = ALU;

            alu_data1 = gpr[instruction_fields.rs1];
            alu_data2 = instruction_fields.imm16;
          end

          3'b101 : begin
            // SRLI - Shift Right Logical Immediate
            if (instruction_fields.funct7 == 7'b0000000) begin
              // 0000000, shamt, rs1, 101, rd, 0b0010011, SRLI
              // rd = rs1 >> shamt

              reg_write      = 1'b1;
              reg_write_addr = instruction_fields.rd;

              arithmetic_type = LOGICAL_RIGHT;
              reg_write_source = ALU;

              alu_data1 = gpr[instruction_fields.rs1];
              alu_data2 = instruction_fields.shamt;
            end

            // SRAI - Shift Right Arithmetic Immediate
            else if (instruction_fields.funct7 == 7'b0100000) begin
              // 0100000, shamt, rs1, 101, rd, 0b0010011, SRAI
              // rd = rs1 >>> shamt

              reg_write      = 1'b1;
              reg_write_addr = instruction_fields.rd;

              arithmetic_type = ARITHMETIC_RIGHT;
              reg_write_source = ALU;

              alu_data1 = gpr[instruction_fields.rs1];
              alu_data2 = instruction_fields.shamt;
            end

            else
              $fatal(1, "Unhandled IMM shift instruction funct7: 0b%0b", instruction_fields.funct7);
          end

          // ORI - OR Immediate
          3'b110 : begin
            // imm[11:0], rs1, 110, rd, 0b0010011, ORI
            // rd = rs1 | imm

            reg_write      = 1'b1;
            reg_write_addr = instruction_fields.rd;

            arithmetic_type = OR;
            reg_write_source = ALU;

            alu_data1 = gpr[instruction_fields.rs1];
            alu_data2 = instruction_fields.imm16;
          end

          // ANDI - AND Immediate
          3'b111 : begin
            // imm[11:0], rs1, 111, rd, 0b0010011, ANDI
            // rd = rs1 & imm

            reg_write      = 1'b1;
            reg_write_addr = instruction_fields.rd;

            arithmetic_type = AND;
            reg_write_source = ALU;

            alu_data1 = gpr[instruction_fields.rs1];
            alu_data2 = instruction_fields.imm16;
          end

          default : $fatal(1, "Unhandled IMM instruction funct3: 0b%0b", instruction_fields.funct3);
        endcase
      end

      // AUIPIC - Add Upper Immediate to PC
      `OP_ALU_AUIPC : begin
        // imm[31:12], rd, 0b0010111, AUIPC
        // rd = pc + (imm << 12)

        is_branch = 1'b0;
        reg_write = 1'b1;
        reg_write_addr = instruction_fields.rd;

        arithmetic_type = ADD;
        reg_write_source = ALU;

        alu_data1 = pc;
        alu_data2 = instruction_fields.imm16;
      end

      `OP_ALU_ARTH : begin
        // ADD
        if(instruction_fields.funct3 == 3'b000 && instruction_fields.funct7 == 7'b0000000) begin
          // 0000000, rs2, rs1, 000, rd, 0b0110011, ADD
          // rd = rs1 + rs2

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = ADD;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        // SUB
        else if (instruction_fields.funct3 == 3'b000 && instruction_fields.funct7 == 7'b0100000) begin
          // 0100000, rs2, rs1, 000, rd, 0b0110011, SUB
          // rd = rs1 - rs2

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = SUB;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        // SLL - Shift Left Logical
        else if (instruction_fields.funct3 == 3'b001 && instruction_fields.funct7 == 7'b0000000) begin
          // 0000000 rs2 rs1 001 rd 0110011 SLL
          // rd = rs1 << rs2

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = LOGICAL_LEFT;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        // SLT - Set Less Than
        else if (instruction_fields.funct3 == 3'b010 && instruction_fields.funct7 == 7'b0000000) begin
          // 0000000 rs2 rs1 010 rd 0110011 SLT
          // rd = (rs1 < rs2)

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = LESS_THAN;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        // SLTU - Set Less Than Unsigned - Equivalent to SLT
        else if (instruction_fields.funct3 == 3'b011 && instruction_fields.funct7 == 7'b0000000) begin
          // 0000000 rs2 rs1 100 rd 0110011 SLTU
          // rd = (rs1 < rs2)

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = LESS_THAN;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        // XOR
        else if (instruction_fields.funct3 == 3'b100 && instruction_fields.funct7 == 7'b0000000) begin
          // 0000000 rs2 rs1 100 rd 0110011 XOR
          // rd = rs1 ^ rs2

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = XOR;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        // SRL - Shift Right Logical
        else if (instruction_fields.funct3 == 3'b101 && instruction_fields.funct7 == 7'b0000000) begin
          // 0000000 rs2 rs1 100 rd 0110011 XOR
          // rd = rs1 >> rs2

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = LOGICAL_RIGHT;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        // SRA - Shift Right Arithmetic
        else if (instruction_fields.funct3 == 3'b101 && instruction_fields.funct7 == 7'b0100000) begin
          // 0100000 rs2 rs1 101 rd 0110011 SRA
          // rd = rs1 >>> rs2

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = ARITHMETIC_RIGHT;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        // OR
        else if (instruction_fields.funct3 == 3'b110 && instruction_fields.funct7 == 7'b0000000) begin
          // 0000000 rs2 rs1 110 rd 0110011 OR
          // rd = rs1 | rs2

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = OR;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        // AND
        else if (instruction_fields.funct3 == 3'b111 && instruction_fields.funct7 == 7'b0000000) begin
          // 0000000 rs2 rs1 111 rd 0110011 AND
          // rd = rs1 & rs2

          reg_write      = 1'b1;
          reg_write_addr = instruction_fields.rd;

          arithmetic_type = AND;
          reg_write_source = ALU;

          alu_data1 = gpr[instruction_fields.rs1];
          alu_data2 = gpr[instruction_fields.rs2];
        end

        else
          $fatal(1, "Unhandled Arithmetic opcode: 0b%0b, 0b%0b", instruction_fields.funct3, instruction_fields.funct7);
      end

      `OP_ALU_BRANCH : begin
        case (instruction_fields.funct3)
          // BEQ - Branch if Equal
          3'b000 : begin
            // imm[12|10:5], rs2, rs1, 000, imm[4:1|11], 0b1100011, BEQ
            // if (rs1 == rs2) pc += imm

            reg_write = 1'b0;

            arithmetic_type = ADD;
            reg_write_source = ALU;

            //pc = pc + imm;
            is_branch = gpr[instruction_fields.rs1] == gpr[instruction_fields.rs2];
            pc_data = pc + instruction_fields.imm16;
          end

          // BNE - Branch if Not Equal
          3'b001 : begin
            // imm[12|10:5], rs2, rs1, 001, imm[4:1|11], 0b1100011, BNE
            // if (rs1 != rs2) pc += imm

            reg_write = 1'b0;

            arithmetic_type = ADD;
            reg_write_source = ALU;

            //pc = pc + imm;
            is_branch = gpr[instruction_fields.rs1] != gpr[instruction_fields.rs2];
            pc_data = pc + instruction_fields.imm16;
          end

          // BLT - Branch if Less Than
          3'b100 : begin
            // imm[12|10:5], rs2, rs1, 100, imm[4:1|11], 0b1100011, BLT
            // if (rs1 < rs2) pc += imm

            reg_write = 1'b0;

            arithmetic_type = ADD;
            reg_write_source = ALU;

            //pc = pc + imm;
            is_branch = $signed(gpr[instruction_fields.rs1]) < $signed(gpr[instruction_fields.rs2]);
            pc_data = pc + instruction_fields.imm16;
          end

          // BGE - Branch if Greater Than or Equal
          3'b101 : begin
            // imm[12|10:5], rs2, rs1, 101, imm[4:1|11], 0b1100011, BGE
            // if (rs1 >= rs2) pc += imm

            reg_write = 1'b0;

            arithmetic_type = ADD;
            reg_write_source = ALU;

            //pc = pc + imm;
            is_branch = $signed(gpr[instruction_fields.rs1]) >= $signed(gpr[instruction_fields.rs2]);
            pc_data = pc + instruction_fields.imm16;
          end

          // BLTU - Branch if Less Than Unsigned
          3'b110 : begin
            // imm[12|10:5], rs2, rs1, 110, imm[4:1|11], 0b1100011, BLTU
            // if (rs1 < rs2) pc += imm

            reg_write = 1'b0;

            arithmetic_type = ADD;
            reg_write_source = ALU;

            //pc = pc + imm;
            is_branch = gpr[instruction_fields.rs1] < gpr[instruction_fields.rs2];
            pc_data = pc + instruction_fields.imm16;
          end

          // BGEU - Branch if Greater Than or Equal Unsigned
          3'b111 : begin
            // imm[12|10:5], rs2, rs1, 111, imm[4:1|11], 0b1100011, BGEU
            // if (rs1 >= rs2) pc += imm

            reg_write = 1'b0;

            arithmetic_type = ADD;
            reg_write_source = ALU;

            //pc = pc + imm;
            is_branch = gpr[instruction_fields.rs1] >= gpr[instruction_fields.rs2];
            pc_data = pc + instruction_fields.imm16;
          end

          default : $fatal(1, "Unhandled branch instruction funct3: 0b%0b", instruction_fields.funct3);
        endcase
      end

      `OP_ALU_JALR : begin
        // imm[11:0], rs1, 000, rd, 0b1100111, JALR
        // rd = pc+4; pc = (rs1+imm) & ~1

        if (instruction_fields.funct3 != 3'b000)
          $fatal(1, "Unhandled JALR instruction funct3: 0b%0b", instruction_fields.funct3);

        reg_write      = 1'b1;
        reg_write_addr = instruction_fields.rd;

        arithmetic_type = ADD;
        reg_write_source = ALU;

        //rd = pc + 4;
        alu_data1 = pc;
        alu_data2 = 4;

        //pc = (rs1 + imm) & ~1;
        is_branch = 1'b1;
        pc_data = (gpr[instruction_fields.rs1] + instruction_fields.imm16) & 32'hfffffffe;
      end

      `OP_ALU_JAL : begin
        // imm[20|10:1|11|19:12] rd 0b1101111 JAL
        // rd = pc+4; pc += imm

        reg_write      = 1'b1;
        reg_write_addr = instruction_fields.rd;

        arithmetic_type = ADD;
        reg_write_source = ALU;

        //rd = pc + 4;
        alu_data1 = pc;
        alu_data2 = 4;

        //pc = pc + imm;
        is_branch = 1'b1;
        pc_data = pc + instruction_fields.imm16;
      end

      default : $fatal(1, "Unhandled opcode=0b%0b funct3=0b%0b funct7=0b%0b", instruction_fields.opcode, instruction_fields.funct3, instruction_fields.funct7);
    endcase
  end

endmodule: control_unit
