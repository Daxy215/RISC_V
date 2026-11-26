module RV32I(
  input logic clk,
  input logic reset,

  output logic [31:0] instruction_addr,
  input  logic [31:0] instruction_data,

  output logic [31:0] mem_addr,
  output logic [31:0] mem_write_data,
  input  logic [31:0] mem_read_data,
  input  logic        mem_ready,
  output logic        mem_read,
  output logic        mem_write,
  output logic [3:0]  mem_byte_enable
);

  import types_pkg::*;
  import alu_arithmetic_types::*;
  import control_unit_write_source::*;

  /*
   * The RV32I CPU contains 32 GPRS,
   * each being 32 bits wide.
   * plus a PC
   */

  // 32 registers each 32 bits wide
  logic [31:0] gpr [31:0] = '{default:0};
  logic [31:0] pc = 0, next_pc = 0;

  assign instruction_addr = pc;

  instruction_fields_t instruction_fields;

  instruction_decoder u_instruction_decoder (
    .data              (instruction_data),
    .instruction_fields(instruction_fields)
  );

  logic [31:0] alu_data1, alu_data2, alu_result;
  arithmetic_types arithmetic_type;

  // https://stevengong.co/notes/Control-Unit
  alu u_alu (
    .data1          (alu_data1),
    .data2          (alu_data2),
    .arithmetic_type(arithmetic_type),
    .result         (alu_result)
  );

  logic        reg_write;
  logic [4:0]  reg_write_addr;

  logic [31:0] pc_data, pc_sum;

  adder u_pc_adder (
    .data1 (pc),
    .data2 (4),
    .result(pc_sum),
    .c_out ()
  );

  bit is_branch;

  write_source reg_write_source;
  logic mem_read_request, mem_write_request;
  logic [31:0] reg_write_data, shifted_read_data, load_data;
  logic [3:0] mem_access_mask;
  logic mem_aligned;

  assign mem_addr = alu_result;
  assign mem_write_data = gpr[instruction_fields.rs2] << {mem_addr[1:0], 3'b000};
  assign mem_byte_enable = mem_write ? mem_access_mask << mem_addr[1:0] : 4'b0000;
  assign mem_read = mem_read_request && !reset && mem_aligned;
  assign mem_write = mem_write_request && !reset && mem_aligned;
  assign shifted_read_data = mem_read_data >> {mem_addr[1:0], 3'b000};
  assign reg_write_data = reg_write_source == MEMORY ? load_data : alu_result;

  always_comb begin
    mem_aligned = 1'b1;
    load_data = shifted_read_data;

    case (mem_access_mask)
      // LB / LBU - Load Byte
      4'b0001 : begin
        load_data = instruction_fields.funct3[2] ? {24'b0, shifted_read_data[7:0]} : {{24{shifted_read_data[7]}}, shifted_read_data[7:0]};
      end

      // LH / LHU - Load Halfword
      4'b0011 : begin
        mem_aligned = !mem_addr[0];
        load_data = instruction_fields.funct3[2] ? {16'b0, shifted_read_data[15:0]} : {{16{shifted_read_data[15]}}, shifted_read_data[15:0]};
      end

      // LW / SW - Word alignment
      4'b1111 : begin
        mem_aligned = mem_addr[1:0] == 2'b00;
      end

      default : begin end
    endcase
  end

  control_unit u_control_unit (
    .instruction_fields(instruction_fields),
    .gpr               (gpr),
    .pc                (pc),

    .alu_data1         (alu_data1),
    .alu_data2         (alu_data2),
    .arithmetic_type   (arithmetic_type),

    .mem_read          (mem_read_request),
    .mem_write         (mem_write_request),
    .mem_byte_enable   (mem_access_mask),

    .reg_write         (reg_write),
    .reg_write_addr    (reg_write_addr),
    .reg_write_source  (reg_write_source),

    .is_branch         (is_branch),
    .pc_data           (pc_data)
  );

  always_comb begin
      if(is_branch)
        next_pc = pc_data;
      else
        next_pc = pc_sum;
  end

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      pc           <= 32'b0;
      gpr          <= '{default:0};
    end

    else begin
      /*
       * Updates a CPU's register based on,
       * data provided from the control unit
       */
      if (mem_read_request || mem_write_request) begin
        assert (mem_aligned)
            else $fatal(1, "Misaligned memory access: 0x%0h", mem_addr);
      end

      // Keep the instruction and its request stable until RAM completes it.
      if (!(mem_read_request || mem_write_request) || mem_ready) begin
        if (reg_write && reg_write_addr != 0 && mem_aligned)
          gpr[reg_write_addr] <= reg_write_data;

        pc <= next_pc;
      end
    end
  end

endmodule: RV32I
