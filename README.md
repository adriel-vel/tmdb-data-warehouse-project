# TMDB Data Warehouse and Analytics Project

Welcome! This project will demonstrate a data warehouse using Python and PostgreSQL.
This project extracts movie data from a Kaggle Dataset using Kaggle API that is sourced from TMDB data and I will then process it through an ETL pipleine to create a structured data warehouse designed for analytics.
The warehouse follows a Medallion Architecture (Bronze, Silver, Gold) and supports SQL-based analysis of movie trends such as genres, ratings, and release patterns.

---
## Tech Stack

| Tool | Purpose |
|---|---|
| Python | ETL scripting — extract and load data |
| Kaggle API | Programmatic dataset download via 'kagglehub' |
| PostgreSQL | Data warehouse storage |
| SQL | Data transformation and analytics |

---
## Data Source

**Dataset:** TMDB Movies Dataset (~1,000,000 movies) sourced from [Kaggle](https://www.kaggle.com/datasets/asaniczka/tmdb-movies-dataset-2023-930k-movies)

The dataset contains movie metadata sourced from The Movie Database (TMDB), including:

- Title, original title, and overview
- Release data and status
- Genres
- Popularity score and vote average
- Runtime, budget, and revenue
- Production companies, countries, and spoken languages
- Keywords

---

## Architecture

This project follows the **Medallion Architecture** pattern, organizing data into three progressive layers (Bronze, Silver, and Gold).

For a full architecture diagram, see ['docs/TMBD_data_architecture.png'](docs/TMBD_data_architecture.png).

### Bronze Layer
Stores the raw movie data exactly as it appears in the source CSV. No transformations applied. Acts as the original file to fall back on if our code breaks.

### Silver Layer
Cleans and standardizes the raw data:
- Handles missing and null values
- Standardizes data types (dates, booleans, numerics)
- Parses the 'genres' column (comma-separated text) into a normalized bridge table linking movies to genres

### Gold Layer
Produces analytics-ready aggregated tables designed to answer specific business questions about movies popularity, genres, ratings, and release patterns.

---

## Analytics & Reporting

### Objective
Provide an analytics-ready dataset that allows exploration of trends in movie popularity.

The warehouse supports analysis such as:

- Which movies have the highest popularity scores?
- Most common genres among popular movies?
- Average runtime of popular movies?
- Release timing patterns
- Relationship between ratings and popularity

## Repository Structure

```
tmdb-warehouse/
├── datasets/
│   └── raw/                  # Raw CSV file (not committed to git)
├── docs/                     # Architecture diagrams and data catalog
├── scripts/
│   ├── init_tmdb_database.sql    # Database and schema setup
│   ├── extract_tmdb_movies.py    # Download dataset via Kaggle API
│   ├── load_tmdb_movies.py       # Load CSV into bronze layer
│   ├── silver_movies.sql         # Clean and standardize movies
│   ├── silver_genres.sql         # Normalize genres into bridge table
│   └── gold_*.sql                # Gold layer analytics tables
├── tests/                    # Pipeline tests
├── .env.example              # Environment variable template
├── .gitignore
├── requirements.txt
└── README.md
```

---

## Getting Started

### Prerequisites
- Python 3.8+
- PostgreSQL
- A Kaggle account with an API key ('kaggle.json')

---

## License

This project is licensed under the MIT License. You are free to use, modify, and distribute this project for educational or personal use.\

## About Me

Hello! I'm **Adriel Velasquez**, and I am currently a Computer Science Major at Stony Brook University with a goal of becoming a Data Engineer. 
I love to explore how data can be transformed into useful insights. Through projects like this one, I am to develop practical data engineering skills and create systems that help people explore and understand data.
