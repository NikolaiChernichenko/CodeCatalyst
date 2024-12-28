#!/usr/bin/env bash

# 1. Define your commit messages
COMMIT_MESSAGES=(
  "Refactor code for clarity"
  "Fix minor bug"
  "Add new feature"
  "Update documentation"
  "Improve performance"
  "Cleanup deprecated code"
  "Add test coverage"
  "Code style improvements"
  "Fix merge conflicts"
  "Version bump"
)

# 2. Define author details
AUTHOR_NAME="gordonshumwayalf"
AUTHOR_EMAIL="miceleturincio@gmail.com"

# 3. Define your date range
START_DATE="2020-05-25"
END_DATE="2021-05-04"

# 4. Generate all dates from START_DATE to END_DATE using Python
date_list=$(python3 -c "
import datetime
start = datetime.datetime.strptime('$START_DATE', '%Y-%m-%d')
end = datetime.datetime.strptime('$END_DATE', '%Y-%m-%d')
current = start
while current <= end:
    print(current.strftime('%Y-%m-%d'))
    current += datetime.timedelta(days=1)
")

# 5. Iterate over the generated dates
for current_date in $date_list; do

  # --- Determine day of week (Monday=0, Sunday=6) ---
  day_of_week=$(python3 -c "
import datetime
dt = datetime.datetime.strptime('$current_date', '%Y-%m-%d')
print(dt.weekday())
")

  # Skip Sundays entirely (weekday=6)
  if [ "$day_of_week" -eq 6 ]; then
    continue  # no commits on Sunday
  fi

  # Randomly skip some Saturdays (weekday=5)
  if [ "$day_of_week" -eq 5 ]; then
    # 50% chance to skip
    if [ $((RANDOM % 2)) -eq 0 ]; then
      continue  # skip this Saturday
    fi
  fi

  # Generate a random number between 4 and 12 for daily commits
  # RANDOM % 9 gives 0..8; adding 4 yields 4..12
  num_commits=$((4 + RANDOM % 9))

  for i in $(seq 1 "$num_commits"); do
    # Pick a random message from the array
    random_index=$((RANDOM % ${#COMMIT_MESSAGES[@]}))
    commit_message="${COMMIT_MESSAGES[$random_index]}"

    # Make a file change so there's something to commit
    echo "Commit on $current_date #$i" >> commits.txt

    # Stage changes
    git add commits.txt

    # Commit with artificial author/committer details and date
    GIT_AUTHOR_NAME="$AUTHOR_NAME" \
    GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL" \
    GIT_COMMITTER_NAME="$AUTHOR_NAME" \
    GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL" \
    GIT_AUTHOR_DATE="$current_date 12:00:00" \
    GIT_COMMITTER_DATE="$current_date 12:00:00" \
    git commit -m "$commit_message"
  done

done
