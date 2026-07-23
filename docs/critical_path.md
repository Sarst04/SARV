# Critical Path Analysis

This document describes the longest combinational path in the SARV core, which determines the maximum achievable clock frequency after synthesis and timing analysis.

The analysis is based on a post-synthesis netlist generated using **Yosys**, with timing estimation performed using **OpenSTA**.

---

## Overview

The critical path in SARV is primarily caused by **data hazards handled through the forwarding logic in the pipeline**.

In particular, branch-related dependencies extend the critical path through the comparator and program counter (PC) update logic.

---

## Combined Critical Path

The worst-case combinational path in the current design is:

**Writeback Stage → Forwarding Unit → Comparator → PC Input MUX → PC Register**

This path represents the maximum delay through the pipeline in scenarios involving branch resolution with data dependencies.

---

## Critical Path Visualization Big Picture

<p align="center">
  <img src="assets/criticalPath.svg"
       alt="SARV Critical Path"
       width="900">
</p>

Detailed module-level design, datapath diagrams, and signal-level descriptions are available in the `docs/` directory.

---


## Optimization 

- Moving writeback selection logic earlier in the pipeline (MEM stage)
- Reducing comparator delay

## Optimization Opportunities

Several optimizations can reduce the critical path:

- Moving forward logic earlier in the pipeline (Decode stage)
- Reducing comparator delay even less than what it is

These changes aim to shorten the combinational logic between pipeline registers and improve overall timing closure.

---
