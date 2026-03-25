# MoodSync — Mood-Based Music Recommendation System

A full-stack application that recommends music based on your current mood, built with **Flask**, **MySQL**, and vanilla **HTML/CSS/JS**.

## Architecture

```
MoodSync/
├── database/
│   ├── schema.sql        # Table definitions & indexes
│   └── seed_data.sql     # Sample data (artists, songs, users)
├── backend/
│   ├── app.py            # Flask API (10 endpoints)
│   ├── config.py         # DB & app configuration
│   └── db.py             # MySQL connection pool helper
├── frontend/
│   ├── index.html        # Single-page UI
│   ├── style.css         # Dark glassmorphism theme
│   └── app.js            # Frontend logic
├── .env                  # DB credentials (edit this)
├── requirements.txt      # Python dependencies
└── README.md
```

## Prerequisites

- **Python 3.9+**
- **MySQL 8.0+** (running locally)
- **pip**

## Setup Instructions

### 1. Set up the Database

```bash
# Log in to MySQL
mysql -u root -p

# Inside MySQL, run the schema and seed data:
SOURCE C:/Users/siris/MoodSync/database/schema.sql;
SOURCE C:/Users/siris/MoodSync/database/seed_data.sql;
```

### 2. Configure Environment

Edit the `.env` file in the project root with your MySQL credentials:

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password_here
DB_NAME=moodsync
DB_PORT=3306
```

### 3. Install Python Dependencies

```bash
cd MoodSync
pip install -r requirements.txt
```

### 4. Run the Server

```bash
cd backend
python app.py
```

The app will start at **http://localhost:5000**.

### 5. Open in Browser

Navigate to **http://localhost:5000** — the Flask server serves the frontend automatically.

## API Endpoints

| Endpoint | Method | Parameters | Description |
|---|---|---|---|
| `/api/getMoods` | GET | – | List all moods |
| `/api/getUsers` | GET | – | List all users |
| `/api/getSongsByMood` | GET | `mood` | Songs for a mood |
| `/api/recommendSongs` | GET | `user_id`, `mood` | Top 10 smart recommendations |
| `/api/addToPlaylist` | POST | `playlist_id`, `song_id` | Add song to playlist |
| `/api/logListening` | POST | `user_id`, `song_id`, `action` | Log play/like/skip |
| `/api/getUserActivity` | GET | `user_id` | User's history & rec log |
| `/api/getPlaylists` | GET | `user_id` | User's playlists |
| `/api/createPlaylist` | POST | `user_id`, `name` | Create new playlist |
| `/api/getPlaylistSongs` | GET | `playlist_id` | Songs in a playlist |

## Sample API Responses

### GET `/api/recommendSongs?user_id=1&mood=Happy`

```json
[
  {
    "song_id": 5,
    "title": "Happy Together",
    "artist": "Bruno Mars",
    "bpm": 120,
    "genre": "Pop",
    "mood": "Happy",
    "score": 10.0
  },
  {
    "song_id": 2,
    "title": "Levitating",
    "artist": "Dua Lipa",
    "bpm": 103,
    "genre": "Disco-pop",
    "mood": "Happy",
    "score": 8.59
  }
]
```

### POST `/api/logListening`

```json
// Request
{ "user_id": 1, "song_id": 2, "action": "like" }

// Response
{ "message": "Action \"like\" logged" }
```

### POST `/api/addToPlaylist`

```json
// Request
{ "playlist_id": 1, "song_id": 5 }

// Response
{ "message": "Song added to playlist" }
```

## Recommendation Algorithm

1. Fetch all songs matching the requested mood
2. Compute **BPM similarity score** — songs closer to the mood's ideal BPM center score higher (0–10 scale)
3. **Boost by listening history**: `likes × 3 + plays × 1 − skips × 2`
4. Combine scores, sort descending, return **top 10**
5. Log all recommendations to `Recommendation_Log` table
