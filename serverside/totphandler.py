# note to refer https://github.com/pyauth/pyotp and https://datatracker.ietf.org/doc/html/rfc6238#section-5 at time of deployment
import pyotp
import os
import voterid.qrgen as qrgen


class PyTOTP:
    def __init__(self):
        self.secrets_file = "secrets.txt"
        self.secret = None

    def create_secret(self):
        self.secret = pyotp.random_base32()

        with open(self.secrets_file, "w") as f:
            f.write(self.secret)

    def get_secret(self):
        if os.path.isfile(self.secrets_file):
            with open(self.secrets_file, "r") as f:
                return f.read(self.secret)
        else:
            return self.create_secret()

    def present_qr(self):
        self.get_secret()
        qr_string = pyotp.totp.TOTP(self.secret).provisioning_uri(
            name="abrah@ham.com", issuer_name="Evot app"
        )
        qr = qrgen.QRWindow()
        qr.show_qr(qr_string)
        totp = pyotp.TOTP(self.secret)


if __name__ == "__main__":
    otp = PyTOTP()
    otp.present_qr()
