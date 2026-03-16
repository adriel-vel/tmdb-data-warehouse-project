import requests 
import os
import json
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()
api_key = os.getenv("API_KEY")

def get_trending_movies(api_key, time_window='day'):
    url = f"https://api.themoviedb.org/3/trending/movie/{time_window}"
    all_movies = []
    today = datetime.today().strftime("%Y_%m_%d")
    for page in range(1,6):
        payload = {
            "api_key" : api_key,
            "page" : page
        }
        response = requests.get(url, params=payload) 

        if response.status_code == 200:
            data = response.json()
            all_movies.extend(data["results"])
        else:
            print("Request failed:", response.status_code)
    return all_movies

movies = get_trending_movies(api_key)
print(movies[0])