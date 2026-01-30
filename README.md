# Photo Favorites Date Calendar

This project exports creation dates of favorite Photos items and renders them as a calendar heatmap.

## Steps

1) Copy the Photos database files into `db_copy/`

```
cp "/Users/<user>/Pictures/Photos Library.photoslibrary/database/Photos.sqlite" db_copy/
cp "/Users/<user>/Pictures/Photos Library.photoslibrary/database/Photos.sqlite-wal" db_copy/
cp "/Users/<user>/Pictures/Photos Library.photoslibrary/database/Photos.sqlite-shm" db_copy/
```

2) Run the export script to generate `fav_dates.csv`

```
python3 export_fav_dates.py
```

3) Start a local HTTP server

```
python3 -m http.server
```

4) Open the calendar in your browser

```
http://localhost:8000/favorites_calendar.html
```

## Notes

- The script reads from `db_copy/Photos.sqlite` by default.
- To include videos, run:

```
python3 export_fav_dates.py --include-videos
```
