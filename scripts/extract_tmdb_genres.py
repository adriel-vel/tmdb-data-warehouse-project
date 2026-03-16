import requests 
import os
import json
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("API_KEY")

def get_genres(api_key):
    url = f"https://api.themoviedb.org/3/genre/movie/list"
    payload = {
        "api_key" : api_key,
    }
    response = requests.get(url, params=payload) 

    if response.status_code == 200:
        data = response.json()
        filename = f"datasets/raw/genres.json"
        with open(filename, "w") as f:
            json.dump(data, f)
    else:
        print("Request failed:", response.status_code)

genres = get_genres(api_key)
print(genres)