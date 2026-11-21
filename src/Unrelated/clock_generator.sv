// -------------------------------------------------------------------
// @author daxy
// @copyright (C) 2026
//
// Created : 17. Nov 2026 2:58
//
// Note: This will only be used in a simulation
//
//-------------------------------------------------------------------

timeunit 1ns;
timeprecision 1ps;

module clock_generator (
  input logic reset,

  output logic clk
);

  initial clk = 0;

  // 5ns HIGH
  // 5ns LOW
  // Therefore, T = 10ns
  // To nanoseconds to seconds: T = 10 * 10^-9 = 1e-8 s
  // Frequency becomes: f = ((1) / (T)) -> 100000000
  //always #5 clk = ~clk; // Toggle clock every 5 ns for 100 MHz

  // f(MHz) = 500 / 20 = 25 MHz
  always begin
    if(reset)
      clk = 0;
    else
      clk = ~clk;

    #20; // 25 MHz clock (My FPGA is slow)
  end

endmodule : clock_generator
