module RAM #(
  parameter RAM_SIZE = 1024,
  parameter DATA_WIDTH = 32,
  parameter FREQ = 27_000_000
)(
  input logic clk,
  input logic clk_sdram,
  input logic reset,

  input logic [31:0] addr,
  input logic [DATA_WIDTH-1:0] write_data,
  output logic [DATA_WIDTH-1:0] read_data,
  input logic read_enable,
  input logic write_enable,
  input logic [DATA_WIDTH/8-1:0] byte_enable,
  output logic ready,
  output logic uart_txp,

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

  localparam BYTE_COUNT = DATA_WIDTH / 8;
  localparam ADDR_SHIFT = $clog2(BYTE_COUNT);
  localparam REFRESH_COUNT = FREQ / 1_000_000 * 15;

  typedef enum logic [2:0] {
    IDLE, READ, READ_RESULT, WRITE, WRITE_RESULT, FINISH
  } state_t;

  state_t state;
  logic [22:0] request_addr;
  logic [DATA_WIDTH-1:0] request_data;
  logic [BYTE_COUNT-1:0] request_byte_enable;
  integer byte_index;
  integer refresh_time;

  logic rd, wr, refresh;
  logic busy, data_ready;
  logic [22:0] sdram_addr;
  logic [7:0] din;
  wire [31:0] dout32;
  wire [31:0] shifted_data = dout32 >> {request_addr[1:0], 3'b000};

  // DATA_WIDTH is the logic-side word size; the physical SDRAM bus is 32 bits.
  // RAM_SIZE counts these words. Addresses remain byte addresses.
  initial begin
    assert (DATA_WIDTH == 8 || DATA_WIDTH == 16 || DATA_WIDTH == 32)
        else $fatal(1, "RAM DATA_WIDTH must be 8, 16 or 32");
    assert (RAM_SIZE > 0 && RAM_SIZE <= 8_388_608 / BYTE_COUNT)
        else $fatal(1, "RAM_SIZE exceeds SDRAM capacity");
    assert (FREQ >= 1_000_000 && FREQ <= 66_700_000)
        else $fatal(1, "Unsupported SDRAM clock frequency");
  end

  // The caller holds its request until ready, then advances on that clock edge.
  assign ready = state == FINISH && !reset;
  assign uart_txp = 1'b1;

  always_comb begin
    rd = 1'b0;
    wr = 1'b0;
    refresh = 1'b0;
    sdram_addr = request_addr;
    din = 8'b0;

    if (!reset && !busy) begin
      if (refresh_time >= REFRESH_COUNT)
        refresh = 1'b1;
      else if (state == READ)
        rd = 1'b1;
      else if (state == WRITE && byte_index < BYTE_COUNT) begin
        sdram_addr = request_addr + 23'(byte_index);
        din = request_data[byte_index * 8 +: 8];
        wr = request_byte_enable[byte_index];
      end
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      request_addr <= 0;
      request_data <= 0;
      request_byte_enable <= 0;
      read_data <= 0;
      byte_index <= 0;
      refresh_time <= 0;
    end else begin
      // Saturate while busy so a pending refresh cannot be lost.
      if (refresh)
        refresh_time <= 0;
      else if (refresh_time < REFRESH_COUNT)
        refresh_time <= refresh_time + 1;

      case (state)
        IDLE: begin
          if (read_enable || write_enable) begin
            assert ((addr >> ADDR_SHIFT) < RAM_SIZE)
                else $fatal(1, "RAM address out of range: 0x%0h", addr);
            assert (!(read_enable && write_enable))
                else $fatal(1, "Simultaneous RAM read and write");
            request_addr <= 23'((addr >> ADDR_SHIFT) << ADDR_SHIFT);
            request_data <= write_data;
            request_byte_enable <= byte_enable;
            byte_index <= 0;
            if (read_enable)
              state <= READ;
            else
              state <= WRITE;
          end
        end

        READ: if (rd) state <= READ_RESULT;

        READ_RESULT: begin
          if (data_ready) begin
            // dout32 is only valid during data_ready, unlike buffered dout.
            read_data <= shifted_data[DATA_WIDTH-1:0];
            state <= FINISH;
          end
        end

        WRITE: begin
          if (byte_index == BYTE_COUNT)
            state <= FINISH;
          else if (wr)
            state <= WRITE_RESULT;
          else if (!request_byte_enable[byte_index])
            byte_index <= byte_index + 1;
        end

        WRITE_RESULT: begin
          if (!busy) begin
            byte_index <= byte_index + 1;
            state <= WRITE;
          end
        end

        FINISH: state <= IDLE;
        default: state <= IDLE;
      endcase
    end
  end

  sdram #(
    .FREQ(FREQ)
  ) u_sdram (
    .clk        (clk),
    .clk_sdram  (clk_sdram),
    .resetn     (!reset),
    .addr       (sdram_addr),
    .rd         (rd),
    .wr         (wr),
    .refresh    (refresh),
    .din        (din),
    .dout       (),
    .dout32     (dout32),
    .data_ready (data_ready),
    .busy       (busy),
    .SDRAM_DQ   (IO_sdram_dq),
    .SDRAM_A    (O_sdram_addr),
    .SDRAM_BA   (O_sdram_ba),
    .SDRAM_nCS  (O_sdram_cs_n),
    .SDRAM_nWE  (O_sdram_wen_n),
    .SDRAM_nRAS (O_sdram_ras_n),
    .SDRAM_nCAS (O_sdram_cas_n),
    .SDRAM_CLK  (O_sdram_clk),
    .SDRAM_CKE  (O_sdram_cke),
    .SDRAM_DQM  (O_sdram_dqm)
  );

endmodule: RAM
