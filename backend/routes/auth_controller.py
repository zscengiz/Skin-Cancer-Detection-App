from fastapi import APIRouter, HTTPException, Body, status, Depends
from pydantic import EmailStr
from internal.database.database import get_user_by_email, user_collection, access_token_collection, refresh_token_collection
from internal.models.user import UserSignUp, UserLogin, ForgotPasswordRequest
from internal.models.access_token import AccessToken
from internal.models.refresh_token import RefreshToken
from internal.email.verification_code import generate_code, save_verification_code, verify_code
from internal.email.mailer import send_email
from internal.tokens.tokens import create_access_token, create_refresh_token
from internal.tokens.dependencies import get_current_user
from internal.utils.response import success_response
from config.config import conf
import bcrypt
import uuid
from datetime import datetime, timedelta, timezone

router = APIRouter(prefix="/api/auth", tags=["Auth"])

@router.post("/signup")
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

    return success_response(
        message="Signup successful",
        
        data={
            "id": user_id,
            "email": user.email,
            "name": user.name,
            "surname": user.surname
            })

@router.post("/login")
async def login(user: UserLogin):
    existing_user = await get_user_by_email(user.email)
    if not existing_user or not bcrypt.checkpw(user.password.encode('utf-8'), existing_user["hashed_password"].encode('utf-8')):
        raise HTTPException(status_code=400, detail="Invalid credentials")

    access_token = create_access_token({
        "sub": user.email,
        "user_id": existing_user["id"],
        "name": existing_user["name"]
    })

    refresh_token = create_refresh_token({
        "sub": user.email,
        "user_id": existing_user["id"]
    })

    access_token_obj = AccessToken(
        token=access_token,
        user_id=existing_user["id"],
        created_at=datetime.now(timezone.utc),
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=conf["access_token_expire_minutes"]),
        is_active=True
    )
    await access_token_collection.insert_one(access_token_obj.dict())

    refresh_token_obj = RefreshToken(
        token=refresh_token,
        user_id=existing_user["id"],
        created_at=datetime.now(timezone.utc),
        expires_at=datetime.now(timezone.utc) + timedelta(days=conf["refresh_token_expire_days"]),
        is_active=True
    )
    await refresh_token_collection.insert_one(refresh_token_obj.dict())

    return success_response(
        message="Login successful",
        data={
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
    )

@router.post("/request-password-reset")
async def request_password_reset(request: ForgotPasswordRequest):
    email = request.email
    user = await get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    reset_token = await generate_code()
    await save_verification_code(email, reset_token)

    reset_link = f"http://localhost:8000/reset-password.html?token={reset_token}&email={email}"
    await send_email(email, "Password Reset", f"Click the link to reset your password:\n\n{reset_link}")

    return success_response(message="Password reset link sent to your email.")

@router.post("/reset-password")
async def reset_password(email: EmailStr = Body(...), token: str = Body(...), new_password: str = Body(...)):
    if not await verify_code(email, token):
        raise HTTPException(status_code=400, detail="Invalid or expired token.")

    hashed_pw = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    await user_collection.update_one({"email": email}, {"$set": {"hashed_password": hashed_pw}})
    
    return success_response(message="Password has been reset successfully.")

@router.get("/protected-route")
async def protected_route(current_user: dict = Depends(get_current_user)):
    return success_response(message=f"Hello {current_user['email']}!")

@router.post("/refresh-token")
async def refresh_access_token(refresh_token: str = Body(..., embed=True)):
    refresh_token_data = await refresh_token_collection.find_one({"token": refresh_token})

    if not refresh_token_data:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

    now = datetime.now(timezone.utc)
    expires_at = refresh_token_data["expires_at"]

    if now > expires_at:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token expired")

    if not refresh_token_data.get("is_active", True):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Inactive refresh token")

    user_id = refresh_token_data["user_id"]

    await refresh_token_collection.update_one(
        {"token": refresh_token},
        {"$set": {"is_active": False}}
    )

    user = await user_collection.find_one({"id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    new_access_token = create_access_token({
        "sub": user["email"],
        "user_id": user_id,
        "name": user["name"]
    })

    new_refresh_token = create_refresh_token({
        "sub": user["email"],
        "user_id": user_id
    })

    access_token_obj = AccessToken(
        token=new_access_token,
        user_id=user_id,
        created_at=datetime.now(timezone.utc),
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=conf["access_token_expire_minutes"]),
        is_active=True
    )
    await access_token_collection.insert_one(access_token_obj.dict())

    refresh_token_obj = RefreshToken(
        token=new_refresh_token,
        user_id=user_id,
        created_at=datetime.now(timezone.utc),
        expires_at=datetime.now(timezone.utc) + timedelta(days=conf["refresh_token_expire_days"]),
        is_active=True
    )
    await refresh_token_collection.insert_one(refresh_token_obj.dict())

    return success_response(
        message="Token refreshed successfully",
        data={
            "access_token": new_access_token,
            "refresh_token": new_refresh_token,
            "token_type": "bearer"
        }
    )

@router.post("/change-password")
async def change_password(
    old_password: str = Body(...),
    new_password: str = Body(...),
    current_user: dict = Depends(get_current_user)
):
    user = await user_collection.find_one({"id": current_user["user_id"]})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not bcrypt.checkpw(old_password.encode('utf-8'), user["hashed_password"].encode('utf-8')):
        raise HTTPException(status_code=400, detail="Old password is incorrect")

    hashed_new = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    await user_collection.update_one(
        {"id": current_user["user_id"]},
        {"$set": {"hashed_password": hashed_new}}
    )

    return success_response(message="Password changed successfully")


@router.post("/logout")
async def logout(
    access_token: str = Body(..., embed=True),
    refresh_token: str = Body(..., embed=True)
):
    await access_token_collection.update_one(
        {"token": access_token},
        {"$set": {"is_active": False}}
    )
    await refresh_token_collection.update_one(
        {"token": refresh_token},
        {"$set": {"is_active": False}}
    )

    return success_response(message="Successfully logged out.")
