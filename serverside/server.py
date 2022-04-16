import json
import authentication
import config
import os
import brownie

from pathlib import Path
from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse
from database_handling.mongodb_wrapper import MongoAPI
from database_handling.sql_handling import db
from crypto_functions import JWT, AESKey, RSAKey, get_random, generate_master_token
from definitions_dump import AuthenticationException


app = Flask(__name__)
api = Api(app)
mongo = MongoAPI()

app.config["SQLALCHEMY_DATABASE_URI"] = config.SQL_URI
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.secret_key = config.SQL_SECRET

proj = brownie.project.load(
    (Path(os.path.dirname(os.path.realpath(__file__))) / "votestorage").resolve()
)
brownie.network.connect("development")
proj.load_config()
json_file_loc = config.basedir / "brownie_dump.json"


def brownie_run(method, json_file=False, kwargs={}):
    if json_file:
        kwargs["json_file"] = json_file_loc

    brownie.run(
        script_path="scripts/contract_functions.py",
        method_name=method,
        kwargs=kwargs,
    )


brownie_run(method="deploy")

db.init_app(app)
with app.app_context():
    db.create_all()

# Home
class Home(Resource):
    def get(self):
        return jsonify({"message": "Nothing to see here"})


class Login(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("id")
        parser.add_argument("pin")
        argsr = parser.parse_args()

        id = argsr["id"]
        pin = argsr["pin"]

        try:
            if not config.vote_config.ongoing:
                raise AuthenticationException(
                    "no_vote", "There is no vote ongoing as of now"
                )

            auth, message = authentication.authenticate_login(id, pin)

            if not auth:
                raise AuthenticationException("auth_error", message)

            existing_jwt = mongo.fetch_user_data(id, data="jwt")
            if existing_jwt:
                response = JWT.verify(existing_jwt)
                if not response:
                    if not id:
                        mongo.delete_user_data(id)
                    raise AuthenticationException(
                        "already_active",
                        "This account is already logged in or session expired",
                    )

            pvt, pub = RSAKey.generate()
            jwt = JWT.generate(id)

            mongo.set_user_data(id=id, msg_key=pvt, jwt=jwt)

            response = {
                "jwt": jwt,
                "pub_key": pub,
            }

        except AuthenticationException as e:
            response = {"error_type": e.code, "message": e.message}

        # JSON to return
        return jsonify(response)


class Auth(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("auth_type")
        parser.add_argument("auth_content")
        parser.add_argument("enc_key")
        parser.add_argument("iv")
        argsr = parser.parse_args()

        try:
            auth_type = argsr["auth_type"]
            auth_content = argsr["auth_content"]
            key = argsr["enc_key"]
            iv = argsr["iv"]

            jwtoken = request.headers["Authorization"].replace("Bearer ", "")
            id, response = JWT.verify(jwtoken)

            pvt_key = mongo.fetch_user_data(id, data="msg_key")

            if not config.vote_config.ongoing:
                raise AuthenticationException(
                    "no_vote", "There is no vote ongoing as of now"
                )

            if not pvt_key:
                raise AuthenticationException("user_error", "User does not Exist")

            if response:
                key = RSAKey.decrypt(msg=key, pvt_pem=pvt_key)
                iv = RSAKey.decrypt(msg=iv, pvt_pem=pvt_key)

                auth_content = AESKey.decrypt(auth_content, key=key, iv=iv)

                if auth_type in config.vote_config.req_methods:
                    auth_type = authentication.AuthType(auth_type)
                    authenticated = False

                    if auth_type in [
                        authentication.AuthType.TOTP1,
                        authentication.AuthType.TOTP2,
                    ]:
                        authenticated = authentication.validate_totp(
                            id, auth_type, auth_content
                        )
                    elif auth_type == authentication.AuthType.UID:
                        authenticated = authentication.validate_uid(id, auth_content)

                    if authenticated:
                        new_token = get_random(32)

                        mongo.set_user_data(
                            id, auth_tokens={auth_type.value: new_token}
                        )

                        response = {"method": auth_type.value, "token": new_token}
                    else:
                        raise AuthenticationException(
                            "auth_failed", "Authentication Failed"
                        )
                else:
                    raise AuthenticationException(
                        "invalid_method", "Invalid Authentication Method"
                    )
            else:
                raise AuthenticationException(
                    "token_invalid", "Invalid Authorization Token"
                )
        except AuthenticationException as e:
            response = {
                "error_type": e.code,
                "message": e.message,
            }

        return jsonify(response)


class GetVoteForm(Resource):
    def get(self):
        form = {
            "prompt": config.vote_config.prompt,
            "options": config.vote_config.options,
        }
        return jsonify(form)


class MgmtPage(Resource):
    def post(self):
        option_list = config.vote_config.options

        brownie_run(
            method="write_votes_json",
            kwargs={"option_list": option_list},
            json_file=True,
        )

        with open(json_file_loc) as f:
            data = json.load(f)

        return jsonify(data)


class SubmitVote(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument("master_token")
        parser.add_argument("form_option")
        parser.add_argument("enc_key")
        parser.add_argument("iv")
        argsr = parser.parse_args()

        token = argsr["master_token"]
        option = argsr["form_option"]
        key = argsr["enc_key"]
        iv = argsr["iv"]

        jwtoken = request.headers["Authorization"].replace("Bearer ", "")

        id, response = JWT.verify(jwtoken)

        pvt_key = mongo.fetch_user_data(id, data="msg_key")

        try:
            if not config.vote_config.ongoing:
                raise AuthenticationException(
                    "no_vote", "There is no vote ongoing as of now"
                )

            if not pvt_key:
                raise AuthenticationException("user_error", "User does not Exist")

            if response:
                key = RSAKey.decrypt(msg=key, pvt_pem=pvt_key)
                iv = RSAKey.decrypt(msg=iv, pvt_pem=pvt_key)

                option = AESKey.decrypt(msg=option, key=key, iv=iv)
                token = AESKey.decrypt(token, key=key, iv=iv)

                tokens = mongo.fetch_user_data(id=id, data="auth_tokens")

                master_token = generate_master_token(
                    uid=tokens["uid"], totp1=tokens["totp1"], totp2=tokens["totp2"]
                )

                if token == master_token:
                    brownie_run(method="increment_vote", kwargs={"option_name": option})
                    response = {
                        "vote_status": "vote_success",
                        "message": "The vote has been cast successfully",
                    }
                else:
                    raise AuthenticationException(
                        "bad_token", "Master token does not match"
                    )
            else:
                raise AuthenticationException(
                    "token_invalid", "Invalid Authorization Token"
                )

        except AuthenticationException as e:
            response = {
                "error_type": e.code,
                "message": e.message,
            }

        mongo.delete_user_data(id)
        return jsonify(response)


api.add_resource(Home, "/")
api.add_resource(Auth, "/auth_verify")
api.add_resource(Login, "/login")
api.add_resource(GetVoteForm, "/vote_form")
api.add_resource(SubmitVote, "/submit")
api.add_resource(MgmtPage, "/mgmt_page")


if __name__ == "__main__":
    app.run(debug=True, host=config.SERVER_URI, port=config.SERVER_PORT)
