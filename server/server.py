import config
import brownie

from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse
from flask_cors import CORS
from database_handling.mongodb_wrapper import MongoAPI
from database_handling.sql_handling import db, VoteCfg
from function_kit.brownie_functions import brownie_run, check_vote, store_voter_ids
from function_kit.authentication import (
    AuthType,
    AuthenticationException,
    JWT,
    JWTStatus,
    authenticate_login,
    validate_totp,
    validate_uid,
)
from function_kit.crypto_functions import (
    AESKey,
    RSAKey,
    get_random,
    generate_master_token,
)


app = Flask(__name__)
api = Api(app)
CORS(app)
mongo = MongoAPI()

app.config["SQLALCHEMY_DATABASE_URI"] = config.SQL_URI
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.secret_key = config.SQL_SECRET

proj = brownie.project.load((config.basedir / "votestorage").resolve())
brownie.network.connect("development")
proj.load_config()


brownie_run(method="deploy")

db.init_app(app)
with app.app_context():
    db.create_all()


class Home(Resource):
    def get(self):
        VoteCfg.fetch_config()
        return jsonify({"message": "Nothing to see here"})


class Login(Resource):
    def post(self):
        parser = reqparse.RequestParser()
        parser.argument("id")
        parser.add_argument("pin")
        argsr = parser.parse_args()

        id = argsr["id"]
        pin = argsr["pin"]

        vote_config = VoteCfg.fetch_config()

        try:
            if not id.isdigit() or (" " in id):
                raise AuthenticationException("invalid_id", "The ID is invalid")

            if (len(pin) < 8) or (" " in pin):
                raise AuthenticationException("invalid_pin", "The pin is invalid")

            if not vote_config["ongoing"]:
                raise AuthenticationException(
                    "no_vote", "There is no vote ongoing as of now"
                )

            if check_vote(id):
                raise AuthenticationException(
                    "already_voted", "There is already a vote cast from this ID"
                )

            existing_jwt = mongo.fetch_user_data(id, data="jwt")

            if existing_jwt:
                _, response = JWT.verify(existing_jwt)

                if response == JWTStatus.expired:
                    mongo.delete_user_data(id)
                    raise AuthenticationException(
                        "session_expired",
                        "Session has expired. Please log in again.",
                    )
                elif response == JWTStatus.verified:
                    raise AuthenticationException(
                        "already_active",
                        "This user is currently logged in.",
                    )

            auth, message = authenticate_login(id, pin)

            if not auth:
                raise AuthenticationException("auth_error", message)

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

        vote_config = VoteCfg.fetch_config()

        try:
            auth_type = argsr["auth_type"]
            auth_content = argsr["auth_content"]
            key = argsr["enc_key"]
            iv = argsr["iv"]

            jwtoken = request.headers["Authorization"].replace("Bearer ", "")
            id, response = JWT.verify(jwtoken)

            pvt_key = mongo.fetch_user_data(id, data="msg_key")

            if not vote_config["ongoing"]:
                raise AuthenticationException(
                    "no_vote", "There is no vote ongoing as of now"
                )

            if not pvt_key:
                raise AuthenticationException("user_error", "User does not Exist")

            if response == JWTStatus.verified:
                key = RSAKey.decrypt(msg=key, pvt_pem=pvt_key)
                iv = RSAKey.decrypt(msg=iv, pvt_pem=pvt_key)

                auth_content = AESKey.decrypt(auth_content, key=key, iv=iv)

                if auth_type in vote_config["req_methods"]:
                    auth_type = AuthType(auth_type)
                    authenticated = False

                    if auth_type in [
                        AuthType.TOTP1,
                        AuthType.TOTP2,
                    ]:
                        if len(auth_content) != 6:
                            raise AuthenticationException(
                                "otp_error", "OTP is of invalid length"
                            )

                        if not auth_content.isdigit():
                            raise AuthenticationException(
                                "otp_error", "OTP must only contain numbers"
                            )

                        if " " in auth_content:
                            raise AuthenticationException(
                                "otp_error", "OTP must not contain spaces"
                            )

                        authenticated = validate_totp(id, auth_type, auth_content)
                    elif auth_type == AuthType.UID:
                        if " " in auth_content:
                            raise AuthenticationException(
                                "uid_error", "UID must not contain spaces"
                            )

                        authenticated = validate_uid(id, auth_content)

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

        vote_config = VoteCfg.fetch_config()

        form = {
            "prompt": vote_config["prompt"],
            "options": vote_config["options"],
        }
        return jsonify(form)


class VoteStatus(Resource):
    def get(self):
        vote_config = VoteCfg.fetch_config()

        option_list = vote_config["options"]

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

        vote_config = VoteCfg.fetch_config()

        jwtoken = request.headers["Authorization"].replace("Bearer ", "")

        id, response = JWT.verify(jwtoken)

        pvt_key = mongo.fetch_user_data(id, data="msg_key")

        try:
            if check_vote(id):
                raise AuthenticationException(
                    "already_voted", "There is already a vote cast from this id"
                )

            if not vote_config["ongoing"]:
                raise AuthenticationException(
                    "no_vote", "There is no vote ongoing as of now"
                )

            if not pvt_key:
                raise AuthenticationException("user_error", "User does not Exist")

            if response == JWTStatus.verified:
                key = RSAKey.decrypt(msg=key, pvt_pem=pvt_key)
                iv = RSAKey.decrypt(msg=iv, pvt_pem=pvt_key)

                option = AESKey.decrypt(msg=option, key=key, iv=iv)
                token = AESKey.decrypt(msg=token, key=key, iv=iv)

                tokens = mongo.fetch_user_data(id=id, data="auth_tokens")

                master_token = generate_master_token(
                    uid=tokens["uid"], totp1=tokens["totp1"], totp2=tokens["totp2"]
                )

                if option not in vote_config["options"]:
                    raise AuthenticationException(
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
api.add_resource(VoteStatus, "/vote_status")


if __name__ == "__main__":
    context = (
        str((config.basedir / "ssl_stuff" / "server.crt").resolve()),
        str((config.basedir / "ssl_stuff" / "server.key").resolve()),
    )
    app.run(
        debug=True, host=config.SERVER_URI, port=config.SERVER_PORT, ssl_context=context
    )
