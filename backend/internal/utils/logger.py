import logging
from logging.handlers import TimedRotatingFileHandler
from pathlib import Path
from datetime import datetime

LOG_DIR = Path("logs")
LOG_DIR.mkdir(exist_ok=True)

log_filename = f"{datetime.now().strftime('%Y-%m-%d')}.log"
log_path = LOG_DIR / log_filename

file_handler = TimedRotatingFileHandler(
    filename=log_path,
    when="midnight",
    interval=1,
    backupCount=14,
    encoding="utf-8"
)

file_handler.suffix = "%Y-%m-%d"

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)

formatter = logging.Formatter(
    "[%(asctime)s] [%(levelname)s] [%(name)s:%(lineno)d] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

file_handler.setFormatter(formatter)
console_handler.setFormatter(formatter)

logger = logging.getLogger("skin-cancer-app")
logger.setLevel(logging.DEBUG)
logger.addHandler(file_handler)
logger.addHandler(console_handler)

logger.propagate = False
