import pyqrcode
import secrets
import tkinter

root = tkinter.Tk()

token = secrets.token_hex(256)
print(token)


def show_qr(qr_code):
    qrcode = pyqrcode.create(qr_code)

    img = tkinter.BitmapImage(data=qrcode.xbm(scale=5))
    img.config(background="white")

    label = tkinter.Label(image=img)
    label.pack()

    tkinter.mainloop()


if __name__ == "__main__":
    show_qr()
