from flask import Flask, jsonify, request
from flask_restful import Resource, Api
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv

import os

load_dotenv()

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("SQLURI")
api = Api(app)

# Home
class Home(Resource):
    def get(self):
        return jsonify({"data": "hello"})


# Authenticate User's PIN
class PinAuth:
    def post(self):
        return jsonify({"data": "pin"})


# Authenticate User's TOTP
class OTPAuth:
    def post(self):
        return jsonify({"data": "otp"})


# Authenticate User's Govt ID
class GovtAuth:
    def post(self):
        return jsonify({"data": "gov"})


api.add_resource(Home, "/")
api.add_resource(PinAuth, "/pin")
api.add_resource(OTPAuth, "/otp")
api.add_resource(GovtAuth, "/gov")


if __name__ == "__main__":
    app.run(debug=True)
