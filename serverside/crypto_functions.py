import jwt
import secrets
import config
import time

from cryptography.hazmat.primitives.kdf.scrypt import Scrypt
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives.padding import PKCS7
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.fernet import Fernet
from cryptography.exceptions import InvalidKey

token_time = lambda: int(time.time() + config.vote_config.expiry)
get_random = lambda x: secrets.token_hex(x)


def generate_master_token(uid, totp1, totp2):
    """
    Spits out master token
    """
    token_string = str(uid + "." + totp1 + "." + totp2)

    digest = hashes.Hash(hashes.SHA256())
    digest.update(token_string.encode())
    digest = digest.finalize()

    master_token = digest.hex()

    return master_token


class RSAKey:
    @staticmethod
    def generate():
        """
        returns private and public keys in pem format

        return pvt, pub
        """
        private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
        public_key = private_key.public_key()

        pvt_pem = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        )

        pub_pem = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo,
        )

        return pvt_pem.decode(), pub_pem.decode()

    @staticmethod
    def decrypt(pvt_pem, msg):
        """
        pvt_pem = string of pem formatted pvt key
        msg = string message to decrypt

        returns decoded string
        """

        pvt_pem = pvt_pem.encode()
        msg = bytes.fromhex(msg)

        pvt_key = serialization.load_pem_private_key(pvt_pem, password=None)

        decrypted_msg = pvt_key.decrypt(
            msg,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                label=None,
                algorithm=hashes.SHA256(),
            ),
        )

        return decrypted_msg.decode()

    @staticmethod
    def encrypt(pub_pem, msg):
        """
        pub_pem = string of pem formatted pub key
        msg = string message

        returns hex of encrypted message
        """

        pub_pem = pub_pem.encode()

        pub_key = serialization.load_pem_public_key(pub_pem)

        msg = msg.encode()

        encrypted_msg = pub_key.encrypt(
            msg,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                label=None,
                algorithm=hashes.SHA256(),
            ),
        )

        return encrypted_msg.hex()


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


class AESKey:
    @staticmethod
    def generate():
        """
        returns key, iv
        """
        key = secrets.token_bytes(32)
        iv = secrets.token_bytes(16)

        return key.hex(), iv.hex()

    @staticmethod
    def encrypt(msg, key, iv):
        """
        takes message(str), key(hex) and iv(hex)

        returns hex of encrypted messsage
        """
        key = bytes.fromhex(key)
        iv = bytes.fromhex(iv)

        padder = PKCS7(128).padder()
        msg = padder.update(msg.encode()) + padder.finalize()

        cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
        encryptor = cipher.encryptor()
        encrypted_msg = encryptor.update(msg) + encryptor.finalize()

        return encrypted_msg.hex()

    @staticmethod
    def decrypt(msg, key, iv):
        """
        takes hexed encrypted message, key and iv

        returns decrypted message string
        """

        key = bytes.fromhex(key)
        iv = bytes.fromhex(iv)
        msg = bytes.fromhex(msg)

        cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
        decryptor = cipher.decryptor()
        decrypted_msg = decryptor.update(msg) + decryptor.finalize()

        unpadder = PKCS7(128).unpadder()
        decrypted_msg = unpadder.update(decrypted_msg) + unpadder.finalize()

        return decrypted_msg.decode()


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
        response = False
        id = None
        try:
            id = jwt.decode(
                token,
                config.JWT_SECRET,
                algorithm="HS512",
                issuer=config.APP_NAME,
            )["user_id"]
            response = True
        except jwt.exceptions.ExpiredSignatureError:
            id = False  # TODO: Better response value
        except jwt.exceptions.InvalidTokenError as e:
            pass

        return id, response


if __name__ == "__main__":
    pvt_key, pub_key = RSAKey.generate()

    print(pvt_key)
    print(pub_key)

    a = ServerKey.encrypt("gas")
    print(ServerKey.decrypt(a))

    encrypted = RSAKey.encrypt(pub_key, "was")
    print(RSAKey.decrypt(pvt_key, encrypted))

    key, iv = AESKey.generate()

    encd_msg = AESKey.encrypt("test message", key=key, iv=iv)
    print(encd_msg)
    print(AESKey.decrypt(encd_msg, key=key, iv=iv))
