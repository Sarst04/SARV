# Return Address Stack

## Overview

The **Return Address Stack (RAS)**, implemented inside the **Jump Unit**, improves SARV pipeline performance by reducing the control hazard penalty caused by `call` / `return` instruction pairs.

Subroutine returns are notoriously hard to predict with a normal branch predictor, since the same `return` instruction can jump to a different target every time it executes, depending on which caller invoked it. In the SARV architecture, the jump target for a `return` is only truly known once the instruction is resolved in the **Execute stage**. Without prediction, every `return` would stall or flush the pipeline while the target is recomputed.

The SARV RAS solves this by predicting return targets speculatively in the **Fetch stage**: whenever a `call` is detected, the instruction's return address is pushed onto a small hardware stack. When a `return` is later fetched, the top of that stack is popped and used immediately as the predicted next PC — following the natural LIFO (last-in, first-out) behavior of function calls.

### Key Features

* Parameterized stack depth
* LIFO (stack) storage discipline, built on a circular buffer
* Speculative prediction in the Fetch stage
* Return address capture on `call` detection
* Deferred, confirmed push/pop commit in the Execute stage
* Separate, always-mispredicted handling for non-return jumps (e.g. `jal`)

The design can be configured at synthesis time by modifying the **`ENTRY_INDEX_BITS`** parameter on the `jump_unit` module.

## Architecture Overview

The Jump Unit wraps a `circular_buffer` used as a LIFO. Each stack entry stores:

* **Return Address (31 bits):** The instruction address immediately following the `call`, with the low alignment bit dropped (`nextPC[31:1]`), since all instructions are 2-byte aligned.

Unlike the branch predictor's tagged, PC-indexed table, the RAS has no per-entry valid bit or PC tag — entries are addressed purely by stack position (the stack pointer `sp`), not by the branch's PC.

The total stack depth scales exponentially with the index parameter:

$$\text{Depth} = 2^{\text{ENTRY\_INDEX\_BITS}}$$

### Configuration Options

| ENTRY\_INDEX\_BITS | Depth | Description |
| :---- | :---- | :---- |
| **0** | RAS disabled | Every jump is treated as an unpredicted, Execute-stage-resolved redirect |
| **1** | 2 entries | Minimal footprint |
| **2** | 4 entries | Small scale |
| **4** | 16 entries | Medium scale |
| **8** | 256 entries | High capacity |

This parameterization lets designers balance **call/return prediction accuracy** against **hardware area**, since deeply nested or recursive call chains need a deeper stack to avoid overflow-induced mispredictions.

## Stack Organization

The underlying `circular_buffer` implements a classic pointer-based LIFO:

| Signal | Description |
| :---- | :---- |
| **sp** | Stack pointer; indicates the next free slot |
| **stack[sp-1]** | Current top-of-stack entry (`popData`) |
| **push** | Writes `pushData` to `stack[sp]` and increments `sp` |
| **pop** | Decrements `sp` |

```Verilog
assign popData = stack[sp - 1'b1];
```

The reconstructed 32-bit address exposed to the front end restores the dropped alignment bit:

```Verilog
assign topOfRas = {popData, 1'b0};
```

**Note:** Reading `topOfRas` does **not** by itself modify the stack — `popData` is a combinational read of the current top entry. The stack pointer only changes when `push`/`pop` are actually asserted, which happens only once the corresponding `call`/`return` is confirmed in the Execute stage.

## Push Mechanism (Call Capture)

When a jump resolves in the Execute stage and is identified as a `call`:

* The return address (`nextPC_E_o_A_i[31:1]`, i.e. the instruction after the call) is written into `pushData`.
* `push` is asserted, storing the return address on top of the stack.

```Verilog
if (callDetected_E_o_A_i) begin
    pushData = nextPC_E_o_A_i[31:1];
    push     = 1'b1;
end
```

Because the call target itself is a direct/unconditional jump, it is **not predicted early** — it is always resolved and redirected from the Execute stage, alongside the push.

## Prediction Flow (Return Handling)

Return prediction happens speculatively, one stage earlier than confirmation:

> 1. **Fetch Detection:** The Fetch stage detects a `return` instruction (`returnDetected_F_o_A_i`).
> 2. **Speculative Redirect:** The current top-of-stack address (`topOfRas`) is immediately used as the predicted next PC.
> 3. **No Stack Mutation Yet:** The stack pointer is *not* changed at this point — only a combinational read occurs.
> 4. **Execute Confirmation:** When the same `return` reaches Execute (`returnDetected_E_o_A_i`), its actual target is compared against the prediction via `targetMatch_E_o_A_i`.
> 5. **Commit:** Only if the prediction was correct does the Jump Unit actually assert `pop`, permanently removing the entry from the stack.

```Verilog
if (returnDetected_F_o_A_i) begin
    changePCSrcJumpUnitTarget = 1'b1;
    PCTargetJumpUnit          = {popData, 1'b0};
end
```

## Misprediction Detection & Recovery

### 1. Return Misprediction

Occurs when a `return`'s actual computed target (resolved in Execute) does not match the address that was speculatively popped in Fetch.

* **Detection:** `returnDetected_E_o_A_i && !targetMatch_E_o_A_i`
* **Recovery Action:**
  ```Verilog
  PC = PCTarget_E_o_A_i; // actual, computed target
  mispredictJump = 1'b1;
  ```
* **Result:** The pipeline is redirected to the correct target and incorrectly fetched instructions are flushed. The stack is **not** popped in this case, since the speculative read was wrong — the entry is left in place rather than being committed.

### 2. Non-Return Jump (Call / Unconditional Jump)

Direct jumps and calls are never predicted early by the RAS — they are always resolved in the Execute stage.

* **Detection:** `jumpDetect_E_o_A_i && !returnDetected_E_o_A_i`
* **Recovery Action:**
  ```Verilog
  PC = PCTarget_E_o_A_i;
  mispredictJump = 1'b1;
  ```
* **Side Effect:** If the jump is also a `call`, the return address is pushed onto the RAS in the same cycle (see **Push Mechanism** above).

### 3. Correct Return Prediction

* **Detection:** `returnDetected_E_o_A_i && targetMatch_E_o_A_i`
* **Action:** `pop` is asserted to commit the earlier speculative read; no PC redirect is needed since the Fetch-stage prediction already had the pipeline on the correct path.

## Disabled Mode (`ENTRY_INDEX_BITS == 0`)

When the RAS is synthesized out entirely, the Jump Unit falls back to naive behavior: every detected jump (including returns) is treated as unpredicted and is redirected purely from the Execute stage.

