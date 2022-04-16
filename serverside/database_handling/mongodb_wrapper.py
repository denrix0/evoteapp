from pymongo import MongoClient


class MongoAPI:
    def __init__(self):
        mongoclient = MongoClient("localhost", 27017)

        db = mongoclient["evote_db"]
        self.user_data = db["user_data"]

    def set_user_data(self, id, jwt=None, msg_key=None, auth_tokens={}):
        """
        msg_key = string
        auth_tokens = {'<method>': '<token>', ...}
        """
        defaults = self.fetch_user_data(id=id)

        data = {
            "user_id": id,
            "jwt": "",
            "auth_tokens": {},
            "msg_key": "",
        }

        if defaults:
            for key in data.keys():
                try:
                    data[key] = defaults[key]
                except KeyError:
                    pass

        if jwt:
            data["jwt"] = jwt

        if msg_key:
            data["msg_key"] = msg_key

        if auth_tokens:
            for k, v in auth_tokens.items():
                data["auth_tokens"][k] = v

        self.user_data.update_one({"user_id": id}, {"$set": data}, upsert=True)

    def fetch_user_data(self, id, data=None, sub_data=None, jwt=False):
        """
        data = auth_tokens, master_token, msg_key
        sub_data = auth_tokens(method), keypair(pub, pvt)
        """

        if jwt:
            response = self.user_data.find_one({"jwt": id})
        else:
            response = self.user_data.find_one({"user_id": id})

        if data and response:
            response = response[data]
            if response == "auth_tokens":
                response = response[sub_data]

        return response

    def delete_user_data(self, id):
        self.user_data.delete_one({id: {"$type": "object"}})


if __name__ == "__main__":
    api = MongoAPI()

    api.set_user_data("101", auth_tokens={"totp2": "ysses"}, jwt="mass")
    print(api.fetch_user_data("mass", jwt=True))
    api.delete_user_data("ass")
