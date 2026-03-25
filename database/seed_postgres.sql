-- MoodSync PostgreSQL Seed Data
-- ============================================================
-- Users
-- ============================================================
INSERT INTO Users (name, email) VALUES
('Alice Johnson',  'alice@example.com'),
('Bob Smith',      'bob@example.com'),
('Charlie Lee',    'charlie@example.com'),
('Diana Patel',    'diana@example.com');

-- ============================================================
-- Moods
-- ============================================================
INSERT INTO Moods (mood_name) VALUES
('Happy'),
('Sad'),
('Energetic'),
('Calm'),
('Romantic'),
('Angry'),
('Focused'),
('Melancholy');

-- ============================================================
-- Artists
-- ============================================================
INSERT INTO Artists (name) VALUES
('The Weeknd'),
('Dua Lipa'),
('Adele'),
('Eminem'),
('Ed Sheeran'),
('Billie Eilish'),
('Imagine Dragons'),
('Lana Del Rey'),
('Coldplay'),
('Daft Punk'),
('Taylor Swift'),
('Linkin Park'),
('Ludovico Einaudi'),
('Arctic Monkeys'),
('Bruno Mars'),
('Radiohead'),
('Kendrick Lamar'),
('Lorde'),
('Hans Zimmer'),
('Post Malone');

-- ============================================================
-- Songs
-- ============================================================
INSERT INTO Songs (title, artist_id, bpm, genre, mood_id) VALUES
('Blinding Lights',          1,  171, 'Synth-pop',       1),
('Levitating',               2,  103, 'Disco-pop',       1),
('Uptown Funk',              15, 115, 'Funk',            1),
('Shake It Off',             11, 160, 'Pop',             1),
('Happy Together',           15, 120, 'Pop',             1),
('Someone Like You',         3,   67, 'Soul',            2),
('When We Were Young',       3,   72, 'Ballad',          2),
('Skinny Love',              6,   76, 'Indie',           2),
('Let Her Go',               5,   75, 'Folk',            2),
('Hurt',                     12,  68, 'Alt-Rock',        2),
('Lose Yourself',            4,  171, 'Hip-Hop',         3),
('Thunder',                  7,  168, 'Alt-Rock',        3),
('Get Lucky',                10, 116, 'Funk',            3),
('HUMBLE.',                  17, 150, 'Hip-Hop',         3),
('Radioactive',              7,  136, 'Alt-Rock',        3),
('Nuvole Bianche',           13,  70, 'Classical',       4),
('Yellow',                   9,   80, 'Alt-Rock',        4),
('Ocean Eyes',               6,   72, 'Electro-pop',     4),
('Time',                     19,  68, 'Soundtrack',      4),
('Interstellar Main Theme',  19,  72, 'Soundtrack',      4),
('Perfect',                  5,   63, 'Pop-Ballad',      5),
('Thinking Out Loud',        5,   79, 'Pop-Soul',        5),
('Love On Top',              15, 100, 'R&B',             5),
('Summertime Sadness',       8,  100, 'Indie-pop',       5),
('All of Me',                15,  63, 'R&B',             5),
('Numb',                     12, 110, 'Nu-Metal',        6),
('In the End',               12, 105, 'Alt-Rock',        6),
('Rap God',                  4,  148, 'Hip-Hop',         6),
('Do I Wanna Know?',         14, 85,  'Indie-Rock',      6),
('Kill Bill',                18, 100, 'Alt-pop',         6),
('Experience',               13,  76, 'Classical',       7),
('No Time to Die',           6,   74, 'Cinematic-pop',   7),
('Clocks',                   9,  131, 'Alt-Rock',        7),
('Cornfield Chase',          19,  72, 'Soundtrack',      7),
('Harder Better Faster',     10, 123, 'Electronic',      7),
('Exit Music (For a Film)',  16,  72, 'Art-Rock',        8),
('Creep',                    16,  92, 'Alt-Rock',        8),
('Video Games',              8,   65, 'Indie-pop',       8),
('Sunflower',                20, 100, 'Pop-Rap',         8),
('Circles',                  20,  78, 'Pop',             8);

-- ============================================================
-- Sample Playlists
-- ============================================================
INSERT INTO Playlists (user_id, name) VALUES
(1, 'Morning Vibes'),
(1, 'Late Night'),
(2, 'Workout Beats'),
(3, 'Study Session');

-- ============================================================
-- Sample Playlist_Songs
-- ============================================================
INSERT INTO Playlist_Songs (playlist_id, song_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 6), (2, 7), (2, 36),
(3, 11), (3, 12), (3, 14),
(4, 16), (4, 31), (4, 34);

-- ============================================================
-- Sample Listening_History
-- ============================================================
INSERT INTO Listening_History (user_id, song_id, action) VALUES
(1, 1,  'play'),
(1, 1,  'like'),
(1, 2,  'play'),
(1, 6,  'play'),
(1, 6,  'like'),
(1, 11, 'skip'),
(2, 11, 'play'),
(2, 11, 'like'),
(2, 12, 'play'),
(2, 14, 'like'),
(3, 16, 'play'),
(3, 16, 'like'),
(3, 31, 'play'),
(4, 21, 'play'),
(4, 21, 'like'),
(4, 22, 'play');
