from enum import Enum
from database_handling.sql_handling import fetch_entry

import crypto_functions as cryp
import pyotp


class AuthenticationException(Exception):
    def __init__(self, code, message):
        self.code = code
        self.message = message

    def __str__(self) -> str:
        return self.message


class AuthType(Enum):
    TOTP1 = "totp1"
    TOTP2 = "totp2"
    UID = "uid"


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
    # TODO: Work with some API
    return True
