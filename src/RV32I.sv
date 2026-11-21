module RV32I(
  logic reset
);

  import types_pkg::*;
  import alu_arithmetic_types::*;
  import control_unit_write_source::*;

  /*
   * The RV32I CPU contains 32 GPRS,
   * each being 32 bits wide.
   * plus a PC
   */
  reg clk;

  // 32 registers each 32 bits wide
  logic [31:0] gpr [31:0] = '{default:0};
  logic [31:0] pc = 0, next_pc = 0;

  // Used for data fetching
  reg [31:0] memFetchAddr = 0;
  reg [31:0] memFetchRes;

  ROM #(

  ) u_ROM (
    .addr  (memFetchAddr),
    .result(memFetchRes)
  );

  instruction_fields_t instruction_fields;

  logic [31:0] instruction_data;
  assign instruction_data = memFetchRes;
  
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

  logic pc_write;
  logic [31:0] pc_data;
  logic [31:0] branch_sum, pc_sum;
  
  adder u_branch_adder (
    .data1 (pc),
    .data2 (alu_data2),
    .result(pc_data),
    .c_out ()
  );
  
  adder u_pc_adder (
    .data1 (pc),
    .data2 (4),
    .result(pc_sum),
    .c_out ()
  );

  bit is_branch;

  write_source reg_write_source;
  
  control_unit u_control_unit (
    .instruction_fields(instruction_fields),
    .gpr               (gpr),
    .pc                (pc),

    .alu_data1         (alu_data1),
    .alu_data2         (alu_data2),

    .reg_write         (reg_write),
    .reg_write_addr    (reg_write_addr),
    .reg_write_source  (reg_write_source),

    .is_branch         (is_branch),
    .pc_data           (pc_data)
  );

  initial begin
    clk = 1'b0;
  end

  always #200 clk = ~clk; // 25 MHz

  always_comb begin
      if(is_branch)
        next_pc = branch_sum;
      else
        next_pc = pc_sum;
  end

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      pc           <= 32'b0;
      memFetchAddr <= 32'b0;
      gpr          <= '{default:0};
    end

    else begin
      /*
       * Updates a CPU's register based on,
       * data provided from the control unit
       */
      if (reg_write && reg_write_addr != 0)
        gpr[reg_write_addr] <= alu_result;

      pc <= next_pc;

      // Fetch next instruction
      memFetchAddr <= next_pc;
    end
  end

endmodule: RV32I
