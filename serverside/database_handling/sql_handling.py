from flask_sqlalchemy import SQLAlchemy
from crypto_functions import hash_pin

db = SQLAlchemy()


class UserDetails(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=False)
    pin = db.Column(db.String(64), nullable=False)
    salt = db.Column(db.String(32), nullable=False)
    totp1 = db.Column(db.String(64))
    totp2 = db.Column(db.String(64))


def add_entry(id, pin, totp1=None, totp2=None):
    hashed_pin, salt = hash_pin(pin)

    db.session.add(
        UserDetails(id=id, pin=hashed_pin, salt=salt, totp1=totp1, totp2=totp2)
    )

    db.session.commit()


def fetch_entry(id):
    user = UserDetails.query.filter_by(id=id).first()
    return user


def delete_entry(id):
    user = fetch_entry(id)
    db.session.delete(user)
    db.session.commit()
