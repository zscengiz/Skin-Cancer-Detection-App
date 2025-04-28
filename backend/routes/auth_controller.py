from fastapi import APIRouter, HTTPException, Body, status
from pydantic import EmailStr
from backend.internal.database.database import get_user_by_email, user_collection
from backend.internal.models.user import UserSignUp, UserLogin, UserResponse
from backend.internal.email.verification_code import generate_code, save_verification_code, verify_code
from backend.internal.email.mailer import send_email
from backend.internal.tokens.tokens import create_access_token, create_refresh_token
import bcrypt
import uuid
from backend.internal.database.database import access_token_collection, refresh_token_collection
from backend.internal.models.access_token import AccessToken
from backend.internal.models.refresh_token import RefreshToken
from datetime import datetime, timedelta
from backend.config.config import conf

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/signup", response_model=UserResponse)
async def signup(user: UserSignUp):
    existing_user = await get_user_by_email(user.email)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    user_id = str(uuid.uuid4())

    user_data = {
        "id": user_id,
        "name": user.name,
        "surname": user.surname,
        "email": user.email,
        "hashed_password": hashed_password,
    }

    await user_collection.insert_one(user_data)

    return UserResponse(
        id=user_id,
        email=user.email
    )

@router.post("/login")
async def login(user: UserLogin):
    existing_user = await get_user_by_email(user.email)
    if not existing_user or not bcrypt.checkpw(user.password.encode('utf-8'), existing_user["hashed_password"].encode('utf-8')):
        raise HTTPException(status_code=400, detail="Invalid credentials")

    access_token = create_access_token(data={
        "sub": user.email,
        "user_id": existing_user["id"]
    })

    refresh_token = create_refresh_token(data={
        "sub": user.email,
        "user_id": existing_user["id"]
    })

    access_token_obj = AccessToken(
        token=access_token,
        user_id=existing_user["id"],
        created_at=datetime.utcnow(),
        expires_at=datetime.utcnow() + timedelta(minutes=conf["access_token_expire_minutes"]),
        is_active=True
    )
    await access_token_collection.insert_one(access_token_obj.dict())

    refresh_token_obj = RefreshToken(
        token=refresh_token,
        user_id=existing_user["id"],
        created_at=datetime.utcnow(),
        expires_at=datetime.utcnow() + timedelta(days=conf["refresh_token_expire_days"])
    )
    await refresh_token_collection.insert_one(refresh_token_obj.dict())

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/request-password-reset")
async def request_password_reset(email: EmailStr = Body(...)):
    user = await get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    reset_token = await generate_code()
    await save_verification_code(email, reset_token)

    reset_link = f"http://localhost:8000/reset-password.html?token={reset_token}&email={email}"
    await send_email(email, "Password Reset", f"Click the link to reset your password:\n\n{reset_link}")

    return {"message": "Password reset link sent to your email."}

@router.post("/reset-password")
async def reset_password(email: EmailStr = Body(...), token: str = Body(...), new_password: str = Body(...)):
    if not await verify_code(email, token):
        raise HTTPException(status_code=400, detail="Invalid or expired token.")

    hashed_pw = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    await user_collection.update_one({"email": email}, {"$set": {"hashed_password": hashed_pw}})
    
    return {"message": "Password has been reset successfully."}
