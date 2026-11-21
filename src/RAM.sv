module RAM #(
  parameter RAM_SIZE = 1024
)(
  input logic clk,
  input logic reset,

  input logic [31:0] addr,
  input logic [31:0] write_data,
  output logic [31:0] read_data,
  input logic read_enable,
  input logic write_enable,
  input logic [3:0] byte_enable
);

  // RAM_SIZE is in 32-bit words. Addresses are byte addresses.
  // Each enable selects one byte of the aligned little-endian word.
  logic [31:0] memory [0:RAM_SIZE - 1];

  always_comb begin
    read_data = 32'b0;
    if (read_enable && !reset && (addr >> 2) < RAM_SIZE)
      read_data = memory[addr >> 2];
  end

  always_ff @(posedge clk) begin
    if (!reset) begin
      if (read_enable || write_enable) begin
        assert ((addr >> 2) < RAM_SIZE)
            else $fatal(1, "RAM address out of range: 0x%0h", addr);
      end

      if (write_enable && (addr >> 2) < RAM_SIZE) begin
        for (int i = 0; i < 4; i++) begin
          if (byte_enable[i])
            memory[addr >> 2][i * 8 +: 8] <= write_data[i * 8 +: 8];
        end
      end
    end
  end

endmodule: RAM
