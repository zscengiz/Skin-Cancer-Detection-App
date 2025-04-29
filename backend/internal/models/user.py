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
            raise ValueError('Name field cannot be empty.')
        if len(v) < 2:
            raise ValueError('Name must be at least 2 characters long.')
        if not v.isalpha():
            raise ValueError('Name must contain only letters.')
        return v

    @field_validator('surname')
    @classmethod
    def validate_surname(cls, v):
        if not v.strip():
            raise ValueError('Surname field cannot be empty.')
        if len(v) < 2:
            raise ValueError('Surname must be at least 2 characters long.')
        if not v.isalpha():
            raise ValueError('Surname must contain only letters.')
        return v

    @field_validator('password')
    @classmethod
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long.')
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter.')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain at least one lowercase letter.')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain at least one digit.')
        if not re.search(r'[!@#$%^&*()\-\_=+\[\]{};:\'",.<>/?\\|]', v):
            raise ValueError('Password must contain at least one special character.')
        return v

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: str
    email: EmailStr
class ForgotPasswordRequest(BaseModel):
    email: EmailStr
