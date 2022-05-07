class APIException(Exception):
    def __init__(self, code, message):
        self.code = code
        self.message = message

    def __str__(self) -> str:
        return self.message
