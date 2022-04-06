from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse, abort

import authentication
import config
import json


app = Flask(__name__)
api = Api(app)


# Home
class Home(Resource):
    def get(self):
        return jsonify({"message": "Nothing to see here"})


class Login(Resource):
    def post(self):

        # Parse arguments
        parser = reqparse.RequestParser()
        parser.add_argument("id")
        parser.add_argument("pin")
        argsr = parser.parse_args()

        id = argsr["id"]
        pin = argsr["pin"]

        # Validate Credentials
        auth = authentication.authenticate_login(id, pin)

        if auth == authentication.Status.Success:
            response = {
                "jwt": "wow text",
                "req_methods": ["meth 1", "meth 2", "meth 3"],
                "enc_key": "big key",
                "expiry": "1/1/1970",
            }
        else:
            response = {"error_type": "auth_failed", "message": "Login Failed"}

        # JSON to return
        return jsonify(response)


class Auth(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("auth_type")
        parser.add_argument("auth_key")
        argsr = parser.parse_args()

        authr = request.headers["Authorization"]

        return jsonify({"token": "big token", "expiry": "1/1/1970"})


class GetVoteForm(Resource):
    def get(self):
        voting_form = config.basedir / "data" / "voting_form.json"
        with voting_form.open() as f:
            form_data = json.load(f)
        return jsonify(form_data)


class SubmitVote(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("master_token")
        parser.add_argument("form_data")
        argsr = parser.parse_args()
        authr = request.headers["Authorization"]

        return jsonify(
            {"vote_status": "success", "message": "the vote has been cast successfully"}
        )


api.add_resource(Home, "/")
api.add_resource(Auth, "/auth_verify")
api.add_resource(Login, "/login")
api.add_resource(GetVoteForm, "/vote_form")
api.add_resource(SubmitVote, "/submit")


if __name__ == "__main__":
    app.run(debug=True, host="192.168.1.34")
