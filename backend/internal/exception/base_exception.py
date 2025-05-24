class BaseException(Exception):
    def __init__(self, message: str, status_code: int = 400, error_code: str = "BASE_EXCEPTION"):
        self.message = message
        self.status_code = status_code
        self.error_code = error_code
        super().__init__(self.message)
