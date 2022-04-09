from enum import Enum
from database_handling.sql_handling import fetch_entry

import crypto_functions as cryp


class Status(Enum):
    Success = 0
    Fail = 1


def authenticate_login(id, pin):
    entry = fetch_entry(id=id)

    response = Status.Fail
    message = "None"

    if entry is not None:
        if cryp.verify_pin(pin, hashed_pin=entry.pin, salt=entry.salt):
            response = Status.Success
        else:
            message = "Incorrect PIN"
    else:
        message = "User doesn't exist"

    return response, message
