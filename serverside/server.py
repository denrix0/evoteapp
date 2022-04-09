from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse
from database_handling.mongodb_wrapper import MongoAPI
from database_handling.sql_handling import db, add_entry, fetch_entry, delete_entry
from crypto_functions import generate_jwt, token_time

import authentication
import config


app = Flask(__name__)
api = Api(app)
mongo_api = MongoAPI()

app.config["SQLALCHEMY_DATABASE_URI"] = config.SQL_URI
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.secret_key = config.SQL_SECRET_KEY

db.init_app(app)
with app.app_context():
    db.create_all()

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
        auth, message = authentication.authenticate_login(id, pin)

        if auth is authentication.Status.Success:
            response = {
                "jwt": generate_jwt(),
                "req_methods": config.REQUESTED_METHODS,
                "enc_key": "big key",
                "expiry": token_time(),
            }

        else:
            response = {"error_type": "auth_failed", "message": message}

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
        return jsonify(mongo_api.fetch_voting_form())


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


class TempUniqueIDAuth(Resource):
    def post(self):
        return jsonify({"works": "yes"})


api.add_resource(Home, "/")
api.add_resource(Auth, "/auth_verify")
api.add_resource(Login, "/login")
api.add_resource(GetVoteForm, "/vote_form")
api.add_resource(SubmitVote, "/submit")


if __name__ == "__main__":
    app.run(debug=True, host=config.SERVER_URI, port=config.SERVER_PORT)
