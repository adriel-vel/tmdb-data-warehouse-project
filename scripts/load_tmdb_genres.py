import os
import json
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

with open("datasets/raw/genres.json", "r", encoding="utf-8") as f:
    data = json.load(f)

for genre in data["genres"]:
    cursor.execute("""
        INSERT INTO bronze.tmdb_genres_info (id, name)
        VALUES (%s, %s)
        ON CONFLICT DO NOTHING
    """, (
        genre["id"],
        genre["name"]
    ))

connection.commit()
cursor.close()
connection.close()

print(f"Loaded {len(data['genres'])} genres successfully!")