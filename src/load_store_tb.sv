module load_store_tb;
  import control_unit_write_source::*;

  logic clk = 0;
  logic reset = 1;

  logic [31:0] instruction_addr;
  logic [31:0] instruction_data = 32'h00000013;

  logic [31:0] mem_addr, mem_write_data, mem_read_data;
  logic       mem_read, mem_write;
  logic [3:0] mem_byte_enable;

  RV32I u_cpu (
    .clk              (clk),
    .reset            (reset),
    .instruction_addr (instruction_addr),
    .instruction_data (instruction_data),
    .mem_addr         (mem_addr),
    .mem_write_data   (mem_write_data),
    .mem_read_data    (mem_read_data),
    .mem_read         (mem_read),
    .mem_write        (mem_write),
    .mem_byte_enable  (mem_byte_enable)
  );

  RAM #(
    .RAM_SIZE(1024)
  ) u_ram (
    .clk         (clk),
    .reset       (reset),
    .addr        (mem_addr),
    .write_data  (mem_write_data),
    .read_data   (mem_read_data),
    .read_enable (mem_read),
    .write_enable(mem_write),
    .byte_enable (mem_byte_enable)
  );

  always #5 clk = ~clk;

  initial begin
    repeat (2) @(negedge clk);
    reset = 0;

    // lui x1, 0x00000
    check_data(/*instr=*/32'h000000b7, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // addi x1, x1, 64
    check_data(/*instr=*/32'h04008093, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'h00000040, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lui x2, 0x80ff8
    check_data(/*instr=*/32'h80ff8137, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd2, /*reg_write_data=*/32'h80ff8000, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // addi x2, x2, -255
    check_data(/*instr=*/32'hf0110113, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd2, /*reg_write_data=*/32'h80ff7f01, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sw x2, -4(x1)
    check_data(/*instr=*/32'hfe20ae23, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b1, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h80ff7f01, /*mem_byte_enable=*/4'b1111);

    // lw x3, -4(x1)
    check_data(/*instr=*/32'hffc0a183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h80ff7f01, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lb x3, -4(x1)
    check_data(/*instr=*/32'hffc08183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h00000001, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lb x3, -3(x1)
    check_data(/*instr=*/32'hffd08183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h0000007f, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003d, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lb x3, -2(x1)
    check_data(/*instr=*/32'hffe08183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'hffffffff, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003e, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lb x3, -1(x1)
    check_data(/*instr=*/32'hfff08183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'hffffff80, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003f, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lbu x3, -4(x1)
    check_data(/*instr=*/32'hffc0c183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h00000001, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lbu x3, -3(x1)
    check_data(/*instr=*/32'hffd0c183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h0000007f, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003d, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lbu x3, -2(x1)
    check_data(/*instr=*/32'hffe0c183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h000000ff, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003e, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lbu x3, -1(x1)
    check_data(/*instr=*/32'hfff0c183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h00000080, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003f, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lh x3, -4(x1)
    check_data(/*instr=*/32'hffc09183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h00007f01, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lh x3, -2(x1)
    check_data(/*instr=*/32'hffe09183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'hffff80ff, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003e, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lhu x3, -4(x1)
    check_data(/*instr=*/32'hffc0d183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h00007f01, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lhu x3, -2(x1)
    check_data(/*instr=*/32'hffe0d183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h000080ff, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003e, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lui x2, 0x12345
    check_data(/*instr=*/32'h12345137, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd2, /*reg_write_data=*/32'h12345000, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // addi x2, x2, 1706
    check_data(/*instr=*/32'h6aa10113, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd2, /*reg_write_data=*/32'h123456aa, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sb x2, -4(x1)
    check_data(/*instr=*/32'hfe208e23, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b1, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h123456aa, /*mem_byte_enable=*/4'b0001);

    // lw x3, -4(x1)
    check_data(/*instr=*/32'hffc0a183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h80ff7faa, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sb x2, -3(x1)
    check_data(/*instr=*/32'hfe208ea3, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b1, /*mem_addr=*/32'h0000003d, /*mem_write_data=*/32'h3456aa00, /*mem_byte_enable=*/4'b0010);

    // lw x3, -4(x1)
    check_data(/*instr=*/32'hffc0a183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h80ffaaaa, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sb x2, -2(x1)
    check_data(/*instr=*/32'hfe208f23, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b1, /*mem_addr=*/32'h0000003e, /*mem_write_data=*/32'h56aa0000, /*mem_byte_enable=*/4'b0100);

    // lw x3, -4(x1)
    check_data(/*instr=*/32'hffc0a183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h80aaaaaa, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sb x2, -1(x1)
    check_data(/*instr=*/32'hfe208fa3, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b1, /*mem_addr=*/32'h0000003f, /*mem_write_data=*/32'haa000000, /*mem_byte_enable=*/4'b1000);

    // lw x3, -4(x1)
    check_data(/*instr=*/32'hffc0a183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'haaaaaaaa, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lui x2, 0xffff8
    check_data(/*instr=*/32'hffff8137, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd2, /*reg_write_data=*/32'hffff8000, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // addi x2, x2, 0
    check_data(/*instr=*/32'h00010113, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd2, /*reg_write_data=*/32'hffff8000, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sh x2, -4(x1)
    check_data(/*instr=*/32'hfe209e23, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b1, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'hffff8000, /*mem_byte_enable=*/4'b0011);

    // lw x3, -4(x1)
    check_data(/*instr=*/32'hffc0a183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'haaaa8000, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lh x3, -4(x1)
    check_data(/*instr=*/32'hffc09183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'hffff8000, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lhu x3, -4(x1)
    check_data(/*instr=*/32'hffc0d183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h00008000, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lui x2, 0x12348
    check_data(/*instr=*/32'h12348137, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd2, /*reg_write_data=*/32'h12348000, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // addi x2, x2, -1
    check_data(/*instr=*/32'hfff10113, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd2, /*reg_write_data=*/32'h12347fff, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sh x2, -2(x1)
    check_data(/*instr=*/32'hfe209f23, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b1, /*mem_addr=*/32'h0000003e, /*mem_write_data=*/32'h7fff0000, /*mem_byte_enable=*/4'b1100);

    // lw x3, -4(x1)
    check_data(/*instr=*/32'hffc0a183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h7fff8000, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lw x0, -4(x1)
    check_data(/*instr=*/32'hffc0a003, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h7fff8000, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lw x1, -4(x1)
    check_data(/*instr=*/32'hffc0a083, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'h7fff8000, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h0000003c, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lui x1, 0x00001
    check_data(/*instr=*/32'h000010b7, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'h00001000, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // addi x1, x1, -2048
    check_data(/*instr=*/32'h80008093, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'h00000800, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sw x2, -2048(x1)
    check_data(/*instr=*/32'h8020a023, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b1, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h12347fff, /*mem_byte_enable=*/4'b1111);

    // lw x3, -2048(x1)
    check_data(/*instr=*/32'h8000a183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h12347fff, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sb x2, 2047(x1)
    check_data(/*instr=*/32'h7e208fa3, /*reg_write=*/1'b0, /*reg_write_addr=*/5'd0, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b1, /*mem_addr=*/32'h00000fff, /*mem_write_data=*/32'hff000000, /*mem_byte_enable=*/4'b1000);

    // lb x3, 2047(x1)
    check_data(/*instr=*/32'h7ff08183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'hffffffff, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000fff, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lbu x3, 2047(x1)
    check_data(/*instr=*/32'h7ff0c183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h000000ff, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000fff, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // sw x2, 0(x1) during reset
    instruction_data = 32'h0020a023;
    reset = 1;

    #1;

    assert (!mem_read && !mem_write && mem_byte_enable == 0)
        else $fatal(1, "Memory active during reset");

    @(negedge clk);

    instruction_data = 32'h00000013;
    reset = 0;

    // lui x1, 0x00000
    check_data(/*instr=*/32'h000000b7, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // addi x1, x1, 0
    check_data(/*instr=*/32'h00008093, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd1, /*reg_write_data=*/32'h00000000, /*mem_read=*/1'b0, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lw x3, 0(x1)
    check_data(/*instr=*/32'h0000a183, /*reg_write=*/1'b1, /*reg_write_addr=*/5'd3, /*reg_write_data=*/32'h12347fff, /*mem_read=*/1'b1, /*mem_write=*/1'b0, /*mem_addr=*/32'h00000000, /*mem_write_data=*/32'h00000000, /*mem_byte_enable=*/4'b0000);

    // lh x3, 1(x1) - expected failure
    if ($test$plusargs("misaligned_load")) begin
      instruction_data = 32'h00109183;

      #1;

      assert (!mem_read && !mem_write)
          else $fatal(1, "Misaligned read escaped");

      @(negedge clk);

      $fatal(1, "Misaligned load was not rejected");
    end

    // sw x2, 2(x1) - expected failure
    if ($test$plusargs("misaligned_store")) begin
      instruction_data = 32'h0020a123;

      #1;

      assert (!mem_read && !mem_write)
          else $fatal(1, "Misaligned write escaped");

      @(negedge clk);

      $fatal(1, "Misaligned store was not rejected");
    end

    $finish;
  end

  task automatic check_data(
      input [31:0] instr,

      input logic        expected_reg_write,
      input logic [4:0]  expected_reg_write_addr,
      input logic [31:0] expected_reg_write_data,

      input logic        expected_mem_read,
      input logic        expected_mem_write,
      input logic [31:0] expected_mem_addr,
      input logic [31:0] expected_mem_write_data,
      input logic [3:0]  expected_mem_byte_enable
  );

    $display("testing instruction: 0x%0h", instr);

    instruction_data = instr;

    #1;

    assert (u_cpu.reg_write === expected_reg_write)
        else $fatal(1, "Incorrect reg_write: 0b%0b expected: 0b%0b", u_cpu.reg_write, expected_reg_write);

    if (expected_reg_write) begin
      assert (u_cpu.reg_write_addr === expected_reg_write_addr)
          else $fatal(1, "Incorrect reg_write_addr: 0b%0b expected: 0b%0b", u_cpu.reg_write_addr, expected_reg_write_addr);

      assert (u_cpu.reg_write_data === expected_reg_write_data)
          else $fatal(1, "Incorrect reg_write_data: 0x%0h expected: 0x%0h", u_cpu.reg_write_data, expected_reg_write_data);

      assert (u_cpu.reg_write_source === (expected_mem_read ? MEMORY : ALU))
          else $fatal(1, "Incorrect reg_write_source");
    end

    assert (mem_read === expected_mem_read)
        else $fatal(1, "Incorrect mem_read: 0b%0b expected: 0b%0b", mem_read, expected_mem_read);

    assert (mem_write === expected_mem_write)
        else $fatal(1, "Incorrect mem_write: 0b%0b expected: 0b%0b", mem_write, expected_mem_write);

    if (expected_mem_read || expected_mem_write) begin
      assert (mem_addr === expected_mem_addr)
          else $fatal(1, "Incorrect mem_addr: 0x%0h expected: 0x%0h", mem_addr, expected_mem_addr);
    end

    if (expected_mem_write) begin
      assert (mem_write_data === expected_mem_write_data)
          else $fatal(1, "Incorrect mem_write_data: 0x%0h expected: 0x%0h", mem_write_data, expected_mem_write_data);
    end

    assert (mem_byte_enable === expected_mem_byte_enable)
        else $fatal(1, "Incorrect mem_byte_enable: 0b%0b expected: 0b%0b", mem_byte_enable, expected_mem_byte_enable);

    assert (u_cpu.is_branch === 1'b0)
        else $fatal(1, "Unexpected branch");

    @(negedge clk);

    if (expected_reg_write && expected_reg_write_addr != 0) begin
      assert (u_cpu.gpr[expected_reg_write_addr] === expected_reg_write_data)
          else $fatal(1, "Incorrect register writeback: 0x%0h expected: 0x%0h", u_cpu.gpr[expected_reg_write_addr], expected_reg_write_data);
    end

    assert (u_cpu.gpr[0] === 32'b0)
        else $fatal(1, "Incorrect x0 value: 0x%0h", u_cpu.gpr[0]);

    $display("PASS: 0x%08h", instr);

  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule
