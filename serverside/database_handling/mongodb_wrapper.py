from pymongo import MongoClient


class MongoAPI:
    def __init__(self):
        mongoclient = MongoClient("localhost", 27017)
        self.user_data = mongoclient["evote_db"]["user_data"]

    def set_user_data(self, id, jwt=None, msg_key=None, auth_tokens={}):
        """
        Args:
            id: User ID
            jwt: JWT of the user
            msg_key: Private RSA Key
            auth_tokens: DICT of keys to set
                         {'<method>': '<token>', ...}
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

    def fetch_user_data(self, id, data=None, sub_data=None):
        """
        Args:
            id: User id
            data: Initial property
                  Possible values: 'auth_tokens', 'master_token', 'msg_key'
            sub_data: If data is 'auth_tokens' specify method name
                      Possible values: 'totp1', 'totp2', 'uid'

        Returns:
            value of defined key
        """

        response = self.user_data.find_one({"user_id": id})

        if data and response:
            response = response[data]
            if response == "auth_tokens":
                response = response[sub_data]

        return response

    def delete_user_data(self, id):
        """
        Args:
            id: User ID
        """
        self.user_data.delete_one({"user_id": id})
