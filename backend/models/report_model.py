from pydantic import BaseModel
from datetime import datetime

class LesionReport(BaseModel):
    user_id: str
    image_file_id: str
    pdf_file_id: str
    label: str
    confidence: float
    risk_level: str
    advice: str
    created_at: datetime

