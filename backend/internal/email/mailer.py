import aiosmtplib
from email.message import EmailMessage
from config.config import get_config

async def send_email(to: str, subject: str, content: str):
    msg = EmailMessage()
    msg["From"] = get_config("smtp_user")
    msg["To"] = to
    msg["Subject"] = subject
    msg.set_content(content)

    await aiosmtplib.send(
        msg,
        hostname=get_config("smtp_host"),
        port=int(get_config("smtp_port")),
        username=get_config("smtp_user"),
        password=get_config("smtp_pass"),
        use_tls=True,
    )
