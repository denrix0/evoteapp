from ssl import ALERT_DESCRIPTION_UNKNOWN_PSK_IDENTITY
from webbrowser import BackgroundBrowser
import pyqrcode
import secrets
import tkinter

root = tkinter.Tk()

token = secrets.token_hex(256)
print(token)

qrcode = pyqrcode.create(token)

img = tkinter.BitmapImage(data=qrcode.xbm(scale=5))
img.config(background="white")

label = tkinter.Label(image=img)
label.pack()

tkinter.mainloop()
