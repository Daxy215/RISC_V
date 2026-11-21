module mux1(
  // Inputs
  input logic [1:0] select,
  input logic [3:0] d,

  // Outputs
  output logic q
);

  assing q = d[select];

endmodule: mux1

module mux2(
  // Inputs
  input logic [1:0] select,
  input logic [3:0] d,

  // Outputs
  output logic q
);

  always @(d or select) begin
    q = d[select];
  end

endmodule: mux2

module mux3(
  // Inputs
  input logic [1:0] select,
  input logic [3:0] d,

  // Outputs
  output logic q
);

  always @(*) begin
    if (select == 0) begin
      q = d[0];
    end

    if (select == 1) begin
      q = d[1];
    end

    if (select == 2) begin
      q = d[2];
    end

    if (select == 3) begin
      q = d[3];
    end
  end

endmodule: mux3
