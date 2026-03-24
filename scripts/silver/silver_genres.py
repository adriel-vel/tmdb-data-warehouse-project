import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    """Creates and returns a connection to the PostgreSQL database using .env credentials."""
    return psycopg2.connect(
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT'),
        dbname=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD')
    )


def fetch_movies_with_genres(cursor):
    """
    Fetches deduplicated released movies that have genre data from the bronze layer.
    Uses ROW_NUMBER() to keep only the first occurrence of each movie ID,
    matching the deduplication strategy used in silver_movies.sql.
    """
    cursor.execute("""
        WITH deduplicated AS (
            SELECT
                id,
                genres,
                ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS row_num
            FROM bronze.tmdb_movies
            WHERE status = 'Released'
              AND genres IS NOT NULL
              AND genres <> ''
        )
        SELECT id, genres
        FROM deduplicated
        WHERE row_num = 1;
    """)
    return cursor.fetchall()


def parse_genres(genres_raw):
    """
    Takes a comma-separated genre string like 'Action, Drama, Comedy'
    and returns a cleaned list: ['Action', 'Drama', 'Comedy'].
    """
    return [genre.strip() for genre in genres_raw.split(',') if genre.strip()]


def upsert_genre(cursor, genre_name):
    """
    Inserts a genre into silver.genres if it doesn't already exist.
    Returns the genre_id for the given genre name.
    """
    cursor.execute("""
        INSERT INTO silver.genres (genre_name)
        VALUES (%s)
        ON CONFLICT (genre_name) DO NOTHING;
    """, (genre_name,))

    cursor.execute("SELECT genre_id FROM silver.genres WHERE genre_name = %s;", (genre_name,))
    return cursor.fetchone()[0]


def link_movie_genre(cursor, movie_id, genre_id):
    """
    Inserts a movie-genre pair into the silver.movie_genres bridge table.
    Silently skips if the pair already exists.
    """
    cursor.execute("""
        INSERT INTO silver.movie_genres (movie_id, genre_id)
        VALUES (%s, %s)
        ON CONFLICT DO NOTHING;
    """, (movie_id, genre_id))


def load_genres():
    """
    Main orchestrator: fetches deduplicated movies from bronze,
    parses their genre strings, and loads the normalized genre data
    into silver.genres and silver.movie_genres.
    """
    conn = None
    cursor = None

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        movies = fetch_movies_with_genres(cursor)
        print(f"Fetched {len(movies)} deduplicated movies with genre data.")

        for movie_id, genres_raw in movies:
            genre_list = parse_genres(genres_raw)

            for genre_name in genre_list:
                genre_id = upsert_genre(cursor, genre_name)
                link_movie_genre(cursor, movie_id, genre_id)

        conn.commit()
        print("Genres loaded successfully.")

    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Error loading genres: {e}")
        raise

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


if __name__ == "__main__":
    load_genres()