from pydantic import BaseModel
from typing import Dict, Any, List

# What the Frontend sends to us
class AuditRequest(BaseModel):
    username: str

# What we send back to the Frontend
class ReportResponse(BaseModel):
    username: str
    score: int
    grade: str
    summary: str
    details: Dict[str, Any]
    
    class Config:
        from_attributes = True