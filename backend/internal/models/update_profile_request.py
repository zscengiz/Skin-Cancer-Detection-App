from pydantic import BaseModel, EmailStr

class UpdateProfileRequest(BaseModel):
    name: str
    surname: str
    email: EmailStr
