# Revision Notes

Correct answers to everything I got wrong or incomplete in check-ins. Organised by topic, so it grows into one revision sheet.
Read this before every Sunday check-in and before real interviews.

---

## Interview habits

- **Answer every part of the question.** Before finishing, re-read the question: did I answer "what", "why" and "when"? (Day 1: skipped "when to use each", "why", and the print line until prompted.)
- **Give technical reasons, not general ones.** "Memory", "security", "coding standards" and "nobody uses it" are not reasons unless I can explain the actual problem. (Day 1, Day 2)
- **Trace my actual code before predicting output.** Go line by line through the code on screen, not the general idea. (Day 2: FizzBuzz with `continue`, switch without `break`)

---

## JavaScript

### `var` vs `let` vs `const` (Day 1)

| | Scope | Redeclare | Reassign | Use before declaring |
|---|---|---|---|---|
| `var` | Function | Yes | Yes | Gives `undefined` (hoisted) |
| `let` | Block | No | Yes | Error |
| `const` | Block | No | No | Error |

- **Rule:** `const` by default, `let` only when the value changes, never `var` in modern code.
- **Why `var` is a problem - bugs, not memory or security:**
  - Declaring `var count` twice silently overwrites the first one, and no error warns you.
  - A `var i` in a loop leaks out, so later code can use a stale `i` by mistake.
- **Need `i` after a loop?** Declare it before the loop - don't switch to `var`:

```js
let i;
for (i = 0; i < 3; i++) { }
console.log(i); // 3
```

### What `const` actually locks (Day 1)

`const` locks the **binding** - the link between the name and the value - not the contents.

```js
const arr = [1, 2];
arr.push(3);   // OK: contents change -> [1, 2, 3]
arr = [4, 5];  // TypeError: Assignment to constant variable.
```

Analogy: the label is glued to the box; you can still change what's inside the box.

### Data types (Day 1)

- **7 primitives:** `string`, `number`, `bigint`, `boolean`, `undefined`, `null`, `symbol`.
- **No `int` type.** `3` and `3.14` are both `number`. `boolean` is its own type, not part of `number`.
- Everything else (arrays, functions, plain objects) is an **object**.

| Expression | Result | Note |
|---|---|---|
| `typeof 3.14` | `"number"` | |
| `typeof undefined` | `"undefined"` | `let a;` gives `undefined` |
| `typeof null` | `"object"` | Old JS bug - `null` is still a primitive |
| `typeof []` | `"object"` | Arrays are objects |
| `Array.isArray([])` | `true` | **The** way to check for an array |

### Return vs print inside a function (Day 1)

Prefer returning the value; let the caller decide what to do with it.

```js
function celsiusToFahrenheit(c) {
  return c * (9 / 5) + 32;
}

const fahrenheit = celsiusToFahrenheit(100);
console.log(`100°C = ${fahrenheit}°F`);
```

- **Reusable:** the same value can go to the UI, an API response, or another calculation.
- **Testable:** a test can check `celsiusToFahrenheit(100) === 212`; you can't easily test something that only prints.
- **One job per function:** calculate *or* display, not both.
- Print inside a function only when output is its whole job (e.g. a logger).
- **Reuse needs return (Day 2):** `palindrome` had to copy the reverse loop because `reverseString` only printed. With a return it's one line:

```js
function reverseString(str) {
  let reversed = "";
  for (let i = str.length - 1; i >= 0; i--) reversed += str[i];
  return reversed;
}

const isPalindrome = (str) =>
  str.toLowerCase() === reverseString(str).toLowerCase();
```

**A function with no `return` gives back `undefined` (Day 2 re-test):**

```js
function square(n) { console.log(n * n); }
const result = square(4) + 1; // prints 16, but square(4) returns undefined
console.log(result);          // NaN, because undefined + 1 is NaN
```

**`return` inside a `switch` replaces `break`:** `return` exits the whole function, so the next cases never run. A `break` after a `return` would never execute.

### `var` in a loop - the actual bug (Day 2)

`var i` belongs to the **whole function**, not the loop. After the loop it still exists (holding the last value), so a later loop or variable named `i` silently reuses it. With callbacks (Day 5) every callback sees the final `i`:

```js
for (var i = 0; i < 3; i++) setTimeout(() => console.log(i)); // 3 3 3
for (let i = 0; i < 3; i++) setTimeout(() => console.log(i)); // 0 1 2
```

### `switch` and fall-through (Day 2)

A `case` is only an **entry point**. Execution keeps going into the next cases until it hits a `break` (or the end).

```js
const day = 2;
switch (day) {
  case 1: console.log("Monday");
  case 2: console.log("Tuesday");     // enters here
  case 3: console.log("Wednesday");   // falls through, prints too
          break;                      // stops here
  default: console.log("Other day");  // never reached
}
// Output: Tuesday, Wednesday
```

Rule: end every case with `break` unless you deliberately want fall-through (then add a comment saying so).

### `switch` vs `if/else` (Day 2)

| Use | When | Example |
|---|---|---|
| `switch` | One value compared against many exact matches | Day names, order status `"PENDING"` / `"PAID"` / `"SHIPPED"` |
| `if/else` | Ranges or combined conditions | `marks >= 90` -> A; `age >= 18 && hasLicense` |

### Arrow functions and default parameters (Day 2)

```js
// Regular function
function calculateDiscount(price, rate = 10) {
  return price * rate / 100;
}

// Arrow function - same thing
const calculateDiscount2 = (price, rate = 10) => price * rate / 100;

calculateDiscount2(500);     // 50  (rate defaults to 10)
calculateDiscount2(500, 20); // 100
```

- One-line arrow body returns automatically (no `return`, no `{}`).
- With `{}` you must write `return`.
- A default kicks in only when the argument is missing or `undefined`.

### Loops (Day 2)

| Loop | Gives you | Works on |
|---|---|---|
| `for...of` | Values | Arrays, strings, Maps, Sets (iterables). On a plain object: `TypeError: ... is not iterable` |
| `for...in` | Keys, **as strings** (`"0"`, `"1"`) | Objects (and arrays, but avoid it for arrays) |
| `for` | You control the counter | Known number of iterations |
| `while` | Runs until a condition changes | Unknown number of iterations (e.g. sum of digits) |

**Off-by-one:** `for (let i = 0; i <= 5; i++)` runs **6** times (0-5). For exactly 1-5: `let i = 1; i <= 5`.

**`continue` changes the trace:** in FizzBuzz, if the `% 3` check comes first and ends in `continue`, 15 prints only `Fizz` - the later checks never run. That's why the "both" check must come first.
