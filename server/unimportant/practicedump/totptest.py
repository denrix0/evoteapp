from asyncore import write
import pyotp
import os
import voterid.qrgen as qrgen

# note to refer https://github.com/pyauth/pyotp and https://datatracker.ietf.org/doc/html/rfc6238#section-5 at time of deployment


class PyTOTP:
    def __init__(self):
        self.secrets_file = "secrets.txt"
        self.secret = None

    def create_secret(self, write=False):
        self.secret = pyotp.random_base32()

        if write:
            with open(self.secrets_file, "w") as f:
                f.write(self.secret)

        return self.secret

    def get_secret(self):
        if os.path.isfile(self.secrets_file):
            with open(self.secrets_file, "r") as f:
                return f.read(self.secret)
        else:
            return self.create_secret(write=True)

    def get_totp_string(self, name="a", issuer="b", secret="cret"):

        totp_string = pyotp.totp.TOTP(secret).provisioning_uri(
            name=name, issuer_name=issuer
        )

        return totp_string

    def present_qr(self, qr_string):
        qr = qrgen.QRWindow()

        qr.show_qr(qr_string)


if __name__ == "__main__":
    otp = PyTOTP()
    otp.present_qr(otp.get_totp_string(secret=otp.get_secret()))
