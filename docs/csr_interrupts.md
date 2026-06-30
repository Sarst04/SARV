# CSR and Interrupt System

This document describes the Control and Status Register (CSR) subsystem of the SARV RISC-V core.

The CSR unit is responsible for system control, interrupt handling, exception processing, and performance monitoring.

It operates in Machine Mode (M-mode) and implements the Zicsr extension along with additional custom control logic.

Currently, SARV implements only Machine Mode (M-mode); Supervisor and User modes are not supported.

---

## Overview

The CSR subsystem in SARV is a multi-block control system consisting of:

- CSR Write Unit  
- CSR Read Unit  
- Trap Handler  
- Interrupt Controller  
- Sleep (WFI) Unit  
- CPI Management Unit  
- Performance Counter System  

---

## CSR Instruction Support

SARV implements all standard Zicsr instructions.

| Instruction | Operation |
|-------------|-----------|
| CSRRW  | Atomic read/write |
| CSRRS  | Atomic read and set bits |
| CSRRC  | Atomic read and clear bits |
| CSRRWI | Immediate read/write |
| CSRRSI | Immediate read and set bits |
| CSRRCI | Immediate read and clear bits |

---

## CSR Organization

The control and status registers are grouped into the following categories:

- Machine Information Registers  
- Machine Trap Setup  
- Machine Trap Handling  
- Power Management (Custom CSR Extensions)  
- Performance Counters  

---

## CSR Register Map

The SARV CSR unit implements standard RISC-V Machine-mode CSRs along with custom performance and control registers.

All CSR addresses follow the standard 12-bit CSR encoding.

---

### Machine Information Registers

| CSR Name   | Address | Description |
|------------|--------|-------------|
| mvendorid  | 0xF11   | Vendor ID |
| marchid    | 0xF12   | Architecture ID |
| mimpid     | 0xF13   | Implementation ID |
| mhartid    | 0xF14   | Hardware thread ID |
| mconfigptr | 0xF15   | Configuration pointer |

---

### Machine Trap Setup

| CSR Name | Address | Description |
|----------|--------|-------------|
| mstatus  | 0x300   | Machine status register |
| misa     | 0x301   | ISA and extension configuration |
| mie      | 0x304   | Machine interrupt enable |
| mtvec    | 0x305   | Trap vector base address |

---

### Machine Trap Handling

| CSR Name | Address | Description |
|----------|--------|-------------|
| mscratch | 0x340   | Scratch register for trap handler |
| mepc     | 0x341   | Exception program counter |
| mcause   | 0x342   | Trap cause register |
| mtval    | 0x343   | Trap value register |
| mip      | 0x344   | Interrupt pending register |

---

### Machine Performance Counters

| CSR Name        | Address | Description |
|----------------|--------|-------------|
| mcycle         | 0xB00   | Cycle counter (low) |
| mcycleh        | 0xB80   | Cycle counter (high) |
| minstret       | 0xB02   | Instruction retirement counter |
| minstreth      | 0xB82   | Instruction counter high |
| mhpmcounter3   | 0xB03   | Performance counter 3 |
| mhpmcounter4   | 0xB04   | Performance counter 4 |
| mhpmcounter5   | 0xB05   | Performance counter 5 |
| mhpmcounter6   | 0xB06   | Performance counter 6 |
| mhpmcounter7   | 0xB07   | Performance counter 7 |
| mhpmcounter8   | 0xB08   | Performance counter 8 |
| mhpmcounter9   | 0xB08   | Performance counter 9 |
| mcountinhibit  | 0x320   | Counter enable control |

> **Note:** The width of the hardware performance counters (`mhpmcounter3`–`mhpmcounter9`) is configurable through the `MHPM_COUNTER_SIZE` parameter and can be selected at synthesis time.

---

### Machine Custom CSRs

| CSR Name  | Address | Description            |
|-----------|--------|-------------------------|
| mcpirate  | 0x7C0   | CPI rate configuration |
| mcpictrl  | 0x7C4   | CPI control register   |

---

## Interrupt System

SARV supports the following Machine-mode interrupts:

- MEI → External interrupt
- MTI → Timer interrupt
- MSI → Software interrupt

### Interrupt Handling Flow

1. An interrupt request is reflected in the corresponding bit of the `mip` register.

2. The `CSR_inter_interrupt_controller` checks:
   - the pending interrupt bits in `mip`
   - the corresponding enable bits in `mie`
   - the global interrupt enable (`MIE`) bit in `mstatus`

3. If the interrupt is accepted, the controller asserts `coldDownPipe`, preventing new instructions from entering the pipeline while allowing all in-flight instructions to complete normally.

   During this cooldown period, any pending branch or jump instructions are still allowed to update the program counter.

4. Once the pipeline is empty, the current program counter is saved to `mepc`.

5. The interrupt cause is written to `mcause`.

6. The global interrupt enable bit (`mstatus.MIE`) is cleared to prevent out of control nested interrupts.

7. The program counter is updated with the trap vector generated from `mtvec`, transferring execution to the interrupt handler.

8. Execution resumes after an `mret` instruction, which restores the program counter from `mepc` and re-enables interrupts.


## Trap PC Generator

The trap target address is generated according to the RISC-V Privileged Architecture Specification.

The `mtvec` register contains:

- **BASE** — Trap handler base address
- **MODE** — Trap vectoring mode

SARV supports both trap modes defined by the specification:

- **Direct Mode** — All traps jump to the address stored in `mtvec.BASE`.
- **Vectored Mode** — Interrupts jump to `mtvec.BASE + 4 × cause`, while synchronous exceptions continue to use the base address.

Unlike some implementations, SARV does not impose additional alignment restrictions beyond those required by the RISC-V specification.

### WFI (Sleep Unit)

The `CSR_sleeping_unit` implements the WFI instruction:

- Core enters low-activity state
- Execution resumes on valid interrupt
- Pipeline is stalled during sleep mode

