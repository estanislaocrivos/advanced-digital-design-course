module count #(
    /* Parameters with defaults that can be overriden from the outside */
    parameter NB_SW      = 3,
    parameter NB_COUNTER = 32
) (
    /* Define module's outputs and inputs here */
    output o_valid,

    /* N-bits I/O are defined using the range MSB:LSB */
    input [NB_SW-1:0] i_sw,
    input             i_reset,
    input             clock
);

    /* Internal constants that cannot be modified from outside */
    localparam R0 = (2 ** (NB_COUNTER - 10)) - 1;
    localparam R1 = (2 ** (NB_COUNTER - 9)) - 1;
    localparam R2 = (2 ** (NB_COUNTER - 8)) - 1;
    localparam R3 = (2 ** (NB_COUNTER - 7)) - 1;

    /* Wires are static linkages which connect one or multiple bits statically. Are usually used for combinational logic or for connecting modules */
    wire [NB_COUNTER-1:0] limit_sh;

    /* Registers can store values and can be assigned a value inside posedge expressions */
    reg  [NB_COUNTER-1:0] counter;
    reg                   valid;

    /* MUX allows the selection of each R constant as the counter limit */
    /* A constant can be defined as <width>'<type><value> (2'0hAA or 4'b0000) */
    assign limit_sh = (i_sw[2:1] == 2'b00) ?
        R0 : (i_sw[2:1] == 2'b01) ? R1 : (i_sw[2:1] == 2'b10) ? R2 : R3;

    /* Increment counter up to limit and reset */
    always @(posedge clock) begin
        /* Inside this block you can put sequential logic that changes with every clock pulse */
        if (i_reset) begin
            counter <= {NB_COUNTER{1'b0}};
            valid   <= 1'b0;
        end else if (i_sw[0]) begin
            if (counter >= limit_sh) begin
                /* Repetition syntax consists on <factor>{<constant>} */
                counter <= {NB_COUNTER{1'b0}};
                /* Assignments inside posedge expressions are non-blocking using <= which assigns the value under clock action */
                valid   <= 1'b1;
            end else begin
                counter <= counter + 1;
                valid   <= 1'b0;
            end
        end else begin
            counter <= counter;
            valid   <= valid;
        end
    end

    /* Here you assign inputs and outputs of the module's interface to the signals inside it */
    assign o_valid = valid;

endmodule
