from enum import Enum
from database_handling.sql_handling import fetch_entry

import crypto_functions as cryp
import pyotp
import jwt
import config
import time


token_time = lambda: int(time.time() + config.vote_config.expiry)


class AuthType(Enum):
    TOTP1 = "totp1"
    TOTP2 = "totp2"
    UID = "uid"


class JWTStatus(Enum):
    failed = 0
    expired = 1
    verified = 2


class AuthenticationException(Exception):
    def __init__(self, code, message):
        self.code = code
        self.message = message

    def __str__(self) -> str:
        return self.message


def authenticate_login(id, pin):
    entry = fetch_entry(id=id)

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
    entry = fetch_entry(id=id)

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
