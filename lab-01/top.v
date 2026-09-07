module top #(
    parameter NB_LEDS    = 4,
    parameter NB_SW      = 4,
    parameter NB_COUNTER = 32
) (
    o_sum,
    o_c,
    i_a,
    i_b,
    i_c
);

    output [3:0] o_led;
    output [3:0] o_led_b;
    output [3:0] o_led_g;

    input [3:0] i_sw;
    input i_reset;
    input clock;

    wire               connect_valid;
    wire [NB_LEDS-1:0] connect_leds;

    count #(
        .NB_SW     (NB_SW - 1),
        .NB_COUNTER(NB_COUNTER)
    ) u_count (
        .o_valid(),
        .i_sw   (i_sw[NB_SW-1:0]),
        .i_reset(i_reset),
        .clock  (clock)
    );

    shiftreg #(
        .NB_LEDS(NB_LEDS)
    ) u_shiftreg (
        .o_led  (),
        .i_valid(),
        .i_reset(i_reset),
        .clock  (clock)
    );

    assign o_led   = connect_leds;
    assign o_led_b = (i_sw[3]) ? connect_leds : 4'b0000;
    assign o_led_g = (i_sw[3]) ? 4'b0000 : connect_leds;

endmodule
