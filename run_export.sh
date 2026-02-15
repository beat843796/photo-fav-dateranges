#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
DB_COPY_DIR="$SCRIPT_DIR/db_copy"
PHOTOS_DB_DIR="$HOME/Pictures/Photos Library.photoslibrary/database"

echo "[1/5] Checking and activating virtual environment..."
if [[ ! -d "$VENV_DIR" ]]; then
  echo "ERROR: Virtual environment not found at $VENV_DIR"
  echo "Create it first with: python3 -m venv .venv"
  exit 1
fi

if [[ "${VIRTUAL_ENV:-}" != "$VENV_DIR" ]]; then
  # shellcheck disable=SC1091
  source "$VENV_DIR/bin/activate"
  echo "Activated virtual environment: $VENV_DIR"
else
  echo "Virtual environment already active: $VIRTUAL_ENV"
fi

echo "[2/5] Copying Photos DB files to $DB_COPY_DIR..."
mkdir -p "$DB_COPY_DIR"
cp "$PHOTOS_DB_DIR/Photos.sqlite" "$DB_COPY_DIR/"
cp "$PHOTOS_DB_DIR/Photos.sqlite-wal" "$DB_COPY_DIR/"
cp "$PHOTOS_DB_DIR/Photos.sqlite-shm" "$DB_COPY_DIR/"
echo "DB files copied successfully."

echo "[3/5] Running export_fav_dates.py..."
python "$SCRIPT_DIR/export_fav_dates.py"
echo "Export finished."

echo "[4/5] Cleaning up $DB_COPY_DIR..."
rm -f "$DB_COPY_DIR/Photos.sqlite" \
      "$DB_COPY_DIR/Photos.sqlite-wal" \
      "$DB_COPY_DIR/Photos.sqlite-shm"
echo "Cleanup complete."

echo "[5/5] Checking for changes in fav_dates.csv..."
if git -C "$SCRIPT_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
  if git -C "$SCRIPT_DIR" diff --quiet HEAD -- "$SCRIPT_DIR/fav_dates.csv"; then
    echo "No changes in fav_dates.csv compared to last commit. Skipping commit/push."
  else
    echo "Changes detected in fav_dates.csv. Committing and pushing..."
    git -C "$SCRIPT_DIR" add "$SCRIPT_DIR/fav_dates.csv"
    git -C "$SCRIPT_DIR" commit -m "dates udpate" -- "$SCRIPT_DIR/fav_dates.csv"
    git -C "$SCRIPT_DIR" push origin main
    echo "Changes pushed to origin/main."
  fi
else
  echo "No commits found yet (HEAD missing). Skipping commit/push step."
fi

echo "All steps completed."
