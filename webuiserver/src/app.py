import src.config as config
import requests
from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse
from flask_cors import CORS
from src.sql_handling import db, VoteCfg, VoteUser

app = Flask(__name__)
api = Api(app)
CORS(app)

app.config["SQLALCHEMY_DATABASE_URI"] = config.SQL_URI
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.secret_key = config.SQL_SECRET

db.init_app(app)
with app.app_context():
    db.create_all()


class APIException(Exception):
    def __init__(self, code, message):
        self.code = code
        self.message = message

    def __str__(self) -> str:
        return self.message


class Home(Resource):
    def get(self):
        return jsonify({"user_type": config.SQL_USER})


class VoteConfigAPI(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("type")
        parser.add_argument("data")
        argsr = parser.parse_args()

        req_type = argsr["type"]
        data = None

        if req_type == "edit":
            data = request.get_json()["data"]

        response = {}

        try:
            if req_type == "fetch":
                response["message"] = "Query success. Fetched Vote Configuration"
                response["data"] = VoteCfg.fetch_config()
            elif req_type == "reset":
                if config.SQL_USER != "evote_owner":
                    raise APIException("not_owner", "Cannot Modify Config, Not owner")
                VoteCfg.set_defaults()
                response["message"] = "Vote configuration has been reset"
            elif req_type == "edit":
                if config.SQL_USER != "evote_owner":
                    raise APIException("not_owner", "Cannot Modify Config, Not owner")
                if data["property"] in list(VoteCfg.fetch_config()):
                    VoteCfg.edit_config(str(data["property"]), str(data["value"]))
                    response["message"] = "Property has been edited"
                else:
                    raise APIException("property_invalid", "Invalid Property")
            else:
                raise APIException("unknown_tpye", "Invalid Request Type")
        except APIException as e:
            response = {"error_type": e.code, "message": e.message}
        except:
            response = {"error_type": "unknown", "message": "Something happened"}

        return jsonify(response)


class VoteUserAPI(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("type")
        parser.add_argument("data")
        argsr = parser.parse_args()

        req_type = argsr["type"]
        data = request.get_json()["data"]

        response = {}

        try:
            if req_type == "add":
                if not data["id"].isdigit():
                    raise APIException("invalid_id", "Invalid User ID")

                if len(data["pin"]) < 8:
                    raise APIException(
                        "invalid_pin", "PIN Must be longer than 8 characters"
                    )

                VoteUser.add_entry(
                    id=data["id"],
                    pin=data["pin"],
                    totp1=data["totp1"],
                    totp2=data["totp2"],
                )
                response["message"] = "User has been added."
            elif req_type == "delete":
                if VoteUser.fetch_entry(data["id"]):
                    VoteUser.delete_entry(data["id"])
                    response["message"] = "User deleted"
                else:
                    raise APIException("no_user", "User by that ID doesn't exist")
            else:
                raise APIException("unknown_tpye", "Invalid Request Type")
        except APIException as e:
            response = {"error_type": e.code, "message": e.message}
        except Exception as e:
            response = {
                "error_type": "unknown",
                "message": "Something happened" + str(e),
            }

        return jsonify(response)


class VoteStatus(Resource):
    def get(self):
        return requests.get(
            "https://127.0.0.1:" + config.SERVER_PORT + "/vote_status", verify=False
        ).json()


api.add_resource(Home, "/")
api.add_resource(VoteConfigAPI, "/config")
api.add_resource(VoteUserAPI, "/users")
api.add_resource(VoteStatus, "/vote_status")
