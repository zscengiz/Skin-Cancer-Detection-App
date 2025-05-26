from pydantic import BaseModel, EmailStr, field_validator
import re

class UpdateProfileRequest(BaseModel):
    name: str
    surname: str
    email: EmailStr

    @field_validator("name")
    @classmethod
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError("Name cannot be empty")
        if len(v) < 3:
            raise ValueError("Name must be at least 3 characters")
        if not re.match(r"^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]+$", v):
            raise ValueError("Name must contain only letters")
        return v

    @field_validator("surname")
    @classmethod
    def validate_surname(cls, v):
        if not v.strip():
            raise ValueError("Surname cannot be empty")
        if len(v) < 3:
            raise ValueError("Surname must be at least 3 characters")
        if not re.match(r"^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]+$", v):
            raise ValueError("Surname must contain only letters")
        return v
