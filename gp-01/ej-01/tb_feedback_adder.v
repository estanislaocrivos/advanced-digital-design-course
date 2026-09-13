module tb_feedback_adder ();

    reg        clock;
    reg        i_reset_n;
    reg  [2:0] i_data1;
    reg  [2:0] i_data2;
    reg  [1:0] i_sel;

    wire       o_overflow;
    wire [5:0] o_data;

    feedback_adder u_feedback_adder (
        .clock     (clock),
        .i_reset_n (i_reset_n),
        .i_data1   (i_data1),
        .i_data2   (i_data2),
        .i_sel     (i_sel),
        .o_overflow(o_overflow),
        .o_data    (o_data)
    );

    always #5 clock = ~clock;

    initial begin
        clock     = 1'b0;
        i_reset_n = 1'b0;
        i_data1   = 3'd0;
        i_data2   = 3'd0;
        i_sel     = 2'b00;

        /* Reset sostenido un par de ciclos, despues liberado */
        #12;
        @(posedge clock);
        i_reset_n = 1'b1;
        #1;
        $display("t=%0t RESET      -> o_data=%0d ovf=%b", $time, o_data,
                 o_overflow);

        /* Caso 1: sel=01 (suma) -- 5+3=8, reg 0+8=8 */
        i_data1 = 3'd5;
        i_data2 = 3'd3;
        i_sel   = 2'b01;
        @(posedge clock);
        #1;
        $display("t=%0t CASO1 sum  -> o_data=%0d ovf=%b (esperado 8, 0)",
                 $time, o_data, o_overflow);

        /* Caso 2: sel=10 (i_data1) -- mux=7, reg 8+7=15 */
        i_data1 = 3'd7;
        i_data2 = 3'd7;
        i_sel   = 2'b10;
        @(posedge clock);
        #1;
        $display("t=%0t CASO2 in1  -> o_data=%0d ovf=%b (esperado 15, 0)",
                 $time, o_data, o_overflow);

        /* Caso 3: sel=01 (suma) repetido para forzar overflow.
           mux=14 cada vez: 15+14=29, 29+14=43, 43+14=57, 57+14=71 (>63 => overflow, reg=71-64=7) */
        i_sel = 2'b01;
        @(posedge clock);
        #1;
        $display("t=%0t CASO3.1    -> o_data=%0d ovf=%b (esperado 29, 0)",
                 $time, o_data, o_overflow);

        @(posedge clock);
        #1;
        $display("t=%0t CASO3.2    -> o_data=%0d ovf=%b (esperado 43, 0)",
                 $time, o_data, o_overflow);

        @(posedge clock);
        #1;
        /* o_overflow es combinacional (reg NUEVO + mux ACTUAL): ya anticipa
           que la proxima suma (57+14=71) desborda, aunque o_data todavia
           muestra el valor recien guardado (57), sin desbordar todavia */
        $display("t=%0t CASO3.3    -> o_data=%0d ovf=%b (esperado 57, 1)",
                 $time, o_data, o_overflow);

        @(posedge clock);
        #1;
        /* aca ya se guardo el valor que desbordo: 57+14=71 -> 71-64=7 */
        $display("t=%0t CASO3.4 OVF-> o_data=%0d ovf=%b (esperado 7, 0)",
                 $time, o_data, o_overflow);

        #10;
        $finish;
    end

endmodule
