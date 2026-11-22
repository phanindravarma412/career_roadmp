# Roadmap Tracker (Flutter, Android)

A phone app for the daily plan, so you can check today's tasks without opening the laptop.

It reads the plan, check-in scores, check-in reports and revision notes **straight from this repo on GitHub**, so whatever is pushed to `main` shows up in the app without a rebuild. Your ticks are stored only on the phone.

## What it does

1. **Today:** the day you're on (the first day that isn't finished):
   - tasks with folder chips, tags, and an Input / Output expander
   - a ring for today's tasks, your streak, level and XP
   - an on-schedule / behind-schedule banner with a Re-plan button
   - your latest check-in result, and open revision topics
   - a preview of the next day
   - a daily line and your "why"
2. **Plan:** every week and day with status (done, in progress, today). Tap a day to see or tick its tasks.
3. **Reviews:** every `check-ins/day-NN.md` (score, date, decision; tap for the full report with each question as a card) and `notes/revision-notes.md`.
4. **Progress:**
   - overall % done and % pending, tasks and days done, and a projected date for applications at your current pace
   - level and XP
   - current and best streak, plus a 15-week activity heatmap
   - check-in scores chart with the 3.5 pass line and a "readiness" %
   - skill tracks (DSA, SQL, LLD, React, Backend…)
   - week bars and badges
5. **Guides:** the "How to prepare" sections, readable on the phone.
6. **Celebrations:** confetti when you finish a day or reach a new level.
7. **Reminders:** a daily notification at your chosen time ("Day 3: 9 tasks waiting"), plus a 9:30 PM nudge if your streak is at risk and you haven't ticked anything that day.
8. **Settings:** GitHub sync status and repo, reminder time, Day 1 date, Re-plan, your goal text, copy/restore a backup, reset.

XP: 10 per task, 25 per finished day, 50 per passed check-in (average ≥ 3.5). There are 11 levels, from "Rusty Coder" to "Senior Full-Stack" at 100%.

## First install

1. On the phone, turn on **Settings → About phone → tap Build number 7 times** (Developer options), then **Developer options → USB debugging**.
2. Connect the phone by USB and allow the computer when asked.
3. Run:

```bash
cd tracker-app
flutter install --release
```

No cable? Build the APK and send it to the phone (Drive, WhatsApp to yourself, etc.), then open it and allow "install unknown apps":

```bash
cd tracker-app
flutter build apk --release
```

The file is `tracker-app/build/app/outputs/flutter-apk/app-release.apk`.

On first launch, pick the day you're on (every earlier day is marked done) and the date you did Day 1.

## Sync with GitHub (no re-install)

After a check-in, Claude updates `plan/daily-plan.md`, `plan/progress-log.md`, `check-ins/day-NN.md` and `notes/revision-notes.md`. **Commit and push**, and the app picks them up:

- every time you open the app, and when you come back to it after a minute or more
- when you pull down on Today or Reviews, or tap the cloud icon
- Settings → Sync now

How it works: the app asks GitHub for the latest commit on `main` (repo `phanindravarma412/career_roadmp`, changeable in Settings). If it moved, it downloads only the files that changed. The last synced copy is cached on the phone, so the app works offline. The repo must stay **public**; there's no login or token. GitHub allows 60 sync checks an hour without login, which is far more than you'll use.

Only these are synced: `plan/daily-plan.md`, `plan/progress-log.md`, `check-ins/*.md` (not `_template.md`), `notes/revision-notes.md`.

You only need to re-install when the **app's code** changes. The copy built into the app (`assets/repo/`, refreshed by `./tool/sync_plan.sh`) is used only on a first launch with no internet.

Re-installing over the top keeps your ticks. **Uninstalling deletes them**, so use Settings → Copy backup first if you ever need to uninstall.

Ticks are stored by day and task number (e.g. `d3-4`). If a task is inserted in the middle of a day you already ticked, check that day once.

## Develop

```bash
flutter test      # parser, streak, schedule, GitHub sync and screen smoke tests
flutter analyze
```

Code layout:

| Path | What |
|---|---|
| `lib/models/plan.dart` | Parses the daily plan into weeks, days, tasks and guides |
| `lib/models/progress_log.dart` | Parses check-in scores and the revision list |
| `lib/models/docs.dart` | Check-in reports: title, date, average, decision |
| `lib/services/repo_sync.dart` | GitHub sync, offline cache, bundled fallback |
| `lib/state/app_state.dart` | Ticks, progress maths, schedule, XP, badges, backup |
| `lib/logic/gamification.dart` | Levels, streaks, motivation lines |
| `lib/services/reminders.dart` | Local notifications (Android only) |
| `lib/screens/` | Today, Plan, Day, Reviews, Progress, Guides, Settings, Onboarding |
| `lib/widgets/` | Task tile, markdown renderer, sync status, rings, heatmap, chart, confetti |
| `tool/sync_plan.sh` | Refreshes the offline copy in `assets/repo/` |
| `tool/icon/render_icon_test.dart` | Draws the app icon (road climbing to a flag) into `assets/icon/` |

## App icon

The icon is drawn in code. To change it, edit `tool/icon/render_icon_test.dart`, then:

```bash
flutter test tool/icon/render_icon_test.dart   # writes assets/icon/*.png (+ build/icon_preview_circle.png)
dart run flutter_launcher_icons                 # Android, adaptive, iOS and web icons
```
