/* iCE40HX4K (TQ144) board wrapper around `top`. Everything specific to this
   board's physical I/O lives here; `top.v` itself stays board-agnostic.

   Port mapping:
     i_sw[0] (enable) <- btn1
     i_sw[1] (speed)  <- btn2       (chooses between R2/R3 -- see i_sw[2])
     i_sw[2]          <- tied to 1'b1 (no physical button; keeps only the
                          two slowest thresholds, R2/R3, selectable)
     i_sw[3] (color)  <- btn3
     i_reset          <- btn4

   Buttons are assumed active-high (pressed = 1), matching how they're used
   here as level switches. Verify against the board's actual wiring and add
   an inverter per signal if it turns out to be active-low.

   Only one LED bank (`o_led_b`) is routed to the board's 4 physical LEDs --
   `o_led` and `o_led_g` are intentionally left unconnected rather than
   assigned to guessed "spare" pins, since a wrong pin on a real board can
   collide with a pin wired to something else (flash, config, etc). Wire
   them to the PCF yourself if you confirm which pins are actually free. */

module top_ice40 (
    input clk,
    input btn1,
    input btn2,
    input btn3,
    input btn4,

    output led_green,
    output led_red,
    output led_yellow,
    output led_blue
);

    wire [3:0] i_sw;
    assign i_sw = {btn3, 1'b1, btn2, btn1};

    wire [3:0] o_led;
    wire [3:0] o_led_b;
    wire [3:0] o_led_g;

    top u_top (
        .o_led  (o_led),
        .o_led_b(o_led_b),
        .o_led_g(o_led_g),
        .i_sw   (i_sw),
        .i_reset(btn4),
        .clock  (clk)
    );

    assign led_green  = o_led_b[0];
    assign led_red    = o_led_b[1];
    assign led_yellow = o_led_b[2];
    assign led_blue   = o_led_b[3];

endmodule
