import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT'),
        dbname=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD')
    )

def load_genres():
    conn = get_db_connection()
    cursor = conn.cursor()

    # Step 1: Fetch all movies that have genres
    cursor.execute("""SELECT id, genres FROM bronze.tmdb_movies WHERE genres IS NOT NULL AND genres <> '' AND status = 'Released';""")
    movies = cursor.fetchall()

    #Step 2, 3, 4, 5: Loop through movies
    for movie in movies:
        movie_id = movie[0]
        genres_raw = movie[1]

        # Step 2: Split genres by comma
        genre_list = [genre.strip() for genre in genres_raw.split(',')]
        for genre_name in genre_list:
            # Step 3: Insert genre, ignoring duplicates
            cursor.execute("""
                INSERT INTO silver.genres (genre_name)
                VALUES (%s)
                ON CONFLICT (genre_name) DO NOTHING;
            """, (genre_name,))

            # Step 4: Get genre_id
            cursor.execute("SELECT genre_id FROM silver.genres WHERE genre_name = %s;", (genre_name,))
            genre_id = cursor.fetchone()[0]

            # Step 5: Insert into bridge table
            cursor.execute("""
                INSERT INTO silver.movie_genres (movie_id, genre_id)
                VALUES (%s, %s)
                ON CONFLICT DO NOTHING;
            """, (movie_id, genre_id))

    conn.commit()
    cursor.close()
    conn.close()
    print("Genres loaded successfully.")

load_genres()