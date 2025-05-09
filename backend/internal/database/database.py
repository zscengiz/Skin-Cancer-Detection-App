from motor.motor_asyncio import AsyncIOMotorClient
from backend.config.config import get_config
from bson.objectid import ObjectId
from typing import Optional

mongodb_uri = get_config("mongodb_uri")
mongodb_name = get_config("mongodb_database")

client = AsyncIOMotorClient(
    mongodb_uri,
    tls=True,
    tlsAllowInvalidCertificates=True
)
db = client[mongodb_name]

user_collection = db.users
access_token_collection = db.access_tokens
refresh_token_collection = db.refresh_tokens

async def get_user_by_email(email: str) -> Optional[dict]:
    user_data = await user_collection.find_one({"email": email})
    if user_data:
        user_data["id"] = str(user_data["_id"]) 
        return user_data
    return None

async def create_user(user_data: dict):
    result = await user_collection.insert_one(user_data)
    return str(result.inserted_id)
