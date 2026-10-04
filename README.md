# Advanced Digital Design Course 2026 💽

Course record for the Advanced Digital Design course from the University of Cordoba, Argentina.

## Setup

### Requirements

- [Verible](https://github.com/chipsalliance/verible/releases) — Verilog/SystemVerilog formatter and linter
- [Python 3](https://www.python.org/downloads/)
- [pre-commit](https://pre-commit.com/)

### Install

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/pip install -e .
.venv/bin/pre-commit install
```

This installs a pre-commit hook that automatically formats `.v` and `.sv` files with `verible-verilog-format` before each commit.

If the formatter modifies any file, the commit is aborted — re-stage and commit again.

## Shared Python helpers

`shared/dsptools/` holds the fixed-point and DSP helpers used across labs.

The editable install above makes it importable from any working directory:

```python
from dsptools import DeFixedInt, write_mem, two_tone, rcosine, resp_freq
```

| Module         | Contents                                                                                    |
| -------------- | ------------------------------------------------------------------------------------------- |
| `_fixedInt.py` | `DeFixedInt`, `arrayFixedInt` — fixed-point types with configurable rounding and saturation |
| `dsp.py`       | `rcosine`, `eyediagram`, `resp_freq` — course DSP helpers                                   |
| `genmem.py`    | `quantize`, `write_mem`, `two_tone` — generate `$readmemh` stimulus files                   |

`_fixedInt.py` is third-party code under the LGPL-2.1 and is **not** covered by
this repository's MIT license. See [`shared/NOTICE`](shared/NOTICE).
