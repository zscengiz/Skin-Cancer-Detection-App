from dotenv import load_dotenv, find_dotenv
from internal.utils.logger import logger
from decouple import config
from typing import Optional
import sys

dotenv_path = find_dotenv()
if not dotenv_path:
    logger.warning(".env file not found. Exiting program.")
    sys.exit(1)

load_dotenv(override=True)

conf = {}

conf["mongodb_user"] = config("MONGODB_USERNAME", default=None)
conf["mongodb_pass"] = config("MONGODB_PASSWORD", default=None)
conf["mongodb_host"] = config("MONGODB_HOST", default="localhost:27017")
conf["mongodb_database"] = config("MONGODB_DATABASE", default="skincancer")

if conf["mongodb_user"] and conf["mongodb_pass"]:
    conf["mongodb_uri"] = (
        f'mongodb+srv://{conf["mongodb_user"]}:{conf["mongodb_pass"]}@{conf["mongodb_host"]}'
    )
else:
    conf["mongodb_uri"] = f'mongodb://{conf["mongodb_host"]}/{conf["mongodb_database"]}'

def get_config(name: str):
    if name == "all":
        return conf
    return conf.get(name)

def set_config(name: str, value):
    conf[name] = value