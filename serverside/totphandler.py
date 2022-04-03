# note to refer https://github.com/pyauth/pyotp and https://datatracker.ietf.org/doc/html/rfc6238#section-5 at time of deployment
import pyotp
import os
import voterid.qrgen as qrgen

secrets_file = "secrets.txt"
secret = None


def create_secret():
    secret = pyotp.random_base32()

    with open(secrets_file, "w") as f:
        f.write(secret)


def get_secret():
    if os.path.isfile(secrets_file):
        with open(secrets_file, "r") as f:
            secret = f.read(secret)


create_secret()

qr_string = pyotp.totp.TOTP(secret).provisioning_uri(
    name="abrah@ham.com", issuer_name="Evot app"
)

qr = qrgen.QRWindow()
qr.show_qr(qr_string)
totp = pyotp.TOTP(secret)
