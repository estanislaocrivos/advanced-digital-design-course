module shiftreg #(
    parameter NB_LEDS = 4
) (
    output [NB_LEDS-1:0] o_led,

    input i_valid,
    input i_reset,
    input clock
);

    reg [NB_LEDS-1:0] shiftReg;

    /* Move bits left every clock pulse */
    always @(posedge clock) begin
        if (i_reset) begin
            shiftReg <= {{NB_LEDS - 1{1'b0}}, 1'b1};
        end else if (i_valid) begin
            shiftReg <= {shiftReg[NB_LEDS-2:0], shiftReg[NB_LEDS-1]};
        end
    end

    assign o_led = shiftReg;

endmodule
