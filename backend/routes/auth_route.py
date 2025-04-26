from fastapi import APIRouter, Request, HTTPException, Body, status
from pydantic import EmailStr
from backend.internal.email.verification_code import generate_code, save_verification_code, verify_code
from backend.internal.email.mailer import send_email
from backend.internal.database.database import get_user_by_email, user_collection
import bcrypt

router = APIRouter(prefix="/auth", tags=["Auth"])

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
