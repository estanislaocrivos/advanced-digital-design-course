# lab-01 on iCE40HX4K (TQ144)

Open-source port of lab-01 (`top.v` + `count.v` + `shiftreg.v`) to the Lattice
iCE40HX4K, via Yosys + nextpnr-ice40 + IceStorm, orchestrated by FuseSoC. See
`top_ice40.v` for the board-specific pin mapping and its tradeoffs.

## Requirements

- [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) (yosys, nextpnr-ice40, icepack, iceprog)
- Python 3 + FuseSoC (`pip install fusesoc`, see `requirements.txt`)

### Installing OSS CAD Suite

Download the release tarball for your platform and extract it anywhere, e.g.:

```bash
tar -xzf oss-cad-suite-linux-x64-*.tgz -C ~/.local
```

Then just add its `bin/` to `PATH`:

```bash
export PATH="$HOME/.local/oss-cad-suite/bin:$PATH"
```

**Don't** `source oss-cad-suite/environment` for this project — it also shadows the
system `python3` with the suite's bundled one, which lacks `ensurepip` and breaks
`scripts/setup.sh`'s `python3 -m venv` step.

## Usage

```bash
./scripts/build.sh   # synthesize + place & route + bitstream -> build/
./scripts/flash.sh   # program the FPGA
rm -rf build          # clean
```

## Toolchain

```text
top_ice40.v -> [yosys] -> netlist.json -> [nextpnr-ice40] -> top.asc -> [icepack] -> top.bin -> [iceprog] -> FPGA
```
