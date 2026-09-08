module tb_top ();

    parameter NB_LEDS = 4;
    parameter NB_SW = 4;
    parameter NB_COUNTER = 32;

    output [NB_LEDS-1:0] o_led;
    output [NB_LEDS-1:0] o_led_b;
    output [NB_LEDS-1:0] o_led_g;

    input [NB_SW-1:0] i_sw;
    input i_reset;
    input clock;

    wire [NB_LEDS-1:0] o_led;
    wire [NB_LEDS-1:0] o_led_b;
    wire [NB_LEDS-1:0] o_led_g;

    reg  [  NB_SW-1:0] i_sw;
    reg                i_reset;
    reg                clock;

    initial begin
        clock   = 1'b0;
        i_sw    = 4'b0000;
        i_reset = 1'b0;

        #50;
        @(posedge clock);
        i_reset = 1'b1;

        #50;
        @(posedge clock);
        i_sw = 4'b0001;

        #10000;
        @(posedge clock);
        i_sw = 4'b0011;

        #10000;
        @(posedge clock);
        i_sw = 4'b0100;

        #10000;
        @(posedge clock);
        i_sw = 4'b0101;

        #10000;
        @(posedge clock);
        i_sw = 4'b0110;

        #10000;
        @(posedge clock);
        i_sw = 4'b0111;

        #10000;
        @(posedge clock);
        i_sw = 4'b1000;

        #10000;
        @(posedge clock);
        i_sw = 4'b1001;

        #10000;
        @(posedge clock);
        i_sw = 4'b1010;

        #10000;
        @(posedge clock);
        i_sw = 4'b1011;

        #10000;
        @(posedge clock);
        i_sw = 4'b1100;

        #10000;
        @(posedge clock);
        i_sw = 4'b1101;

        #10000;
        @(posedge clock);
        i_sw = 4'b1110;

        #10000;
        @(posedge clock);
        i_sw = 4'b1111;
    end

    always #5 clock = ~clock;

    top #(
        .NB_LEDS   (NB_LEDS),
        .NB_SW     (NB_SW),
        .NB_COUNTER(NB_COUNTER)
    ) utop (
        .o_led  (),
        .o_led_b(),
        .o_led_g(),
        .i_sw   (),
        .i_reset(),
        .clock  ()
    );

endmodule
