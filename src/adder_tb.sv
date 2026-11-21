module adder_tb();

  logic [31:0] data1, data2, result;
  bit c_out;

  adder u_adder (
    .data1  (data1),
    .data2  (data2),
    .result (result),
    .c_out  (c_out)
  );

  initial begin
    data1 = 0;
    data2 = 0;

    // 5 + 8 = 13
    check_value(5, 8, 13, 0);

    // 5 + -3 = 2
    check_value(5, -3, 2, 1'b1);

    // MAX_32BIT + 1
    check_value(32'hFFFFFFFF, 32'h00000001, 0, 1'b1);

  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  task automatic check_value(
    input logic [31:0] given_data1, given_data2,
    input logic [31:0] expected_result,
    input logic [1:0]  expected_c_out
  );
    data1 = given_data1;
    data2 = given_data2;

    #1;

    $display("testing %0d + %0d", given_data1, given_data2);

    assert(result == expected_result)
        else $fatal(1, "Incorrect results for %0d + %0d, got: 0b%0b expected 0b%0b", given_data1, given_data2, result, expected_result);

    assert(c_out == expected_c_out)
        else $fatal(1, "Incorrect c_out for %0d + %0d, got: 0b%0b expected 0b%0b", given_data1, given_data2, c_out, expected_c_out);

    $display("test for %0d + %0d passed", given_data1, given_data2);

  endtask

endmodule