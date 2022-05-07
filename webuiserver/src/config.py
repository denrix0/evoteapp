from os import getenv
from dotenv import load_dotenv
from pathlib import Path

basedir = Path(__file__).parent

load_dotenv()

SQL_USER = getenv("SQL_USER") or "user"
SQL_PASS = getenv("SQL_PASS") or "pass"
SQL_HOSTNAME = getenv("SQL_HOSTNAME") or "%"
SQL_DB = getenv("SQL_DB") or "evoteapp"
SQL_SECRET = getenv("SQL_SECRET")

SQL_URI = f"mysql://{SQL_USER}:{SQL_PASS}@{SQL_HOSTNAME}/{SQL_DB}"

WEBUI_SERVER_URI = getenv("WEBUI_SERVER_URI") or "127.0.0.1"
WEBUI_SERVER_PORT = getenv("WEBUI_SERVER_PORT") or 6000
