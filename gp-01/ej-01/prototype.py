def step(reg, i_data1, i_data2, i_sel, i_rst_n):
    """Un llamado = un flanco positivo de clock.
    `reg` es el valor ACTUAL del registro (antes de este flanco).
    Devuelve (o_data, o_overflow, next_reg)."""

    i_mux2 = i_data1 & 0x0F
    i_mux1 = (i_data1 & 0x07) + (i_data2 & 0x07) & 0x0F
    i_mux0 = i_data2 & 0x0F

    if i_sel == 0:
        o_mux = i_mux0
    elif i_sel == 1:
        o_mux = i_mux1
    else:
        o_mux = i_mux2

    sum = 0

    if i_rst_n == 0:
        next_reg = 0
        o_overflow = 0
    else:
        sum = ((reg & 0x3F) + o_mux) & 0x7F
        o_overflow = int(bool(sum & 0x40))
        next_reg = sum & 0x3F

    o_data = next_reg
    return o_data, o_overflow, next_reg


if __name__ == "__main__":
    reg = 0
    vectors = [
        # (i_data1, i_data2, i_sel, i_rst_n)
        (0, 0, 0, 0),  # reset held: everything must read 0
        (5, 3, 1, 1),  # sel=1 (suma): mux=5+3=8   -> reg 0+8=8
        (7, 7, 2, 1),  # sel=2 (i_data1): mux=7     -> reg 8+7=15
        (7, 7, 0, 1),  # sel=0 (i_data2): mux=7     -> reg 15+7=22
        (7, 7, 1, 1),  # sel=1 (suma): mux=14       -> reg 22+14=36
        (7, 7, 1, 1),  # sel=1 (suma): mux=14       -> reg 36+14=50
        (
            7,
            7,
            1,
            1,
        ),  # sel=1 (suma): mux=14       -> reg 50+14=64 => overflow, wraps a 0
        (0, 0, 0, 1),  # confirma que quedó en 0 tras el wrap
        (3, 2, 2, 0),  # reset a mitad de secuencia: fuerza todo a 0 de nuevo
        (3, 2, 2, 1),  # post-reset: mux=i_data1=3  -> reg 0+3=3
    ]
    for i_data1, i_data2, i_sel, i_rst_n in vectors:
        o_data, o_overflow, reg = step(reg, i_data1, i_data2, i_sel, i_rst_n)
        print(
            f"d1={i_data1} d2={i_data2} sel={i_sel} rst_n={i_rst_n} -> o_data={o_data} ovf={o_overflow}"
        )
