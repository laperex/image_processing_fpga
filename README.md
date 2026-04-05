# image_processing_fpga

FPGA-accelerated image processing pipeline on the PYNQ-Z2 (Zynq xc7z020), built for real-time object detection via color segmentation. Implements two custom AXI-Stream IPs — RGB→HSV color space conversion and HSV range masking — wired together in a Vivado Block Design and driven by the ARM PS over AXI DMA.

---

## Pipeline Overview

```
DDR (RGB frame)
     │
     ▼
 AXI DMA (MM2S)
     │  AXI-Stream (64-bit, 2 pixels/cycle)
     ▼
 FIFO (axis_data_fifo_1)
     │
     ▼
 ip_rgb_to_hsv       <- converts 2 RGB pixels/cycle to HSV
     │
     ▼
 ip_inrange          <- masks pixels within a configurable HSV range
     │                   range set via AXI-Lite from PS
     ▼
 FIFO (axis_data_fifo_0)
     │
     ▼
 AXI DMA (S2MM)
     │
     ▼
DDR (mask frame)
```

The PS reads/writes DDR frame buffers and configures the HSV threshold range. The PL pipeline processes 2 pixels per clock cycle at 100 MHz.

---

## Custom IPs

### `ip_rgb_to_hsv`

Converts packed RGB pixels to HSV color space using a fully pipelined, division-free architecture.

- **Throughput:** 2 pixels/cycle (packed in 64-bit AXI-Stream word)
- **Latency:** 5 pipeline stages
- **Division:** avoided via pre-computed reciprocal LUTs (`inv_rom_cmax`, `inv_rom_delta`) with 16-bit fixed-point precision
- **Interface:** AXI-Stream slave + AXI-Stream master
- **No backpressure** (tready passthrough); upstream must gate via FIFOs

**Pipeline stages:**

| Stage | Operation |
|-------|-----------|
| s0 | Compute cmax, cmin |
| s1 | Compute delta; LUT lookup for 1/cmax |
| s2 | Compute S = delta/cmax; LUT lookup for 1/delta |
| s3 | Compute raw H based on dominant channel |
| s4 | Scale H to [0, 180] (OpenCV convention) |

### `ip_inrange`

Compares HSV pixels against a lower/upper bound and outputs a binary mask. Bounds are set at runtime by the PS over AXI-Lite.

- **Throughput:** 2 pixels/cycle
- **Latency:** 1 clock cycle
- **Interface:** AXI-Stream slave + AXI-Stream master + AXI-Lite slave
- **Register map:**

| Offset | Field | Description |
|--------|-------|-------------|
| `0x00` | lower | `[7:0]` H, `[15:8]` S, `[23:16]` V lower bounds |
| `0x04` | upper | `[7:0]` H, `[15:8]` S, `[23:16]` V upper bounds |

Output pixels are `0xFFFFFFFF` (white) where the mask is true, `0x000000FF` (black, alpha=255) otherwise.

---

## Block Design — `bd_image_processing`

| IP | Role |
|----|------|
| `processing_system7_0` | Zynq PS — runs Linux, drives DMA and IP config |
| `axi_dma_0` | Scatter-gather-less DMA, 64-bit MM2S + S2MM |
| `axi_mem_intercon` | Memory interconnect to HP0 and HP2 slave ports |
| `ps7_0_axi_periph` | Peripheral interconnect for AXI-Lite control |
| `rst_ps7_0_100M` | Synchronous reset generator |
| `axis_data_fifo_0/1` | Input/output stream buffering |
| `ip_rgb_to_hsv_0` | RGB→HSV conversion IP |
| `ip_inrange_0` | HSV range mask IP |

**Address map (PS Data space):**

| Peripheral | Base Address | Range |
|------------|-------------|-------|
| AXI DMA | `0x4040_0000` | 64 KB |
| ip_inrange (AXI-Lite) | `0x6000_0000` | 512 MB* |

*The large range is a Vivado auto-assign artifact; effective register space is 2 words (8 bytes).

---

## Project Structure

```
.
├── srcs/
│   └── rtl/
│       ├── axi_types.sv          # AXI interface definitions
│       ├── axi_lite_slave.sv     # Generic AXI-Lite slave logic
│       ├── cv_types.sv           # Packed struct types: pkt_rgb, pkt_hsv
│       ├── cv_rgb_to_hsv.sv      # Pipelined RGB→HSV core
│       ├── cv_inrange.sv         # Single-pixel HSV range comparator
│       ├── ip_rgb_to_hsv.sv      # 2-pixel-wide AXI-Stream wrapper
│       ├── ip_inrange.sv         # 2-pixel-wide AXI-Stream + AXI-Lite wrapper
│       └── wrapper/              # Auto-generated IP top wrappers (xviv_wrap_top)
├── scripts/
│   ├── bd/
│   │   ├── bd_image_processing.tcl       # Exported BD TCL
│   │   └── bd_image_processing_1.0.tcl   # BD hook (sourced before BD creation)
│   └── synth/
│       └── bd_image_processing_wrapper.tcl  # Synthesis hook
├── build/                        # Generated outputs (gitignored)
│   ├── ip/                       # Packaged custom IPs
│   └── bd/                       # Block design outputs
├── project.toml                  # xviv project configuration
└── run.sh                        # Full build script
```

---

## Dependencies

- **Vivado 2024.1** (`xc7z020clg400-1` / PYNQ-Z2)
- **[xviv](https://github.com/laperex/xviv)** — project controller; a Python CLI that drives Vivado in batch mode for IP packaging, block design generation, and synthesis without a GUI. All build stages in this project are orchestrated through `xviv` and configured via `project.toml`.
- Python 3.14+ with `xviv` installed in a virtualenv

---

## Build

```bash
# Create and activate virtualenv (first time)
python -m venv .venv
source .venv/bin/activate
pip install xviv

# Full build
source run.sh
```

`run.sh` runs the following stages in order:

```bash
# Generate IP wrapper port maps
xviv_wrap_top -t ip_rgb_to_hsv ./srcs/rtl/{axi_types,ip_rgb_to_hsv}.sv -o ./srcs/rtl/wrapper
xviv_wrap_top -t ip_inrange    ./srcs/rtl/{axi_types,ip_inrange}.sv    -o ./srcs/rtl/wrapper

# Package custom IPs into the IP repository
xviv create-ip --ip ip_rgb_to_hsv
xviv create-ip --ip ip_inrange

# Create and generate block design
xviv create-bd   --bd bd_image_processing
xviv generate-bd --bd bd_image_processing

# Synthesize (place & route and bitstream follow)
xviv synthesis --top bd_image_processing_wrapper
```

---

## Target Hardware

**PYNQ-Z2** (TUL) — Xilinx Zynq-7020 SoC

- Dual-core ARM Cortex-A9 @ 650 MHz
- 512 MB DDR3
- FPGA fabric clocked at 100 MHz (FCLK0)
- DMA uses HP0 and HP2 high-performance AXI slave ports (64-bit, 256 MB each)

---

## Known Issues / Limitations

- **`u_cv_inrange_1` tvalid/tlast** are left unconnected; the second pixel lane's handshake signals are commented out.
- **No backpressure** on `ip_rgb_to_hsv` — the pipeline will drop pixels if downstream is not ready. The FIFOs absorb burst mismatches but sustained stalls will cause data loss.
- **HSV range address space** is reported as 512 MB by Vivado's auto-assign; this is harmless but can be tightened by constraining the segment range in the BD TCL to `0x8` (2 registers × 4 bytes).
