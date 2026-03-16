import os
import json
import glob
import re
import psycopg2
from dotenv import load_dotenv

load_dotenv()

db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")

connection = psycopg2.connect(
    host=db_host, 
    port=db_port,
    dbname=db_name,
    user=db_user,
    password=db_password
)
cursor = connection.cursor()

# Find all trending movie files
file_pattern = "datasets/raw/trending_movies_*.json"

for filepath in glob.glob(file_pattern):
    filename = os.path.basename(filepath)
    
    # Extract run_date from filename (e.g., trending_movies_2026_03_15_page1.json)
    match = re.search(r'trending_movies_(\d{4})_(\d{2})_(\d{2})', filename)
    if match:
        run_date = f"{match.group(1)}-{match.group(2)}-{match.group(3)}"
    else:
        print(f"Skipping {filename}: could not extract date")
        continue
    
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    for movie in data["results"]:
        cursor.execute("""
            INSERT INTO bronze.tmdb_trending_info (
                adult, backdrop_path, id, title, original_title, overview,
                poster_path, media_type, original_language, genre_ids,
                popularity, release_date, video, vote_average, vote_count, run_date
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id, run_date) DO NOTHING
        """, (
            movie["adult"],
            movie.get("backdrop_path"),
            movie["id"],
            movie["title"],
            movie["original_title"],
            movie["overview"],
            movie.get("poster_path"),
            movie["media_type"],
            movie["original_language"],
            movie["genre_ids"],
            movie["popularity"],
            movie.get("release_date") or None,
            movie["video"],
            movie["vote_average"],
            movie["vote_count"],
            run_date
        ))
    
    print(f"Loaded {len(data['results'])} movies from {filename}")

connection.commit()
cursor.close()
connection.close()

print("All trending movies loaded successfully!")