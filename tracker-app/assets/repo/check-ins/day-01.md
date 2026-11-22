# Day 01 Check-in - 2026-11-08

**Day's topics:** JS variables (`var`/`let`/`const`), data types, operators, template strings; programs: temperature converter, simple interest, swap, multiplication table
**Phani's report:** All 4 programs done; simple interest total and °C/°F format fixed after review. Swap uses a temp variable (destructuring moved to Day 3). Multiplication table to be redone with a loop on Day 2.

## Questions and answers

| # | Topic | Question | Answer (summary) | Score | Feedback |
|---|---|---|---|---|---|
| 1a | var/let/const | Difference between `var`, `let`, `const`; when to use each | `const` for constants; `var` function-scoped, `let` block-scoped | 3 | Scope correct. Missed: `const` is block-scoped, prevents reassignment not mutation, hoisting, redeclaration, when to use each |
| 1b | var/let/const | Review code: `var count` declared twice, `var i` in a loop, `console.log(i)` after it | `i` is 3 because `var` leaks out of the loop; `let` would throw. `var` can be redeclared, `let` can't. Wouldn't approve: redeclaring is bad practice, may cause memory allocation / security issues | 3 | Behaviour correct. Reasons wrong: the problem is accidental overwrites and stale/leaked variables causing bugs, not memory or security. Didn't say what to change to (`let count`, `for (let i...)`) |
| 2 | const reassignment | `const x = 5; x = 10;` | Throws on line 2: `TypeError: Assignment to constant variable` | 5 | Exact line, error type and message |
| 3 | const + mutation | `const arr = [1,2]; arr.push(3)` | Works, prints `[1, 2, 3]`; can push/pop but not reassign; `arr = [4,5]` throws the same TypeError. Population analogy | 4 | Great analogy. Missing the term: `const` locks the binding (reference), not the contents |
| 4 | Data types | Name the primitives; `typeof null`; `typeof []`; how to check for an array | int, number, boolean, string; "int and boolean are inside number"; `let a;` is `undefined` (primitive); both `typeof` give `"object"`; didn't know how to check for an array | 2 | No `int` type in JS - `number` covers 3 and 3.14. Boolean is separate. Missed `bigint`, `symbol`, `null` (null is primitive; `typeof null` is a historical bug). Array check: `Array.isArray(value)` |
| 5 | Operators / coercion | `5 + "5"`, `"5" - 2`, `5 == "5"`, `5 === "5"` and why | `55`, `3`, `true` (after a slip), `false`. `+` with a string concatenates, other operators convert to number. `==` compares value, `===` value and type; uses `===` | 4 | Correct reasoning. One slip ("2" for true) |
| 6 | Template strings | Rewrite with a template string; what else they can do | `` `Total: ${total} rupees for ${name}` ``; multi-line strings; calculations inside `${}` | 5 | Complete |
| 7 | Functions: return vs print | Write `celsiusToFahrenheit` that returns; print `100°C = 212°F`; why return | Correct code after 2 nudges (misnamed variable `celsuis`, missing print line). "Return when you need the value, print when you just do an operation" | 3 | Code right in the end. Why: returning makes the function reusable (UI, API, other calculations) and testable; printing inside only fits output-only functions like a logger |
| 8 | Swap logic | Why `a = b; b = a;` fails | Both become 8 because `a` is overwritten before being saved | 5 | Clear and correct |
| R | var/let/const (re-test) | `let`/`const`/`var` for loop counter, API URL, `cartItems`, `totalPrice`; when to use `var` today | `let` for the counter (but `var` if needed after the loop); `const` URL; `const` cart (contents change, array not replaced); `let` total | 3 | 3 of 4 right with reasons. Wrong: if you need `i` after the loop, declare `let i` before the loop - don't use `var`. No reason given for `totalPrice`. Modern code: never `var` |

## Topic scores

| Topic | Score | Status |
|---|---|---|
| var / let / const | 3 | Revise within 2 days |
| const reassignment | 5 | Move on |
| const + mutation | 4 | Move on |
| Data types | 2 | Redo tomorrow before Day 2 |
| Operators / coercion | 4 | Move on |
| Template strings | 5 | Move on |
| Functions: return vs print | 3 | Revise within 2 days |
| Swap logic | 5 | Move on |

**Average:** 3.9 / 5
**Decision:** Move on to Day 2, but first spend 30 min redoing data types (one topic scored 2).

## What went well

- Error behaviour is precise: exact line, `TypeError`, message.
- Good use of analogy (population array) - interviewers remember that.
- `==` vs `===` and coercion reasoning were solid.

## What to fix

- Answer the full question. Several answers skipped a part ("when to use each", "why", the print line) until prompted.
- Give real technical reasons, not general ones ("memory", "security", "coding standards").
- JS has no `int` - only `number`.

## Added to revision list

- Data types: the 7 primitives, `typeof` quirks, `Array.isArray`
- var/let/const: why `var` causes bugs; declare `let i` before a loop if needed after it
- Return vs print: reusability and testability
