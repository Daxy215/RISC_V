module GPU (
    input  logic clk,
    input  logic rst,

    output logic [2:0] TMDSp,
    output logic [2:0] TMDSn,

    output logic TMDSp_clock,
    output logic TMDSn_clock
);

    // Clock generation
    logic clk_TMDS;
    logic pixclk;
    logic pll_locked;
    logic reset;

    assign reset = rst || !pll_locked;

    Gowin_rPLL u_pll (
        .clkin  (clk),
        .clkout (clk_TMDS),
        .lock   (pll_locked)
    );

    CLKDIV #(
        .DIV_MODE("5"),
        .GSREN("false")
    ) u_clkdiv (
        .HCLKIN (clk_TMDS),
        .RESETN (!reset),
        .CLKOUT (pixclk),
        .CALIB  (1'b0)
    );

    // Video timing (1280x720 @ 60Hz)
    logic [10:0] counter_x;
    logic [9:0] counter_y;
    logic hsync, vsync, draw_area;

    always_ff @(posedge pixclk or posedge reset) begin
        if (reset) begin
            counter_x <= '0;
            counter_y <= '0;
        end

        else if (counter_x == 11'd1649) begin
            counter_x <= '0;

            if (counter_y == 10'd749) begin
                counter_y <= '0;
            end
            else
                counter_y <= counter_y + 10'd1;
        end

        else begin
            counter_x <= counter_x + 11'd1;
        end
    end

    always_comb begin
        draw_area = (counter_x < 1280) && (counter_y < 720);
        hsync = (counter_x >= 1390) && (counter_x < 1430);
        vsync = (counter_y >= 725) && (counter_y < 730);
    end

    // Pixel generation
    logic [7:0] red, green, blue;
    logic [10:0] x = 500, y = 400;

    always_comb begin
        red   = 8'h00;
        green = 8'h00;
        blue  = 8'h00;

        if (counter_x >= (x) && counter_x < (x + 300) && counter_y >= (y) && counter_y < (y + 300)) begin
            red = 8'hFF;
            blue = 8'hFF;
        end
    end

    // TMDS encoding
    logic [9:0] tmds_data [2:0];

    TMDS_encoder u_encode_red (
        .clk  (pixclk),
        .VD   (red),
        .CD   (2'b00),
        .VDE  (draw_area),
        .TMDS (tmds_data[2])
    );

    TMDS_encoder u_encode_green (
        .clk  (pixclk),
        .VD   (green),
        .CD   (2'b00),
        .VDE  (draw_area),
        .TMDS (tmds_data[1])
    );

    TMDS_encoder u_encode_blue (
        .clk  (pixclk),
        .VD   (blue),
        .CD   ({vsync, hsync}),
        .VDE  (draw_area),
        .TMDS (tmds_data[0])
    );

    // Hardware serialization
    logic [2:0] serial_data;

    for (genvar i = 0; i < 3; i++) begin : g_tmds
        OSER10 u_serializer (
            .D0    (tmds_data[i][0]),
            .D1    (tmds_data[i][1]),
            .D2    (tmds_data[i][2]),
            .D3    (tmds_data[i][3]),
            .D4    (tmds_data[i][4]),
            .D5    (tmds_data[i][5]),
            .D6    (tmds_data[i][6]),
            .D7    (tmds_data[i][7]),
            .D8    (tmds_data[i][8]),
            .D9    (tmds_data[i][9]),

            .PCLK  (pixclk),
            .FCLK  (clk_TMDS),
            .RESET (reset),
            .Q     (serial_data[i])
        );

        TLVDS_OBUF u_output (
            .I  (serial_data[i]),
            .O  (TMDSp[i]),
            .OB (TMDSn[i])
        );
    end

    // Differential HDMI clock
    TLVDS_OBUF u_clock_output (
        .I  (pixclk),
        .O  (TMDSp_clock),
        .OB (TMDSn_clock)
    );

endmodule : GPU
