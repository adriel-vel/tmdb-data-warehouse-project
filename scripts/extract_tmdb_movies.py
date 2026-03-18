import os
from dotenv import load_dotenv
import kagglehub

load_dotenv()

def get_tmdb_movies_dataset():
    # This makes the directory within the project if it isn't created to prevent errors
    os.makedirs("datasets/raw", exist_ok=True)

    # This gets the file we're trying to download using Kaggle API and set the directory to 'datasets/raw'
    path = kagglehub.dataset_download("asaniczka/tmdb-movies-dataset-2023-930k-movies", output_dir="datasets/raw")
    print("Dataset downloaded to:", path)
    return path

get_tmdb_movies_dataset()