# Career Roadmap

Phani's 14-week prep to move from a service-company lead role to a **Senior Full-Stack Engineer** at a mid-to-large product company.

- **Main lane:** React + Node.js + PostgreSQL, all in TypeScript
- **Bonus lane:** Flutter
- **Rule:** AI tools off for everything in this repo. Type it yourself.

## Start here

1. Read `plan/career-plan.md` once - the strategy and why.
2. Read the "How to prepare" section at the top of `plan/daily-plan.md`.
3. Do Day 0 in `plan/daily-plan.md`.
4. Every day after: do that day's tasks, commit, then check in with Claude for a quiz and score.

## Folders

| Folder | What goes in it | Used on |
|---|---|---|
| `plan/` | `career-plan.md` (strategy), `daily-plan.md` (Day 0-98 tasks + how-to-prepare guides), `progress-log.md` (check-in scores, filled in by Claude) | Every day |
| `.vscode/` | Workspace settings that turn off Copilot and all AI inline suggestions in this repo | Always |
| `js-ts/` | `learn/` for topic notes (`01-variables.md`), `programs/` for exercises (`01_temp_converter.js`) | Days 1-7 |
| `dsa/` | LeetCode solutions, one file per problem | Day 8 onward |
| `react/` | React projects: Contacts app, product list, todo, machine-coding builds | Days 8-21, Weeks 6 and 10 |
| `backend/` | Node + Express + TypeScript APIs, Prisma, auth, Redis, queues, tests | Weeks 2-4, 7, 8, 10 |
| `sql/` | SQL scripts: table designs, practice queries, LeetCode SQL answers | Week 3, Week 7 |
| `dart/` | Dart language exercises | Week 5 |
| `flutter/` | Flutter apps, including the client for your own Node API | Week 5, Week 10 |
| `system-design/` | One file per design: notes, diagrams (screenshots or Excalidraw exports), trade-offs | Weeks 6-9 weekends |
| `lld/` | Low-level design in TypeScript: OOP, SOLID, patterns, and 8 designs (parking lot, Splitwise, elevator, ticket booking...). One folder per design with `design.md` + code | Weeks 8-11 |
| `check-ins/` | Daily test results from Claude: `day-NN.md` with every question, your answer, score (1-5), feedback and the move-on decision. `_template.md` shows the format | Every day |
| `notes/` | `revision-notes.md` (correct answers from check-in feedback, by topic), `mistakes-log.md`, `stories.md` (STAR stories), daily notes, cheatsheets | Every day |
| `resume/` | Resume versions (full-stack, Flutter), LinkedIn text, target company list | Weeks 10-12 |
| `tracker-app/` | **Roadmap Tracker**, a Flutter Android app showing the plan, today's tasks, check-in reports, revision notes, streak, % done and reminders. It syncs from this GitHub repo by itself, so **push after each check-in** and the phone updates. Not practice code; see its `README.md` to install | Every day (on the phone) |

## Naming

| Where | Pattern | Example |
|---|---|---|
| `dsa/` | `<4-digit number>-<name>.ts` | `dsa/0001-two-sum.ts` |
| `sql/leetcode/` | `<number>-<name>.sql` | `sql/leetcode/0175-combine-two-tables.sql` |
| `js-ts/learn/` | `<NN>-<topic>.md` | `js-ts/learn/01-variables.md` |
| `js-ts/programs/` | `<NN>_<name>.js` (or `.ts` from Day 6) | `js-ts/programs/01_temp_converter.js` |
| `dart/` | same `learn/` + `programs/` layout as `js-ts/` | `dart/programs/01_basics.dart` |
| `react/`, `flutter/`, `backend/` | one folder per project | `react/contacts-v0/`, `backend/contacts-api/` |
| `system-design/` | `<name>.md` | `system-design/url-shortener.md` |
| `notes/` | `day-<NN>.md` for daily notes | `notes/day-01.md` |

## Daily loop

1. Open `plan/daily-plan.md` at today's day.
2. Do the tasks in order, AI off.
3. Write 3 lines in `notes/day-NN.md`: what I learned, what confused me, what to redo.
4. Add any problem you got stuck on to `notes/mistakes-log.md`.
5. Tell Claude "Day NN done" - answer the quiz from memory and get your score.
6. Claude saves the result in `check-ins/day-NN.md` and updates `plan/progress-log.md`.
7. Commit everything: `git add . && git commit -m "Day NN"` and push.

## Running things

| What | Command |
|---|---|
| A JS file | `node js-ts/programs/01_temp_converter.js` |
| A TS file | `npx tsx js-ts/programs/<NN>_<name>.ts` |
| A DSA solution | `npx tsx dsa/0001-two-sum.ts` |
| A Dart file | `dart run dart/programs/01_basics.dart` |
| New React app | `cd react && npm create vite@latest contacts-v0 -- --template react-ts` |
| New Flutter app | `cd flutter && flutter create contacts_app` |
| Postgres shell | `psql -U postgres` |
