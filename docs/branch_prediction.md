# Branch Prediction

## Overview

The **Branch Prediction Unit (BPU)** improves SARV pipeline performance by reducing the control hazard penalty caused by branches.  
In a pipelined processor, branch instructions create uncertainty about the next program counter (PC). In the SARV architecture, branch conditions are resolved in the **Execute stage**. Without prediction, a taken branch causes incorrectly fetched instructions to be flushed, creating a costly pipeline recovery penalty.  
The SARV BPU reduces this penalty by predicting the branch direction and target address in the **Address Generation stage**, allowing the processor to continue execution seamlessly from the predicted path.

### Key Features

* Parameterized prediction entry storage  
* PC indexed prediction entries  
* Two bit saturating prediction history  
* Stored branch target addresses  
* Robust misprediction detection and recovery

The design can be configured at synthesis time by modifying the **`BRANCH_PREDICTION_ENTRY_INDEX_BITS`** parameter at the top module.

## Architecture Overview

The Branch Prediction Unit contains multiple prediction entries. Each entry stores:

* **Valid bit:** Indicates active prediction data.  
* **PC tag:** Identifies the specific branch instruction.  
* **Target address:** Stores the destination address of the branch.  
* **History:** Tracks the two-bit saturating prediction state.

The total number of entries scales exponentially with the index parameter:

$$\text{Number of entries} = 2^{\text{ENTRY\_INDEX\_BITS}}$$

### Configuration Options

| ENTRY\_INDEX\_BITS | Number of Entries | Description |
| :---- | :---- | :---- |
| **0** | Predictor disabled | Disables branch prediction |
| **1** | 2 entries | Minimal footprint |
| **2** | 4 entries | Small scale |
| **4** | 16 entries | Medium scale |
| **8** | 256 entries | High capacity |

This parameterization allows designers to easily balance **prediction accuracy**, **hardware area**, and **power consumption**.

## Prediction Entry Organization

Each prediction entry is structured with the following fields:

| Field | Description |
| :---- | :---- |
| **Valid** | Indicates that the entry contains valid branch information. |
| **Tag** | Upper PC bits used to uniquely identify the branch instruction. |
| **Target Address** | Stored destination address of the branch. |
| **History** | Two bit saturating prediction state determining branch confidence. |

## PC Indexing Mechanism

To optimize storage requirements and ensure fast access times, the complete program counter is not stored directly. Instead, the PC is partitioned into distinct segments:

| PC Tag | Entry Index | Offset (0) |
| :---- | :---- | :---- |

* **Entry Index:** Selects the target prediction entry:  

```Verilog  
  index = PC[ENTRY_INDEX_BITS : 1];
```

* **PC Tag:** Stores the remaining upper bits for validation:  
  
```Verilog  
  tag = PC[31 : ENTRY_INDEX_BITS+1];
```

* **Offset (0)** All branches in RiscV architucture are allign to 2 byte


### Validation Check

During prediction, an entry is considered valid only if:

> 1. The entry's **Valid bit** is set.  
> 2. The **stored tag** matches the current PC tag.

**Note:** This tagging mechanism prevents aliasing issues and incorrect predictions when different branches map to the same entry index.

## Branch History Prediction

Each prediction entry maintains a two bit saturating counter representing confidence levels for branch behavior.

| State | Binary Value | Prediction |
| :---- | :---- | :---- |
| **Strongly Not Taken** | 00 | Not Taken |
| **Weakly Not Taken** | 01 | Not Taken |
| **Weakly Taken** | 10 | Taken |
| **Strongly Taken** | 11 | Taken |

## Prediction Flow

The prediction sequence operates during the Fetch stage:

> 1. **PC Provision:** The Fetch stage supplies the current PC.  
> 2. **Index Selection:** The PC index selects a specific prediction entry.  
> 3. **Tag Comparison:** The stored tag is compared against the current PC tag.  
> 4. **Target Redirection:** If the entry is valid, tags match, and history predicts taken:  
   * The stored target address is selected.  
   * The next PC is redirected to the predicted target.  
> 5. **Sequential Execution:** If no valid prediction exists, normal sequential execution continues.

## Branch Update Flow

When a branch instruction reaches the Execute stage:

* The actual branch condition is computed.  
* The predictor entry corresponding to the branch PC is accessed.  
* The branch target address is updated/verified.  
* The two-bit history counter is adjusted based on actual outcomes.  
* The predicted result is compared against the real execution result.

## Misprediction Detection & Recovery

A branch misprediction occurs when:

$$\text{Predicted Result} \neq \text{Actual Result}$$

The BPU handles recovery through two primary scenarios:

### 1\. Predicted Not Taken, Actually Taken

The processor continued sequential execution, but the branch should have been taken.

* **Recovery Action:**  
  ```Verilog  
  PC = Actual Branch Target;
  ```

* **Result:** The pipeline is immediately redirected to the correct target address, and incorrectly fetched sequential instructions are flushed.

### 2\. Predicted Taken, Actually Not Taken

The processor followed the predicted branch target, but the branch should not have been taken.

* **Recovery Action:**  
  ```Verilog  
  PC = Next Sequential PC;
  ```

* **Result:** The pipeline returns to the instruction directly following the branch, and incorrectly fetched sequential instructions are flushed.