from pydantic import BaseModel, EmailStr, field_validator
import re

class UserSignUp(BaseModel):
    name: str
    surname: str
    email: EmailStr
    password: str

    @field_validator('name')
    @classmethod
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        if len(v) < 3:
            raise ValueError('Name must be at least 3 characters')
        if not re.match(r"^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]+$", v):
            raise ValueError('Name must contain only letters')
        return v

    @field_validator('surname')
    @classmethod
    def validate_surname(cls, v):
        if not v.strip():
            raise ValueError('Surname cannot be empty')
        if len(v) < 3:
            raise ValueError('Surname must be at least 3 characters')
        if not re.match(r"^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]+$", v):
            raise ValueError('Surname must contain only letters')
        return v

    @field_validator('password')
    @classmethod
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain an uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain a lowercase letter")
        if not re.search(r"[0-9]", v):
            raise ValueError("Password must contain a number")
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", v):
            raise ValueError("Password must contain a special character")
        return v

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: str
    email: EmailStr
class ForgotPasswordRequest(BaseModel):
    email: EmailStr
