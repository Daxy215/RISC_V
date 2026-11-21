module RAM_tb;

  logic clk = 0;
  logic reset = 1;
  logic [31:0] addr = 0, write_data = 0, read_data;
  logic read_enable = 0, write_enable = 0;
  logic [3:0] byte_enable = 0;

  RAM #(.RAM_SIZE(4)) u_ram (.*);

  always #5 clk = ~clk;

  task automatic write_word(input logic [31:0] address, data, input logic [3:0] mask);
    @(negedge clk);
    addr = address;
    write_data = data;
    byte_enable = mask;
    write_enable = 1;
    @(negedge clk);
    write_enable = 0;
  endtask

  task automatic check_word(input logic [31:0] address, expected);
    addr = address;
    read_enable = 1;
    #1;
    assert (read_data === expected)
        else $fatal(1, "RAM[0x%0h]: 0x%0h expected: 0x%0h", address, read_data, expected);
    read_enable = 0;
    #1;
    assert (read_data == 0) else $fatal(1, "Disabled read must return zero");
  endtask

  initial begin
    @(negedge clk);
    reset = 0;

    write_word(0, 32'h11223344, 4'b1111);
    write_word(4, 32'h55667788, 4'b1111);
    write_word(12, 32'hdeadbeef, 4'b1111);
    check_word(0, 32'h11223344);
    check_word(4, 32'h55667788);
    check_word(12, 32'hdeadbeef);

    // Byte lanes use addr[31:2]; low address bits do not shift write data.
    write_word(1, 32'h0000aa00, 4'b0010);
    check_word(0, 32'h1122aa44);
    write_word(2, 32'hbbcc0000, 4'b1100);
    check_word(0, 32'hbbccaa44);
    write_word(0, 32'h000000dd, 4'b0001);
    check_word(0, 32'hbbccaadd);
    write_word(0, 32'hffffffff, 4'b0000);
    check_word(0, 32'hbbccaadd);
    check_word(4, 32'h55667788);

    // Reset suppresses accesses and preserves stored data.
    reset = 1;
    write_word(0, 0, 4'b1111);
    read_enable = 1;
    #1;
    assert (read_data == 0) else $fatal(1, "Reset did not suppress read");
    read_enable = 0;
    reset = 0;
    check_word(0, 32'hbbccaadd);

    $display("RAM tests passed");
    $finish;
  end

endmodule: RAM_tb
