import mysql.connector
from mysql.connector import pooling
from config import DB_CONFIG

_pool = None


def get_pool():
    """Create or return the existing connection pool."""
    global _pool
    if _pool is None:
        _pool = pooling.MySQLConnectionPool(
            pool_name="moodsync_pool",
            pool_size=5,
            **DB_CONFIG
        )
    return _pool


def get_connection():
    """Get a connection from the pool."""
    return get_pool().get_connection()


def query(sql, params=None, fetchone=False):
    """Run a SELECT query and return results as list of dicts."""
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
    """Run an INSERT / UPDATE / DELETE and return lastrowid."""
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
