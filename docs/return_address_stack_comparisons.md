# Return Address Stack (RAS) Size Comparisons

> **Version under Test:** `SARV_V1.4`  
> **Compilation Target / Flags:** `riscvib_zicond_zmmul_zicsr_zca`  
> **Microarchitecture Parameters:**  
> * `BRANCH_PREDICTION_ENTRY_INDEX_BITS = 1` (Entry size 2)  
> **Synthesis Technology Node:** `Nangate 45nm, Yosys`  
> **Simulated Frequency:** `500 MHz`

This document analyzes the performance, execution time, and hardware area trade-offs of varying the Return Address Stack (RAS) buffer size on the SARV 32-bit RISC-V processor.

---

## Detailed Breakdown by Configuration

### 1. Index 0 — No RAS (Disabled)
* **CoreMark Score (Iterations/Sec):** 1,464.441887
* **CoreMark / MHz:** 2.92888
* **Execution Time:** 0.000683 s
* **Area:** 31,522.596 µm²
* **Performance Improvement vs. Baseline:** Baseline (0.00%)
* *Details:* Baseline configuration with branch prediction enabled (`BTB entries = 2`) but no return address stack, serving as the reference point for function return penalty evaluations.

### 2. Index 1 — Buffer Size = 2
* **CoreMark Score (Iterations/Sec):** 1,475.217816
* **CoreMark / MHz:** 2.95044
* **Execution Time:** 0.000678 s
* **Area:** 32,371.668 µm²
* **Performance Improvement vs. Baseline:** +0.74%
* *Details:* Minimal RAS addition (+849.07 µm² area overhead) that successfully captures shallow subroutine nesting and yields an immediate performance boost.

### 3. Index 2 — Buffer Size = 4
* **CoreMark Score (Iterations/Sec):** 1,475.226521
* **CoreMark / MHz:** 2.95045
* **Execution Time:** 0.000678 s
* **Area:** 32,698.848 µm²
* **Performance Improvement vs. Baseline:** +0.74%
* *Details:* Extends stack depth to 4 entries with negligible incremental area cost.

### 4. Index 3 — Buffer Size = 8
* **CoreMark Score (Iterations/Sec):** 1,475.226521
* **CoreMark / MHz:** 2.95045
* **Execution Time:** 0.000678 s
* **Area:** 33,604.578 µm²
* **Performance Improvement vs. Baseline:** +0.74%
* *Details:* Medium-scale buffer depth configuration. CoreMark benchmark behavior saturates at this level, showing identical iteration throughput to smaller depths.

### 5. Index 4 — Buffer Size = 16
* **CoreMark Score (Iterations/Sec):** 1,475.226521
* **CoreMark / MHz:** 2.95045
* **Execution Time:** 0.000678 s
* **Area:** 35,705.446 µm²
* **Performance Improvement vs. Baseline:** +0.74%
* *Details:* Deeper stack capacity resulting in increased multiplexing and register area overhead without additional execution performance gains for this benchmark workload.

### 6. Index 5 — Buffer Size = 32
* **CoreMark Score (Iterations/Sec):** 1,475.226521
* **CoreMark / MHz:** 2.95045
* **Execution Time:** 0.000678 s
* **Area:** 39,130.462 µm²
* **Performance Improvement vs. Baseline:** +0.74%
* *Details:* Maximum buffer depth tested. Exhibits performance saturation, confirming that a 2-to-4 entry RAS is optimal for the CoreMark benchmark profile on SARV.

---

## Summary Comparison Table

| Index | RAS Buffer Size | CoreMark Score (Iter/Sec) | CoreMark / MHz | Execution Time (s) | Perf. vs. Baseline (%) | Area (µm²) | Area Overhead (%) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 0 (No RAS) | 1,464.441887 | 2.92888 | 0.000683 | **Baseline** | 31,522.596 | Baseline (0%) |
| **1** | 2 | 1,475.217816 | 2.95044 | 0.000678 | **+0.74%** | 32,371.668 | +2.69% |
| **2** | 4 | 1,475.226521 | 2.95045 | 0.000678 | **+0.74%** | 32,698.848 | +3.73% |
| **3** | 8 | 1,475.226521 | 2.95045 | 0.000678 | **+0.74%** | 33,604.578 | +6.60% |
| **4** | 16 | 1,475.226521 | 2.95045 | 0.000678 | **+0.74%** | 35,705.446 | +13.27% |
| **5** | 32 | 1,475.226521 | 2.95045 | 0.000678 | **+0.74%** | 39,130.462 | +24.13% |