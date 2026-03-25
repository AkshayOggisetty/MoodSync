-- MoodSync Database Schema
-- Mood-Based Music Recommendation System

CREATE DATABASE IF NOT EXISTS moodsync;
USE moodsync;

-- ============================================================
-- Users table
-- ============================================================
CREATE TABLE IF NOT EXISTS Users (
    user_id   INT AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(100) NOT NULL,
    email     VARCHAR(150) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- Artists table
-- ============================================================
CREATE TABLE IF NOT EXISTS Artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(150) NOT NULL
) ENGINE=InnoDB;

-- ============================================================
-- Moods table
-- ============================================================
CREATE TABLE IF NOT EXISTS Moods (
    mood_id   INT AUTO_INCREMENT PRIMARY KEY,
    mood_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ============================================================
-- Songs table
-- ============================================================
CREATE TABLE IF NOT EXISTS Songs (
    song_id   INT AUTO_INCREMENT PRIMARY KEY,
    title     VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    bpm       INT NOT NULL DEFAULT 120,
    genre     VARCHAR(80),
    mood_id   INT NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (mood_id) REFERENCES Moods(mood_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- Playlists table
-- ============================================================
CREATE TABLE IF NOT EXISTS Playlists (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL,
    name        VARCHAR(150) NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- Playlist_Songs junction table
-- ============================================================
CREATE TABLE IF NOT EXISTS Playlist_Songs (
    playlist_id INT NOT NULL,
    song_id     INT NOT NULL,
    added_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- Listening_History table
-- action: 'play', 'like', 'skip'
-- ============================================================
CREATE TABLE IF NOT EXISTS Listening_History (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    song_id    INT NOT NULL,
    action     ENUM('play', 'like', 'skip') NOT NULL DEFAULT 'play',
    timestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- Recommendation_Log table
-- ============================================================
CREATE TABLE IF NOT EXISTS Recommendation_Log (
    rec_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id   INT NOT NULL,
    song_id   INT NOT NULL,
    mood_id   INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (mood_id) REFERENCES Moods(mood_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- Indexes for common queries
-- ============================================================
CREATE INDEX idx_songs_mood   ON Songs(mood_id);
CREATE INDEX idx_songs_artist ON Songs(artist_id);
CREATE INDEX idx_history_user ON Listening_History(user_id);
CREATE INDEX idx_rec_user     ON Recommendation_Log(user_id);
CREATE INDEX idx_playlist_user ON Playlists(user_id);
