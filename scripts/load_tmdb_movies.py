import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

# ============================================================
# Setting up our database variables from our .env file
# ============================================================
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")

# This reads our CSV file into a pandas DataFrame and `dtype=str` forces every value in every column to be stored as text
df = pd.read_csv("datasets/raw/TMDB_movie_dataset_v11.csv", dtype=str)

# This creates a SQLAlchemy engine that acts as the bridge between Python and our PostgreSQL database
engine = create_engine(f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}")

def load_movies(df, engine):

    # This will open a database connection, delete all rows from bronze.tmdb_movies, and commit that change
    with engine.connect() as conn:
        conn.execute(text("TRUNCATE TABLE bronze.tmdb_movies"))
        conn.commit()
    # This bulk inserts the DataFrame into bronze.tmdb_movies, appending to the existing table structure
    df.to_sql(
        name="tmdb_movies",
        schema="bronze",
        con=engine,
        if_exists="append",
        index=False
        )
    print("Movies loaded into bronze.tmdb_movies successfully!")
load_movies(df, engine)