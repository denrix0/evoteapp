import pyqrcode
import secrets

token = secrets.token_hex(256)
print(token)

qrcode = pyqrcode.create(token)
print(qrcode.terminal())
