# SARV A Risc-V
<p align="center">
  <img src="docs/assets/logo.png" alt="SARV32 Core Logo" width="800">
</p>

**SARV** is a 32-bit RISC-V processor implementing the RV32I base ISA together with selected standard extensions including Bit Manipulation (B), Compressed Instructions (C), Zmmul, Zicond, and Zicsr.

The core is written in Verilog HDL and targets FPGA and ASIC implementations. It is designed as a compact embedded processor with a modular RTL architecture.

---

## Documentation
- [CSR & interrupts](docs/csr_interrupts.md#csr-interrupts)
- [Critical Path](docs/critical_path.md#critical-path)
- [Power Control](docs/clock_throttling.md#clock-throttling)
- [Branch Prediction](docs/branch_prediction.md#branch-prediction)

## ISA Support

| Extension | Description | Status |
| :--- | :--- | :--- |
| **RV32I** | Base Integer Instructions | Full |
| **Zmmul** | Integer Multiplication (no division) | Full |
| **Zicond** | Conditional Operations | Full |
| **Zihintpause** | Pause Hint Instruction | Full |

### Compressed Instructions (C)

| Sub-extension | Description | Status |
| :--- | :--- | :--- |
| Zca | Integer Compressed | Full |

### Bit Manipulation (B)

| Sub-extension | Description | Status |
| :--- | :--- | :--- |
| Zba | Address Generation | Full |
| Zbb | Basic Bit-Manipulation | Full |
| Zbs | Single-Bit Operations | Full |

### Control & Status

| Extension | Description | Status |
| :--- | :--- | :--- |
| **Zicsr** | Control Status Registers | Full |
| **Zihpm** | Hardware Performance Monitors | Full |

### Interrupts

| Type | Description | Status |
| :--- | :--- | :--- |
| MEI | Machine External Interrupt | Supported |
| MTI | Machine Timer Interrupt | Supported |
| MSI | Machine Software Interrupt | Supported |

### Power Management

| Feature | Description | Status |
| :--- | :--- | :--- |
| **WFI** | Wait for Interrupt — halts core until IRQ | Supported |

---


##  CoreMark Performance

| Metric | Value |
| :--- | :--- |
| CoreMark | 1448.624531 |
| Frequency | 500 MHz (simulated) |
| CoreMark/MHz | 2.897 |
| Simulation | Gate-level, ideal memory |
| Flags      | -march=rv32ib_zicond_zmmul_zicsr -mabi=ilp32 -O3 |

*Measured in gate-level simulation without cache/memory latency. Provides architectural comparison point.*
*The design under test uses a Branch Target Buffer (BTB) with 4 entries (BRANCH_PREDICTION_ENTRY_INDEX_BITS = 2) and a Return Address Stack (RAS) with 2 entries (RETURN_ADDRESS_PREDICTION_ENTRY_INDEX_BITS = 1).*


## Verification

| Test Suite | Status |
| :--- | :--- |
| CoreMark | Pass |
| Custom tests |  In progress |


## Synthesis Results

### Technology: Nangate 45nm Open Cell Library

| Metric | Value |
| :--- | :--- |
| **Total Area** | 33.428 µm² |
| **Cell Count** | 23,840 |
| **KGE** | 12.56 kGE |
| **Flip-Flops (DFFR/DFFS)** | 2,486 |
| **Synthesis Tool** | Yosys |
|**Post-synthesis estimated Fmax** | 550 MHz |

## Architecture

The figure below shows the top level organization of the SARV core. Detailed down to wire and module documentation are available in the `docs/` directory.

<p align="center">
  <img src="docs/assets/schematicBigPicture.svg"
       alt="SARV Architecture"
       width="900">
</p>