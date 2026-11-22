# Day 02 Check-in - 2026-11-18

**Day's topics:** if/else, switch, loops (`for`, `while`, `for...of`, `for...in`), functions (default params, arrow functions); programs: FizzBuzz, sum of digits, reverse string, palindrome, count vowels, multiplication table with a loop
**Phani's report:** All 6 programs done and passing after review fixes (multiplication started at 0; count vowels missed capitals). Arrow functions / default params lesson not done yet. Functions still print instead of return; `var` still in count vowels; repo not committed.

## Questions and answers

| # | Topic | Question | Answer (summary) | Score | Feedback |
|---|---|---|---|---|---|
| 1 | for...of vs for...in | Output for an array; is the `for...in` key a number or string; which works on an object | `for...of` gives values, `for...in` gives indexes 0 1 2. Said the indexes are numbers. On an object `for...of` throws `TypeError: user is not iterable`; `for...in` gives keys `name`, `city` | 4 | All correct except: `for...in` keys are **strings** (`"0"`, `"1"`), so `x + 1` gives `"01"` |
| 2 | for vs while | Why `while` for sum of digits, `for` for FizzBuzz | First answer vague ("huge numbers"); then: `for` when the number of iterations is known, `while` when looping until a condition changes | 4 | Right rule after one prompt. Could also say any `while` can be written as a `for` |
| 3 | switch fall-through | `day = 2`, no `break` after case 2 | "Tuesday", then "Tuesday and Other day", then not sure | 1 | Prints `Tuesday` **and** `Wednesday`. Without `break`, execution falls into the next case's code until a `break`; `default` is not reached because case 3 has `break` |
| 4 | Arrow functions + default params | Rewrite as arrow with `rate = 10`; value of `calculateDiscount(500)` | `const calculateDiscount = (price, rate) => price * rate / 100;` - topic not studied yet | 2 | Arrow syntax correct. Missing default: `(price, rate = 10)`. `calculateDiscount(500)` returns `50` |
| 5 | Control flow order | What breaks if the "both 3 and 5" check moves to the end of FizzBuzz | 15 would print `Fizz` and `Buzz` on two lines instead of `FizzBuzz` | 3 | Right idea that order matters, wrong trace of your own code: every branch ends with `continue`, so 15 prints only `Fizz`. Trace the code you wrote, not the general idea |
| 6 | Return vs print (re-test) | Change `reverseString` so `palindrome` can reuse it | Didn't understand; after rephrasing: "Yes, we can do that too" | 1 | Add `return reversedString;` in `reverseString`. Then `palindrome` is one line: `str.toLowerCase() === reverseString(str).toLowerCase()` |
| 7 | Data types (re-test) | `typeof` of 42, 3.5, "42", true, undefined, null; `Array.isArray([1,2])` | number, number, string, boolean, undefined, object, true | 5 | All correct - big improvement from Day 1 (2 -> 5) |
| 8 | var vs let (re-test) | Approve `var i` in countVowels? What bug? | Change to `let` because nobody uses `var` now; result is the same either way | 3 | Right change, weak reason. Real bug: `var i` belongs to the whole function, so after the loop `i` still exists and can be reused by mistake; in callbacks (Day 5) every callback sees the final `i` |
| 9 | switch vs if/else | When to use each, one example each | `switch` when one value is compared to many options, e.g. 7 weekdays | 3 | Correct for `switch`. Missing `if/else` side: ranges and combined conditions (`marks >= 90`, `age > 18 && hasLicense`) |
| 10 | Off-by-one | Lines printed by `i = 0; i <= 5`; fix to print Line 1-5 | 6 lines, i = 0 to 5 | 3 | Count correct. Didn't give the fix: `let i = 1; i <= 5` |

## Topic scores

| Topic | Score | Status |
|---|---|---|
| for...of vs for...in | 4 | Move on; note keys are strings |
| for vs while | 4 | Move on |
| switch fall-through | 1 | Redo before Day 3 |
| Arrow functions + default params | 2 | Redo before Day 3 (lesson not done) |
| Control flow order / tracing | 3 | Revise within 2 days |
| Return vs print | 1 | Redo before Day 3 |
| Data types | 5 | Cleared from revision list |
| var vs let | 3 | Revise within 2 days |
| switch vs if/else | 3 | Revise within 2 days |
| Off-by-one | 3 | Revise within 2 days |

**Average:** 2.9 / 5
**Decision:** Not ready for Day 3 yet. Before Day 3: finish the Day 2 functions lesson (arrow functions, default params), study `switch` and `break`, and make all Day 2 functions `return`. Then a 5-question re-test on those three topics.

## What went well

- Data types went from 2 to 5 - the Day 1 revision worked.
- `for...of` / `for...in` and the "not iterable" error were precise.
- Correct `for` vs `while` rule.

## What to fix

- The Day 2 lesson items (switch, functions) were skipped - programs alone don't cover them.
- Trace your actual code line by line before predicting output (Q3, Q5).
- Return vs print is now on the list twice; the Day 2 code still prints everywhere.
- Answer every part: Q4 (value of 500), Q9 (if/else example), Q10 (the fix) were each half-answered.

## Added to revision list

- switch fall-through and `break`
- Arrow functions and default parameters
- `for...in` keys are strings
- Tracing control flow with `continue`
- if/else vs switch: ranges and combined conditions
- Off-by-one: loop bounds
