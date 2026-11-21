module instruction_decoder_tb;
  import types_pkg::*;

  logic [31:0] data;
  instruction_fields_t instruction_fields;

  instruction_decoder u_instruction_decoder (
    .data              (data),
    .instruction_fields(instruction_fields)
  );

  initial begin
    data = 0;

    // Using: https://binarycon.com/tools/risc-v-instruction-encoder-decoder/
    // To generate tests

    // addi x1, x0, 5
    check_i_type(/*instr=*/32'h00500093, /*op=*/7'b0010011, /*rd=*/1, /*funct3=*/3'b000, /*rs1=*/0, /*rs2=*/5, /*shmat=*/5, /*funct7=*/7'b0000000, /*imm=*/5);

    // addi x1, x0, -1
    check_i_type(/*instr=*/32'hFFF00093, /*op=*/7'b0010011, /*rd=*/1, /*funct3=*/3'b000, /*rs1=*/0, /*rs2=*/-1, /*shmat=*/-1, /*funct7=*/0, /*imm=*/32'hFFFFFFFF);

    // addi x5, x6, 7
    // Technically, RS2 should be 0, but it's changing due to imm,
    // which is expected behaviour.
    check_i_type(/*instr=*/32'h00730293, /*op=*/7'b0010011, /*rd=*/5'b00101, /*funct3=*/3'b000, /*rs1=*/5'b00110, /*rs2=*/5'b00111, /*shmat=*/5'b00111, /*funct7=*/0, /*imm=*/7);

    // add x3, x1, x2
    check_i_type(/*instr=*/32'h002081b3, /*op=*/7'b0110011, /*rd=*/3, /*funct3=*/3'b000, /*rs1=*/1, /*rs2=*/2, /*shmat=*/0, /*funct7=*/7'b0000000, /*imm=*/0);

    // sub x4, x2, x1
    check_i_type(/*instr=*/32'h40110233, /*op=*/7'b0110011, /*rd=*/4, /*funct3=*/3'b000, /*rs1=*/2, /*rs2=*/1, /*shmat=*/0, /*funct7=*/7'b0100000, /*imm=*/0);

    // jal x0, 0
    check_i_type(/*instr=*/32'h0000006F, /*op=*/7'b1101111, /*rd=*/0, /*funct3=*/3'b000, /*rs1=*/0, /*rs2=*/0, /*shmat=*/0, /*funct7=*/7'b0000000, /*imm=*/0);

    // jal x1, 8
    check_i_type(/*instr=*/32'h008000EF, /*op=*/7'b1101111, /*rd=*/1, /*funct3=*/3'b000, /*rs1=*/0, /*rs2=*/4'b1000, /*shmat=*/0, /*funct7=*/7'b0000000, /*imm=*/4'b1000);

    // jal 0x, 0
    check_i_type(/*instr=*/32'h0000006F, /*op=*/7'b1101111, /*rd=*/0, /*funct3=*/3'b000, /*rs1=*/0, /*rs2=*/4'b0000, /*shmat=*/0, /*funct7=*/7'b0000000, /*imm=*/4'b0000);

    $finish;
  end

  task automatic check_i_type(
      input logic [31:0] instr,
      input logic [6:0]  expected_op,
      input logic [4:0]  expected_rd,
      input logic [2:0]  expected_funct3,
      input logic [4:0]  expected_rs1,
      input logic [4:0]  expected_rs2,
      input logic [4:0]  expected_shmat,
      input logic [6:0]  expected_funct7,
      input logic [31:0] expected_imm
  );

    data = instr;

    #1ns;

    $display("opcode: 0b%0b", instruction_fields.opcode);

    assert (instruction_fields.opcode == expected_op)
        else $fatal(1, "Incorrect opcode: 0b%0b expected: 0b%0b", instruction_fields.opcode, expected_op);

    assert (instruction_fields.rd == expected_rd)
        else $fatal(1, "Incorrect rd: 0b%0b expected: 0b%0b", instruction_fields.rd, expected_rd);

    assert (instruction_fields.funct3 == expected_funct3)
        else $fatal(1, "Incorrect func3: 0b%0b expected: 0b%0b", instruction_fields.funct3, expected_funct3);

    assert (instruction_fields.rs1 == expected_rs1)
        else $fatal(1, "Incorrect rs1: 0b%0b expected: 0b%0b", instruction_fields.rs1, expected_rs1);

    assert (instruction_fields.rs2 == expected_rs2)
        else $fatal(1, "Incorrect rs2: 0b%0b expected: 0b%0b", instruction_fields.rs2, expected_rs2);

    assert (instruction_fields.shamt == expected_shmat)
        else $fatal(1, "Incorrect shmat: 0b%0b expected: 0b%0b", instruction_fields.shamt, expected_shmat);

    assert (instruction_fields.funct7 == expected_funct7)
        else $fatal(1, "Incorrect funct7: 0b%0b expected: 0b%0b", instruction_fields.funct7, expected_funct7);

    assert (instruction_fields.imm16 == expected_imm)
        else $fatal(1, "Incorrect immediate: 0b%0b expected: 0b%0b", instruction_fields.imm16, expected_imm);

    $display("PASS: 0x%08h", instr);

  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule : instruction_decoder_tb
