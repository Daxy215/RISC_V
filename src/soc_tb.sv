module soc_tb;

  logic clk = 0;
  logic reset = 1;

  soc u_soc (
    .clk  (clk),
    .reset(reset)
  );

  always #5 clk = ~clk;

  initial begin
    // rom_image.mem: ADDI, ADDI, ADD, SUB, then JAL x0, 0.
    repeat (2) @(negedge clk);
    reset = 0;
    repeat (8) @(negedge clk);

    assert (u_soc.u_cpu.gpr[0] == 0) else $fatal(1, "x0 changed");
    assert (u_soc.u_cpu.gpr[1] == 5) else $fatal(1, "ADDI x1 failed");
    assert (u_soc.u_cpu.gpr[2] == 10) else $fatal(1, "ADDI x2 failed");
    assert (u_soc.u_cpu.gpr[3] == 15) else $fatal(1, "ADD failed");
    assert (u_soc.u_cpu.gpr[4] == 5) else $fatal(1, "SUB failed");
    assert (u_soc.instruction_addr == 16) else $fatal(1, "JAL loop failed");
    assert (!u_soc.mem_read && !u_soc.mem_write && u_soc.mem_byte_enable == 0)
        else $fatal(1, "Unexpected memory access");

    reset = 1;
    @(negedge clk);
    assert (u_soc.instruction_addr == 0) else $fatal(1, "PC reset failed");
    foreach (u_soc.u_cpu.gpr[i])
      assert (u_soc.u_cpu.gpr[i] == 0) else $fatal(1, "Register reset failed");

    $display("SoC tests passed");
    $finish;
  end

endmodule: soc_tb
