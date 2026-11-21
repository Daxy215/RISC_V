import alu_arithmetic_types::*;

module alu_tb;

  logic [31:0] data1, data2, result;

  arithmetic_types arithmetic_type;

  alu u_alu (
    .data1          (data1),
    .data2          (data2),
    .arithmetic_type(arithmetic_type),
    .result         (result)
  );

  initial begin
    data1 = 0;
    data2 = 0;

    // 1 + 2 = 3
    check_results(1, 2, ADD, 3);

    // 5 - 3 = 2
    check_results(5, 3, SUB, 2);

    // 12 & 10 = 8
    check_results(12, 10, AND, 8);

    // 12 | 10 = 14
    check_results(12, 10, OR, 14);

    // 12 ^ 10 = 6
    check_results(12, 10, XOR, 6);

    // 4 << 2 = 16
    check_results(4, 2, LOGICAL_LEFT, 16);

    // 4 <<< 2 = 16
    check_results(4, 2, ARITHMETIC_LEFT, 16);

    // -16 <<< 2 = -64
    check_results(32'hFFFFFFF0, 2, ARITHMETIC_LEFT, 32'hFFFFFFC0);

    // 16 >> 2 = 4
    check_results(16, 2, LOGICAL_RIGHT, 4);

    // -16 >> 2 = 1073741820 (zero-fill)
    check_results(32'hFFFFFFF0, 2, LOGICAL_RIGHT, 32'h3FFFFFFC);

    // 16 >>> 2 = 4
    check_results(16, 2, ARITHMETIC_RIGHT, 4);

    // -16 >>> 2 = -4 (sign extension)
    check_results(32'hFFFFFFF0, 2, ARITHMETIC_RIGHT, 32'hFFFFFFFC);

    // 5 == 5 = 1
    check_results(5, 5, EQUAL, 1);

    // 5 == 6 = 0
    check_results(5, 6, EQUAL, 0);

    // 3 < 5 = 1
    check_results(3, 5, LESS_THAN, 1);

    // 5 < 3 = 0
    check_results(5, 3, LESS_THAN, 0);

    // -3 < 5 = 1
    check_results(32'hFFFFFFFD, 5, SIGNED_LESS_THAN, 1);

    // 5 < -3 = 0
    check_results(5, 32'hFFFFFFFD, SIGNED_LESS_THAN, 0);

    // 3 < 5 = 1
    check_results(3, 5, SIGNED_LESS_THAN, 1);

    // 5 < 3 = 0
    check_results(5, 3, SIGNED_LESS_THAN, 0);

    // 5 < 5 = 0
    check_results(5, 5, SIGNED_LESS_THAN, 0);

    // -5 < -3 = 1
    check_results(32'hFFFFFFFB, 32'hFFFFFFFD, SIGNED_LESS_THAN, 1);

    // -3 < -5 = 0
    check_results(32'hFFFFFFFD, 32'hFFFFFFFB, SIGNED_LESS_THAN, 0);

    // -3 < -3 = 0
    check_results(32'hFFFFFFFD, 32'hFFFFFFFD, SIGNED_LESS_THAN, 0);

    // 0 < 0 = 0
    check_results(0, 0, SIGNED_LESS_THAN, 0);

    // -1 < 0 = 1
    check_results(32'hFFFFFFFF, 0, SIGNED_LESS_THAN, 1);

    // 0 < -1 = 0
    check_results(0, 32'hFFFFFFFF, SIGNED_LESS_THAN, 0);

    // -2147483648 < 2147483647 = 1
    check_results(32'h80000000, 32'h7FFFFFFF, SIGNED_LESS_THAN, 1);

    // 2147483647 < -2147483648 = 0
    check_results(32'h7FFFFFFF, 32'h80000000, SIGNED_LESS_THAN, 0);

    // -2147483648 < -2147483648 = 0
    check_results(32'h80000000, 32'h80000000, SIGNED_LESS_THAN, 0);

    // 2147483647 < 2147483647 = 0
    check_results(32'h7FFFFFFF, 32'h7FFFFFFF, SIGNED_LESS_THAN, 0);

    // 3 < 5 = 1
    //check_results(3, 5, UNSIGNED_LESS_THAN, 1);

  end

  task automatic check_results(
      logic [31:0]     given_data1,
      logic [31:0]     given_data2,
      arithmetic_types given_arithmetic_type,
      logic [31:0]     expected_result
  );

    data1           = given_data1;
    data2           = given_data2;
    arithmetic_type = given_arithmetic_type;

    #1;

    $display("testing arithmetic %0s", arithmetic_type.name());

    assert (result == expected_result)
        else $fatal(1, "Incorrect result for (%0s): 0b%0b expected: 0b%0b", arithmetic_type.name(), result, expected_result);

    $display("arithmetic %0s passed", arithmetic_type.name());

  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule
