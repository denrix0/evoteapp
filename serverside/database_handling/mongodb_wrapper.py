from pymongo import MongoClient


class MongoAPI:
    def __init__(self):
        mongoclient = MongoClient("localhost", 27017)

        self.db = mongoclient["evote_configuration"]
        self.voting_form = self.db["voting_form"]
        self.vote_config = self.db["vote_config"]

        if "evote_configuration" not in mongoclient.list_database_names():
            self.set_defaults()

    def set_defaults(self):
        config_data = {
            "req_methods": ["totp1", "totp2", "uid"],
            "expiry": 600,
        }

        form_data = {
            "prompt": "Sample Prompt",
            "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
        }

        self.vote_config.insert_one(config_data)
        self.voting_form.insert_one(form_data)

    def set_vote_form(
        self,
        prompt=None,
        options=None,
    ):
        default_values = self.fetch_voting_form()
        if not prompt:
            prompt = default_values["prompt"]
        if not options:
            options = default_values["options"]

        data = {"prompt": prompt, "options": options}

        id = self.voting_form.find_one()["_id"]
        self.voting_form.update_many({"_id": id}, {"$set": data})

    def set_vote_config(self, req_methods=None, expiry=None):
        if not req_methods:
            req_methods = self.fetch_vote_config()
        if not expiry:
            expiry = self.fetch_vote_config("expiry")

        data = {"req_methods": req_methods, "expiry": expiry}

        id = self.vote_config.find_one()["_id"]
        self.vote_config.update_many({"_id": id}, {"$set": data})

    def fetch_voting_form(self):
        form = self.voting_form.find_one()
        form.pop("_id")

        return form

    def fetch_vote_config(self, data="req_methods"):
        response = self.vote_config.find_one()

        return response[data]


if __name__ == "__main__":
    api = MongoAPI()
    print(api.fetch_voting_form())
    print(api.fetch_vote_config("req_methods"))
    print(api.fetch_vote_config("expiry"))
    api.set_vote_form(prompt="Hi")
    print(api.fetch_voting_form())
    api.set_vote_config(req_methods=["meth1", "meth2"])
    print(api.fetch_vote_config("req_methods"))
    print(api.fetch_vote_config("expiry"))
