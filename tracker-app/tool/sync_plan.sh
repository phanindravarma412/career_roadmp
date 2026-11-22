#!/bin/sh
# Copies the repo's plan, check-ins and revision notes into the app's assets.
# The app downloads the latest versions from GitHub by itself; these bundled
# copies are only used on first launch with no internet. Run this before a
# release build so the offline copy isn't too old.
set -e
cd "$(dirname "$0")/.."
rm -rf assets/repo
mkdir -p assets/repo/plan assets/repo/check-ins assets/repo/notes
cp ../plan/daily-plan.md ../plan/progress-log.md assets/repo/plan/
for f in ../check-ins/*.md; do
  case "$(basename "$f")" in _*) ;; *) cp "$f" assets/repo/check-ins/ ;; esac
done
cp ../notes/revision-notes.md assets/repo/notes/
echo "Synced into tracker-app/assets/repo/"
