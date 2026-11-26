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
    //$readmemh(ROM_FILE, memory, 0, ROM_SIZE - 1);

    memory[0] = 32'h00500093;
    memory[1] = 32'h00a00113;
    memory[2] = 32'h002081b3;
    memory[3] = 32'h40110233;
    memory[4] = 32'h0000006f;
  end

  // >> 2 for alignment
  assign result = memory[addr >> 2];

endmodule: ROM
