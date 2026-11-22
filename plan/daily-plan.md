# Daily Plan - Full Stack (Day 0 to Day 98)

- Day 1 is the Monday you start. 14 weeks total. Applications start on Day 99.
- Weekdays: 2 hours. Weekends: 5 hours.
- Main lane: React + Node + PostgreSQL (all in TypeScript). Bonus lane: Flutter.
- Keep AI tools off for all of it.
- (DSA) = data structures and algorithms practice. (SQL) = SQL query practice. (LLD) = low-level design practice.
- [Brackets] = LeetCode problem number. (P) = premium on LeetCode, solve it free on neetcode.io.
- Program tasks list the **Input** and expected **Output** under them. Your program is done when it prints the same values (Node adds its own spacing, e.g. `[ 1, 2, 3 ]` - that's fine). LeetCode problems use the examples on LeetCode.
- The chip at the end of each task is the folder where you do it, e.g. `react/`. Two chips = work in both. `setup` = no folder (machine setup).

---

# How to prepare

## How to prepare for DSA
1. Use one language for all problems: JavaScript (or TypeScript).
2. Before a new topic, watch the NeetCode explanation of that data structure and draw it on paper (20 min).
3. Read the problem and say it back in your own words.
4. Write 2 examples and 1 edge case (empty input, one item, duplicates, negatives).
5. Say the brute-force solution and its Big-O first, even if it is slow.
6. Then look for the pattern (see the table below).
7. Give yourself 25 minutes. If still stuck, watch the video only until you get the idea, close it, and code it yourself.
8. Test your code by hand with your examples before pressing Run.
9. State time and space complexity at the end.
10. Add every problem you got stuck on to `notes/mistakes-log.md`: problem, pattern, why you missed it.
11. Re-solve mistakes after 3 days and again after 7 days.
12. Talk aloud while solving, even alone. Interviews grade your thinking, not just the code.
13. Understand 100 problems rather than memorise 300. If you can't explain why it works, it isn't done.
14. From Week 10, solve with a timer and without autocomplete, like a real interview.

**Pattern cheatsheet**

| If the problem says... | Try... |
|---|---|
| Find a pair, count, duplicates | Hash map / Set |
| Sorted array, pair from both ends | Two pointers |
| Longest/shortest subarray or substring | Sliding window |
| Brackets, "next greater", undo | Stack |
| Sorted input, "minimum that works" | Binary search |
| Tree problem | Recursion (DFS) or level by level (BFS) |
| Shortest path, levels, spreading | BFS |
| Dependencies, order of tasks | Topological sort |
| All combinations / subsets / permutations | Backtracking |
| Top K, kth largest, running median | Heap |
| Count ways, min/max cost, choices at each step | Dynamic programming |
| Overlapping time ranges | Sort by start, then merge |

## How to prepare for React interviews
1. Know the basics without thinking: components, props, state, `useEffect`, keys, controlled forms.
2. For every topic, prepare 3 things: what it is, an example from your own project, and its trade-off.
3. Practise answering these aloud:
   1. What causes a component to re-render?
   2. How does reconciliation work, and why do keys matter?
   3. When do you use `useMemo`, `useCallback` and `React.memo` - and when not?
   4. What is a stale closure in a hook? How do you fix it?
   5. Context vs Redux Toolkit vs Zustand vs React Query - when do you pick each?
   6. How do you make a slow list or page faster?
   7. How do you handle auth tokens in a React app safely?
   8. Explain the JavaScript event loop, closures, and `this`.
   9. What happens when you type a URL and press Enter?
4. Machine-coding rounds are common: build a working feature in 60-90 min. Practise weekly.
5. Practise coding in a plain editor or CodeSandbox. Many interviews don't give you your IDE.

## How to prepare for backend (Node.js) interviews
1. Build first, then learn theory: every concept should map to code you wrote in `backend/`.
2. Know HTTP well: methods, status codes, headers, cookies, CORS.
3. Be able to design a clean REST API: resource names, pagination, filtering, versioning, error format, idempotency.
4. Practise answering these aloud:
   1. How does Node handle thousands of requests on one thread?
   2. What blocks the event loop, and how do you avoid it?
   3. How does middleware work in Express?
   4. How do you implement login with JWT and refresh tokens? Where do you store them?
   5. How do you hash passwords, and why not encrypt them?
   6. How do you handle errors and logging in production?
   7. When do you use a queue or background job?
   8. How do you add rate limiting?
   9. How do you test an API?
   10. Monolith vs microservices - when would you split?
5. Be ready to write an Express endpoint with validation and error handling from memory.

## How to prepare for SQL and databases
1. Write every query by hand. Reading SQL is not the same as writing it.
2. Practise on your own tables (Week 3 e-commerce schema) and on LeetCode SQL problems.
3. Master in this order: SELECT/WHERE -> JOINs -> GROUP BY/HAVING -> subqueries -> window functions.
4. For every table you design, say: primary key, foreign keys, which indexes, and why.
5. Run `EXPLAIN ANALYZE` on slow queries and learn to read the output.
6. Practise answering these aloud:
   1. What is an index, and when does it not help?
   2. What do ACID and isolation levels mean?
   3. What is the N+1 query problem?
   4. Normalisation - what is 3NF, and when do you denormalise?
   5. SQL vs NoSQL - when would you pick MongoDB or Redis?
   6. How do you scale a database (replicas, sharding, caching)?

## How to prepare for LLD (low-level design)
1. Learn the 4 OOP ideas first: encapsulation, abstraction, inheritance, polymorphism - each with a TypeScript example.
2. Learn SOLID. For each principle, write one bad example and the fixed version.
3. Learn the patterns that come up most: singleton, factory, builder, strategy, observer, state, decorator, repository. For each: what problem it solves and one real example.
4. Follow the same steps in every LLD round:
   1. Clarify requirements (2-5 min): list the features, ask which are must-haves.
   2. Find the entities (nouns become classes) and actions (verbs become methods).
   3. Draw the class diagram: fields, methods, and relationships (has-a, is-a).
   4. Use patterns only where they fit naturally. Don't force them in to impress.
   5. Write code for the core flows and keep it runnable.
   6. Walk through one use case end to end.
   7. Discuss extensions: a new vehicle type, a new pricing rule, two users acting at once.
5. Prefer composition over inheritance, and code against interfaces.
6. Handle edge cases and concurrency where they matter (two people booking the same seat).
7. Time-box each problem to 60-90 minutes, AI off, from a blank file.
8. Save each one in `lld/<name>/`: `design.md` (requirements + class diagram) and the code.
9. Practise answering these aloud:
   1. Explain each SOLID principle with an example from your own code.
   2. Composition vs inheritance - when do you pick each?
   3. When is a singleton a bad idea?
   4. How do you prevent double booking?
   5. What's the difference between LLD and system design (HLD)?

**Common LLD questions**

| Question | Key idea | In the plan |
|---|---|---|
| Parking lot | Inheritance for vehicle types, strategy for pricing | Day 76 |
| Tic-tac-toe / snake and ladder | Clean classes, game loop, working code | Day 77 |
| Library management | Entities, relationships, search, fines | Day 83 |
| Splitwise (expense sharing) | Balance calculation, strategy for split types | Day 84 |
| Vending machine | State pattern | Day 85 |
| Elevator system | State pattern, scheduling strategy | Day 86 |
| Food-delivery order flow | Order states, observer for status updates | Day 87 |
| Movie ticket booking | Seat locking, concurrency | Day 90 |
| Extra, if you have time | ATM, logger, LRU cache, rate limiter, notification service, hotel booking, chess | - |

## How to prepare for Flutter interviews (bonus lane)
1. Know: Stateless vs Stateful, widget lifecycle, `setState`, keys, `BuildContext`.
2. Practise answering aloud: what happens on `setState`; why `const` constructors; `Future` vs `Stream`; the three trees; which state management and why; fixing a laggy list; Flutter vs React Native.
3. Be ready to draw the architecture of one of your Divami Flutter apps and explain every choice.

## How to prepare for system design
1. Learn the basics first: HTTP, REST, auth tokens, caching, CDN, load balancers, databases, queues.
2. Always start by asking questions: who are the users, how many, read-heavy or write-heavy, real-time needed, what matters most.
3. Use the same order every time: requirements -> rough scale numbers -> API -> data model -> high-level diagram -> deep dive (cache, DB scaling, queues) -> trade-offs -> monitoring.
4. Draw boxes and arrows on paper or excalidraw.com while you talk.
5. For every decision, say the trade-off ("I chose X because..., the cost is...").
6. As a full-stack candidate, cover both sides: the client (state, caching, pagination, offline) and the server (API, DB, scaling).
7. Practise on your own apps first, then on new problems.

## How to prepare for HR and manager rounds
1. Write 7 STAR stories (Situation, Task, Action, Result), 2 minutes each.
2. Put numbers in results where you can: users, time saved, crashes reduced, team size.
3. Prepare: 60-second intro, "Why leave?", "Why product company?", strengths, one real weakness.
4. Salary: don't say a number first. If pushed, give a range based on research, not on your current CTC.
5. Notice period: "60 days, open to discussing an early release."
6. Prepare 2-3 questions to ask the interviewer (team, challenges, how success is measured).

## On interview day
1. Check camera, mic and internet 15 minutes early.
2. Keep pen and paper ready.
3. Ask clarifying questions before writing any code.
4. Think aloud the whole time.
5. If stuck, say what you're thinking. Asking for a hint is better than silence.
6. Test your code with an example before saying "done".
7. After the interview, write down every question you were asked and tell me.

## How to do mock interviews with me
1. Send a message like "Mock: DSA", "Mock: React", "Mock: Node", "Mock: SQL", "Mock: system design", "Mock: LLD" or "Mock: HR".
2. I act as the interviewer; no hints unless you ask.
3. You get feedback at the end: what went well, what to fix, what to practise next.

## Daily check-in with me (after every day)
1. Send: "Day N done", what you completed, what was hard, how long it took.
2. I act as a real interviewer: a fixed set of **10 questions, one at a time**, numbered so you know where you are. At most **one** short follow-up, only when an answer is unclear - otherwise straight to the next question. No scores or model answers during the quiz - those come together at the end. Question types: explain a concept, predict code output, write a small piece of code or a SQL query from memory, or explain a problem's approach and Big-O.
3. Answer from memory. No docs, no AI, no IDE. "I don't know" is a fine answer; a guess hides the gap.
4. I score each topic from 1 to 5:

| Score | Meaning | What happens |
|---|---|---|
| 5 | Interview ready - clear answer, handles follow-ups | Move on |
| 4 | Solid, small gaps | Move on; note the gap |
| 3 | Shaky | Move on, but revise it within 2 days (15-30 min) |
| 2 | Weak | Redo that part tomorrow before the new day's tasks |
| 1 | Not learned | Repeat the day |

5. **Rule to move on:** average 3.5 or more, and no topic at 2 or below.
6. On Sundays the check-in covers the whole week, not just that day.
7. I save the full test in `check-ins/day-NN.md`: every question, a summary of your answer, the score, feedback and the decision.
8. I add a one-line summary to `plan/progress-log.md` and update the revision list, so we can see trends across weeks.
9. I add the correct answers for anything you missed to `notes/revision-notes.md`, organised by topic. Read it before every Sunday check-in.
10. Commit these files with that day's work.

---

## Day 0 (weekend before)
1. Install Node.js LTS; check `node -v` `setup`
2. Install PostgreSQL (or Docker Desktop to run it later) `setup`
3. Run `flutter doctor` and fix every error `setup`
4. Turn off AI extensions in VS Code `setup`
5. Open the `career-roadmap` folder in VS Code; read its `README.md`; create a GitHub repo and push it `setup`
6. Make LeetCode and NeetCode accounts `setup`
7. Block 2 hours daily and 5 hours on weekends in your calendar `setup`

---

# Week F1 - JavaScript, TypeScript, Node basics

## Day 1
1. Learn JavaScript variables: `let`, `const`, data types, operators, template strings `js-ts/`
2. Write a temperature converter `js-ts/`
   - Input: `celsius = 100`, `fahrenheit = 98.6`
   - Output: `100°C = 212°F` and `98.6°F = 37°C`
   - Also test: `0°C = 32°F`, `-40°C = -40°F`
3. Write a simple interest calculator `js-ts/`
   - Input: `principal = 10000`, `rate = 5`, `time = 2`
   - Output: `Interest: 1000, Total: 11000`
4. Write a program to swap two numbers `js-ts/`
   - Input: `a = 4`, `b = 8`
   - Output: `Before: a = 4, b = 8` then `After: a = 8, b = 4`
   - Use a temporary variable (destructuring comes on Day 3)
5. Write a multiplication table `js-ts/`
   - Input: `num = 7`
   - Output: 10 lines, from `7 x 1 = 7` to `7 x 10 = 70`
6. Write 3 lines of notes and commit `notes/`

## Day 2
1. Learn if/else and switch `js-ts/`
2. Learn `for`, `while`, `for...of` and `for...in` loops `js-ts/`
3. Learn functions: default params, arrow functions `js-ts/`
4. Write FizzBuzz `js-ts/`
   - Input: `n = 15`
   - Output: numbers 1 to 15, one per line, but multiples of 3 print `Fizz`, multiples of 5 print `Buzz`, multiples of both print `FizzBuzz`
   - Expected: `1, 2, Fizz, 4, Buzz, Fizz, 7, 8, Fizz, Buzz, 11, Fizz, 13, 14, FizzBuzz`
5. Write sum of digits `js-ts/`
   - Input: `1234` -> Output: `10`
   - Also test: `9` -> `9`, `0` -> `0`
   - Use maths (`%` and `Math.floor`), not string conversion
6. Write reverse a string `js-ts/`
   - Input: `"hello"` -> Output: `"olleh"`
   - Also test: `""` -> `""`
   - Use a loop, not `.reverse()`
7. Write palindrome check `js-ts/`
   - Input: `"madam"` -> Output: `true`
   - Input: `"hello"` -> Output: `false`
   - Bonus: `"Madam"` -> `true` (ignore upper/lower case)
8. Write count vowels `js-ts/`
   - Input: `"Hello World"` -> Output: `3`
   - Also test: `"rhythm"` -> `0`
9. Rewrite `04_multiplication_table.js` with a `for` loop (no repeated lines); print `4 x 3 = 12` with `=`; rename the function parameter so it doesn't shadow the outer `number`. Bonus: print tables 1-10 with a nested loop `js-ts/`
   - Input: `num = 4`
   - Output: 10 lines, from `4 x 1 = 4` to `4 x 10 = 40`
10. Write 3 lines of notes and commit `notes/`

## Day 2 redo (from the Day 2 check-in - do before Day 3)
1. Learn arrow functions and default parameters; write notes in `js-ts/learn/02-functions.md` `js-ts/`
2. Learn `switch`, `break` and fall-through; write notes in `js-ts/learn/02-switch.md` `js-ts/`
3. Make all 6 Day 2 functions **return** instead of print; print outside the function `js-ts/`
   - Rewrite `palindrome` to reuse `reverseString` (one line)
   - Change `var i` to `let i` in `09_count_vowels.js`; use `===` in FizzBuzz
4. Write a `switch` program `js-ts/`
   - Input: `status = "PAID"`
   - Output: `"PENDING"` -> `Waiting for payment`, `"PAID"` -> `Payment received`, `"SHIPPED"` -> `On the way`, anything else -> `Unknown status`
5. Re-test with me: 5 questions on functions, switch and return vs print `check-ins/`
6. Commit everything (first commit of the repo) `notes/`

## Day 3
1. Learn arrays and `map`, `filter`, `reduce`, `slice`, `splice`, `sort` `js-ts/`
2. Learn objects, `Map` and `Set` `js-ts/`
3. Learn destructuring and spread `js-ts/`
   - Practice: add a second swap to `03_swap_numbers.js` using `[a, b] = [b, a]`; same input and output as Day 1
4. Write word count using a Map `js-ts/`
   - Input: `"the cat and the hat"`
   - Output: `Map(4) { 'the' => 2, 'cat' => 1, 'and' => 1, 'hat' => 1 }`
5. Write remove duplicates using a Set `js-ts/`
   - Input: `[1, 2, 2, 3, 1, 4]` -> Output: `[1, 2, 3, 4]`
6. Write filter even numbers `js-ts/`
   - Input: `[1, 2, 3, 4, 5, 6]` -> Output: `[2, 4, 6]`
   - Use `filter`, not a loop
7. Write group names by first letter `js-ts/`
   - Input: `["Ravi", "Rahul", "Anil", "Arjun", "Sita"]`
   - Output: `{ R: ['Ravi', 'Rahul'], A: ['Anil', 'Arjun'], S: ['Sita'] }`
8. Remember: `[10, 2, 1].sort()` gives `[1, 10, 2]`. Always use `(a, b) => a - b` `notes/`
9. Write 3 lines of notes and commit `notes/`

## Day 4
1. Learn classes, constructors, inheritance, getters `js-ts/`
2. Learn closures and `this` `js-ts/`
3. Learn modules: `import` and `export` `js-ts/`
4. Write a `Contact` class with `fromJSON` and `toJSON` `js-ts/`
   - Input: `new Contact("Ravi", "9876543210", "ravi@mail.com")`
   - Output of `contact.toJSON()`: `{ name: 'Ravi', phone: '9876543210', email: 'ravi@mail.com' }`
   - Input: `Contact.fromJSON({ name: "Sita", phone: "9123456780", email: "sita@mail.com" })`
   - Output: a `Contact` object; `result instanceof Contact` prints `true`
5. Write a `Shape` class with `Circle` and `Rectangle` `js-ts/`
   - Input: `new Circle(7)`, `new Rectangle(4, 5)`
   - Output: loop over `[circle, rect]` and print `Circle area: 153.94` and `Rectangle area: 20`
   - `Shape.area()` itself should throw `Error: area() not implemented`
6. Write a `BankAccount` class with deposit and withdraw `js-ts/`
   - Input: `const acc = new BankAccount("Ravi", 1000)`
   - `acc.deposit(500)` -> balance `1500`
   - `acc.withdraw(2000)` -> prints `Error: Insufficient balance`; balance stays `1500`
   - `acc.deposit(-100)` -> prints `Error: Amount must be positive`
7. Write 3 lines of notes and commit `notes/`

## Day 5
1. Learn callbacks, promises, `async`/`await` `js-ts/`
2. Learn `try/catch` and `setTimeout` `js-ts/`
3. Learn the event loop basics `js-ts/`
4. Write a fake `fetchUsers()` that waits 1 second `js-ts/`
   - Input: none
   - Output after about 1 second: `[ { id: 1, name: 'Ravi' }, { id: 2, name: 'Sita' } ]`
5. Make it fail sometimes and handle the error `js-ts/`
   - Fail about half the time (use `Math.random()`)
   - Output on failure: `Failed: Network error`, and the program does not crash
6. Run 3 fake calls together with `Promise.all` `js-ts/`
   - Input: 3 fake calls that take 1, 2 and 3 seconds
   - Output: all 3 results, then `Done in 3.0s` (about 3 seconds in total, not 6)
7. Write 3 lines of notes and commit `notes/`

## Day 6 (Saturday, 5 h)
1. Set up TypeScript (`tsconfig.json`, run with `npx tsx`) `js-ts/`
2. Learn types, interfaces, `type` vs `interface` `js-ts/`
3. Learn union types, optional fields, enums, generics `js-ts/`
4. Learn `unknown` vs `any` `js-ts/`
5. Redo Day 3 exercises in TypeScript `js-ts/`
   - Same inputs and outputs as Day 3
   - No `any`; every function has typed parameters and a return type
6. Redo Day 4 exercises in TypeScript `js-ts/`
   - Same inputs and outputs as Day 4
   - `Shape` becomes an `abstract class`; `new Shape()` should give a compile error
7. Write 3 lines of notes and commit `notes/`

## Day 7 (Sunday, 5 h)
1. Learn Node basics: `npm`, `package.json`, scripts `js-ts/`
2. Learn `fs`, `path` and `process` `js-ts/`
3. Write a script that reads `contacts.json` and prints a summary `js-ts/`
   - Input: create `contacts.json` yourself with 5 contacts (`name`, `phone`, `city`); leave one `phone` empty; 3 in Hyderabad, 2 in Bangalore
   - Output, 3 lines: `Total contacts: 5` / `By city: Hyderabad 3, Bangalore 2` / `Missing phone: 1`
4. Write a JS/TS cheatsheet from memory, then check it `notes/`
5. Test: FizzBuzz, word count and `Contact` class in TypeScript in 30 minutes `js-ts/`
   - Same inputs and outputs as Days 2-4
6. Write 3 lines of notes and commit `notes/`

---

# Week F2 - React from zero + DSA basics

## Day 8
1. Create a React + TypeScript project with Vite `react/`
2. Learn JSX, components and props `react/`
3. Build a profile card component `react/`
4. (DSA) Learn what Big-O means (O(1), O(n), O(n^2), O(log n)) `dsa/`
5. Write 3 lines of notes and commit `notes/`

## Day 9
1. Learn CSS layout: flexbox and grid `react/`
2. Build a login screen layout `react/`
3. (DSA) Learn how arrays work `dsa/`
4. (DSA) Write "find max" and "reverse array" `dsa/`
   - Input: `[3, 9, 2, 7]`
   - Output: max `9` (without `Math.max`); reversed in place `[7, 2, 9, 3]` (without `.reverse()`, no new array)
5. Write 3 lines of notes and commit `notes/`

## Day 10
1. Learn `useState`, events and conditional rendering `react/`
2. Build a counter `react/`
3. Build a list item with a like button `react/`
4. (DSA) Learn how hash maps work `dsa/`
5. (DSA) Solve Two Sum [1] `dsa/`
6. Write 3 lines of notes and commit `notes/`

## Day 11
1. Learn rendering lists with `.map()` and keys `react/`
2. Build a list of 20 contacts `react/`
3. (DSA) Solve Contains Duplicate [217] `dsa/`
4. (DSA) Solve Valid Anagram [242] `dsa/`
5. Write 3 lines of notes and commit `notes/`

## Day 12
1. Learn controlled forms and validation `react/`
2. Learn `react-router`: routes and URL params `react/`
3. Build a contact detail page `react/`
4. (DSA) Learn the two pointers technique `dsa/`
5. (DSA) Solve Valid Palindrome [125] `dsa/`
6. Write 3 lines of notes and commit `notes/`

## Day 13 (Saturday, 5 h)
1. Build Contacts app v0: list page `react/`
2. Add a detail page `react/`
3. Add an "add contact" form `react/`
4. Add delete `react/`
5. (DSA) Learn how stacks and queues work `dsa/`
6. (DSA) Solve Valid Parentheses [20] `dsa/`
7. (DSA) Solve Best Time to Buy and Sell Stock [121] `dsa/`
8. Write 3 lines of notes and commit `notes/`

## Day 14 (Sunday, 5 h)
1. Rebuild the Contacts app from a blank project without looking (2 h) `react/`
2. (DSA) Re-solve all 6 problems from this week `dsa/`
3. Read about HTTP methods, status codes and JSON `notes/`
4. Mock interview with me: basics check `check-ins/`
5. Write 3 lines of notes and commit `notes/`

---

# Week 1 - React with real API data

## Day 15
1. (DSA) Solve Group Anagrams [49] `dsa/`
2. (DSA) Solve Top K Frequent Elements [347] `dsa/`
3. Fetch data with `useEffect` from dummyjson.com; show loading and error `react/`
4. Write 3 lines of notes and commit `notes/`

## Day 16
1. (DSA) Solve Product of Array Except Self [238] `dsa/`
2. (DSA) Solve Encode and Decode Strings [271] (P) `dsa/`
3. Write a custom hook: `useFetch` `react/`
4. Write 3 lines of notes and commit `notes/`

## Day 17
1. (DSA) Solve Valid Sudoku [36] `dsa/`
2. (DSA) Solve Longest Consecutive Sequence [128] `dsa/`
3. Learn lifting state up and the Context API `react/`
4. Write 3 lines of notes and commit `notes/`

## Day 18
1. (DSA) Solve Two Sum II [167] `dsa/`
2. (DSA) Solve 3Sum [15] `dsa/`
3. Add search with debounce `react/`
4. Write 3 lines of notes and commit `notes/`

## Day 19
1. (DSA) Solve Container With Most Water [11] `dsa/`
2. Add pagination or infinite scroll `react/`
3. Write 3 lines of notes and commit `notes/`

## Day 20 (Saturday, 5 h)
1. (DSA) Re-solve 2 problems from your mistakes log `dsa/`
2. (DSA) Optional: Trapping Rain Water [42] `dsa/`
3. Build a product list app: search, filters, pagination, detail page `react/`
4. Read about REST and HTTP status codes `notes/`
5. Write 3 lines of notes and commit `notes/`

## Day 21 (Sunday, 5 h)
1. (DSA) Re-solve 3 problems, 25 minutes each, talking aloud `dsa/`
2. Replace your fetching with React Query (TanStack Query) `react/`
3. Rebuild the list page from blank in 45 minutes `react/`
4. Read about login with sessions vs JWT `notes/`
5. Write 3 lines of notes and commit `notes/`

---

# Week 2 - Node + Express REST API

## Day 22
1. (DSA) Solve Longest Substring Without Repeating Characters [3] `dsa/`
2. (DSA) Solve Longest Repeating Character Replacement [424] `dsa/`
3. Create a server with Node's `http` module that returns JSON (no framework) `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 23
1. (DSA) Solve Permutation in String [567] `dsa/`
2. (DSA) Solve Min Stack [155] `dsa/`
3. Set up Express + TypeScript; learn routes, params, query, body `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 24
1. (DSA) Solve Evaluate Reverse Polish Notation [150] `dsa/`
2. (DSA) Solve Daily Temperatures [739] `dsa/`
3. Learn middleware: logging, error handler, CORS `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 25
1. (DSA) Solve Generate Parentheses [22] `dsa/`
2. (DSA) Solve Car Fleet [853] `dsa/`
3. Build a CRUD API for contacts (in-memory array) with correct status codes `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 26
1. (DSA) Re-solve 2 problems from your mistakes log `dsa/`
2. Add request validation with `zod` `backend/`
3. Split code into routes, controllers and services `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 27 (Saturday, 5 h)
1. (DSA) Re-solve 3 problems `dsa/`
2. Finish the Contacts API; test every endpoint in Postman or Thunder Client `backend/`
3. Connect your React Contacts app to your own API `react/`
4. Read about REST API design: naming, pagination, versioning, idempotency `notes/`
5. Write 3 lines of notes and commit `notes/`

## Day 28 (Sunday, 5 h)
1. (DSA) Re-solve 3 problems, timed `dsa/`
2. Write API tests with Jest and Supertest `backend/`
3. Read how Node's event loop handles many requests `notes/`
4. Write 3 lines of notes and commit `notes/`

---

# Week 3 - SQL + PostgreSQL

## Day 29
1. (DSA) Solve Binary Search [704] `dsa/`
2. (DSA) Solve Search a 2D Matrix [74] `dsa/`
3. Start Postgres; use `psql`; learn `CREATE TABLE`, data types, `INSERT`, `SELECT`, `WHERE`, `ORDER BY`, `LIMIT` `sql/`
4. Write 3 lines of notes and commit `notes/`

## Day 30
1. (DSA) Solve Koko Eating Bananas [875] `dsa/`
2. (DSA) Solve Find Minimum in Rotated Sorted Array [153] `dsa/`
3. Learn `UPDATE`, `DELETE`, primary keys, foreign keys, `UNIQUE`, `NOT NULL` `sql/`
4. Create `users` and `contacts` tables `sql/`
5. Write 3 lines of notes and commit `notes/`

## Day 31
1. (DSA) Solve Search in Rotated Sorted Array [33] `dsa/`
2. (DSA) Solve Time Based Key-Value Store [981] `dsa/`
3. Learn JOINs: inner, left, right `sql/`
4. (SQL) Solve Combine Two Tables [175], Employees Earning More Than Their Managers [181] `sql/`
5. Write 3 lines of notes and commit `notes/`

## Day 32
1. (DSA) Solve Reverse Linked List [206] `dsa/`
2. (DSA) Solve Merge Two Sorted Lists [21] `dsa/`
3. Learn `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG` `sql/`
4. (SQL) Solve Duplicate Emails [182], Customers Who Never Order [183] `sql/`
5. Write 3 lines of notes and commit `notes/`

## Day 33
1. (DSA) Solve Linked List Cycle [141] `dsa/`
2. (DSA) Solve Remove Nth Node From End of List [19] `dsa/`
3. Learn subqueries and window functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`) `sql/`
4. (SQL) Solve Second Highest Salary [176], Rank Scores [178] `sql/`
5. Write 3 lines of notes and commit `notes/`

## Day 34 (Saturday, 5 h)
1. (SQL) Solve Department Highest Salary [184], Department Top Three Salaries [185], Consecutive Numbers [180] `sql/`
2. Design tables for a small shop: users, products, orders, order_items `sql/`
3. Write 10 queries on it (top customers, monthly revenue, unsold products...) `sql/`
4. Read about normalisation (1NF, 2NF, 3NF) `notes/`
5. Write 3 lines of notes and commit `notes/`

## Day 35 (Sunday, 5 h)
1. (DSA) Re-solve 3 problems `dsa/`
2. Connect your Node API to Postgres with `pg` (raw SQL); remove the in-memory array `backend/`
3. Read about SQL injection and parameterised queries `notes/`
4. Write 3 lines of notes and commit `notes/`

---

# Week 4 - Full-stack app with login

## Day 36
1. (DSA) Solve Reorder List [143] `dsa/`
2. (DSA) Solve Add Two Numbers [2] `dsa/`
3. Learn Prisma: schema, migrations, client; move your API to Prisma `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 37
1. (DSA) Solve Copy List with Random Pointer [138] `dsa/`
2. (DSA) Solve LRU Cache [146] `dsa/`
3. Add relations (a user has many contacts) and API pagination (offset and cursor) `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 38
1. (DSA) Solve Invert Binary Tree [226] `dsa/`
2. (DSA) Solve Maximum Depth of Binary Tree [104] `dsa/`
3. (DSA) Solve Same Tree [100] `dsa/`
4. Add signup and login with `bcrypt` password hashing `backend/`
5. Write 3 lines of notes and commit `notes/`

## Day 39
1. (DSA) Re-solve 2 problems `dsa/`
2. Add JWT access tokens and an auth middleware; protect the routes `backend/`
3. Write 3 lines of notes and commit `notes/`

## Day 40
1. (DSA) Re-solve 2 problems `dsa/`
2. Add refresh tokens `backend/`
3. In React: login page, store the token, protected routes `react/`
4. Write 3 lines of notes and commit `notes/`

## Day 41 (Saturday, 5 h)
1. (DSA) Re-solve 3 problems `dsa/`
2. Finish full-stack Contacts app v1: React + Node + Postgres + login; each user sees only their contacts `react/` `backend/`
3. Read: CORS, cookies vs localStorage for tokens, OWASP Top 10 overview `notes/`
4. Write 3 lines of notes and commit `notes/`

## Day 42 (Sunday, 5 h)
1. **Exit test (2 h):** build a full-stack CRUD app (one table, API + React list and form), no AI, no docs `react/` `backend/`
2. (DSA) Re-solve 2 problems `dsa/`
3. Mock interview with me: coding check `check-ins/`
4. Write 3 lines of notes and commit `notes/`

---

# Week 5 - Flutter recall (bonus lane)

## Day 43
1. (DSA) Solve Diameter of Binary Tree [543] `dsa/`
2. (DSA) Solve Balanced Binary Tree [110] `dsa/`
3. Dart refresh: redo Day 2 and Day 3 exercises in Dart `dart/`
   - Same inputs and outputs as Day 2 and Day 3
4. Write 3 lines of notes and commit `notes/`

## Day 44
1. (DSA) Solve Subtree of Another Tree [572] `dsa/`
2. (DSA) Solve Binary Tree Level Order Traversal [102] `dsa/`
3. Dart classes, null safety, `Future`; write `Contact` with `fromJson` `dart/`
   - Same input and output as the Day 4 `Contact` exercise
   - Make `email` optional (`String?`); `Contact.fromJson` with no email should still work
4. Write 3 lines of notes and commit `notes/`

## Day 45
1. (DSA) Solve Binary Tree Right Side View [199] `dsa/`
2. (DSA) Solve Count Good Nodes in Binary Tree [1448] `dsa/`
3. Flutter: `Scaffold`, `Row`/`Column`, `StatefulWidget`; build profile and login screens `flutter/`
4. Write 3 lines of notes and commit `notes/`

## Day 46
1. (DSA) Solve Lowest Common Ancestor of a BST [235] `dsa/`
2. (DSA) Solve Validate Binary Search Tree [98] `dsa/`
3. Flutter: `ListView.builder`, `Navigator`, forms; contacts list -> detail `flutter/`
4. Write 3 lines of notes and commit `notes/`

## Day 47
1. (DSA) Solve Kth Smallest Element in a BST [230] `dsa/`
2. (DSA) Solve Construct Binary Tree from Preorder and Inorder [105] `dsa/`
3. Flutter: `http` + `FutureBuilder`; call your own Node API (Android emulator uses `10.0.2.2` for localhost) `flutter/`
4. Write 3 lines of notes and commit `notes/`

## Day 48 (Saturday, 5 h)
1. (DSA) Re-solve 3 problems `dsa/`
2. Build a Flutter client for your full-stack Contacts app, with login (Provider or Riverpod) `flutter/`
3. Write notes: Flutter vs React Native vs React web `notes/`
4. Write 3 lines of notes and commit `notes/`

## Day 49 (Sunday, 5 h)
1. (DSA) Re-solve 3 problems, timed `dsa/`
2. Rebuild a Flutter list -> detail -> form app from blank in 90 minutes `flutter/`
3. Write 3 lines of notes and commit `notes/`

---

# Week 6 - JavaScript + React depth

## Day 50
1. (DSA) Write a MinHeap in JavaScript from scratch `dsa/`
2. (DSA) Solve Kth Largest Element in a Stream [703] `dsa/`
3. Learn the JS event loop: microtasks vs macrotasks; closures; `this` `js-ts/`
4. Write 3 lines of notes and commit `notes/`

## Day 51
1. (DSA) Solve Last Stone Weight [1046] `dsa/`
2. (DSA) Solve K Closest Points to Origin [973] `dsa/`
3. Learn what triggers a React re-render; reconciliation; keys `react/`
4. Write 3 lines of notes and commit `notes/`

## Day 52
1. (DSA) Solve Kth Largest Element in an Array [215] `dsa/`
2. (DSA) Solve Task Scheduler [621] `dsa/`
3. Learn hook pitfalls: stale closures, `useEffect` dependencies, cleanup; `useRef`, `useMemo`, `useCallback`, `React.memo` `react/`
4. Write 3 lines of notes and commit `notes/`

## Day 53
1. (DSA) Solve Merge Intervals [56] `dsa/`
2. (DSA) Solve Insert Interval [57] `dsa/`
3. Compare Context, Redux Toolkit, Zustand and React Query - when to use each `react/`
4. Write 3 lines of notes and commit `notes/`

## Day 54
1. (DSA) Solve Non-overlapping Intervals [435] `dsa/`
2. Learn React performance: code splitting, lazy loading, list virtualisation, React DevTools Profiler, Web Vitals `react/`
3. Write 3 lines of notes and commit `notes/`

## Day 55 (Saturday, 5 h)
1. (DSA) Solve Meeting Rooms [252] (P) `dsa/`
2. (DSA) Solve Meeting Rooms II [253] (P) `dsa/`
3. Frontend system design: design a news feed web app `system-design/`
4. Write interview story 1: leading your team `notes/stories.md`
5. Write interview story 2: a conflict `notes/stories.md`
6. Write 3 lines of notes and commit `notes/`

## Day 56 (Sunday, 5 h)
1. DSA mock interview with me `check-ins/`
2. Build a React todo app with filters and saved state in 90 minutes `react/`
3. Read how a browser loads a page; caching headers `notes/`
4. Write 3 lines of notes and commit `notes/`

---

# Week 7 - Database depth

## Day 57
1. (DSA) Solve Number of Islands [200] `dsa/`
2. (DSA) Solve Max Area of Island [695] `dsa/`
3. Learn indexes (B-tree, composite); run `EXPLAIN ANALYZE` on your shop database `sql/`
4. Write 3 lines of notes and commit `notes/`

## Day 58
1. (DSA) Solve Clone Graph [133] `dsa/`
2. (DSA) Solve Rotting Oranges [994] `dsa/`
3. Learn transactions, ACID, isolation levels, locks `sql/`
4. Write 3 lines of notes and commit `notes/`

## Day 59
1. (DSA) Solve Pacific Atlantic Water Flow [417] `dsa/`
2. (DSA) Solve Surrounded Regions [130] `dsa/`
3. Learn the N+1 query problem and connection pooling `sql/`
4. Write 3 lines of notes and commit `notes/`

## Day 60
1. (DSA) Solve Course Schedule [207] `dsa/`
2. (DSA) Solve Course Schedule II [210] `dsa/`
3. Learn MongoDB basics: documents, collections, when to use it instead of SQL `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 61
1. (DSA) Solve Redundant Connection [684] `dsa/`
2. (SQL) Solve Nth Highest Salary [177], Rising Temperature [197] `sql/`
3. Learn Redis basics: keys, TTL, using it as a cache `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 62 (Saturday, 5 h)
1. (DSA) Re-solve 3 problems `dsa/`
2. Design the database for a food-delivery app; explain each index `sql/`
3. Write interview story 3: a failure `notes/stories.md`
4. Write interview story 4: toughest technical problem `notes/stories.md`
5. Write 3 lines of notes and commit `notes/`

## Day 63 (Sunday, 5 h)
1. (DSA) Re-solve 3 problems, timed `dsa/`
2. Add Redis caching to your Contacts API `GET` endpoint `backend/`
3. Read: SQL vs NoSQL trade-offs; database replication basics `notes/`
4. Write 3 lines of notes and commit `notes/`

---

# Week 8 - Backend depth

## Day 64
1. (DSA) Solve Subsets [78] `dsa/`
2. (DSA) Solve Combination Sum [39] `dsa/`
3. Learn the Node event loop in depth; blocking vs non-blocking; worker threads `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 65
1. (DSA) Solve Permutations [46] `dsa/`
2. (DSA) Solve Subsets II [90] `dsa/`
3. Learn error handling, logging (pino), config and environment variables, secrets `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 66
1. (DSA) Solve Letter Combinations of a Phone Number [17] `dsa/`
2. (DSA) Solve Word Search [79] `dsa/`
3. Learn background jobs and queues (BullMQ + Redis) `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 67
1. (DSA) Re-solve 2 problems `dsa/`
2. Learn rate limiting, file uploads, and WebSockets (socket.io) `backend/`
3. Write 3 lines of notes and commit `notes/`

## Day 68
1. (DSA) Re-solve 2 problems `dsa/`
2. Learn unit vs integration tests; mocking the database; test coverage `backend/`
3. Write 3 lines of notes and commit `notes/`

## Day 69 (Saturday, 5 h)
1. (DSA) Re-solve 2 problems `dsa/`
2. (LLD) Learn OOP and SOLID with TypeScript examples (1 h) `lld/`
3. Backend system design: design a URL shortener `system-design/`
4. Write interview story 5: an architecture decision `notes/stories.md`
5. Write interview story 6: mentoring someone `notes/stories.md`
6. Write 3 lines of notes and commit `notes/`

## Day 70 (Sunday, 5 h)
1. (DSA) Re-solve 2 problems, timed `dsa/`
2. (LLD) Learn design patterns: singleton, factory, strategy, observer, state (1 h) `lld/`
3. Add a background job (fake welcome email) or live updates with WebSockets to your app `backend/`
4. Read: monolith vs microservices `notes/`
5. Write 3 lines of notes and commit `notes/`

---

# Week 9 - Backend system design

## Day 71
1. (DSA) Solve Climbing Stairs [70] `dsa/`
2. (DSA) Solve Min Cost Climbing Stairs [746] `dsa/`
3. Learn load balancers, horizontal vs vertical scaling, stateless servers `system-design/`
4. Write 3 lines of notes and commit `notes/`

## Day 72
1. (DSA) Solve House Robber [198] `dsa/`
2. (DSA) Solve House Robber II [213] `dsa/`
3. Learn caching strategies (cache-aside, write-through), CDN, cache invalidation `system-design/`
4. Write 3 lines of notes and commit `notes/`

## Day 73
1. (DSA) Solve Coin Change [322] `dsa/`
2. (DSA) Solve Decode Ways [91] `dsa/`
3. Learn read replicas, sharding, partitioning; the CAP theorem in simple terms `system-design/`
4. Write 3 lines of notes and commit `notes/`

## Day 74
1. (DSA) Solve Longest Palindromic Substring [5] `dsa/`
2. (DSA) Solve Palindromic Substrings [647] `dsa/`
3. Learn message queues (Kafka/RabbitMQ concepts), event-driven design, eventual consistency `system-design/`
4. Write 3 lines of notes and commit `notes/`

## Day 75
1. (DSA) Solve Word Break [139] `dsa/`
2. (DSA) Solve Longest Increasing Subsequence [300] `dsa/`
3. Learn API gateways, auth across services, idempotency `system-design/`
4. Write 3 lines of notes and commit `notes/`

## Day 76 (Saturday, 5 h)
1. (DSA) Re-solve 2 problems `dsa/`
2. (LLD) Design a parking lot in TypeScript (1 h) `lld/`
3. Design a chat system, full-stack: client, API, WebSockets, database, scaling `system-design/`
4. Write interview story 7: spec-driven / AI development `notes/stories.md`
5. Write 3 lines of notes and commit `notes/`

## Day 77 (Sunday, 5 h)
1. (DSA) Re-solve 2 problems, timed `dsa/`
2. (LLD) Build tic-tac-toe or snake and ladder as working code (1 h) `lld/`
3. Design a notification system or a rate limiter `system-design/`
4. System design mock with me `check-ins/`
5. Write 3 lines of notes and commit `notes/`

---

# Week 10 - Deploy, Flutter depth, resume

## Day 78
1. (DSA) Solve Maximum Product Subarray [152] `dsa/`
2. (DSA) Solve Maximum Subarray [53] `dsa/`
3. Learn Docker: images, containers, a Dockerfile for your Node API; docker-compose with Postgres and Redis `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 79
1. (DSA) Solve Jump Game [55] `dsa/`
2. (DSA) Solve Jump Game II [45] `dsa/`
3. Set up GitHub Actions: run tests and build on every push `backend/`
4. Write 3 lines of notes and commit `notes/`

## Day 80
1. (DSA) Solve Gas Station [134] `dsa/`
2. (DSA) Solve Partition Labels [763] `dsa/`
3. Learn AWS basics: EC2, S3, RDS, Lambda - what each is for `notes/`
4. Write 3 lines of notes and commit `notes/`

## Day 81
1. (DSA) Solve Unique Paths [62] `dsa/`
2. (DSA) Solve Longest Common Subsequence [1143] `dsa/`
3. Flutter depth: widget/element/render trees, keys, constraints, state management choice `flutter/`
4. Write 3 lines of notes and commit `notes/`

## Day 82
1. (DSA) Re-solve 2 problems `dsa/`
2. Rewrite your resume: full-stack version `resume/`
3. Write 3 lines of notes and commit `notes/`

## Day 83 (Saturday, 5 h)
1. (DSA) Re-solve 2 problems `dsa/`
2. (LLD) Design a library management system (1 h) `lld/`
3. Deploy the full-stack app (API on Render/Railway or AWS, React on Vercel/Netlify) `react/` `backend/`
4. Write a README with an architecture diagram; pin the repo on GitHub `react/` `backend/`
5. Make the Flutter version of your resume; update LinkedIn `resume/`
6. Write 3 lines of notes and commit `notes/`

## Day 84 (Sunday, 5 h)
1. (DSA) Re-solve 2 problems, timed `dsa/`
2. (LLD) Design Splitwise - expense sharing (1 h) `lld/`
3. React machine-coding mock with me (90 min) `react/`
4. Node + database deep-dive mock with me `check-ins/`
5. Write 3 lines of notes and commit `notes/`

---

# Week 11 - LLD, security, first applications

## Day 85
1. (DSA) Solve Coin Change II [518] `dsa/`
2. (DSA) Solve Target Sum [494] `dsa/`
3. (LLD) Revise SOLID; design a vending machine (state pattern) `lld/`
4. Write 3 lines of notes and commit `notes/`

## Day 86
1. (DSA) Solve Edit Distance [72] `dsa/`
2. (DSA) Solve Best Time to Buy and Sell Stock with Cooldown [309] `dsa/`
3. (LLD) Design an elevator system `lld/`
4. Write 3 lines of notes and commit `notes/`

## Day 87
1. (DSA) Solve Implement Trie [208] `dsa/`
2. (DSA) Solve Design Add and Search Words [211] `dsa/`
3. (LLD) Design a food-delivery order flow (order states, status updates) `lld/`
4. Write 3 lines of notes and commit `notes/`

## Day 88
1. (DSA) Solve Find Median from Data Stream [295] `dsa/`
2. Learn security: OWASP Top 10, XSS, CSRF, SQL injection, HTTPS, hashing vs encryption `notes/`
3. Write 3 lines of notes and commit `notes/`

## Day 89
1. (DSA) Solve Merge K Sorted Lists [23] `dsa/`
2. Complete your Naukri profile `resume/`
3. Write 20 likely full-stack interview questions; answer them aloud `notes/`
4. Write 3 lines of notes and commit `notes/`

## Day 90 (Saturday, 5 h)
1. (DSA) Re-solve 3 problems `dsa/`
2. (LLD) Design a movie ticket booking system (seat locking, no double booking) `lld/`
3. Apply to 3-5 practice companies `resume/`
4. Prepare answers: "Why leave?", "Why product?", 60-second intro `notes/stories.md`
5. Write 3 lines of notes and commit `notes/`

## Day 91 (Sunday, 5 h)
1. (DSA) Solve 3 problems from your mistakes log, timed `dsa/`
2. Behavioural mock with me `check-ins/`
3. Flutter quick revision: answer the Flutter question list aloud `notes/`
4. Write 3 lines of notes and commit `notes/`

---

# Week 12 - Final practice

## Day 92
1. (DSA) Solve 2 old problems, timed `dsa/`
2. (DSA) Solve Partition Equal Subset Sum [416] `dsa/`
3. Revise JavaScript and TypeScript notes `notes/`
4. Write 3 lines of notes and commit `notes/`

## Day 93
1. (DSA) Solve 2 old problems, timed `dsa/`
2. (DSA) Solve Hand of Straights [846] `dsa/`
3. Revise React notes `notes/`
4. Write 3 lines of notes and commit `notes/`

## Day 94
1. (DSA) Solve 2 old problems, timed `dsa/`
2. (DSA) Optional: Minimum Window Substring [76] `dsa/`
3. Revise Node and database notes; redo 5 SQL problems `notes/` `sql/`
4. Write 3 lines of notes and commit `notes/`

## Day 95
1. (DSA) Solve 2 old problems, timed `dsa/`
2. Revise system design notes `notes/`
3. List 20-30 target companies `resume/`
4. Write 3 lines of notes and commit `notes/`

## Day 96
1. (DSA) Solve 2 old problems, timed `dsa/`
2. Ask 5 people for referrals `resume/`
3. Write 3 lines of notes and commit `notes/`

## Day 97 (Saturday, 5 h)
1. Full mock interview with me (3 hours: coding, full-stack design, hiring manager) `check-ins/`
2. Build a small full-stack feature in 90 minutes `react/` `backend/`
3. Fix the weakest area from the mock `notes/`
4. Write 3 lines of notes and commit `notes/`

## Day 98 (Sunday, 5 h)
1. Second full mock interview with me (includes an LLD round) `check-ins/`
2. Final check of resume, LinkedIn and Naukri `resume/`
3. Pick which companies to apply to first `resume/`
4. Write 3 lines of notes and commit `notes/`

---

## Day 99 onward
1. Start applying, referrals first `resume/`
2. Keep solving 2 problems a day `dsa/`
3. Tell me after every interview `check-ins/`
