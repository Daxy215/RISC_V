module RV32I(
  input logic clk,
  input logic reset,

  output logic [31:0] instruction_addr,
  input  logic [31:0] instruction_data,

  output logic [31:0] mem_addr,
  output logic [31:0] mem_write_data,
  input  logic [31:0] mem_read_data,
  output logic        mem_read,
  output logic        mem_write,
  output logic [3:0]   mem_byte_enable
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
  logic [31:0] reg_write_data;

  assign mem_addr = alu_result;
  assign mem_write_data = gpr[instruction_fields.rs2];
  assign mem_read = mem_read_request && !reset;
  assign mem_write = mem_write_request && !reset;
  assign reg_write_data = reg_write_source == MEMORY ? mem_read_data : alu_result;
  
  control_unit u_control_unit (
    .instruction_fields(instruction_fields),
    .gpr               (gpr),
    .pc                (pc),

    .alu_data1         (alu_data1),
    .alu_data2         (alu_data2),
    .arithmetic_type   (arithmetic_type),

    .mem_read          (mem_read_request),
    .mem_write         (mem_write_request),
    .mem_byte_enable   (mem_byte_enable),

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
      if (reg_write && reg_write_addr != 0)
        gpr[reg_write_addr] <= reg_write_data;

      pc <= next_pc;
    end
  end

endmodule: RV32I
