import config
from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse
from flask_cors import CORS
from database_handling.sql_handling import db, VoteCfg, VoteUser

app = Flask(__name__)
api = Api(app)
CORS(app)

app.config["SQLALCHEMY_DATABASE_URI"] = config.SQL_URI
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.secret_key = config.SQL_SECRET

db.init_app(app)
with app.app_context():
    db.create_all()


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
                VoteCfg.set_defaults()
                response["message"] = "Vote configuration has been reset"
            elif req_type == "edit":
                if data["property"] in list(VoteCfg.fetch_config()):
                    VoteCfg.edit_config(str(data["property"]), str(data["value"]))
                    response["message"] = "Property has been edited"
                else:
                    response["message"] = "Invalid Property"
            else:
                response["message"] = "Invalid Request Type"
        except:
            response["message"] = "Invalid Request"

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
                VoteUser.add_entry(
                    id=data["id"],
                    pin=data["pin"],
                    totp1=data["totp1"],
                    totp2=data["totp2"],
                )
                response["message"] = "Vote configuration has been reset"
            elif req_type == "delete":
                if VoteUser.fetch_entry(data["id"]):
                    VoteUser.delete_entry(data["id"])
                    response["message"] = "User deleted"
                else:
                    response["message"] = "Error deleting user"
            else:
                response["message"] = "Invalid Request Type"
        except:
            response["message"] = "Invalid Request"

        return jsonify(response)


api.add_resource(VoteConfigAPI, "/config")
api.add_resource(VoteUserAPI, "/users")


if __name__ == "__main__":
    context = (
        str((config.basedir / "ssl_stuff" / "server.crt").resolve()),
        str((config.basedir / "ssl_stuff" / "server.key").resolve()),
    )
    app.run(
        debug=True,
        host=config.WEBUI_SERVER_URI,
        port=config.WEBUI_SERVER_PORT,
        ssl_context=context,
    )
