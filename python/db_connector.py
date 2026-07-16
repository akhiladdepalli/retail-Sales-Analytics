"""
Database Connector Module
Handles PostgreSQL database connections with context manager support.
Falls back to standalone mode (no DB required) when PostgreSQL is unavailable.
"""

import logging
from contextlib import contextmanager
from typing import Optional

import pandas as pd

logger = logging.getLogger(__name__)


class DatabaseConnector:
    """
    PostgreSQL database connector with connection pooling and context management.
    Provides a clean interface for executing queries and loading DataFrames.
    """

    def __init__(self, config: dict):
        """
        Initialize the database connector.

        Args:
            config: Dictionary with keys: host, port, database, user, password, schema
        """
        self.config = config
        self._connection = None
        self._available = False
        self._check_availability()

    def _check_availability(self):
        """Check if PostgreSQL is available."""
        try:
            import psycopg2
            conn = psycopg2.connect(
                host=self.config["host"],
                port=self.config["port"],
                database=self.config["database"],
                user=self.config["user"],
                password=self.config["password"],
                connect_timeout=5,
            )
            conn.close()
            self._available = True
            logger.info("✅ PostgreSQL connection verified successfully")
        except Exception as e:
            self._available = False
            logger.warning(f"⚠️  PostgreSQL not available: {e}")
            logger.info("📦 Running in standalone mode (no database required)")

    @property
    def is_available(self) -> bool:
        """Check if database connection is available."""
        return self._available

    @contextmanager
    def get_connection(self):
        """
        Context manager for database connections.

        Yields:
            psycopg2 connection object

        Raises:
            ConnectionError: If database is not available
        """
        if not self._available:
            raise ConnectionError(
                "PostgreSQL is not available. Use standalone mode instead."
            )

        import psycopg2

        conn = None
        try:
            conn = psycopg2.connect(
                host=self.config["host"],
                port=self.config["port"],
                database=self.config["database"],
                user=self.config["user"],
                password=self.config["password"],
            )
            yield conn
        except psycopg2.Error as e:
            if conn:
                conn.rollback()
            logger.error(f"Database error: {e}")
            raise
        finally:
            if conn:
                conn.close()

    def execute_query(self, query: str, params: Optional[tuple] = None) -> pd.DataFrame:
        """
        Execute a SQL query and return results as a pandas DataFrame.

        Args:
            query: SQL query string
            params: Optional query parameters

        Returns:
            pandas DataFrame with query results
        """
        if not self._available:
            raise ConnectionError("Database not available")

        with self.get_connection() as conn:
            return pd.read_sql_query(query, conn, params=params)

    def execute_command(self, command: str, params: Optional[tuple] = None):
        """
        Execute a SQL command (INSERT, UPDATE, DELETE, DDL).

        Args:
            command: SQL command string
            params: Optional command parameters
        """
        if not self._available:
            raise ConnectionError("Database not available")

        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(command, params)
                conn.commit()
                logger.info(f"Command executed successfully. Rows affected: {cursor.rowcount}")

    def execute_script(self, filepath: str):
        """
        Execute a SQL script file.

        Args:
            filepath: Path to the .sql file
        """
        if not self._available:
            raise ConnectionError("Database not available")

        with open(filepath, "r", encoding="utf-8") as f:
            sql = f.read()

        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql)
                conn.commit()
                logger.info(f"Script executed successfully: {filepath}")

    def table_exists(self, table_name: str) -> bool:
        """Check if a table exists in the configured schema."""
        if not self._available:
            return False

        query = """
            SELECT EXISTS (
                SELECT 1 FROM information_schema.tables
                WHERE table_schema = %s AND table_name = %s
            )
        """
        df = self.execute_query(query, (self.config["schema"], table_name))
        return df.iloc[0, 0]

    def get_table_counts(self) -> dict:
        """Get row counts for all tables in the schema."""
        if not self._available:
            return {}

        query = """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = %s
            AND table_type = 'BASE TABLE'
            ORDER BY table_name
        """
        tables_df = self.execute_query(query, (self.config["schema"],))
        counts = {}
        for table in tables_df["table_name"]:
            count_df = self.execute_query(
                f"SELECT COUNT(*) as cnt FROM {self.config['schema']}.{table}"
            )
            counts[table] = count_df.iloc[0, 0]
        return counts
