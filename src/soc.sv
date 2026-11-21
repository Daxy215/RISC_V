module soc #(
  parameter ROM_SIZE = 5,
  parameter ROM_FILE = "rom_image.mem",
  parameter RAM_SIZE = 1024
)(
  input logic clk,
  input logic reset
);

  logic [31:0] instruction_addr, instruction_data;
  logic [31:0] mem_addr, mem_write_data, mem_read_data;
  logic mem_read, mem_write;
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

  ROM #(
    .ROM_SIZE(ROM_SIZE),
    .ROM_FILE(ROM_FILE)
  ) u_rom (
    .addr  (instruction_addr),
    .result(instruction_data)
  );

  RAM #(
    .RAM_SIZE(RAM_SIZE)
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

endmodule: soc
