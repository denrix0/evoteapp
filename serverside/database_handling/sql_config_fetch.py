import mysql.connector
import config
import pickle


class VoteConfig:
    def __init__(self):
        """
        Fetches vote configuration from app's SQL DB
        """
        conn = mysql.connector.connect(
            host=config.SQL_HOSTNAME,
            user=config.SQL_USER,
            passwd=config.SQL_PASS,
            database=config.SQL_DB,
        )
        cur = conn.cursor()

        stmt = "SELECT name, value FROM voting_config"
        cur.execute(stmt)
        values = dict(cur)
        cur.close()

        self.prompt = values["prompt"]
        self.options = pickle.loads(bytearray.fromhex(values["options"]))
        self.req_methods = pickle.loads(bytearray.fromhex(values["req_methods"]))
        self.expiry = int(values["expiry"])
        self.ongoing = True if values["ongoing"] != "0" else False
