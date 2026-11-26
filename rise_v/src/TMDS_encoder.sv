module TMDS_encoder (
  input  logic       clk,
  input  logic [7:0] VD, // Video data (red, green or blue)
  input  logic [1:0] CD, // Control data
  input  logic       VDE, // Video data enable
  output logic [9:0] TMDS = '0
);

  logic [3:0] Nb1s;
  logic       XNOR;
  logic [8:0] q_m;

  logic [3:0] balance_acc = '0;
  logic [3:0] balance;
  logic       balance_sign_eq;
  logic       invert_q_m;
  logic [3:0] balance_acc_inc;
  logic [3:0] balance_acc_new;

  logic [9:0] TMDS_data;
  logic [9:0] TMDS_code;

  assign Nb1s = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7];
  assign XNOR = (Nb1s > 4'd4) || (Nb1s == 4'd4 && VD[0] == 1'b0);

  always_comb begin
    q_m[0] = VD[0];

    for (int i = 1; i < 8; i++)
      q_m[i] = q_m[i - 1] ^ VD[i] ^ XNOR;

    q_m[8] = ~XNOR;
  end

  assign balance = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4;
  assign balance_sign_eq = balance[3] == balance_acc[3];
  assign invert_q_m = (balance == 0 || balance_acc == 0) ? ~q_m[8] : balance_sign_eq;
  assign balance_acc_inc = balance - ((q_m[8] ^ ~balance_sign_eq) & ~(balance == 0 || balance_acc == 0));
  assign balance_acc_new = invert_q_m ? balance_acc - balance_acc_inc : balance_acc + balance_acc_inc;
  assign TMDS_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};

  always_comb begin
    case (CD)
      2'b00: TMDS_code = 10'b1101010100;
      2'b01: TMDS_code = 10'b0010101011;
      2'b10: TMDS_code = 10'b0101010100;
      2'b11: TMDS_code = 10'b1010101011;
      default: TMDS_code = 10'b1101010100;
    endcase
  end

  always_ff @(posedge clk) begin
    TMDS        <= VDE ? TMDS_data : TMDS_code;
    balance_acc <= VDE ? balance_acc_new : 4'h0;
  end

endmodule : TMDS_encoder
