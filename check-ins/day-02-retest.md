# Day 02 Re-test - 2026-11-19

**Why:** Day 2 average was 2.9, with switch (1), arrow functions + default params (2) and return vs print (1) below the bar.
**Before the re-test:** all Day 2 functions changed to return (except FizzBuzz and the multiplication table, which only print by design), palindrome reuses `reverseString`, `var` -> `let`, `==` -> `===`, switch program written. Lesson notes (`02-functions.md`, `02-switch.md`) not written; repo not committed.

## Questions and answers

| # | Topic | Question | Answer (summary) | Score | Feedback |
|---|---|---|---|---|---|
| 1 | switch fall-through | `grade = "B"`; `case "B":` and `case "C":` stacked, no `break` before `case "D"` | `Good` and `Pass` | 5 | Correct trace |
| 2 | Default parameters | `greet()`, `greet("Phani")`, `greet(undefined, "Hi")` | `Hello, Guest!`, `Hello, Phani!`, `Hi, Guest!` | 5 | Correct, including `undefined` triggering the default |
| 3 | Arrow function body | `const add = (a, b) => { a + b }` | `undefined` - braces need an explicit `return`; without braces it returns automatically | 5 | Complete answer |
| 4 | Return vs print | `square` only prints; `square(4) + 1` | Prints `16`, then `NaN` because nothing is returned | 4 | Output right. Reason slightly off: it isn't "adding 1 to a function" - `square(4)` returns `undefined`, and `undefined + 1` is `NaN` |
| 5 | Arrow + default + switch + return | Write `getStatusMessage(status = "PENDING")` returning messages; call with `"SHIPPED"` | Correct function and call. Follow-up: no `break` needed because `return` exits the function | 5 | Correct. A `break` after `return` would never run (unreachable code) |

## Topic scores

| Topic | Day 2 | Re-test | Status |
|---|---|---|---|
| switch fall-through | 1 | 5 | Cleared |
| Arrow functions + default params | 2 | 5 | Cleared |
| Return vs print | 1 | 4 | Cleared |

**Average:** 4.8 / 5
**Decision:** Move on to Day 3.

## What went well

- Every switch / function question answered fully on the first try, with reasons.
- Explained *why* `break` isn't needed with `return` - that's understanding, not memory.

## Still open

- Notes for functions and switch in `js-ts/learn/` - write them so this sticks.
- First git commit.
- From Day 2: var vs let reasoning, tracing with `continue`, if/else vs switch, off-by-one (re-test by Day 4).
