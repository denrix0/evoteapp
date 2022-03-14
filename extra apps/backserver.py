from flask import Flask, jsonify, request
from flask_restful import Resource, Api
from dotenv import load_dotenv

import os

load_dotenv()

app = Flask(__name__)
api = Api(app)

# SQL

# Home
class Home(Resource):
    def get(self):
        return jsonify({"data": "hello"})


# Authenticate User's PIN
class PinAuth(Resource):
    def post(self):
        return jsonify({"data": "pin_verify"})


# Authenticate User's TOTP
class OTPAuth(Resource):
    def post(self):
        return jsonify({"data": "otp_verify"})


# Authenticate User's Govt ID
class GovtAuth(Resource):
    def post(self):
        return jsonify({"data": "gov_verify"})


# Create user
class CreateUser(Resource):
    def post(self):
        return jsonify({"data": "success"})


api.add_resource(Home, "/")
api.add_resource(PinAuth, "/pin_verify")
api.add_resource(OTPAuth, "/otp_verify")
api.add_resource(GovtAuth, "/gov_verify")


if __name__ == "__main__":
    app.run(debug=True)
