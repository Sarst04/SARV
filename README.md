# SARV A Risc-V
<p align="center">
  <img src="docs/assets/logo.png" alt="SARV32 Core Logo" width="800">
</p>

**SARV** is a 32-bit RISC-V core implementation supporting the RV32I base integer instruction set with multiple extensions. Designed for embedded systems.

---

## ✅ ISA Support

| Extension | Description | Status |
| :--- | :--- | :--- |
| **RV32I** | Base Integer Instructions |  Full |
| **Zmmul** | Integer Multiplication (no division) |  Full |
| **Zicond** | Conditional Operations |  Full |
| **Zihintpause** | Pause Hint Instruction |  Full |

### Compressed Instructions (C)

| Sub-extension | Description | Status |
| :--- | :--- | :--- |
| Zca | Integer Compressed |  Full |

### Bit Manipulation (B)

| Sub-extension | Description | Status |
| :--- | :--- | :--- |
| Zba | Address Generation |  Full |
| Zbb | Basic Bit-Manipulation |  Full |
| Zbs | Single-Bit Operations |  Full |

### Control & Status

| Extension | Description | Status |
| :--- | :--- | :--- |
| **Zicsr** | Control Status Registers |  Full |
| **Zihpm** | Hardware Performance Monitors |  Full |

### Interrupts

| Type | Description | Status |
| :--- | :--- | :--- |
| MEI | Machine External Interrupt | Supported |
| MTI | Machine Timer Interrupt | Supported |
| MSI | Machine Software Interrupt | Supported |

---


##  CoreMark Performance

| Metric | Value |
| :--- | :--- |
| CoreMark | 1499 |
| Frequency | 575 MHz (simulated) |
| CoreMark/MHz | 2.61 |
| Simulation | Gate-level, ideal memory |

*Measured in gate-level simulation without cache/memory latency. Provides architectural comparison point.*