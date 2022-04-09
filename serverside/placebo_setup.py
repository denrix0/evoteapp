import mysql.connector

from crypto_functions import hash_pin


def add_to_sql(cursor, id, pin, totp1=None, totp2=None):
    hashed_pin, salt = hash_pin(pin)

    stmt = "INSERT INTO user_details (id, pin, salt{c1}{c2}) VALUES ({id}, '{pin}', '{salt}'{t1}{t2})".format(
        c1=("" if totp1 is None else ", totp1"),
        c2=("" if totp2 is None else ", totp2"),
        id=id,
        pin=hashed_pin,
        salt=salt,
        t1=("" if totp1 is None else (", '" + totp1 + "'")),
        t2=("" if totp2 is None else (", '" + totp2 + "'")),
    )

    cursor.execute(stmt)


def delete_from_sql(cursor, id):
    cursor.execute("DELETE FROM user_details where id=" + id)


if __name__ == "__main__":
    db = mysql.connector.connect(
        host="localhost", user="evote_flask", password="testpass", database="evoteapp"
    )

    cursor = db.cursor()

    for i in range(10):
        add_to_sql(cursor, i, str(123 + i), "213213", "223423")

    db.commit()
    db.close()
