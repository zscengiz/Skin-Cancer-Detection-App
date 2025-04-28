from fastapi import APIRouter, Depends, HTTPException, Body, Request, status
from pydantic import EmailStr
from backend.internal.email.verification_code import generate_code, save_verification_code, verify_code
from backend.internal.email.mailer import send_email
from backend.internal.database.database import get_user_by_email, user_collection
from backend.internal.models.user import UserSignUp, UserLogin
from backend.internal.tokens.tokens import create_access_token, create_refresh_token
from backend.internal.utils.utils import verify_password
import backend.routes.auth_controller as auth_controller
from backend.internal.models.user import UserSignUp, UserLogin, UserResponse
import bcrypt
from backend.internal.tokens.dependencies import get_current_user

router = APIRouter(tags=["Auth"])

@router.post("/signup")
async def signup(user: UserSignUp):
    return await auth_controller.signup(user)

@router.post("/login")
async def login(user: UserLogin):
    return await auth_controller.login(user)

@router.post("/request-password-reset")
async def request_password_reset(request: Request, email: EmailStr = Body(...)):
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

    hashed_pw = bcrypt.hashpw(new_password.encode(), bcrypt.gensalt()).decode()
    await user_collection.update_one({"email": email}, {"$set": {"hashed_password": hashed_pw}})
    
    return {"message": "Password has been reset successfully."}

@router.get("/protected-route")
async def protected_route(current_user: dict = Depends(get_current_user)):
    return {"message": f"Hello {current_user['email']}!"}

@router.post("/refresh-token")
async def refresh_access_token(refresh_token: str = Body(..., embed=True)):
    return await auth_controller.refresh_access_token(refresh_token)