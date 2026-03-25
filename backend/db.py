"""
Database helper – supports both PostgreSQL (Render) and MySQL (local).
If DATABASE_URL env var is set, uses PostgreSQL. Otherwise falls back to MySQL.
"""

import os
import sys

DATABASE_URL = os.getenv('DATABASE_URL', '')

# Render uses postgres:// but psycopg2 requires postgresql://
if DATABASE_URL.startswith('postgres://'):
    DATABASE_URL = DATABASE_URL.replace('postgres://', 'postgresql://', 1)

print(f"[MoodSync] DATABASE_URL is {'SET' if DATABASE_URL else 'NOT SET'}", file=sys.stderr)

# ── PostgreSQL mode (Render) ──
if DATABASE_URL:
    import psycopg2
    import psycopg2.pool
    import psycopg2.extras

    print("[MoodSync] Using PostgreSQL mode", file=sys.stderr)

    _pg_pool = None

    def _get_pg_pool():
        global _pg_pool
        if _pg_pool is None:
            _pg_pool = psycopg2.pool.SimpleConnectionPool(1, 5, DATABASE_URL)
        return _pg_pool

    def get_connection():
        return _get_pg_pool().getconn()

    def release_connection(conn):
        _get_pg_pool().putconn(conn)

    def query(sql, params=None, fetchone=False):
        conn = get_connection()
        try:
            cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            cur.execute(sql, params or ())
            rows = cur.fetchone() if fetchone else cur.fetchall()
            cur.close()
            return dict(rows) if fetchone and rows else [dict(r) for r in rows] if rows else (None if fetchone else [])
        finally:
            release_connection(conn)

    def execute(sql, params=None):
        conn = get_connection()
        try:
            cur = conn.cursor()
            cur.execute(sql, params or ())
            conn.commit()
            try:
                row = cur.fetchone()
                last_id = row[0] if row else None
            except Exception:
                last_id = None
            cur.close()
            return last_id
        finally:
            release_connection(conn)

# ── MySQL mode (local) ──
else:
    import mysql.connector
    from mysql.connector import pooling
    from config import DB_CONFIG

    print("[MoodSync] Using MySQL mode", file=sys.stderr)

    _pool = None

    def _get_pool():
        global _pool
        if _pool is None:
            _pool = pooling.MySQLConnectionPool(
                pool_name="moodsync_pool",
                pool_size=5,
                **DB_CONFIG
            )
        return _pool

    def get_connection():
        return _get_pool().get_connection()

    def release_connection(conn):
        conn.close()

    def query(sql, params=None, fetchone=False):
        conn = get_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute(sql, params or ())
            rows = cursor.fetchone() if fetchone else cursor.fetchall()
            cursor.close()
            return rows
        finally:
            conn.close()

    def execute(sql, params=None):
        conn = get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(sql, params or ())
            conn.commit()
            last_id = cursor.lastrowid
            cursor.close()
            return last_id
        finally:
            conn.close()
