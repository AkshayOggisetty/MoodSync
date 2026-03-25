/* ============================================================
   MoodSync – Frontend Application Logic
   ============================================================ */

const API = '';  // Same-origin, served by Flask

// ── State ──
let currentUser  = null;
let currentMood  = null;
let userPlaylists = [];

// ── DOM refs ──
const $userSelect    = document.getElementById('user-select');
const $moodSelect    = document.getElementById('mood-select');
const $recommendBtn  = document.getElementById('recommend-btn');
const $songsGrid     = document.getElementById('songs-grid');
const $songsHeading  = document.getElementById('songs-heading');
const $songsEmpty    = document.getElementById('songs-empty');
const $playlistsList = document.getElementById('playlists-list');
const $activityList  = document.getElementById('activity-list');
const $createSection = document.getElementById('create-playlist-section');
const $newPlaylistName = document.getElementById('new-playlist-name');
const $createPlaylistBtn = document.getElementById('create-playlist-btn');
const $modalOverlay  = document.getElementById('modal-overlay');
const $modalSongName = document.getElementById('modal-song-name');
const $modalSelect   = document.getElementById('modal-playlist-select');
const $modalAddBtn   = document.getElementById('modal-add-btn');
const $modalCancelBtn = document.getElementById('modal-cancel-btn');
const $psSongsSection = document.getElementById('playlist-songs-section');
const $psSongsTitle  = document.getElementById('playlist-songs-title');
const $psSongsList   = document.getElementById('playlist-songs-list');
const $toast         = document.getElementById('toast');

// ── Helpers ──
async function api(url, opts = {}) {
    const res = await fetch(API + url, {
        headers: { 'Content-Type': 'application/json' },
        ...opts,
    });
    return res.json();
}

function showToast(msg, duration = 2500) {
    $toast.textContent = msg;
    $toast.classList.remove('hidden');
    $toast.classList.add('visible');
    setTimeout(() => {
        $toast.classList.remove('visible');
        setTimeout(() => $toast.classList.add('hidden'), 300);
    }, duration);
}

// ── Init: Load Users & Moods ──
async function init() {
    const [users, moods] = await Promise.all([
        api('/api/getUsers'),
        api('/api/getMoods'),
    ]);

    users.forEach(u => {
        const opt = document.createElement('option');
        opt.value = u.user_id;
        opt.textContent = u.name;
        $userSelect.appendChild(opt);
    });

    moods.forEach(m => {
        const opt = document.createElement('option');
        opt.value = m.mood_name;
        opt.textContent = moodEmoji(m.mood_name) + ' ' + m.mood_name;
        $moodSelect.appendChild(opt);
    });
}

function moodEmoji(mood) {
    const map = {
        Happy: '😄', Sad: '😢', Energetic: '⚡', Calm: '🧘',
        Romantic: '❤️', Angry: '🔥', Focused: '🎯', Melancholy: '🌧️',
    };
    return map[mood] || '🎵';
}

// ── User Change ──
$userSelect.addEventListener('change', async () => {
    const uid = parseInt($userSelect.value);
    if (!uid) {
        currentUser = null;
        $moodSelect.disabled = true;
        $recommendBtn.disabled = true;
        $songsGrid.innerHTML = '';
        $playlistsList.innerHTML = '<p class="placeholder-text">Select a user to see playlists</p>';
        $activityList.innerHTML  = '<p class="placeholder-text">Select a user to see activity</p>';
        $createSection.style.display = 'none';
        $psSongsSection.classList.add('hidden');
        return;
    }
    currentUser = uid;
    $moodSelect.disabled = false;
    $recommendBtn.disabled = !$moodSelect.value;
    loadPlaylists();
    loadActivity();
});

// ── Mood Change ──
$moodSelect.addEventListener('change', () => {
    currentMood = $moodSelect.value;
    $recommendBtn.disabled = !currentMood || !currentUser;
});

// ── Recommend Button ──
$recommendBtn.addEventListener('click', loadRecommendations);

async function loadRecommendations() {
    if (!currentUser || !currentMood) return;

    $recommendBtn.disabled = true;
    $recommendBtn.innerHTML = '<span class="btn-icon">⏳</span> Loading…';

    try {
        const songs = await api(
            `/api/recommendSongs?user_id=${currentUser}&mood=${encodeURIComponent(currentMood)}`
        );
        renderSongs(songs);
        $songsHeading.textContent = `${moodEmoji(currentMood)} Top Picks for "${currentMood}"`;
        loadActivity();  // refresh activity after recs are logged
    } catch (err) {
        showToast('Failed to load recommendations');
        console.error(err);
    } finally {
        $recommendBtn.disabled = false;
        $recommendBtn.innerHTML = '<span class="btn-icon">✨</span> Get Recommendations';
    }
}

// ── Render Song Cards ──
function renderSongs(songs) {
    $songsGrid.innerHTML = '';
    if (!songs.length) {
        $songsEmpty.classList.remove('hidden');
        return;
    }
    $songsEmpty.classList.add('hidden');

    songs.forEach((s, i) => {
        const card = document.createElement('div');
        card.className = 'song-card';
        card.style.animationDelay = `${i * 0.06}s`;
        card.innerHTML = `
            <span class="song-title">${esc(s.title)}</span>
            <span class="song-artist">${esc(s.artist)}</span>
            <div class="song-meta">
                <span class="tag">${esc(s.genre)}</span>
                <span class="tag bpm-tag">${s.bpm} BPM</span>
                ${s.score !== undefined ? `<span class="tag score-tag">Score ${s.score}</span>` : ''}
            </div>
            <div class="song-actions">
                <button class="btn-icon-only" data-action="like" data-song="${s.song_id}" title="Like">❤️</button>
                <button class="btn-icon-only" data-action="skip" data-song="${s.song_id}" title="Skip">⏭️</button>
                <button class="btn-ghost btn-small btn-add-playlist" data-song="${s.song_id}" data-title="${esc(s.title)}">
                    ＋ Playlist
                </button>
            </div>
        `;
        $songsGrid.appendChild(card);
    });

    // Attach action listeners
    $songsGrid.querySelectorAll('[data-action]').forEach(btn => {
        btn.addEventListener('click', handleAction);
    });
    $songsGrid.querySelectorAll('.btn-add-playlist').forEach(btn => {
        btn.addEventListener('click', openPlaylistModal);
    });
}

function esc(str) {
    const d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
}

// ── Like / Skip ──
async function handleAction(e) {
    const btn = e.currentTarget;
    const action = btn.dataset.action;
    const songId = parseInt(btn.dataset.song);

    await api('/api/logListening', {
        method: 'POST',
        body: JSON.stringify({ user_id: currentUser, song_id: songId, action }),
    });

    btn.classList.add(action === 'like' ? 'liked' : 'skipped');
    showToast(action === 'like' ? '❤️ Liked!' : '⏭️ Skipped');
    loadActivity();
}

// ── Add-to-Playlist Modal ──
let pendingSongId = null;

function openPlaylistModal(e) {
    const btn = e.currentTarget;
    pendingSongId = parseInt(btn.dataset.song);
    $modalSongName.textContent = btn.dataset.title;

    // Populate playlists
    $modalSelect.innerHTML = '<option value="">Choose playlist…</option>';
    userPlaylists.forEach(p => {
        const opt = document.createElement('option');
        opt.value = p.playlist_id;
        opt.textContent = p.name;
        $modalSelect.appendChild(opt);
    });

    $modalOverlay.classList.remove('hidden');
}

$modalCancelBtn.addEventListener('click', () => $modalOverlay.classList.add('hidden'));
$modalOverlay.addEventListener('click', e => {
    if (e.target === $modalOverlay) $modalOverlay.classList.add('hidden');
});

$modalAddBtn.addEventListener('click', async () => {
    const plId = parseInt($modalSelect.value);
    if (!plId || !pendingSongId) return;

    const res = await api('/api/addToPlaylist', {
        method: 'POST',
        body: JSON.stringify({ playlist_id: plId, song_id: pendingSongId }),
    });
    showToast(res.message || 'Added!');
    $modalOverlay.classList.add('hidden');
    loadPlaylists();
});

// ── Playlists ──
async function loadPlaylists() {
    if (!currentUser) return;
    userPlaylists = await api(`/api/getPlaylists?user_id=${currentUser}`);
    $createSection.style.display = 'flex';

    if (!userPlaylists.length) {
        $playlistsList.innerHTML = '<p class="placeholder-text">No playlists yet — create one!</p>';
        return;
    }

    $playlistsList.innerHTML = '';
    userPlaylists.forEach(p => {
        const div = document.createElement('div');
        div.className = 'playlist-item';
        div.innerHTML = `
            <span>${esc(p.name)}</span>
            <span class="badge">${p.song_count}</span>
        `;
        div.addEventListener('click', () => viewPlaylistSongs(p));
        $playlistsList.appendChild(div);
    });
}

$createPlaylistBtn.addEventListener('click', async () => {
    const name = $newPlaylistName.value.trim();
    if (!name || !currentUser) return;
    await api('/api/createPlaylist', {
        method: 'POST',
        body: JSON.stringify({ user_id: currentUser, name }),
    });
    $newPlaylistName.value = '';
    showToast('Playlist created!');
    loadPlaylists();
});

async function viewPlaylistSongs(p) {
    const songs = await api(`/api/getPlaylistSongs?playlist_id=${p.playlist_id}`);
    $psSongsTitle.textContent = `🎧 ${esc(p.name)}`;
    $psSongsSection.classList.remove('hidden');

    if (!songs.length) {
        $psSongsList.innerHTML = '<p class="placeholder-text">No songs yet</p>';
        return;
    }
    $psSongsList.innerHTML = songs.map(s => `
        <div class="ps-item">
            <span class="ps-title">${esc(s.title)}</span> — ${esc(s.artist)}
        </div>
    `).join('');

    // Highlight active playlist
    document.querySelectorAll('.playlist-item').forEach(el => el.classList.remove('active'));
    event.currentTarget?.classList.add('active');
}

// ── Activity ──
async function loadActivity() {
    if (!currentUser) return;
    const data = await api(`/api/getUserActivity?user_id=${currentUser}`);

    const actionIcon = { play: '▶️', like: '❤️', skip: '⏭️' };

    if (!data.history?.length && !data.recommendations?.length) {
        $activityList.innerHTML = '<p class="placeholder-text">No activity yet</p>';
        return;
    }

    // Merge and sort
    const items = [];
    (data.history || []).forEach(h => items.push({
        icon: actionIcon[h.action] || '🎵',
        text: `<strong>${esc(h.title)}</strong> by ${esc(h.artist)}`,
        label: h.action,
        time: h.timestamp,
    }));
    (data.recommendations || []).forEach(r => items.push({
        icon: '✨',
        text: `<strong>${esc(r.title)}</strong> recommended (${esc(r.mood)})`,
        label: 'rec',
        time: r.timestamp,
    }));

    items.sort((a, b) => new Date(b.time) - new Date(a.time));

    $activityList.innerHTML = items.slice(0, 30).map(it => `
        <div class="activity-item">
            <span class="act-icon">${it.icon}</span>
            <div class="act-details">
                ${it.text}
                <div class="act-time">${formatTime(it.time)}</div>
            </div>
        </div>
    `).join('');
}

function formatTime(ts) {
    try {
        const d = new Date(ts);
        return d.toLocaleString();
    } catch {
        return ts;
    }
}

// ── Boot ──
init();
