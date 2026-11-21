
module control_unit_tb;
  import types_pkg::*;
  import control_unit_write_source::*;

  instruction_fields_t instruction_fields;

  logic [31:0] pc = 0;
  logic [31:0] gpr [31:0] = '{default:0};

  logic        reg_write;
  logic [4:0]  reg_write_addr;
  logic [31:0] alu_data1, alu_data2;

  write_source reg_write_source;
  write_source alu_source, jump_source;

  bit is_branch;

  logic [31:0] pc_data;

  logic [31:0] instruction_data;

  instruction_decoder u_instruction_decoder (
    .data              (instruction_data),
    .instruction_fields(instruction_fields)
  );

  control_unit u_control_unit (
    .instruction_fields(instruction_fields),
    .gpr               (gpr),
    .pc                (pc),
    .alu_data1         (alu_data1),
    .alu_data2         (alu_data2),
    .reg_write         (reg_write),
    .reg_write_addr    (reg_write_addr),
    .reg_write_source  (reg_write_source),
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
    check_data(/*instr=*/32'h00208463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'd8, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // bne x1, x2, 8 (taken)
    check_data(/*instr=*/32'h00209463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'd8, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    // blt x1, x2, 8 (taken)
    check_data(/*instr=*/32'h0020c463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'd8, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    // bge x1, x2, 8 (not taken)
    check_data(/*instr=*/32'h0020d463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'd8, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // bltu x1, x2, 8 (taken)
    check_data(/*instr=*/32'h0020e463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'd8, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    // bgeu x1, x2, 8 (not taken)
    check_data(/*instr=*/32'h0020f463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'd8, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // beq x1, x1, 8 (taken)
    check_data(/*instr=*/32'h00108463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'd8, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    // bne x1, x1, 8 (not taken)
    check_data(/*instr=*/32'h00109463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'd8, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // blt x2, x1, 8 (not taken)
    check_data(/*instr=*/32'h00114463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd10, /*alu_data2=*/32'd8, /*is_branch=*/1'b0, /*pc_data=*/32'd8);

    // bge x2, x1, 8 (taken)
    check_data(/*instr=*/32'h00115463, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd10, /*alu_data2=*/32'd8, /*is_branch=*/1'b1, /*pc_data=*/32'd8);

    pc = 32;

    #1;

    // beq x1, x1, -8 (taken)
    check_data(/*instr=*/32'hfe108ce3, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'hfffffff8, /*is_branch=*/1'b1, /*pc_data=*/32'd24);

    // bne x1, x2, -8 (taken)
    check_data(/*instr=*/32'hfe209ce3, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd0, /*alu_data1=*/32'd5, /*alu_data2=*/32'hfffffff8, /*is_branch=*/1'b1, /*pc_data=*/32'd24);

    pc = 0;

    #1;

    // jal x0, 0
    check_data(/*instr=*/32'h0000006f, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'd4, /*alu_data1=*/32'd0, /*alu_data2=*/32'd0, /*is_branch=*/1'b1, /*pc_data=*/32'd0);

    jump_source = reg_write_source;

    assert (jump_source != alu_source)
        else $fatal(1, "Incorrect reg_write_source: JAL should not use ALU result");

    pc = 4;

    #1;

    // jal x1, 8
    check_data(/*instr=*/32'h008000ef, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'd8, /*alu_data1=*/32'd4, /*alu_data2=*/32'd8, /*is_branch=*/1'b1, /*pc_data=*/32'd12);

    // jal x5, 16
    check_data(/*instr=*/32'h010002ef, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd5, /*reg_write_data=*/32'd8, /*alu_data1=*/32'd4, /*alu_data2=*/32'd16, /*is_branch=*/1'b1, /*pc_data=*/32'd20);

    // jal x6, -4
    check_data(/*instr=*/32'hffdff36f, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd6, /*reg_write_data=*/32'd8, /*alu_data1=*/32'd4, /*alu_data2=*/32'hfffffffc, /*is_branch=*/1'b1, /*pc_data=*/32'd0);

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

    if (instr[6:0] == 7'b1100011 || instr[6:0] == 7'b1101111) begin
      assert (pc_data === expected_pc_data)
          else $fatal(1, "Incorrect pc_data: 0x%0h expected: 0x%0h", pc_data, expected_pc_data);
    end

    if (reg_write) begin
      if (instr[6:0] == 7'b1101111) begin
        if (instr != 32'h0000006f) begin
          assert (reg_write_source === jump_source)
              else $fatal(1, "Incorrect reg_write_source for JAL");
        end
      end
      else begin
        assert (reg_write_source === alu_source || instr == 32'h00500093)
            else $fatal(1, "Incorrect reg_write_source for ALU instruction");
      end
    end

    // Just so it actually runs
    if (reg_write && reg_write_addr != 0)
      gpr[reg_write_addr] = expected_reg_write_data;

    $display("PASS: 0x%08h", instr);

  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule
