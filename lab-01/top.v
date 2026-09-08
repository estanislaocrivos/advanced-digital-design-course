module top #(
    parameter NB_LEDS    = 4,
    parameter NB_SW      = 4,
    parameter NB_COUNTER = 32
) (
    output [NB_LEDS-1:0] o_led,
    output [NB_LEDS-1:0] o_led_b,
    output [NB_LEDS-1:0] o_led_g,

    input [NB_SW-1:0] i_sw,
    input             i_reset,
    input             clock
);

    /* Local registers or wires */
    wire               connect_valid;
    wire [NB_LEDS-1:0] connect_leds;

    count #(
        .NB_SW     (NB_SW - 1),
        .NB_COUNTER(NB_COUNTER)
    ) u_count (
        .o_valid(connect_valid),
        .i_sw   (i_sw[NB_SW-1:0]),
        .i_reset(~i_reset),
        .clock  (clock)
    );

    shiftreg #(
        .NB_LEDS(NB_LEDS)
    ) u_shiftreg (
        .o_led  (connect_leds),
        .i_valid(connect_valid),
        .i_reset(~i_reset),
        .clock  (clock)
    );

    /* Assign outputs. i_sw[3] bit selects the blue or green LEDs */
    assign o_led   = connect_leds;
    assign o_led_b = (i_sw[3]) ? connect_leds : {NB_LEDS{1'b0}};
    assign o_led_g = (i_sw[3]) ? {NB_LEDS{1'b0}} : connect_leds;

endmodule
