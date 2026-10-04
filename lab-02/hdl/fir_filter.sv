module fir_filter #(
    parameter int WW_INPUT  = 8,  //! Input word width
    parameter int WW_OUTPUT = 8   //! Output word width
) (
    input                         clk,     //! Clock
    input                         i_en,    //! Enable; holds the state when low
    input                         i_srst,  //! Synchronous reset, active high
    input  signed [ WW_INPUT-1:0] i_data,  //! Input sample, S(8,6)
    output signed [WW_OUTPUT-1:0] o_data   //! Output sample, S(8,6)
);

    localparam int WW_COEFF = 8;
    localparam int N_TAPS   = 15;
    localparam int WW_PROD  = WW_INPUT + WW_COEFF;  //! S(16,12)

    //! Coefficients quantized to S(8,6). h[k] = COEFF[k] / 64.
    //  k :   0     1     2     3     4     5     6     7     8     9    10    11    12    13    14
    //  h : 0.000 0.000 -.016 -.031 0.000 0.109 0.266 0.328 0.266 0.109 0.000 -.031 -.016 0.000 0.000
    //! A wire array rather than an unpacked localparam: iverilog does not
    //! support unpacked array parameters, and this form synthesizes identically.
    wire signed [WW_COEFF-1:0] coeff[N_TAPS-1:0];

    assign coeff[0]  = 8'h00;
    assign coeff[1]  = 8'h00;
    assign coeff[2]  = 8'hFF;
    assign coeff[3]  = 8'hFE;
    assign coeff[4]  = 8'h00;
    assign coeff[5]  = 8'h07;
    assign coeff[6]  = 8'h11;
    assign coeff[7]  = 8'h15;
    assign coeff[8]  = 8'h11;
    assign coeff[9]  = 8'h07;
    assign coeff[10] = 8'h00;
    assign coeff[11] = 8'hFE;
    assign coeff[12] = 8'hFF;
    assign coeff[13] = 8'h00;
    assign coeff[14] = 8'h00;

    //! Internal signals
    reg signed [WW_INPUT-1:0] register[N_TAPS-1:1];  //! Tapped delay line
    wire signed [WW_PROD-1:0] prod[N_TAPS-1:0];  //! Partial products
    reg signed [WW_PROD-1:0] prod_d[N_TAPS-1:0];  //! Registered products

    wire signed [WW_PROD : 0] sum[8:1];  //! Tree level 1, S(17,12)
    reg signed [WW_PROD : 0] sum_d[8:1];
    wire signed [WW_PROD+1:0] sum1[4:1];  //! Tree level 2, S(18,12)
    wire signed [WW_PROD+2:0] sum2[2:1];  //! Tree level 3, S(19,12)
    wire signed [WW_PROD+3:0] sum3;  //! Tree level 4, S(20,12)
    reg signed [WW_PROD+3:0] sum3_d;

    /*------- Shift register ----------*/
    integer tap;
    always @(posedge clk) begin : shift_register
        if (i_srst) begin
            for (tap = 1; tap < N_TAPS; tap = tap + 1) register[tap] <= '0;
        end else if (i_en) begin
            register[1] <= i_data;
            for (tap = 2; tap < N_TAPS; tap = tap + 1)
            register[tap] <= register[tap-1];
        end
    end

    /*------- Products ----------*/
    //! Tap 0 multiplies the live input; the rest multiply the delay line.
    assign prod[0] = coeff[0] * i_data;
    generate
        genvar k;
        for (k = 1; k < N_TAPS; k = k + 1) begin : gen_products
            assign prod[k] = coeff[k] * register[k];
        end
    endgenerate

    integer p;
    always @(posedge clk) begin : product_pipeline
        for (p = 0; p < N_TAPS; p = p + 1) prod_d[p] <= prod[p];
    end

    /*------- Adder tree ----------*/
    //! Level 1: 15 products -> 8 partial sums. S(16,12) + S(16,12) = S(17,12).
    //! The odd one out is sign extended so every node of a level has one width.
    assign sum[1] = prod_d[0] + prod_d[1];
    assign sum[2] = prod_d[2] + prod_d[3];
    assign sum[3] = prod_d[4] + prod_d[5];
    assign sum[4] = prod_d[6] + prod_d[7];
    assign sum[5] = prod_d[8] + prod_d[9];
    assign sum[6] = prod_d[10] + prod_d[11];
    assign sum[7] = prod_d[12] + prod_d[13];
    assign sum[8] = {prod_d[14][WW_PROD-1], prod_d[14]};

    integer s;
    always @(posedge clk) begin : sum_pipeline
        for (s = 1; s <= 8; s = s + 1) sum_d[s] <= sum[s];
    end

    //! Level 2: S(17,12) + S(17,12) = S(18,12)
    assign sum1[1] = sum_d[1] + sum_d[2];
    assign sum1[2] = sum_d[3] + sum_d[4];
    assign sum1[3] = sum_d[5] + sum_d[6];
    assign sum1[4] = sum_d[7] + sum_d[8];

    //! Level 3: S(18,12) + S(18,12) = S(19,12)
    assign sum2[1] = sum1[1] + sum1[2];
    assign sum2[2] = sum1[3] + sum1[4];

    //! Level 4: S(19,12) + S(19,12) = S(20,12)
    assign sum3    = sum2[1] + sum2[2];

    always @(posedge clk) begin : output_pipeline
        sum3_d <= sum3;
    end

    /*------- Saturate and truncate back to the output format ----------*/
    sat_trunc #(
        .NB_XI (WW_PROD + 4),
        .NBF_XI(12),
        .NB_XO (WW_OUTPUT),
        .NBF_XO(6)
    ) u_sat_trunc (
        .i_data(sum3_d),
        .o_data(o_data)
    );

endmodule
