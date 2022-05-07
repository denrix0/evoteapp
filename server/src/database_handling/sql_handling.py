import pickle
import ast

from flask_sqlalchemy import SQLAlchemy
from src.function_kit.crypto_functions import PinHash, ServerKey

db = SQLAlchemy()


class UserDetails(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=False)
    pin = db.Column(db.Text, nullable=False)
    salt = db.Column(db.String(32), nullable=False)
    totp1 = db.Column(db.Text)
    totp2 = db.Column(db.Text)


class VotingConfig(db.Model):
    name = db.Column(db.String(64), primary_key=True, nullable=False)
    value = db.Column(db.Text)


class VoteUser:
    @staticmethod
    def add_entry(id, pin, totp1=None, totp2=None):
        hashed_pin, salt = PinHash.hash(pin)

        totp1 = ServerKey.encrypt(totp1)
        totp2 = ServerKey.encrypt(totp2)
        hashed_pin = ServerKey.encrypt(hashed_pin)

        db.session.add(
            UserDetails(id=id, pin=hashed_pin, salt=salt, totp1=totp1, totp2=totp2)
        )

        db.session.commit()

    @staticmethod
    def fetch_entry(id):
        user = UserDetails.query.filter_by(id=id).first()

        user.pin = ServerKey.decrypt(user.pin)
        user.totp1 = ServerKey.decrypt(user.totp1)
        user.totp2 = ServerKey.decrypt(user.totp2)

        return user

    @staticmethod
    def delete_entry(id):
        UserDetails.query.filter_by(id=id).delete()
        db.session.commit()


class VoteCfg:
    @staticmethod
    def set_defaults():
        VotingConfig.query.delete()

        properties = {
            "expiry": "600",
            "ongoing": "0",
            "options": ["Option 0", "Option 1", "Option 2", "Option 3", "Option 4"],
            "prompt": "Sample Text",
            "req_methods": ["totp1", "totp2", "uid"],
        }

        for k, v in properties.items():
            if k in ["options", "req_methods"]:
                v = pickle.dumps(v).hex()
            db.session.add(VotingConfig(name=k, value=v))

        db.session.commit()

    @staticmethod
    def edit_config(setting, value):
        if setting == "options":
            value = pickle.dumps(ast.literal_eval(value)).hex()
        cfg = VotingConfig.query.filter_by(name=setting).first()
        cfg.value = value
        db.session.commit()

    @staticmethod
    def fetch_config():
        result = VotingConfig.query.all()

        properties = {}

        for i in result:
            k = i.name
            v = i.value

            if k in ["options", "req_methods"]:
                v = pickle.loads(bytearray.fromhex(v))

            properties[k] = v

        return properties
