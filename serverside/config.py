from pathlib import Path
from dotenv import load_dotenv
from os import getenv
from database_handling.mongodb_wrapper import MongoAPI

basedir = Path(".") / "serverside"

# Retrieve Voting Config
mongo_api = MongoAPI()

REQUESTED_METHODS = mongo_api.fetch_vote_config("req_methods") or [
    "uid",
    "totp1",
    "totp2",
]
TOKEN_EXPIRY = mongo_api.fetch_vote_config("expiry") or 600

# Load Environment Variables
load_dotenv()

APP_NAME = getenv("APP_NAME") or "EVoteApp"

SERVER_URI = getenv("SERVER_URI") or "127.0.0.1"
SERVER_PORT = getenv("SERVER_PORT") or 5000

SQL_URI = getenv("SQL_URI") or "127.0.0.1"
SQL_SECRET_KEY = getenv("SQL_SECRET_KEY")

JWT_SECRET = getenv("JWT_SECRET")
