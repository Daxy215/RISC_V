module soc #(
  parameter ROM_SIZE = 5,
  parameter ROM_FILE = "rom_image.mem",
  parameter RAM_SIZE = 1024
)(
  input logic clk,
  input logic reset,
  output logic [5:0] led,
  output logic uart_txp,

  output logic [2:0] TMDSp,
  output logic [2:0] TMDSn,

  output logic TMDSp_clock,
  output logic TMDSn_clock,

  output wire O_sdram_clk,
  output wire O_sdram_cke,
  output wire O_sdram_cs_n,
  output wire O_sdram_cas_n,
  output wire O_sdram_ras_n,
  output wire O_sdram_wen_n,
  inout wire [31:0] IO_sdram_dq,
  output wire [10:0] O_sdram_addr,
  output wire [1:0] O_sdram_ba,
  output wire [3:0] O_sdram_dqm
);

  logic [31:0] instruction_addr, instruction_data;
  logic [31:0] mem_addr, mem_write_data, mem_read_data;
  logic mem_read, mem_write;
  logic mem_ready;
  logic [3:0] mem_byte_enable;

  logic system_clk, clk_sdram, pll_locked;
  logic [1:0] reset_sync = 2'b11;
  logic system_reset;
  wire reset_request = reset || !pll_locked;

  SDRAM_PLL u_sdram_pll (
    .clkin  (clk),
    .reset  (reset),
    .clkout (system_clk),
    .clkoutp(clk_sdram),
    .lock   (pll_locked)
  );

  // Assert immediately; release after two locked system clock edges.
  always_ff @(posedge system_clk or posedge reset_request) begin
    if (reset_request)
      reset_sync <= 2'b11;
    else
      reset_sync <= {reset_sync[0], 1'b0};
  end

  assign system_reset = reset_sync[1];

  RV32I u_cpu (
    .clk              (system_clk),
    .reset            (system_reset),
    .instruction_addr (instruction_addr),
    .instruction_data (instruction_data),
    .mem_addr         (mem_addr),
    .mem_write_data   (mem_write_data),
    .mem_read_data    (mem_read_data),
    .mem_ready        (mem_ready),
    .mem_read         (mem_read),
    .mem_write        (mem_write),
    .mem_byte_enable  (mem_byte_enable)
  );

  GPU u_GPU (
    .clk        (clk),
    .rst        (reset),
    .TMDSp      (TMDSp),
    .TMDSn      (TMDSn),
    .TMDSp_clock(TMDSp_clock),
    .TMDSn_clock(TMDSn_clock)
  );

  ROM #(
    .ROM_SIZE(ROM_SIZE),
    .ROM_FILE(ROM_FILE)
  ) u_rom (
    .addr  (instruction_addr),
    .result(instruction_data)
  );

  RAM #(
    .RAM_SIZE  (RAM_SIZE),
    .DATA_WIDTH(32),
    .FREQ      (27_000_000)
  ) u_ram (
    .clk         (system_clk),
    .clk_sdram   (clk_sdram),
    .reset       (system_reset),
    .addr        (mem_addr),
    .write_data  (mem_write_data),
    .read_data   (mem_read_data),
    .read_enable (mem_read),
    .write_enable(mem_write),
    .byte_enable (mem_byte_enable),
    .ready       (mem_ready),
    .uart_txp    (uart_txp),
    .O_sdram_clk (O_sdram_clk),
    .O_sdram_cke (O_sdram_cke),
    .O_sdram_cs_n(O_sdram_cs_n),
    .O_sdram_cas_n(O_sdram_cas_n),
    .O_sdram_ras_n(O_sdram_ras_n),
    .O_sdram_wen_n(O_sdram_wen_n),
    .IO_sdram_dq (IO_sdram_dq),
    .O_sdram_addr(O_sdram_addr),
    .O_sdram_ba  (O_sdram_ba),
    .O_sdram_dqm (O_sdram_dqm)
  );

  assign led = ~instruction_addr[7:2];

endmodule: soc
