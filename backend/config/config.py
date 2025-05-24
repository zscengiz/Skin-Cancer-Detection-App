from dotenv import load_dotenv, find_dotenv
from internal.utils.logger import logger 
from decouple import config
import sys

dotenv_path = find_dotenv()
if not dotenv_path:
    logger.warning(".env file not found. Exiting program.")
    sys.exit(1)

load_dotenv(override=True)

conf = {}

conf["MONGODB_USER"] = config("MONGODB_USERNAME", default=None)
conf["MONGODB_PASS"] = config("MONGODB_PASSWORD", default=None)
conf["MONGODB_HOST"] = config("MONGODB_HOST", default="localhost:27017")
conf["MONGODB_DATABASE"] = config("MONGODB_DATABASE", default="skincancer")


if conf["MONGODB_USER"] and conf["MONGODB_PASS"]:
    conf["MONGO_URI"] = (
        f'mongodb+srv://{conf["MONGODB_USER"]}:{conf["MONGODB_PASS"]}@{conf["MONGODB_HOST"]}'
    )
else:
    conf["MONGO_URI"] = f'mongodb://{conf["MONGODB_HOST"]}/{conf["MONGODB_DATABASE"]}'


conf["secret_key"] = config("SECRET_KEY", default="super-secret-key")
conf["algorithm"] = config("ALGORITHM", default="HS256")
conf["access_token_expire_minutes"] = int(config("ACCESS_TOKEN_EXPIRE_MINUTES", default=15))
conf["refresh_token_expire_days"] = int(config("REFRESH_TOKEN_EXPIRE_DAYS", default=7))

conf["smtp_host"] = config("SMTP_HOST", default="")
conf["smtp_port"] = config("SMTP_PORT", default=587)
conf["smtp_user"] = config("SMTP_USER", default="")
conf["smtp_pass"] = config("SMTP_PASS", default="")


def get_config(name: str, default=None):
    if name == "all":
        return conf
    return conf.get(name, default)

def set_config(name: str, value):
    conf[name] = value