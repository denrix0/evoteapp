from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse

import config
import json


app = Flask(__name__)
api = Api(app)


# Home
class Home(Resource):
    def get(self):
        return jsonify({"data": "hello"})


class InitAuth(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("id")
        parser.add_argument("pin")
        argsr = parser.parse_args()
        return {"auth_token": argsr["id"], "expiry": argsr["pin"]}


class Auth(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("auth_type")
        parser.add_argument("auth_key")
        argsr = parser.parse_args()
        authr = request.headers["Authorization"]
        return {"token": argsr["auth_type"], "expiry": argsr["auth_key"], "auth": authr}


class GetVoteForm(Resource):
    def get(self):
        voting_form = config.basedir / "data" / "voting_form.json"
        with voting_form.open() as f:
            form_data = json.load(f)
        return form_data


class SubmitVote(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("gen_token")
        parser.add_argument("form_data")
        argsr = parser.parse_args()
        authr = request.headers["Authorization"]

        return {
            "vote_status": argsr["gen_token"],
            "message": argsr["form_data"],
            "auth": authr,
        }


# class GetVoteData(Resource):
#     def

api.add_resource(Home, "/")
api.add_resource(Auth, "/auth_verify")
api.add_resource(InitAuth, "/init_auth")
api.add_resource(GetVoteForm, "/voteform")
api.add_resource(SubmitVote, "/submit")


if __name__ == "__main__":
    app.run(debug=True)
