"""
MoodSync – Flask Backend
Mood-Based Music Recommendation System
"""

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from db import query, execute
import os

app = Flask(__name__, static_folder='../frontend', static_url_path='')
CORS(app)

# ---------------------------------------------------------------------------
# Serve frontend
# ---------------------------------------------------------------------------

@app.route('/')
def serve_index():
    return send_from_directory(app.static_folder, 'index.html')


# ---------------------------------------------------------------------------
# Utility endpoints
# ---------------------------------------------------------------------------

@app.route('/api/getMoods', methods=['GET'])
def get_moods():
    moods = query("SELECT mood_id, mood_name FROM Moods ORDER BY mood_name")
    return jsonify(moods)


@app.route('/api/getUsers', methods=['GET'])
def get_users():
    users = query("SELECT user_id, name, email FROM Users ORDER BY name")
    return jsonify(users)


# ---------------------------------------------------------------------------
# GET /api/getSongsByMood?mood=Happy
# ---------------------------------------------------------------------------

@app.route('/api/getSongsByMood', methods=['GET'])
def get_songs_by_mood():
    mood = request.args.get('mood', '')
    if not mood:
        return jsonify({'error': 'mood parameter is required'}), 400

    songs = query("""
        SELECT s.song_id, s.title, a.name AS artist, s.bpm, s.genre,
               m.mood_name AS mood
        FROM Songs s
        JOIN Artists a ON s.artist_id = a.artist_id
        JOIN Moods  m ON s.mood_id   = m.mood_id
        WHERE m.mood_name = %s
        ORDER BY s.title
    """, (mood,))
    return jsonify(songs)


# ---------------------------------------------------------------------------
# GET /api/recommendSongs?user_id=1&mood=Happy
# Recommendation logic:
#   1. Fetch songs for the mood
#   2. Score by BPM similarity to mood-ideal BPM center
#   3. Boost by user history  (like +3, play +1, skip -2)
#   4. Return top 10
#   5. Log recommendations
# ---------------------------------------------------------------------------

# Ideal centre BPM per mood (used for BPM scoring)
MOOD_BPM_CENTER = {
    'Happy':      120,
    'Sad':         70,
    'Energetic':  150,
    'Calm':        72,
    'Romantic':    80,
    'Angry':      130,
    'Focused':     90,
    'Melancholy':  78,
}

ACTION_WEIGHTS = {'like': 3, 'play': 1, 'skip': -2}


@app.route('/api/recommendSongs', methods=['GET'])
def recommend_songs():
    user_id = request.args.get('user_id', type=int)
    mood = request.args.get('mood', '')

    if not user_id or not mood:
        return jsonify({'error': 'user_id and mood params are required'}), 400

    # 1. All songs for this mood
    songs = query("""
        SELECT s.song_id, s.title, a.name AS artist, s.bpm, s.genre,
               m.mood_id, m.mood_name AS mood
        FROM Songs s
        JOIN Artists a ON s.artist_id = a.artist_id
        JOIN Moods  m ON s.mood_id   = m.mood_id
        WHERE m.mood_name = %s
    """, (mood,))

    if not songs:
        return jsonify([])

    # 2. User history stats for these songs
    song_ids = [s['song_id'] for s in songs]
    placeholders = ','.join(['%s'] * len(song_ids))
    history = query(f"""
        SELECT song_id, action, COUNT(*) AS cnt
        FROM Listening_History
        WHERE user_id = %s AND song_id IN ({placeholders})
        GROUP BY song_id, action
    """, (user_id, *song_ids))

    # Build {song_id: total_boost}
    boost_map = {}
    for row in history:
        sid = row['song_id']
        boost_map[sid] = boost_map.get(sid, 0) + ACTION_WEIGHTS.get(row['action'], 0) * row['cnt']

    # 3. Score each song
    ideal_bpm = MOOD_BPM_CENTER.get(mood, 100)
    max_bpm_diff = max(abs(s['bpm'] - ideal_bpm) for s in songs) or 1

    for s in songs:
        bpm_score = 1 - abs(s['bpm'] - ideal_bpm) / max_bpm_diff  # 0‑1
        history_boost = boost_map.get(s['song_id'], 0)
        s['score'] = round(bpm_score * 10 + history_boost, 2)

    # 4. Sort & top 10
    songs.sort(key=lambda s: s['score'], reverse=True)
    top = songs[:10]

    # 5. Log recommendations
    mood_id = top[0]['mood_id']
    for s in top:
        execute(
            "INSERT INTO Recommendation_Log (user_id, song_id, mood_id) VALUES (%s, %s, %s)",
            (user_id, s['song_id'], mood_id)
        )
        # Remove internal fields before returning
        s.pop('mood_id', None)

    return jsonify(top)


# ---------------------------------------------------------------------------
# POST /api/addToPlaylist  {playlist_id, song_id}
# ---------------------------------------------------------------------------

@app.route('/api/addToPlaylist', methods=['POST'])
def add_to_playlist():
    data = request.get_json(force=True)
    playlist_id = data.get('playlist_id')
    song_id = data.get('song_id')

    if not playlist_id or not song_id:
        return jsonify({'error': 'playlist_id and song_id required'}), 400

    # Check if already in playlist
    existing = query(
        "SELECT 1 FROM Playlist_Songs WHERE playlist_id = %s AND song_id = %s",
        (playlist_id, song_id), fetchone=True
    )
    if existing:
        return jsonify({'message': 'Song already in playlist'}), 200

    execute(
        "INSERT INTO Playlist_Songs (playlist_id, song_id) VALUES (%s, %s)",
        (playlist_id, song_id)
    )
    return jsonify({'message': 'Song added to playlist'}), 201


# ---------------------------------------------------------------------------
# POST /api/logListening  {user_id, song_id, action}
# ---------------------------------------------------------------------------

@app.route('/api/logListening', methods=['POST'])
def log_listening():
    data = request.get_json(force=True)
    user_id = data.get('user_id')
    song_id = data.get('song_id')
    action = data.get('action', 'play')

    if not user_id or not song_id:
        return jsonify({'error': 'user_id and song_id required'}), 400
    if action not in ('play', 'like', 'skip'):
        return jsonify({'error': "action must be 'play', 'like', or 'skip'"}), 400

    execute(
        "INSERT INTO Listening_History (user_id, song_id, action) VALUES (%s, %s, %s)",
        (user_id, song_id, action)
    )
    return jsonify({'message': f'Action "{action}" logged'}), 201


# ---------------------------------------------------------------------------
# GET /api/getUserActivity?user_id=1
# ---------------------------------------------------------------------------

@app.route('/api/getUserActivity', methods=['GET'])
def get_user_activity():
    user_id = request.args.get('user_id', type=int)
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400

    # Recent listening history
    history = query("""
        SELECT lh.history_id, s.title, a.name AS artist, lh.action,
               lh.timestamp
        FROM Listening_History lh
        JOIN Songs   s ON lh.song_id   = s.song_id
        JOIN Artists a ON s.artist_id  = a.artist_id
        WHERE lh.user_id = %s
        ORDER BY lh.timestamp DESC
        LIMIT 50
    """, (user_id,))

    # Recent recommendations
    recs = query("""
        SELECT rl.rec_id, s.title, a.name AS artist, m.mood_name AS mood,
               rl.timestamp
        FROM Recommendation_Log rl
        JOIN Songs   s ON rl.song_id  = s.song_id
        JOIN Artists a ON s.artist_id = a.artist_id
        JOIN Moods   m ON rl.mood_id  = m.mood_id
        WHERE rl.user_id = %s
        ORDER BY rl.timestamp DESC
        LIMIT 50
    """, (user_id,))

    # Serialize timestamps
    for row in history:
        row['timestamp'] = str(row['timestamp'])
    for row in recs:
        row['timestamp'] = str(row['timestamp'])

    return jsonify({'history': history, 'recommendations': recs})


# ---------------------------------------------------------------------------
# GET /api/getPlaylists?user_id=1
# ---------------------------------------------------------------------------

@app.route('/api/getPlaylists', methods=['GET'])
def get_playlists():
    user_id = request.args.get('user_id', type=int)
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400

    playlists = query("""
        SELECT p.playlist_id, p.name, p.created_at,
               COUNT(ps.song_id) AS song_count
        FROM Playlists p
        LEFT JOIN Playlist_Songs ps ON p.playlist_id = ps.playlist_id
        WHERE p.user_id = %s
        GROUP BY p.playlist_id
        ORDER BY p.created_at DESC
    """, (user_id,))

    for p in playlists:
        p['created_at'] = str(p['created_at'])

    return jsonify(playlists)


# ---------------------------------------------------------------------------
# POST /api/createPlaylist  {user_id, name}
# ---------------------------------------------------------------------------

@app.route('/api/createPlaylist', methods=['POST'])
def create_playlist():
    data = request.get_json(force=True)
    user_id = data.get('user_id')
    name = data.get('name', '').strip()

    if not user_id or not name:
        return jsonify({'error': 'user_id and name required'}), 400

    pid = execute(
        "INSERT INTO Playlists (user_id, name) VALUES (%s, %s)",
        (user_id, name)
    )
    return jsonify({'message': 'Playlist created', 'playlist_id': pid}), 201


# ---------------------------------------------------------------------------
# GET /api/getPlaylistSongs?playlist_id=1
# ---------------------------------------------------------------------------

@app.route('/api/getPlaylistSongs', methods=['GET'])
def get_playlist_songs():
    playlist_id = request.args.get('playlist_id', type=int)
    if not playlist_id:
        return jsonify({'error': 'playlist_id required'}), 400

    songs = query("""
        SELECT s.song_id, s.title, a.name AS artist, s.bpm, s.genre,
               m.mood_name AS mood
        FROM Playlist_Songs ps
        JOIN Songs   s ON ps.song_id   = s.song_id
        JOIN Artists a ON s.artist_id  = a.artist_id
        JOIN Moods   m ON s.mood_id    = m.mood_id
        WHERE ps.playlist_id = %s
        ORDER BY ps.added_at DESC
    """, (playlist_id,))

    return jsonify(songs)


# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    app.run(debug=True, port=5000)
