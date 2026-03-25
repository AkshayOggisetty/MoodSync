-- MoodSync Seed Data
USE moodsync;

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
('The Weeknd'),          -- 1
('Dua Lipa'),            -- 2
('Adele'),               -- 3
('Eminem'),              -- 4
('Ed Sheeran'),          -- 5
('Billie Eilish'),       -- 6
('Imagine Dragons'),     -- 7
('Lana Del Rey'),        -- 8
('Coldplay'),            -- 9
('Daft Punk'),           -- 10
('Taylor Swift'),        -- 11
('Linkin Park'),         -- 12
('Ludovico Einaudi'),    -- 13
('Arctic Monkeys'),      -- 14
('Bruno Mars'),          -- 15
('Radiohead'),           -- 16
('Kendrick Lamar'),      -- 17
('Lorde'),               -- 18
('Hans Zimmer'),         -- 19
('Post Malone');         -- 20

-- ============================================================
-- Songs (title, artist_id, bpm, genre, mood_id)
-- mood_id: 1=Happy, 2=Sad, 3=Energetic, 4=Calm, 5=Romantic,
--          6=Angry, 7=Focused, 8=Melancholy
-- ============================================================
INSERT INTO Songs (title, artist_id, bpm, genre, mood_id) VALUES
-- Happy (mood_id = 1)
('Blinding Lights',          1,  171, 'Synth-pop',       1),
('Levitating',               2,  103, 'Disco-pop',       1),
('Uptown Funk',              15, 115, 'Funk',            1),
('Shake It Off',             11, 160, 'Pop',             1),
('Happy Together',           15, 120, 'Pop',             1),

-- Sad (mood_id = 2)
('Someone Like You',         3,   67, 'Soul',            2),
('When We Were Young',       3,   72, 'Ballad',          2),
('Skinny Love',              6,   76, 'Indie',           2),
('Let Her Go',               5,   75, 'Folk',            2),
('Hurt',                     12,  68, 'Alt-Rock',        2),

-- Energetic (mood_id = 3)
('Lose Yourself',            4,  171, 'Hip-Hop',         3),
('Thunder',                  7,  168, 'Alt-Rock',        3),
('Get Lucky',                10, 116, 'Funk',            3),
('HUMBLE.',                  17, 150, 'Hip-Hop',         3),
('Radioactive',              7,  136, 'Alt-Rock',        3),

-- Calm (mood_id = 4)
('Nuvole Bianche',           13,  70, 'Classical',       4),
('Yellow',                   9,   80, 'Alt-Rock',        4),
('Ocean Eyes',               6,   72, 'Electro-pop',     4),
('Time',                     19,  68, 'Soundtrack',      4),
('Interstellar Main Theme',  19,  72, 'Soundtrack',      4),

-- Romantic (mood_id = 5)
('Perfect',                  5,   63, 'Pop-Ballad',      5),
('Thinking Out Loud',        5,   79, 'Pop-Soul',        5),
('Love On Top',              15, 100, 'R&B',             5),
('Summertime Sadness',       8,  100, 'Indie-pop',       5),
('All of Me',                15,  63, 'R&B',             5),

-- Angry (mood_id = 6)
('Numb',                     12, 110, 'Nu-Metal',        6),
('In the End',               12, 105, 'Alt-Rock',        6),
('Rap God',                  4,  148, 'Hip-Hop',         6),
('Do I Wanna Know?',         14, 85,  'Indie-Rock',      6),
('Kill Bill',                18, 100, 'Alt-pop',         6),

-- Focused (mood_id = 7)
('Experience',               13,  76, 'Classical',       7),
('No Time to Die',           6,   74, 'Cinematic-pop',   7),
('Clocks',                   9,  131, 'Alt-Rock',        7),
('Cornfield Chase',          19,  72, 'Soundtrack',      7),
('Harder Better Faster',     10, 123, 'Electronic',      7),

-- Melancholy (mood_id = 8)
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
