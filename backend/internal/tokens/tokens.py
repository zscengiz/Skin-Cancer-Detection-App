from jwt import encode
from datetime import datetime, timedelta
from config import conf

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=conf["access_token_expire_minutes"])
    to_encode.update({"exp": expire})
    return encode(to_encode, conf["secret_key"], algorithm=conf["algorithm"])

def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=conf["refresh_token_expire_days"])
    to_encode.update({"exp": expire})
    return encode(to_encode, conf["secret_key"], algorithm=conf["algorithm"])
