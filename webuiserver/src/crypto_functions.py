import secrets
import src.config as config

from cryptography.hazmat.primitives.kdf.scrypt import Scrypt
from cryptography.exceptions import InvalidKey
from cryptography.fernet import Fernet


class PinHash:
    @staticmethod
    def hash(pin):
        """
        hashes pin using scrypt

        returns hashed pin, salt
        """
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

    @staticmethod
    def verify(pin, hashed_pin, salt):
        """
        takes pin, hashed pin and salt as values

        returns bool depending on how verification went
        """
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


class ServerKey:
    @staticmethod
    def encrypt(stringstuff):
        """
        Returns hex string of string passed in
        """
        secret = bytes.fromhex(config.SERVER_SECRET)
        f = Fernet(secret)

        return f.encrypt(stringstuff.encode()).hex()

    @staticmethod
    def decrypt(cryptedstuff):
        """
        Takes hex string, decrypts it
        """
        secret = bytes.fromhex(config.SERVER_SECRET)
        f = Fernet(secret)

        return f.decrypt(bytes.fromhex(cryptedstuff)).decode()
