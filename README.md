# Photo Favorites Date Calendar

This project exports creation dates of favorite Apple Photos items into `fav_dates.csv` and visualizes them in `index.html`.

## Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
```

## One-command export + git push

Use the helper script:

```bash
./run_export.sh
```

It will:

1. Activate `.venv` if needed.
2. Copy `Photos.sqlite`, `Photos.sqlite-wal`, and `Photos.sqlite-shm` from:
   `~/Pictures/Photos Library.photoslibrary/database/`
3. Run `export_fav_dates.py`.
4. Remove copied DB files from `db_copy/`.
5. If `fav_dates.csv` changed vs `HEAD`, commit and push to `origin main`.

## Manual export

If you want to run steps manually:

```bash
mkdir -p db_copy
cp "$HOME/Pictures/Photos Library.photoslibrary/database/Photos.sqlite" db_copy/
cp "$HOME/Pictures/Photos Library.photoslibrary/database/Photos.sqlite-wal" db_copy/
cp "$HOME/Pictures/Photos Library.photoslibrary/database/Photos.sqlite-shm" db_copy/
python3 export_fav_dates.py
```

Optional flags:

```bash
python3 export_fav_dates.py --include-videos
python3 export_fav_dates.py --out fav_dates.csv
python3 export_fav_dates.py --db db_copy/Photos.sqlite
```

## Local preview

```bash
python3 -m http.server
```

Open:

```text
http://localhost:8000/index.html
```

## Notes

- `export_fav_dates.py` reads from `db_copy/Photos.sqlite` by default.
- Export includes only timestamps newer than year 2000 (from 2001 onward).
- `index.html` fetches `fav_dates.csv`, so opening via `file://` will not work.
- A GitHub Action deploys `fav_dates.csv` to Hetzner when that file is pushed.
