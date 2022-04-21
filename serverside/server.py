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


def brownie_run(method, kwargs={}):
    return brownie.run(
        script_path="scripts/contract_functions.py",
        method_name=method,
        kwargs=kwargs,
    )


def store_voter_ids(id):
    """
    stores upto 10 ids in a json file
    when called to add a 11th id, it dumps the json file's id into the blockchain and resets the json file
    """

    dump_file = config.basedir / "voter_dump.json"

    reset = False

    if dump_file.is_file():
        with open(dump_file) as f:
            data = json.load(f)

        if int(data["count"]) < 10:
            data["count"] += 1
            data["id_array"].append(id)
        else:
            brownie_run(method="set_voted", kwargs={"ids": data["id_array"]})
            reset = True

    else:
        reset = True

    if reset:
        data = {"count": 1, "id_array": [id]}

    with open(dump_file, "w") as f:
        json.dump(data, f)


def check_vote(id):
    dump_file = config.basedir / "voter_dump.json"

    voted = False  # Assume vote has already been cast from this id

    # Check json file
    if dump_file.is_file():
        with open(dump_file) as f:
            data = json.load(f)
            if id in data["id_array"]:
                voted = True

    # Check blockchain
    response = brownie_run(method="get_voted", kwargs={"id": id})
    if response:
        voted = True

    return voted


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
            if not id.isdigit() or (" " in id):
                raise authentication.AuthenticationException(
                    "invalid_id", "The id is invalid"
                )

            if (len(pin) < 8) or (" " in pin):
                raise authentication.AuthenticationException(
                    "invalid_pin", "The pin is invalid"
                )

            if not config.vote_config.ongoing:
                raise authentication.AuthenticationException(
                    "no_vote", "There is no vote ongoing as of now"
                )

            if check_vote(id):
                raise authentication.AuthenticationException(
                    "already_voted", "There is already a vote cast from this id"
                )

            auth, message = authentication.authenticate_login(id, pin)

            if not auth:
                raise authentication.AuthenticationException("auth_error", message)

            existing_jwt = mongo.fetch_user_data(id, data="jwt")
            if existing_jwt:
                response = JWT.verify(existing_jwt)
                if not response:
                    if not id:
                        mongo.delete_user_data(id)
                    raise authentication.AuthenticationException(
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

        except authentication.AuthenticationException as e:
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
                raise authentication.AuthenticationException(
                    "no_vote", "There is no vote ongoing as of now"
                )

            if not pvt_key:
                raise authentication.AuthenticationException(
                    "user_error", "User does not Exist"
                )

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
                        if len(auth_content != 6):
                            raise authentication.AuthenticationException(
                                "otp_error", "OTP is of invalid length"
                            )

                        if not auth_content.isdigit():
                            raise authentication.AuthenticationException(
                                "otp_error", "OTP must only contain numbers"
                            )

                        if " " in auth_content:
                            raise authentication.AuthenticationException(
                                "otp_error", "OTP must not contain spaces"
                            )

                        authenticated = authentication.validate_totp(
                            id, auth_type, auth_content
                        )
                    elif auth_type == authentication.AuthType.UID:
                        if " " in auth_content:
                            raise authentication.AuthenticationException(
                                "uid_error", "UID must not contain spaces"
                            )

                        authenticated = authentication.validate_uid(id, auth_content)

                    if authenticated:
                        new_token = get_random(32)

                        mongo.set_user_data(
                            id,
                            auth_tokens={auth_type.value: new_token},
                        )

                        response = {
                            "method": auth_type.value,
                            "token": AESKey.encrypt(new_token, key=key, iv=iv),
                        }
                    else:
                        raise authentication.AuthenticationException(
                            "auth_failed", "Authentication Failed"
                        )
                else:
                    raise authentication.AuthenticationException(
                        "invalid_method", "Invalid Authentication Method"
                    )
            else:
                raise authentication.AuthenticationException(
                    "token_invalid", "Invalid Authorization Token"
                )
        except authentication.AuthenticationException as e:
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
    def get(self):
        option_list = config.vote_config.options

        data = brownie_run(
            method="get_option_values", kwargs={"option_list": option_list}
        )

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
            if check_vote(id):
                raise authentication.AuthenticationException(
                    "already_voted", "There is already a vote cast from this id"
                )

            if not config.vote_config.ongoing:
                raise authentication.AuthenticationException(
                    "no_vote", "There is no vote ongoing as of now"
                )

            if not pvt_key:
                raise authentication.AuthenticationException(
                    "user_error", "User does not Exist"
                )

            if response:
                key = RSAKey.decrypt(msg=key, pvt_pem=pvt_key)
                iv = RSAKey.decrypt(msg=iv, pvt_pem=pvt_key)

                option = AESKey.decrypt(msg=option, key=key, iv=iv)
                token = AESKey.decrypt(msg=token, key=key, iv=iv)

                tokens = mongo.fetch_user_data(id=id, data="auth_tokens")

                master_token = generate_master_token(
                    uid=tokens["uid"], totp1=tokens["totp1"], totp2=tokens["totp2"]
                )

                if option not in config.vote_config.options:
                    raise authentication.AuthenticationException(
                        "invaid_option", "That is an invalid option."
                    )

                if token == master_token:
                    store_voter_ids(id)
                    brownie_run(method="increment_vote", kwargs={"option_name": option})

                    response = {
                        "vote_status": "vote_success",
                        "message": "The vote has been cast successfully",
                    }
                else:
                    raise authentication.AuthenticationException(
                        "bad_token", "Master token does not match"
                    )
            else:
                raise authentication.AuthenticationException(
                    "token_invalid", "Invalid Authorization Token"
                )

        except authentication.AuthenticationException as e:
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
    context = (
        str((config.basedir / "ssl_stuff" / "server.crt").resolve()),
        str((config.basedir / "ssl_stuff" / "server.key").resolve()),
    )
    app.run(
        debug=True, host=config.SERVER_URI, port=config.SERVER_PORT, ssl_context=context
    )
