from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class AccessToken(BaseModel):
    token: str
    user_id: str 
    created_at: datetime
    expires_at: datetime
    is_active: bool = True
