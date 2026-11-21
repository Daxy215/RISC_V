module ROM
#(
  parameter ROM_SIZE = 5,
  parameter ROM_FILE = "rom_image.mem"
)

(
  input [31:0] addr,

  output [31:0] result
);

  logic [31:0] memory [ROM_SIZE - 1:0];

  initial begin
    $display("Loading rom.");
    $readmemh(ROM_FILE, memory, 0, ROM_SIZE - 1);
  end

  // >> 2 for alignment
  assign result = memory[addr >> 2];

endmodule: ROM
