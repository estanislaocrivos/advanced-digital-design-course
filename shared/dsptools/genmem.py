"""Generate memory initialization files for RTL simulation.

Samples are quantized onto a fixed-point grid with DeFixedInt and written one
hex word per line, which is the format Verilog's $readmemh expects.

Refactored from the course's genmem.py template into reusable functions, so
that each lab supplies its own parameters instead of editing this file.
"""

import numpy as np

from ._fixedInt import DeFixedInt


def quantize(
    values,
    width,
    fract_width,
    signed_mode="S",
    round_mode="trunc",
    saturate_mode="saturate",
):
    """Quantize floats onto an S(width, fract_width) grid.

    Note that DeFixedInt's first argument is the TOTAL word width, sign bit
    included -- not the integer part, despite being named intWidth.

    Returns (quantized_floats, hex_words), where hex_words carry no '0x'
    prefix and are zero padded to ceil(width / 4) nibbles.
    """
    sample = DeFixedInt(
        width,
        fract_width,
        signedMode=signed_mode,
        roundMode=round_mode,
        saturateMode=saturate_mode,
    )

    quantized, words = [], []
    for value in values:
        sample.value = float(value)
        quantized.append(sample.fValue)
        words.append(sample.__hex__().removeprefix("0x"))

    return np.array(quantized), words


def write_mem(path, values, width, fract_width, **kwargs):
    """Write values to `path` as one hex word per line, for $readmemh.

    Returns the quantized samples, so the caller can plot what the RTL will
    actually see rather than the ideal signal.
    """
    quantized, words = quantize(values, width, fract_width, **kwargs)
    with open(path, "w") as handle:
        handle.write("\n".join(words) + "\n")
    return quantized


def two_tone(
    n_samples,
    f_signal,
    f_noise,
    sample_rate,
    signal_amplitude=1.0,
    noise_amplitude=0.5,
):
    """Signal plus a sinusoidal interferer -- the stimulus the labs filter."""
    t = np.arange(n_samples) / sample_rate
    return signal_amplitude * np.sin(2 * np.pi * f_signal * t) + (
        noise_amplitude * np.sin(2 * np.pi * f_noise * t)
    )
