-- MoodSync PostgreSQL Schema (for Render deployment)

-- ============================================================
-- Users
-- ============================================================
CREATE TABLE IF NOT EXISTS Users (
    user_id   SERIAL PRIMARY KEY,
    name      VARCHAR(100) NOT NULL,
    email     VARCHAR(150) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Artists
-- ============================================================
CREATE TABLE IF NOT EXISTS Artists (
    artist_id SERIAL PRIMARY KEY,
    name      VARCHAR(150) NOT NULL
);

-- ============================================================
-- Moods
-- ============================================================
CREATE TABLE IF NOT EXISTS Moods (
    mood_id   SERIAL PRIMARY KEY,
    mood_name VARCHAR(50) NOT NULL UNIQUE
);

-- ============================================================
-- Songs
-- ============================================================
CREATE TABLE IF NOT EXISTS Songs (
    song_id   SERIAL PRIMARY KEY,
    title     VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL REFERENCES Artists(artist_id) ON DELETE CASCADE,
    bpm       INT NOT NULL DEFAULT 120,
    genre     VARCHAR(80),
    mood_id   INT NOT NULL REFERENCES Moods(mood_id) ON DELETE CASCADE
);

-- ============================================================
-- Playlists
-- ============================================================
CREATE TABLE IF NOT EXISTS Playlists (
    playlist_id SERIAL PRIMARY KEY,
    user_id     INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    name        VARCHAR(150) NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Playlist_Songs
-- ============================================================
CREATE TABLE IF NOT EXISTS Playlist_Songs (
    playlist_id INT NOT NULL REFERENCES Playlists(playlist_id) ON DELETE CASCADE,
    song_id     INT NOT NULL REFERENCES Songs(song_id) ON DELETE CASCADE,
    added_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, song_id)
);

-- ============================================================
-- Listening_History
-- ============================================================
CREATE TABLE IF NOT EXISTS Listening_History (
    history_id SERIAL PRIMARY KEY,
    user_id    INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    song_id    INT NOT NULL REFERENCES Songs(song_id) ON DELETE CASCADE,
    action     VARCHAR(10) NOT NULL DEFAULT 'play' CHECK (action IN ('play', 'like', 'skip')),
    timestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Recommendation_Log
-- ============================================================
CREATE TABLE IF NOT EXISTS Recommendation_Log (
    rec_id    SERIAL PRIMARY KEY,
    user_id   INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    song_id   INT NOT NULL REFERENCES Songs(song_id) ON DELETE CASCADE,
    mood_id   INT NOT NULL REFERENCES Moods(mood_id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_songs_mood    ON Songs(mood_id);
CREATE INDEX IF NOT EXISTS idx_songs_artist  ON Songs(artist_id);
CREATE INDEX IF NOT EXISTS idx_history_user  ON Listening_History(user_id);
CREATE INDEX IF NOT EXISTS idx_rec_user      ON Recommendation_Log(user_id);
CREATE INDEX IF NOT EXISTS idx_playlist_user ON Playlists(user_id);
