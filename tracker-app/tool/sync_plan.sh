#!/bin/sh
# Copies the latest plan files from the repo into the app's assets.
# Run this after plan/daily-plan.md or plan/progress-log.md changes, then rebuild.
set -e
cd "$(dirname "$0")/.."
cp ../plan/daily-plan.md assets/plan/daily-plan.md
cp ../plan/progress-log.md assets/plan/progress-log.md
echo "Plan synced into tracker-app/assets/plan/"
