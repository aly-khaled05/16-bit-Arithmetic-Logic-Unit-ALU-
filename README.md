# 16-bit Arithmetic Logic Unit (ALU)

A modular **16-bit ALU** written in Verilog, split into independent Arithmetic, Logic, and Shift/Rotate blocks combined through parameterized 3-to-1 multiplexers. Verified with a self-checking testbench (`ALU_TESTBENCH.V`).


## Files

| File | Description |
|---|---|
| `Alu.v` | RTL source — all modules |
| `ALU_TESTBENCH.V` | Self-checking testbench |
| `run.do` | QuestaSim/ModelSim simulation script |
| `ALU_report.pdf` | Full design report (architecture, verification methodology, waveforms, schematics) |

## Top-Level Interface

```verilog
module ALU (A, B, F, Cin, Result, Status);
    input  [15:0] A, B;    // operands
    input  [4:0]  F;       // opcode: F[4:3] = block select, F[2:0] = operation select
    input         Cin;     // carry-in / borrow-in
    output [15:0] Result;  // 16-bit result
    output [5:0]  Status;  // {C, Z, N, V, P, A}
endmodule
```

`F` is a 5-bit opcode. The top two bits (`F[4:3]`) choose which functional block drives the output; the bottom three bits (`F[2:0]`) are forwarded to that block as its own operation select.

### Opcode Map

| F[4:3] | Block | F[2:0] | Operation |
|---|---|---|---|
| `00` | Arithmetic | `001` | INC |
| `00` | Arithmetic | `011` | DEC |
| `00` | Arithmetic | `100` | ADD |
| `00` | Arithmetic | `101` | ADD + Cin |
| `00` | Arithmetic | `110` | SUB |
| `00` | Arithmetic | `111` | SUB − Cin (borrow) |
| `01` | Logic | `000` | AND |
| `01` | Logic | `001` | OR |
| `01` | Logic | `010` | XOR |
| `01` | Logic | `011` | NOT (of `A`) |
| `10` | Shift/Rotate | `000` | SHL |
| `10` | Shift/Rotate | `001` | SHR |
| `10` | Shift/Rotate | `010` | SAL |
| `10` | Shift/Rotate | `011` | SAR |
| `10` | Shift/Rotate | `100` | ROL |
| `10` | Shift/Rotate | `101` | ROR |
| `10` | Shift/Rotate | `110` | RCL (rotate-with-carry left) |
| `10` | Shift/Rotate | `111` | RCR (rotate-with-carry right) |

### Status Flags (`Status[5:0]`)

| Bit | Flag | Meaning |
|---|---|---|
| 5 | C | Carry / borrow out |
| 4 | Z | Result is zero |
| 3 | N | Result is negative (MSB) |
| 2 | V | Signed overflow |
| 1 | P | Parity (even parity of result) |
| 0 | A | Auxiliary carry (carry out of bit 3, low nibble) |

Not every block uses every flag — see the module breakdown below for which flags are driven vs. left `x` (don't-care).

## Module Breakdown

### `MUX_3_to_1`

A parameterized 3-to-1 multiplexer, reused twice: once at `data_size = 16` for selecting the result, and once instantiated as `#(6)` for selecting the 6-bit status word.

```verilog
module MUX_3_to_1(I1, I2, I3, sel, Out);
parameter data_size = 16;
```

`sel = 2'b00` → `I1`, `2'b01` → `I2`, `2'b10` → `I3`, anything else → `0`. In the top-level `ALU`, `sel` is wired to `F[4:3]`, so this is what actually routes one block's output to the ALU's pins.

### `Arithmetic_block`

Handles INC, DEC, ADD, ADD+Cin, SUB, and SUB−Cin. All six ops drive all six flags.

- **C** is computed differently per op: for INC it's `&X` (carry only if `X` is all 1s and would wrap), for ADD/SUB it's the carry/borrow bit out of a 17-bit intermediate sum (`out_with_carry[16]`).
- **V** (overflow) is derived by comparing the carry into bit 15 against the carry out of bit 15 (`carryout_of_bit_14 ^ C`) — the standard two's-complement overflow check, computed via an extra 15-bit adder/subtractor (`carryout14_bus`) just to extract that internal carry.
- **A** (auxiliary carry) is computed the same way but scoped to the bottom 4 bits (`summation_first_4bits_with_carry[4]` / `subtraction_first_4bits[4]`), i.e. carry out of the low nibble.
- **Z, N, P** are computed directly from `OUT`: `Z = ~|OUT` (NOR-reduce), `N = OUT[15]`, `P = ~^OUT` (XNOR-reduce, so `P=1` for even parity).

### `logic_block`

Handles AND, OR, XOR, NOT. Only `X` is used for NOT; `Y` is ignored.

- **C, V, A** are explicitly forced to `1'bx` since they're meaningless for bitwise logic ops — this is intentional (not a bug) and matches how the testbench checks these operations: it only compares `Z`, `N`, and `P`, skipping `C`/`V`/`A`.
- **Z, N, P** follow the same reductions as the arithmetic block.

### `shift_block`

Handles SHL, SHR, SAL, SAR, ROL, ROR, RCL, RCR on operand `X` only (single-operand block; `Y`/`B` isn't connected here).

- **SHL/SAL** are functionally identical in this implementation: both shift left by one, feeding in a `0` at the LSB (`{X[14:0], 1'b0}`), with `C = X[15]` (the bit shifted out).
- **SHR** shifts right logically, feeding a `0` into the MSB (`{1'b0, X[15:1]}`), `C = X[0]`.
- **SAR** shifts right but preserves the sign bit (`{X[15], X[15:1]}`) — a true arithmetic shift.
- **ROL/ROR** rotate the bit that falls off back around to the opposite end (`{X[14:0], X[15]}` / `{X[0], X[15:1]}`).
- **RCL/RCR** rotate *through* the external carry-in: the bit that falls off becomes the new `C`, and `Cin` is shifted in on the other side (`{X[14:0], Cin}` / `{Cin, X[15:1]}`).
- **V, A** are forced to `1'bx` (unused for shifts), matching how the testbench validates this block — it checks `C`, `Z`, `N`, and `P` only.

### `ALU` (top level)

Instantiates `Arithmetic_block`, `logic_block`, and `shift_block` in parallel — all three always compute their result from `A`/`B`/`Cin` every cycle, regardless of which one is actually selected. `F[2:0]` is fanned out to all three blocks as their local operation select, and the two `MUX_3_to_1` instances (driven by `F[4:3]`) pick which block's `{OUT, flags}` pair actually reaches `Result`/`Status`.

This is a combinational, single-cycle design — no clock, no state. `Result` and `Status` settle purely as a function of the current `A`, `B`, `F`, and `Cin`.

## Testbench (`ALU_TESTBENCH.V`)

`ALU_tb` instantiates the `ALU` as the DUT and drives it with 18 directed test vectors — one per opcode. Each vector:

1. Drives `A_tb`, `B_tb` (where relevant), `F_tb`, and `Cin_tb` (where relevant).
2. Waits `#10` for the combinational logic to settle.
3. Sets `result_expected` / `status_expected` to hand-computed values.
4. Compares expected vs. DUT output and prints `CORRECT OUTPUT, <op> is working well` on a match, or halts with `$stop` and an error message on mismatch.

For logic and shift ops, only the flags that block actually drives are checked (e.g. logic ops only check `Z`, `N`, `P`; shift ops check `C`, `Z`, `N`, `P`), matching the `1'bx` don't-cares described above.

## Running the Simulation

```tcl
vlib work
vlog Alu.v ALU_TESTBENCH.V
vsim -voptargs=+acc work.ALU_tb
add wave *
run -all
```

Or simply:

```tcl
do run.do
```

See `ALU_report.pdf` for the full design rationale, verification methodology, waveform captures, and Vivado-elaborated schematics.
