import bcrypt
import jwt
from fastapi import APIRouter, HTTPException, Response, status, Body
from pydantic import EmailStr
from backend.config.config import get_config
from backend.internal.database.database import get_user_by_email, create_user
from backend.internal.utils.logger import logger
from datetime import datetime, timedelta
from typing import Optional
from pydantic import BaseModel

router = APIRouter(prefix="/auth", tags=["Auth"])

SECRET_KEY = get_config("secret_key")
ALGORITHM = get_config("algorithm")
ACCESS_TOKEN_EXPIRE_MINUTES = int(get_config("access_token_expire_minutes", 15))
REFRESH_TOKEN_EXPIRE_DAYS = int(get_config("refresh_token_expire_days", 7))


def create_token(data: dict, expires_delta: timedelta):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


class UserRegister(BaseModel):
    email: EmailStr
    password: str


@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(response: Response, form: UserRegister):
    user = await get_user_by_email(form.email)
    if user:
        raise HTTPException(status_code=400, detail="Email already registered.")

    hashed_pw = bcrypt.hashpw(form.password.encode(), bcrypt.gensalt()).decode()
    await create_user({
        "email": form.email,
        "hashed_password": hashed_pw,  # ✅ DÜZELTME BURADA
        "is_active": True
    })

    access_token = create_token({"email": form.email}, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    refresh_token = create_token({"email": form.email}, timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))

    response.set_cookie("access_token", access_token, httponly=True)
    response.set_cookie("refresh_token", refresh_token, httponly=True)

    return {"message": "User registered", "access_token": access_token, "refresh_token": refresh_token}


@router.post("/login")
async def login(response: Response, email: EmailStr = Body(...), password: str = Body(...)):
    user = await get_user_by_email(email)

    if not user or "hashed_password" not in user:
        raise HTTPException(status_code=401, detail="Invalid credentials.")

    if not bcrypt.checkpw(password.encode(), user["hashed_password"].encode()):
        raise HTTPException(status_code=401, detail="Invalid credentials.")

    access_token = create_token({"email": user["email"]}, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    refresh_token = create_token({"email": user["email"]}, timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))

    response.set_cookie("access_token", access_token, httponly=True)
    response.set_cookie("refresh_token", refresh_token, httponly=True)

    logger.info(f"User logged in: {email}")

    return {"message": "Login successful", "access_token": access_token, "refresh_token": refresh_token}
