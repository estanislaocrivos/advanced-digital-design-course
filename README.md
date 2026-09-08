# Advanced Digital Design Course 2026

Course record for the Advanced Digital Design course from the University of Cordoba, Argentina.

## Setup

### Requirements

- [Verible](https://github.com/chipsalliance/verible/releases) — Verilog/SystemVerilog formatter and linter
- [Python 3](https://www.python.org/downloads/)
- [pre-commit](https://pre-commit.com/)

### Install

```bash
python3 -m venv .venv
.venv/bin/pip install pre-commit
.venv/bin/pre-commit install
```

This installs a pre-commit hook that automatically formats `.v` and `.sv` files with `verible-verilog-format` before each commit.

If the formatter modifies any file, the commit is aborted — re-stage and commit again.
