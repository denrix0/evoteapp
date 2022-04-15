import mysql.connector

from crypto_functions import PinHash, ServerKey
from practicedump.totptest import PyTOTP
import pyotp
import pickle


def add_to_sql(cursor, id, pin, totp1=None, totp2=None):
    hashed_pin, salt = PinHash.hash(pin)
    hashed_pin = ServerKey.encrypt(hashed_pin)
    print(hashed_pin.__len__())

    stmt = "INSERT INTO user_details (id, pin, salt{c1}{c2}) VALUES ({id}, '{pin}', '{salt}'{t1}{t2})".format(
        c1=("" if totp1 is None else ", totp1"),
        c2=("" if totp2 is None else ", totp2"),
        id=id,
        pin=hashed_pin,
        salt=salt,
        t1=("" if totp1 is None else (", '" + totp1 + "'")),
        t2=("" if totp2 is None else (", '" + totp2 + "'")),
    )
    print(stmt)

    cursor.execute(stmt)


def delete_from_sql(cursor, id):
    cursor.execute("DELETE FROM user_details where id=" + id)


def write_temp_settings(cursor):
    options = pickle.dumps(["Option " + str(i) for i in range(5)])
    req_methods = pickle.dumps(["totp1", "totp2", "uid"])

    stmt = "INSERT INTO voting_config (name, value) VALUES "
    stmt += "('prompt', 'Sample Text'), "
    stmt += f"('options', '{options.hex()}'), "
    stmt += f"('req_methods', '{req_methods.hex()}'), "
    stmt += "('expiry', '600'), "
    stmt += "('ongoing', '0')"

    cursor.execute(stmt)


if __name__ == "__main__":
    db = mysql.connector.connect(
        host="localhost", user="evote_node", password="testpass", database="evoteapp"
    )

    cursor = db.cursor()

    totp1_secret = pyotp.random_base32()
    totp2_secret = pyotp.random_base32()

    for i in range(10):
        add_to_sql(
            cursor,
            i,
            str(123 + i),
            totp1=ServerKey.encrypt(totp1_secret),
            totp2=ServerKey.encrypt(totp2_secret),
        )

    otp = PyTOTP()
    otp.present_qr(otp.get_totp_string(secret=totp1_secret))
    otp.present_qr(otp.get_totp_string(secret=totp2_secret))
    print(otp.get_totp_string(secret=totp1_secret))
    print(otp.get_totp_string(secret=totp2_secret))

    write_temp_settings(cursor)

    db.commit()
    db.close()
