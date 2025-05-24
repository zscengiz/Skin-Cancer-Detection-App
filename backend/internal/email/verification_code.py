from datetime import datetime, timedelta
from internal.database.database import db 

async def generate_code():
    import secrets
    return secrets.token_urlsafe(32)

async def save_verification_code(email: str, code: str):
    await db.verification_codes.insert_one({
        "email": email,
        "code": code,
        "created_at": datetime.utcnow()
    })

async def verify_code(email: str, code: str):
    code_entry = await db.verification_codes.find_one({"email": email, "code": code})
    if not code_entry:
        return False
    if datetime.utcnow() - code_entry["created_at"] > timedelta(minutes=15):
        return False
    await db.verification_codes.delete_one({"_id": code_entry["_id"]})
    return True
