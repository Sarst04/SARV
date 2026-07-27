# Branch Prediction Entry Size Comparisons

This document analyzes the performance, execution time, and hardware area trade-offs of varying the Branch Target Buffer (BTB) entry size on the SARV 32-bit RISC-V processor.

> **Compilation Target / Flags:** `riscvib_zicond_zmmul_zicsr_zca`  
> **Version under Test** `SARV_V1.4`
> **Microarchitecture Parameters:**  
> * `RETURN_ADDRESS_PREDICTION_ENTRY_INDEX_BITS = 0` (0-entry Return Address Stack / No RAS)  
>
> **Synthesis Technology Node:** `Nangate 45nm, Yosys`  
> **Simulated Frequency:** `500 MHz`

---

## Detailed Breakdown by Configuration

### 1. Index 0 — No Branch Prediction (0 Entries)

* **CoreMark Score (Iterations/Sec):** 1,333.080937
* **CoreMark / MHz:** 2.66616
* **Execution Time:** 0.000750 s
* **Area:** 30,404.066 µm²
* **Performance Improvement vs. Baseline:** Baseline (0.00%)

### 2. Index 1 — Entry = 2

* **CoreMark Score (Iterations/Sec):** 1,464.441887
* **CoreMark / MHz:** 2.92888
* **Execution Time:** 0.000683 s
* **Area:** 31,522.596 µm²
* **Performance Improvement vs. Baseline:** +9.85%

### 3. Index 2 — Entry = 4

* **CoreMark Score (Iterations/Sec):** 1,481.731730
* **CoreMark / MHz:** 2.96346
* **Execution Time:** 0.000675 s
* **Area:** 32,449.606 µm²
* **Performance Improvement vs. Baseline:** +11.15%

### 4. Index 3 — Entry = 8

* **CoreMark Score (Iterations/Sec):** 1,497.485721
* **CoreMark / MHz:** 2.99497
* **Execution Time:** 0.000668 s
* **Area:** 34,477.324 µm²
* **Performance Improvement vs. Baseline:** +12.33%

### 5. Index 4 — Entry = 16

* **CoreMark Score (Iterations/Sec):** 1,514.531934
* **CoreMark / MHz:** 3.02906
* **Execution Time:** 0.000660 s
* **Area:** 37,894.094 µm²
* **Performance Improvement vs. Baseline:** +13.61%

### 6. Index 5 — Entry = 32

* **CoreMark Score (Iterations/Sec):** 1,522.111717
* **CoreMark / MHz:** 3.04422
* **Execution Time:** 0.000657 s
* **Area:** 45,378.536 µm²
* **Performance Improvement vs. Baseline:** +14.18%


### 7. Index 6 — Entry = 64

* **CoreMark Score (Iterations/Sec):** 1,530.891867
* **CoreMark / MHz:** 3.06178
* **Execution Time:** 0.000653 s
* **Area:** 60,470.046 µm²
* **Performance Improvement vs. Baseline:** +14.84%

---

## Summary Comparison Table

| Index | BTB Entries | CoreMark Score (Iter/Sec) | CoreMark / MHz | Execution Time (s) | Perf. vs. Baseline (%) | Area (µm²) | Area Overhead (%) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 0 (None) | 1,333.080937 | 2.66616 | 0.000750 | **Baseline** | 30,404.066 | Baseline (0%) |
| **1** | 2 | 1,464.441887 | 2.92888 | 0.000683 | **+9.85%** | 31,522.596 | +3.68% |
| **2** | 4 | 1,481.731730 | 2.96346 | 0.000675 | **+11.15%** | 32,449.606 | +6.73% |
| **3** | 8 | 1,497.485721 | 2.99497 | 0.000668 | **+12.33%** | 34,477.324 | +13.40% |
| **4** | 16 | 1,514.531934 | 3.02906 | 0.000660 | **+13.61%** | 37,894.094 | +24.64% |
| **5** | 32 | 1,522.111717 | 3.04422 | 0.000657 | **+14.18%** | 45,378.536 | +49.25% |
| **6** | 64 | 1,530.891867 | 3.06178 | 0.000653 | **+14.84%** | 60,470.046 | +98.89% |
