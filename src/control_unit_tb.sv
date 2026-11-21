
module control_unit_tb;
  import types_pkg::*;
  import alu_arithmetic_types::*;
  import control_unit_write_source::*;

  instruction_fields_t instruction_fields;

  logic [31:0] pc = 0;
  logic [31:0] gpr [31:0] = '{default:0};

  logic        reg_write;
  logic [4:0]  reg_write_addr;
  logic [31:0] alu_data1, alu_data2;

  arithmetic_types arithmetic_type;
  logic [31:0] alu_result;

  write_source reg_write_source;
  write_source alu_source;

  logic mem_read, mem_write;
  logic [3:0] mem_byte_enable;

  bit is_branch;

  logic [31:0] pc_data;

  logic [31:0] instruction_data;

  instruction_decoder u_instruction_decoder (
    .data              (instruction_data),
    .instruction_fields(instruction_fields)
  );

  alu u_alu (
    .data1          (alu_data1),
    .data2          (alu_data2),
    .arithmetic_type(arithmetic_type),
    .result         (alu_result)
  );

  control_unit u_control_unit (
    .instruction_fields(instruction_fields),
    .gpr               (gpr),
    .pc                (pc),
    .alu_data1         (alu_data1),
    .alu_data2         (alu_data2),
    .arithmetic_type   (arithmetic_type),
    .reg_write         (reg_write),
    .reg_write_addr    (reg_write_addr),
    .reg_write_source  (reg_write_source),
    .mem_read          (mem_read),
    .mem_write         (mem_write),
    .mem_byte_enable   (mem_byte_enable),
    .is_branch         (is_branch),
    .pc_data           (pc_data)
  );

  initial begin
    // This is just so it doesn't crash..
    instruction_data = 32'h00500093;

    #1;

    // Using: https://binarycon.com/tools/risc-v-instruction-encoder-decoder/
    // To generate tests, they are also taken from 'instruction_decoder_tb.sv'

    // addi x1, x0, 5
    check_data(/*instr=*/32'h00500093, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'd5, /*alu_data1=*/32'd0, /*alu_data2=*/32'd5, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    alu_source = reg_write_source;

    // addi x2, x0, 10
    check_data(/*instr=*/32'h00a00113, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd2, /*reg_write_data=*/32'd10, /*alu_data1=*/32'd0, /*alu_data2=*/32'd10, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // add x3, x1, x2
    check_data(/*instr=*/32'h002081b3, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'd15, /*alu_data1=*/32'd5, /*alu_data2=*/32'd10, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // sub x4, x2, x1
    check_data(/*instr=*/32'h40110233, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd4, /*reg_write_data=*/32'd5, /*alu_data1=*/32'd10, /*alu_data2=*/32'd5, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // and x5, x1, x2
    check_data(/*instr=*/32'h0020f2b3, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd5, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'd10, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // or x6, x1, x2
    check_data(/*instr=*/32'h0020e333, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd6, /*reg_write_data=*/32'd15, /*alu_data1=*/32'd5, /*alu_data2=*/32'd10, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // xor x7, x1, x2
    check_data(/*instr=*/32'h0020c3b3, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd7, /*reg_write_data=*/32'd15, /*alu_data1=*/32'd5, /*alu_data2=*/32'd10, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // slt x8, x1, x2
    check_data(/*instr=*/32'h0020a433, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd8, /*reg_write_data=*/32'd1, /*alu_data1=*/32'd5, /*alu_data2=*/32'd10, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // sltu x9, x1, x2
    check_data(/*instr=*/32'h0020b4b3, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd9, /*reg_write_data=*/32'd1, /*alu_data1=*/32'd5, /*alu_data2=*/32'd10, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // addi x10, x1, -5
    check_data(/*instr=*/32'hffb08513, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd10, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'hfffffffb, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // andi x11, x1, 3
    check_data(/*instr=*/32'h0030f593, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd11, /*reg_write_data=*/32'd1, /*alu_data1=*/32'd5, /*alu_data2=*/32'd3, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // ori x12, x1, 3
    check_data(/*instr=*/32'h0030e613, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd12, /*reg_write_data=*/32'd7, /*alu_data1=*/32'd5, /*alu_data2=*/32'd3, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // xori x13, x1, 3
    check_data(/*instr=*/32'h0030c693, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd13, /*reg_write_data=*/32'd6, /*alu_data1=*/32'd5, /*alu_data2=*/32'd3, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // slli x14, x1, 2
    check_data(/*instr=*/32'h00209713, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd14, /*reg_write_data=*/32'd20, /*alu_data1=*/32'd5, /*alu_data2=*/32'd2, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // srli x15, x2, 1
    check_data(/*instr=*/32'h00115793, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd15, /*reg_write_data=*/32'd5, /*alu_data1=*/32'd10, /*alu_data2=*/32'd1, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // srai x16, x2, 1
    check_data(/*instr=*/32'h40115813, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd16, /*reg_write_data=*/32'd5, /*alu_data1=*/32'd10, /*alu_data2=*/32'd1, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // sll x17, x1, x2
    check_data(/*instr=*/32'h002098b3, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd17, /*reg_write_data=*/32'd5120, /*alu_data1=*/32'd5, /*alu_data2=*/32'd10, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // srl x18, x2, x1
    check_data(/*instr=*/32'h00115933, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd18, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd10, /*alu_data2=*/32'd5, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // sra x19, x2, x1
    check_data(/*instr=*/32'h401159b3, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd19, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd10, /*alu_data2=*/32'd5, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 0;

    #1;

    // beq x1, x2, 8 (not taken)
    check_data(/*instr=*/32'h00208463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // bne x1, x2, 8 (taken)
    check_data(/*instr=*/32'h00209463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    // blt x1, x2, 8 (taken)
    check_data(/*instr=*/32'h0020c463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    // bge x1, x2, 8 (not taken)
    check_data(/*instr=*/32'h0020d463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // bltu x1, x2, 8 (taken)
    check_data(/*instr=*/32'h0020e463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    // bgeu x1, x2, 8 (not taken)
    check_data(/*instr=*/32'h0020f463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // beq x1, x1, 8 (taken)
    check_data(/*instr=*/32'h00108463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    // bne x1, x1, 8 (not taken)
    check_data(/*instr=*/32'h00109463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // blt x2, x1, 8 (not taken)
    check_data(/*instr=*/32'h00114463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // bge x2, x1, 8 (taken)
    check_data(/*instr=*/32'h00115463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    pc = 32;

    #1;

    // beq x1, x1, -8 (taken)
    check_data(/*instr=*/32'hfe108ce3, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b1, /*pc_data=*/32'd24);

    // bne x1, x2, -8 (taken)
    check_data(/*instr=*/32'hfe209ce3, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b1, /*pc_data=*/32'd24);

    pc = 0;

    #1;

    // jal x0, 0
    check_data(/*instr=*/32'h0000006f, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd4, /*alu_data1=*/32'd0, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'd0);

    pc = 4;

    #1;

    // jal x1, 8
    check_data(/*instr=*/32'h008000ef, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'd8, /*alu_data1=*/32'd4, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'd12);

    // jal x5, 16
    check_data(/*instr=*/32'h010002ef, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd5, /*reg_write_data=*/32'd8, /*alu_data1=*/32'd4, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'd20);

    // jal x6, -4
    check_data(/*instr=*/32'hffdff36f, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd6, /*reg_write_data=*/32'd8, /*alu_data1=*/32'd4, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'd0);

    pc = 32'h00000020;
    gpr[21] = 32'h00000064;

    #1;

    // jalr x20, x21, 8
    check_data(/*instr=*/32'h008a8a67, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd20, /*reg_write_data=*/32'h00000024, /*alu_data1=*/32'h00000020, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h0000006c);

    pc = 32'h00000020;
    gpr[21] = 32'h00000064;

    #1;

    // jalr x20, x21, -8
    check_data(/*instr=*/32'hff8a8a67, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd20, /*reg_write_data=*/32'h00000024, /*alu_data1=*/32'h00000020, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h0000005c);

    pc = 32'h00000020;
    gpr[21] = 32'h00000065;

    #1;

    // jalr x20, x21, 0
    check_data(/*instr=*/32'h000a8a67, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd20, /*reg_write_data=*/32'h00000024, /*alu_data1=*/32'h00000020, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h00000064);

    pc = 32'h00000020;
    gpr[21] = 32'h00000064;

    #1;

    // jalr x20, x21, 1
    check_data(/*instr=*/32'h001a8a67, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd20, /*reg_write_data=*/32'h00000024, /*alu_data1=*/32'h00000020, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h00000064);

    pc = 32'h00000020;
    gpr[21] = 32'h00000064;

    #1;

    // jalr x0, x21, 0
    check_data(/*instr=*/32'h000a8067, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000024, /*alu_data1=*/32'h00000020, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h00000064);

    pc = 32'h00000020;
    gpr[21] = 32'h00000064;

    #1;

    // jalr x21, x21, 4
    check_data(/*instr=*/32'h004a8ae7, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd21, /*reg_write_data=*/32'h00000024, /*alu_data1=*/32'h00000020, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h00000068);

    pc = 32'h00000020;

    #1;

    // jalr x20, x0, 12
    check_data(/*instr=*/32'h00c00a67, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd20, /*reg_write_data=*/32'h00000024, /*alu_data1=*/32'h00000020, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h0000000c);

    pc = 32'h00000020;
    gpr[21] = 32'h00001000;

    #1;

    // jalr x20, x21, -2048
    check_data(/*instr=*/32'h800a8a67, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd20, /*reg_write_data=*/32'h00000024, /*alu_data1=*/32'h00000020, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h00000800);

    pc = 32'h00000020;
    gpr[21] = 32'h00001000;

    #1;

    // jalr x20, x21, 2047
    check_data(/*instr=*/32'h7ffa8a67, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd20, /*reg_write_data=*/32'h00000024, /*alu_data1=*/32'h00000020, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h000017fe);

    pc = 32'hfffffffc;
    gpr[21] = 32'hfffffffc;

    #1;

    // jalr x20, x21, 4
    check_data(/*instr=*/32'h004a8a67, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd20, /*reg_write_data=*/32'h00000000, /*alu_data1=*/32'hfffffffc, /*alu_data2=*/32'd4, /*is_branch=*/1'b1, /*pc_data=*/32'h00000000);

    pc = 32'h00000000;

    #1;

    // auipc x22, 0x00000
    check_data(/*instr=*/32'h00000b17, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'h00000000, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'h00000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h12345678;

    #1;

    // auipc x22, 0x00000
    check_data(/*instr=*/32'h00000b17, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'h12345678, /*alu_data1=*/32'h12345678, /*alu_data2=*/32'h00000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000100;

    #1;

    // auipc x23, 0x00001
    check_data(/*instr=*/32'h00001b97, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd23, /*reg_write_data=*/32'h00001100, /*alu_data1=*/32'h00000100, /*alu_data2=*/32'h00001000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000abc;

    #1;

    // auipc x24, 0x12345
    check_data(/*instr=*/32'h12345c17, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd24, /*reg_write_data=*/32'h12345abc, /*alu_data1=*/32'h00000abc, /*alu_data2=*/32'h12345000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000004;

    #1;

    // auipc x25, 0x7ffff
    check_data(/*instr=*/32'h7ffffc97, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd25, /*reg_write_data=*/32'h7ffff004, /*alu_data1=*/32'h00000004, /*alu_data2=*/32'h7ffff000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000000;

    #1;

    // auipc x26, 0x80000
    check_data(/*instr=*/32'h80000d17, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd26, /*reg_write_data=*/32'h80000000, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'h80000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00002000;

    #1;

    // auipc x27, 0xfffff
    check_data(/*instr=*/32'hfffffd97, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd27, /*reg_write_data=*/32'h00001000, /*alu_data1=*/32'h00002000, /*alu_data2=*/32'hfffff000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'hfffff004;

    #1;

    // auipc x28, 0x00001
    check_data(/*instr=*/32'h00001e17, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd28, /*reg_write_data=*/32'h00000004, /*alu_data1=*/32'hfffff004, /*alu_data2=*/32'h00001000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000100;

    #1;

    // auipc x0, 0x12345
    check_data(/*instr=*/32'h12345017, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h12345100, /*alu_data1=*/32'h00000100, /*alu_data2=*/32'h12345000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000800;

    #1;

    // auipc x31, 0xfffff
    check_data(/*instr=*/32'hffffff97, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd31, /*reg_write_data=*/32'hfffff800, /*alu_data1=*/32'h00000800, /*alu_data2=*/32'hfffff000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'd0;

    gpr[21] = 32'h00000000;

    #1;

    // sltiu x22, x21, 0
    check_data(/*instr=*/32'h000abb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'h00000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000000;

    #1;

    // sltiu x22, x21, 1
    check_data(/*instr=*/32'h001abb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'h00000001, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000005;

    #1;

    // sltiu x22, x21, 5
    check_data(/*instr=*/32'h005abb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h00000005, /*alu_data2=*/32'h00000005, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000006;

    #1;

    // sltiu x22, x21, 5
    check_data(/*instr=*/32'h005abb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h00000006, /*alu_data2=*/32'h00000005, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h000007fe;

    #1;

    // sltiu x22, x21, 2047
    check_data(/*instr=*/32'h7ffabb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'h000007fe, /*alu_data2=*/32'h000007ff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h80000000;

    #1;

    // sltiu x22, x21, 1
    check_data(/*instr=*/32'h001abb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h80000000, /*alu_data2=*/32'h00000001, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000000;

    #1;

    // sltiu x22, x21, -1
    check_data(/*instr=*/32'hfffabb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'hffffffff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hffffffff;

    #1;

    // sltiu x22, x21, -1
    check_data(/*instr=*/32'hfffabb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'hffffffff, /*alu_data2=*/32'hffffffff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hfffff7ff;

    #1;

    // sltiu x22, x21, -2048
    check_data(/*instr=*/32'h800abb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'hfffff7ff, /*alu_data2=*/32'hfffff800, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hfffff800;

    #1;

    // sltiu x22, x21, -2048
    check_data(/*instr=*/32'h800abb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'hfffff800, /*alu_data2=*/32'hfffff800, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hfffff801;

    #1;

    // sltiu x22, x21, -2048
    check_data(/*instr=*/32'h800abb13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'hfffff801, /*alu_data2=*/32'hfffff800, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // sltiu x22, x0, 1
    check_data(/*instr=*/32'h00103b13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'h00000001, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000000;

    #1;

    // sltiu x0, x21, 1
    check_data(/*instr=*/32'h001ab013, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd1, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'h00000001, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000003;

    #1;

    // sltiu x21, x21, 4
    check_data(/*instr=*/32'h004aba93, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd21, /*reg_write_data=*/32'd1, /*alu_data1=*/32'h00000003, /*alu_data2=*/32'h00000004, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'd0;

    gpr[21] = 32'h00000000;

    #1;

    // slti x22, x21, 0
    check_data(/*instr=*/32'h000aab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'h00000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000000;

    #1;

    // slti x22, x21, 1
    check_data(/*instr=*/32'h001aab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'h00000001, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000005;

    #1;

    // slti x22, x21, 5
    check_data(/*instr=*/32'h005aab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h00000005, /*alu_data2=*/32'h00000005, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000006;

    #1;

    // slti x22, x21, 5
    check_data(/*instr=*/32'h005aab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h00000006, /*alu_data2=*/32'h00000005, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hffffffff;

    #1;

    // slti x22, x21, 0
    check_data(/*instr=*/32'h000aab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'hffffffff, /*alu_data2=*/32'h00000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000000;

    #1;

    // slti x22, x21, -1
    check_data(/*instr=*/32'hfffaab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'hffffffff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hfffffffe;

    #1;

    // slti x22, x21, -1
    check_data(/*instr=*/32'hfffaab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'hfffffffe, /*alu_data2=*/32'hffffffff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hffffffff;

    #1;

    // slti x22, x21, -1
    check_data(/*instr=*/32'hfffaab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'hffffffff, /*alu_data2=*/32'hffffffff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h80000000;

    #1;

    // slti x22, x21, -2048
    check_data(/*instr=*/32'h800aab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'h80000000, /*alu_data2=*/32'hfffff800, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h7fffffff;

    #1;

    // slti x22, x21, 2047
    check_data(/*instr=*/32'h7ffaab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h7fffffff, /*alu_data2=*/32'h000007ff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hfffff7ff;

    #1;

    // slti x22, x21, -2048
    check_data(/*instr=*/32'h800aab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'hfffff7ff, /*alu_data2=*/32'hfffff800, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hfffff800;

    #1;

    // slti x22, x21, -2048
    check_data(/*instr=*/32'h800aab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'hfffff800, /*alu_data2=*/32'hfffff800, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hfffff801;

    #1;

    // slti x22, x21, -2048
    check_data(/*instr=*/32'h800aab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'hfffff801, /*alu_data2=*/32'hfffff800, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h000007fe;

    #1;

    // slti x22, x21, 2047
    check_data(/*instr=*/32'h7ffaab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd1, /*alu_data1=*/32'h000007fe, /*alu_data2=*/32'h000007ff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h000007ff;

    #1;

    // slti x22, x21, 2047
    check_data(/*instr=*/32'h7ffaab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h000007ff, /*alu_data2=*/32'h000007ff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'h00000800;

    #1;

    // slti x22, x21, 2047
    check_data(/*instr=*/32'h7ffaab13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h00000800, /*alu_data2=*/32'h000007ff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    // slti x22, x0, -1
    check_data(/*instr=*/32'hfff02b13, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'd0, /*alu_data1=*/32'h00000000, /*alu_data2=*/32'hffffffff, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hffffffff;

    #1;

    // slti x0, x21, 0
    check_data(/*instr=*/32'h000aa013, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd1, /*alu_data1=*/32'hffffffff, /*alu_data2=*/32'h00000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    gpr[21] = 32'hffffffff;

    #1;

    // slti x21, x21, 0
    check_data(/*instr=*/32'h000aaa93, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd21, /*reg_write_data=*/32'd1, /*alu_data1=*/32'hffffffff, /*alu_data2=*/32'h00000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000000;

    #1;

    // lui x22, 0x00000
    check_data(/*instr=*/32'h00000b37, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd22, /*reg_write_data=*/32'h00000000, /*alu_data1=*/32'd0, /*alu_data2=*/32'h00000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000000;

    #1;

    // lui x23, 0x00001
    check_data(/*instr=*/32'h00001bb7, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd23, /*reg_write_data=*/32'h00001000, /*alu_data1=*/32'd0, /*alu_data2=*/32'h00001000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000000;

    #1;

    // lui x24, 0x12345
    check_data(/*instr=*/32'h12345c37, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd24, /*reg_write_data=*/32'h12345000, /*alu_data1=*/32'd0, /*alu_data2=*/32'h12345000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000000;

    #1;

    // lui x25, 0x7ffff
    check_data(/*instr=*/32'h7ffffcb7, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd25, /*reg_write_data=*/32'h7ffff000, /*alu_data1=*/32'd0, /*alu_data2=*/32'h7ffff000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000000;

    #1;

    // lui x26, 0x80000
    check_data(/*instr=*/32'h80000d37, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd26, /*reg_write_data=*/32'h80000000, /*alu_data1=*/32'd0, /*alu_data2=*/32'h80000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000000;

    #1;

    // lui x27, 0xfffff
    check_data(/*instr=*/32'hfffffdb7, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd27, /*reg_write_data=*/32'hfffff000, /*alu_data1=*/32'd0, /*alu_data2=*/32'hfffff000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h12345678;

    #1;

    // lui x28, 0xabcde
    check_data(/*instr=*/32'habcdee37, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd28, /*reg_write_data=*/32'habcde000, /*alu_data1=*/32'd0, /*alu_data2=*/32'habcde000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'hffffffff;

    #1;

    // lui x28, 0x00000
    check_data(/*instr=*/32'h00000e37, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd28, /*reg_write_data=*/32'h00000000, /*alu_data1=*/32'd0, /*alu_data2=*/32'h00000000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000004;

    #1;

    // lui x0, 0x12345
    check_data(/*instr=*/32'h12345037, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h12345000, /*alu_data1=*/32'd0, /*alu_data2=*/32'h12345000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    pc = 32'h00000100;

    #1;

    // lui x31, 0x55555
    check_data(/*instr=*/32'h55555fb7, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd31, /*reg_write_data=*/32'h55555000, /*alu_data1=*/32'd0, /*alu_data2=*/32'h55555000, /*is_branch=*/1'b0, /*pc_data=*/32'd0);

    $finish;
  end

  task automatic check_data(
      input [31:0] instr,

      input logic        expected_reg_write,
      input logic [4:0]  expected_reg_write_addr,
      input logic [31:0] expected_reg_write_data,

      input logic [31:0] expected_alu_data1,
      input logic [31:0] expected_alu_data2,

      input logic        expected_is_branch,
      input logic [31:0] expected_pc_data
  );

    $display("testing instruction: 0x%0h", instr);

    instruction_data = instr;

    #10;

    assert (!mem_read && !mem_write && mem_byte_enable == 0)
        else $fatal(1, "Unexpected memory access for non-memory instruction");

    assert (reg_write === expected_reg_write)
        else $fatal(1, "Incorrect reg_write: 0b%0b expected: 0b%0b", reg_write, expected_reg_write);

    if (expected_reg_write) begin
      assert (reg_write_addr === expected_reg_write_addr)
          else $fatal(1, "Incorrect reg_write_addr: 0b%0b expected: 0b%0b", reg_write_addr, expected_reg_write_addr);
    end

    assert (alu_data1 === expected_alu_data1)
        else $fatal(1, "Incorrect alu_data1: 0x%0h expected: 0x%0h", alu_data1, expected_alu_data1);

    assert (alu_data2 === expected_alu_data2)
        else $fatal(1, "Incorrect alu_data2: 0x%0h expected: 0x%0h", alu_data2, expected_alu_data2);

    assert (is_branch === expected_is_branch)
        else $fatal(1, "Incorrect is_branch: 0b%0b expected: 0b%0b", is_branch, expected_is_branch);

    assert (pc_data === expected_pc_data)
        else $fatal(1, "Incorrect pc_data: 0x%0h expected: 0x%0h", pc_data, expected_pc_data);

    // For now.. I only have an ALU
    if (reg_write) begin
      assert (reg_write_source === ALU)
          else $fatal(1, "Incorrect reg_write_source");
      assert (alu_result === expected_reg_write_data)
          else $fatal(1, "Incorrect ALU result: 0x%0h expected: 0x%0h", alu_result, expected_reg_write_data);
    end

    // Just so it actually runs
    if (reg_write && reg_write_addr != 0)
      gpr[reg_write_addr] = alu_result;

    $display("PASS: 0x%08h", instr);

  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule
