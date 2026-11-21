module nor_gate(
  // Inputs
  input a, b,

  // Outputs
  output y
);

  wire    c;
  supply0 gnd;
  supply1 vdd;

  // pmos/nmos (out, data, control);
  pmos p1(c, vdd, a);
  pmos p2(y, c  , b);
  nmos n1(y, gnd, a);
  nmos n2(y, gnd, b);

endmodule: nor_gate

// OR

module nor_gate2(
  // Inputs
  input logic a, b,

  // Outputs
  output logic y
);

  assign y = ~(a | b);

endmodule: nor_gate2
