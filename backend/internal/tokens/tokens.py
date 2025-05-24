import jwt
from datetime import datetime, timedelta, timezone
from config.config import conf

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=conf["access_token_expire_minutes"])
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, conf["secret_key"], algorithm=conf["algorithm"])

def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=conf["refresh_token_expire_days"])
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, conf["secret_key"], algorithm=conf["algorithm"])
