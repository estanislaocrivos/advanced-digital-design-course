module feedback_adder (
    input       clock,
    input       i_reset_n,
    input [2:0] i_data1,
    input [2:0] i_data2,
    input [1:0] i_sel,

    output       o_overflow,
    output [5:0] o_data
);

    wire [3:0] w_i_mux0;
    wire [3:0] w_i_mux1;
    wire [3:0] w_i_mux2;
    wire [3:0] w_o_mux1;
    wire [6:0] w_sum;
    wire       w_overflow;

    reg  [6:0] r_register;

    /* MUX + first adder */
    assign w_i_mux0 = i_data2;
    assign w_i_mux1 = i_data1 + i_data2;
    assign w_i_mux2 = i_data1;
    assign w_o_mux1 = (i_sel == 2'b00) ? w_i_mux0 : (i_sel == 2'b01) ?
        w_i_mux1 : (i_sel == 2'b10) ? w_i_mux2 : w_i_mux2;

    /* Second adder */
    assign w_sum = r_register + w_o_mux1;
    assign w_overflow = w_sum[6];

    /* Syncronous register handling. Reset signal is asyncronous */
    always @(posedge clock or negedge i_reset_n) begin
        if (~i_reset_n) r_register <= 6'b0;
        else r_register <= w_sum[5:0];
    end

    assign o_overflow = w_overflow;
    assign o_data     = r_register;

endmodule
