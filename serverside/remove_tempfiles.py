import config
import os
from database_handling.mongodb_wrapper import MongoAPI

mongo = MongoAPI()
if os.path.isfile(config.basedir / "voter_dump.json"):
    os.remove(config.basedir / "voter_dump.json")
mongo.clear_db()
