import pyqrcode
import secrets
import tkinter
import os

from totpclient import get_totp_token


class QRWindow:
    def __init__(self) -> None:
        self.root = tkinter.Tk()

    def show_qr(self, qr_code=None, refresh=None):
        self.label = tkinter.Label()
        self.label2 = tkinter.Label(text="", font=("OpenSans", 16), wraplength=600)
        self.label.pack()
        self.label2.pack()

        code = qr_code if qr_code else self.get_code()

        self.update_qr(code)

        if refresh:
            self.root.after(refresh, lambda: self.update_qr(code, refresh=refresh))

        tkinter.mainloop()

    def get_code(self):
        secrets_file = "authsecrets.txt"
        secret = "Nothing"
        if os.path.isfile(secrets_file):
            with open(secrets_file) as f:
                secret = f.read()
        return get_totp_token(secret=secret)

    def update_qr(self, qr_code, refresh=None):
        qrcode = pyqrcode.create(qr_code)
        img = tkinter.BitmapImage(data=qrcode.xbm(scale=5))
        img.config(background="white")
        self.label.config(image=img)
        self.label.image = img
        self.label2.config(text=qr_code)

        code = self.get_code()

        if refresh:
            self.root.after(
                refresh,
                lambda: self.update_qr(code, refresh=refresh),
            )


if __name__ == "__main__":
    qrw = QRWindow()

    qrw.show_qr(refresh=2000)

    # token2 = secrets.token_hex(256)
    # qrw.update_qr(token2)
