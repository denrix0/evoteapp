from enum import Enum
from src.database_handling.sql_handling import VoteUser, VoteCfg

import src.function_kit.crypto_functions as cryp
import pyotp
import jwt
import src.config as config
import time


token_time = lambda: int(time.time() + int(VoteCfg.fetch_config()["expiry"]))


class AuthType(Enum):
    TOTP1 = "totp1"
    TOTP2 = "totp2"
    UID = "uid"


class JWTStatus(Enum):
    failed = 0
    expired = 1
    verified = 2


def authenticate_login(id, pin):
    entry = VoteUser.fetch_entry(id=id)

    response = False
    message = "None"

    if entry is not None:
        if cryp.PinHash.verify(pin, hashed_pin=entry.pin, salt=entry.salt):
            response = True
        else:
            message = "Incorrect PIN"
    else:
        message = "User doesn't exist"

    return response, message


def validate_totp(id, auth_type, token):
    entry = VoteUser.fetch_entry(id=id)

    totp_secret = entry.totp1 if auth_type == AuthType.TOTP1 else entry.totp2

    totp = pyotp.TOTP(totp_secret)

    return totp.verify(token)


def validate_uid(id, uid):
    # TODO: Implement sending a request to third party id verification service
    return True


class JWT:
    @staticmethod
    def generate(id):
        """
        makes jwt
        """
        token = jwt.encode(
            {
                "exp": token_time(),
                "iss": config.APP_NAME,
                "user_id": id,
            },
            config.JWT_SECRET,
            algorithm="HS512",
        )

        return token.decode()

    @staticmethod
    def verify(token):
        """
        verifies jwt
        """
        response = JWTStatus.failed
        id = None
        try:
            id = jwt.decode(
                token,
                config.JWT_SECRET,
                algorithm="HS512",
                issuer=config.APP_NAME,
            )["user_id"]
            response = JWTStatus.verified
        except jwt.exceptions.ExpiredSignatureError:
            response = JWTStatus.expired
        except jwt.exceptions.InvalidTokenError:
            response = JWTStatus.failed

        return id, response
