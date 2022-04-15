from flask_sqlalchemy import SQLAlchemy
from crypto_functions import PinHash, ServerKey

db = SQLAlchemy()


class UserDetails(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=False)
    pin = db.Column(db.Text, nullable=False)
    salt = db.Column(db.String(32), nullable=False)
    totp1 = db.Column(db.Text)
    totp2 = db.Column(db.Text)


def add_entry(id, pin, totp1=None, totp2=None):
    hashed_pin, salt = PinHash.hash(pin)

    totp1 = ServerKey.encrypt(totp1)
    totp2 = ServerKey.encrypt(totp2)
    hashed_pin = ServerKey.encrypt(hashed_pin)

    db.session.add(
        UserDetails(id=id, pin=hashed_pin, salt=salt, totp1=totp1, totp2=totp2)
    )

    db.session.commit()


def fetch_entry(id):
    user = UserDetails.query.filter_by(id=id).first()

    user.pin = ServerKey.decrypt(user.pin)
    user.totp1 = ServerKey.decrypt(user.totp1)
    user.totp2 = ServerKey.decrypt(user.totp2)

    return user


def delete_entry(id):
    user = fetch_entry(id)
    db.session.delete(user)
    db.session.commit()
