import jwt
import secrets
import config
import time

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives.kdf.scrypt import Scrypt
from cryptography.exceptions import InvalidKey

token_time = lambda: (time.time() + config.TOKEN_EXPIRY)


def generate_keypair():
    private_key = Ed25519PrivateKey.generate()
    public_key = private_key.public_key()

    return (private_key, public_key)


def hash_pin(pin):
    salt = secrets.token_bytes(16)

    kdf = Scrypt(
        salt=salt,
        length=32,
        n=2**16,
        r=8,
        p=1,
    )

    hashed_pin = kdf.derive(pin.encode())

    hashed_pin = hashed_pin.hex()
    salt = salt.hex()

    return hashed_pin, salt


def verify_pin(pin, hashed_pin, salt):
    verified = False

    hashed_pin = bytes.fromhex(hashed_pin)
    salt = bytes.fromhex(salt)

    kdf = Scrypt(
        salt=salt,
        length=32,
        n=2**16,
        r=8,
        p=1,
    )

    try:
        kdf.verify(pin.encode(), hashed_pin)
        verified = True
    except InvalidKey:
        pass

    return verified


def generate_jwt():
    token = jwt.encode(
        {"exp": token_time(), "iss": config.APP_NAME},
        config.JWT_SECRET,
        algorithm="HS512",
    )

    return token


def verify_jwt(token):
    response = False
    try:
        jwt.decode(token, config.JWT_SECRET, algorithm="HS512", issuer=config.APP_NAME)
        response = True
    except jwt.exceptions.InvalidTokenError:
        pass

    return response
