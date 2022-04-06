from enum import Enum

import cryptography


class Status(Enum):
    Success = 0
    Fail = 1


def generate_keypair():
    pass


def authenticate_login(id, pin):
    if str(id) == "1234":
        if str(pin) == "0000":
            return Status.Success
    return Status.Fail
