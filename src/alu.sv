module alu(
  // Inputs
  input logic [31:0] data1, data2,
  input arithmetic_types arithmetic_type,

  // Outputs
  output logic [31:0] result
);
  
  import alu_arithmetic_types::*;

  logic [31:0] adder_a, adder_b;
  logic [31:0] adder_result;
  
  adder u_adder (
    .data1 (adder_a),
    .data2 (adder_b),
    .result(adder_result),
    .c_out ()
  );

  always_comb begin
    case (arithmetic_type)
      ADD, SUB:         begin
        adder_a = data1;
        adder_b = arithmetic_type == ADD ? data2 : -data2;

        result <= adder_result;
      end

      AND:              begin result <= data1 &   data2; end
      OR:               begin result <= data1 |   data2; end
      XOR:              begin result <= data1 ^   data2; end
      LOGICAL_LEFT:     begin result <= data1 <<  data2; end
      ARITHMETIC_LEFT:  begin result <= $signed(data1) <<< data2; end
      LOGICAL_RIGHT:    begin result <= data1 >>  data2; end
      ARITHMETIC_RIGHT: begin result <= $signed(data1) >>> data2; end
      EQUAL:            begin result <= data1 ==  data2; end // Should I test for z and x too?
      LESS_THAN:        begin result <= data1 <   data2; end
      default: begin $fatal(1, "ALU unhandled arithmetic type of %0s", arithmetic_type.name()); end
    endcase
  end

endmodule: alu
