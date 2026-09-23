# CSR and Interrupt System

This document describes the Control and Status Register (CSR) subsystem of the SARV RISC-V core.

The CSR unit is responsible for system control, privilege management, interrupt handling, exception processing, and performance monitoring.

SARV implements the Zicsr extension together with machine, supervisor, and user privilege modes. The CSR subsystem also includes additional control logic for power management, performance monitoring.

---

## Overview

The CSR subsystem in SARV is a multi-block control system consisting of:

- CSR Write Unit
- CSR Read Unit
- Trap Handler
- Trap PC Generator
- Interrupt Controller
- Sleep (WFI) Unit
- CPI Management Unit
- Performance Counter System

The CSR system supports M-mode, S-mode, and U-mode execution, including privilege transitions, trap delegation, and supervisor-level interrupts.

---

## CSR Instruction Support

SARV implements all standard Zicsr instructions.

| Instruction | Operation |
|-------------|-----------|
| CSRRW  | Atomic read/write |
| CSRRS  | Atomic read and set bits |
| CSRRC  | Atomic read and clear bits |
| CSRRWI | Immediate atomic read/write |
| CSRRSI | Immediate atomic read and set bits |
| CSRRCI | Immediate atomic read and clear bits |

CSR access is checked against the current privilege mode and the read-only attribute encoded in the CSR address.

---

## Privilege Modes

SARV supports the three standard RISC-V privilege modes:

| Mode | Encoding | Description |
| :--- | :--- | :--- |
| **M-mode** | `11` | Machine mode |
| **S-mode** | `01` | Supervisor mode |
| **U-mode** | `00` | User mode |

Privilege transitions are handled by trap and return instructions, including:

- `MRET`
- `SRET`

The CSR subsystem controls the current privilege level and updates the relevant status fields when entering or leaving a trap.

---

## CSR Organization

The control and status registers are grouped into the following categories:

- Machine Information Registers  
- Machine Trap Setup  
- Machine Trap Handling  
- Supervisor Trap Setup
- Supervisor Trap Handling
- Supervisor Timer
- Power Management (Custom CSR Extensions)  
- Performance Counters  

---

## CSR Register Map

### Machine Information Registers

| CSR Name | Address | Description |
| :--- | :--- | :--- |
| `mvendorid` | `0xF11` | Vendor ID |
| `marchid` | `0xF12` | Architecture ID |
| `mimpid` | `0xF13` | Implementation ID |
| `mhartid` | `0xF14` | Hardware thread ID |
| `mconfigptr` | `0xF15` | Configuration pointer |

---

### Machine Trap Setup

| CSR Name | Address | Description |
| :--- | :--- | :--- |
| `mstatus` | `0x300` | Machine status register |
| `misa` | `0x301` | ISA and extension configuration |
| `medeleg` | `0x302` | Machine exception delegation |
| `mideleg` | `0x303` | Machine interrupt delegation |
| `mie` | `0x304` | Machine interrupt enable |
| `mtvec` | `0x305` | Machine trap vector base |

---

### Machine Trap Handling

| CSR Name | Address | Description |
| :--- | :--- | :--- |
| `mscratch` | `0x340` | Scratch register for trap handler |
| `mepc` | `0x341` | Exception program counter |
| `mcause` | `0x342` | Trap cause register |
| `mtval` | `0x343` | Trap value register |
| `mip` | `0x344` | Interrupt pending register |

---

### Supervisor Trap Setup

| CSR Name | Address | Description |
| :--- | :--- | :--- |
| `sstatus` | `0x100` | Supervisor status register |
| `sie` | `0x104` | Supervisor interrupt enable |
| `stvec` | `0x105` | Supervisor trap vector base |

`sstatus`, `sie`, and `sip` expose the supervisor-visible portions of the corresponding machine-level state where required by the RISC-V architecture.

---

### Supervisor Trap Handling

| CSR Name | Address | Description |
| :--- | :--- | :--- |
| `sscratch` | `0x140` | Scratch register for supervisor trap handler |
| `sepc` | `0x141` | Supervisor exception program counter |
| `scause` | `0x142` | Supervisor trap cause |
| `stval` | `0x143` | Supervisor trap value |
| `sip` | `0x144` | Supervisor interrupt pending |

---

### Supervisor Timer

| CSR Name | Address | Description |
| :--- | :--- | :--- |
| `stimecmp` | `0x14D` | Supervisor timer compare |
| `stimecmph` | `0x15D` | Upper half of supervisor timer compare |

The supervisor timer uses the platform `mtime` counter as its time source.

The supervisor timer interrupt becomes pending when:

```text
mtime >= stimecmp
```

The generated STIP can be delegated to S-mode through `mideleg`.

---

### Machine Performance Counters

| CSR Name | Address | Description |
| :--- | :--- | :--- |
| `mcycle` | `0xB00` | Cycle counter (low) |
| `mcycleh` | `0xB80` | Cycle counter (high) |
| `minstret` | `0xB02` | Instruction retirement counter |
| `minstreth` | `0xB82` | Instruction counter high |
| `mhpmcounter3` | `0xB03` | Performance counter 3 |
| `mhpmcounter4` | `0xB04` | Performance counter 4 |
| `mhpmcounter5` | `0xB05` | Performance counter 5 |
| `mhpmcounter6` | `0xB06` | Performance counter 6 |
| `mhpmcounter7` | `0xB07` | Performance counter 7 |
| `mhpmcounter8` | `0xB08` | Performance counter 8 |
| `mhpmcounter9` | `0xB09` | Performance counter 9 |
| `mcountinhibit` | `0x320` | Counter enable control |


> **Note:** The width of the hardware performance counters (`mhpmcounter3`–`mhpmcounter9`) is configurable through the `MHPM_COUNTER_SIZE` parameter and can be selected at synthesis time.

---

### User Counter Access

SARV provides user-visible counter aliases:

| CSR Name | Address | Description |
| :--- | :--- | :--- |
| `cycle` | `0xC00` | Cycle counter |
| `time` | `0xC01` | Platform timer |
| `instret` | `0xC02` | Instructions retired |
| `cycleh` | `0xC80` | Cycle counter high |
| `timeh` | `0xC81` | Platform timer high |
| `instreth` | `0xC82` | Instructions retired high |

These CSRs provide read access to the corresponding counter or timer values.

---

### Machine Custom CSRs

| CSR Name  | Address | Description            |
|-----------|--------|-------------------------|
| mcpirate  | 0x7C0   | CPI rate configuration |
| mcpictrl  | 0x7C4   | CPI control register   |

---

## Interrupt System

SARV supports machine-level and supervisor-level interrupts.

### Machine Interrupts

| Interrupt | Description | Cause |
| :--- | :--- | :--- |
| MEI | Machine External Interrupt | 11 |
| MTI | Machine Timer Interrupt | 7 |
| MSI | Machine Software Interrupt | 3 |

### Supervisor Interrupts

| Interrupt | Description | Cause |
| :--- | :--- | :--- |
| SEI | Supervisor External Interrupt | 9 |
| STI | Supervisor Timer Interrupt | 5 |
| SSI | Supervisor Software Interrupt | 1 |

Supervisor interrupts can be delegated from M-mode through `mideleg`.

---
### Interrupt Handling Flow

1\. An interrupt request is reflected in the corresponding bit of the `mip` register.

2\. The `CSR_inter_interrupt_controller` checks:
   - the pending interrupt bits in `mip`
   - the corresponding enable bits in `mie`
   - the global interrupt enable (`MIE`) bit in `mstatus`
   - the interrupt delegation bits in `mideleg`

3\. For an interrupt delegated to S-mode, the controller checks:
   - the corresponding supervisor pending interrupt bits in `sip`
   - the corresponding enable bits in `sie`
   - the global interrupt enable (`SIE`) bit in `sstatus`

4\. If the interrupt is accepted, the controller asserts `coldDownPipe`, preventing new instructions from entering the pipeline while allowing all in-flight instructions to complete normally.

   During this cooldown period, any pending branch or jump instructions are still allowed to update the program counter.

5\. Once the pipeline is empty, the current program counter is saved to `mepc` for an M-mode trap or `sepc` for a delegated S-mode trap.

6\. The interrupt cause is written to `mcause` for an M-mode trap or `scause` for a delegated S-mode trap.

7\. The corresponding interrupt enable state is updated:
   - For an M-mode trap, `mstatus.MIE` is cleared and the previous value is saved in `mstatus.MPIE`.
   - For an S-mode trap, `sstatus.SIE` is cleared and the previous value is saved in `sstatus.SPIE`.

8\. The current privilege mode is changed to M-mode or S-mode according to the trap delegation result.

9\. The program counter is updated with the trap vector generated from `mtvec` or `stvec`, transferring execution to the corresponding interrupt handler.

10\. Execution resumes after an `mret` or `sret` instruction, which restores the program counter from `mepc` or `sepc` and restores the corresponding privilege and interrupt-enable state.


**## Trap PC Generator**

The trap target address is generated according to the RISC-V Privileged Architecture Specification.

The `mtvec` and `stvec` registers contain:

- **BASE** — Trap handler base address
- **MODE** — Trap vectoring mode

SARV supports both trap modes defined by the specification:

- **Direct Mode** — All traps jump to the address stored in `mtvec.BASE` or `stvec.BASE`.
- **Vectored Mode** — Interrupts jump to `BASE + 4 × cause`, while synchronous exceptions continue to use the base address.

For M-mode traps, the target address is generated from `mtvec`.

For S-mode traps, the target address is generated from `stvec`.

The appropriate trap vector is selected according to the current privilege mode and the delegation result.

Unlike some implementations, SARV does not impose additional alignment restrictions beyond those required by the RISC-V specification.

---

## Trap Return

SARV supports:

```text
MRET
SRET
```

### MRET

`MRET` returns from a trap handled in M-mode.

The processor restores the previous privilege and interrupt-enable state and resumes execution from `mepc`.

### SRET

`SRET` returns from a trap handled in S-mode.

The processor restores the previous supervisor privilege and interrupt-enable state and resumes execution from `sepc`.

---

## Performance Monitoring

The CSR subsystem provides:

- `mcycle` / `mcycleh`
- `minstret` / `minstreth`
- `mhpmcounter3`–`mhpmcounter9`
- `mcountinhibit`
- User-visible counter aliases

The counters are used for execution monitoring and performance analysis.

---

### WFI (Sleep Unit)

The `CSR_sleeping_unit` implements the WFI instruction:

- Core enters low-activity state
- Execution resumes on valid interrupt
- Pipeline is stalled during sleep mode

