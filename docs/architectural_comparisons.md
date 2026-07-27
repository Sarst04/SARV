# Architectural & ABI Comparisons

> **Version under Test:** `SARV_V1.4`

This document serves as the central hub for performance, ABI, and microarchitectural comparisons for the SARV 32-bit RISC-V processor.

---

## 1. ABI Comparison: ILP32 vs. ILP32E

To evaluate the trade-offs between a 32-register register file and a 16-register register file in embedded targets, the SARV core was benchmarked under both the standard **ILP32** (`x0`–`x31`) and embedded **ILP32E** (`x0`–`x15`) Application Binary Interfaces.

- [Detailed ABI Comparisons](abi_comparisons.md#abi-comparisons-ilp32-vs-ilp32e)

---

## 2. Branch Prediction Entry Size Comparisons

To evaluate control-flow prediction efficiency, the Branch Target Buffer (BTB) was benchmarked across various entry index sizes under the `riscvib_zicond_zmmul_zicsr_zca` compilation target and a 0-entry RAS configuration.

- [Branch Prediction Entry Size Comparisons](branch_prediction_comparisons.md#branch-prediction-entry-size-comparisons)

---

## 3. Return Address Stack (RAS) Size Comparisons

To measure subroutine return performance and stack capacity overhead, the Return Address Stack was benchmarked across multiple circular buffer depths under the `riscvib_zicond_zmmul_zicsr_zca` compilation target and an active 2-entry BTB configuration.

- [Return Address Stack Size Comparisons](return_address_stack_comparisons.md#return-address-stack-ras-size-comparisons)

---
