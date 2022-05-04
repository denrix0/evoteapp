from pathlib import Path
from dotenv import load_dotenv
from os import getenv

basedir = Path(__file__).parent

# Load Environment Variables
load_dotenv()

APP_NAME = getenv("APP_NAME") or "EVoteApp"

SERVER_URI = getenv("SERVER_URI") or "127.0.0.1"
SERVER_PORT = getenv("SERVER_PORT") or 5000
SERVER_SECRET = getenv("SERVER_SECRET")

SQL_USER = getenv("SQL_USER") or "user"
SQL_PASS = getenv("SQL_PASS") or "pass"
SQL_HOSTNAME = getenv("SQL_HOSTNAME") or "%"
SQL_DB = getenv("SQL_DB") or "evoteapp"
SQL_URI = f"mysql://{SQL_USER}:{SQL_PASS}@{SQL_HOSTNAME}/{SQL_DB}"
SQL_SECRET = getenv("SQL_SECRET")

JWT_SECRET = getenv("JWT_SECRET")

OWNER_IP = getenv("OWNER_IP")

# Retrieve Voting Config
from database_handling.sql_config_fetch import VoteConfig

vote_config = VoteConfig()
