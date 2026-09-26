module iir_filter #(
    NB_INPUT  = 8,
    NB_OUTPUT = 12
) (
    input                         clock,
    input                         i_reset_n,
    input  signed [ NB_INPUT-1:0] i_x,
    output signed [NB_OUTPUT-1:0] o_y
);

    logic signed [ NB_INPUT-1:0] x_1;
    logic signed [ NB_INPUT-1:0] x_2;
    logic signed [ NB_INPUT-1:0] x_3;
    logic signed [NB_OUTPUT-1:0] y_1;
    logic signed [NB_OUTPUT-1:0] y_2;
    logic signed [NB_OUTPUT-1:0] y;

    always_comb begin
        y = i_x - x_1 + x_2 + x_3 + (y_1 >>> 1) + (y_2 >>> 2);
    end

    always_ff @(posedge clock or negedge i_reset_n) begin
        if (!i_reset_n) begin
            x_3 <= 0;
            x_2 <= 0;
            x_1 <= 0;
            y_2 <= 0;
            y_1 <= 0;
        end else begin
            x_3 <= x_2;
            x_2 <= x_1;
            x_1 <= i_x;
            y_2 <= y_1;
            y_1 <= y;
        end
    end

    assign o_y = y;

endmodule
