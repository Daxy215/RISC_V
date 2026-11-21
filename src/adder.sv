module adder(
  input logic[31:0] data1, data2,

  output logic [31:0] result,
  output bit c_out
);

  logic [32:0] sum;

  always_comb begin
    sum = data1 + data2;

    result = sum[31:0];
    c_out = sum[32];
  end

endmodule: adder
