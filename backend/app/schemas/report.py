from pydantic import BaseModel, validator
from typing import Dict, Any, List

class AuditRequest(BaseModel):
    # User might paste "https://github.com/johndoe" or just "johndoe"
    profile_url_or_username: str

    @validator('profile_url_or_username')
    def extract_username(cls, v):
        if "github.com/" in v:
            return v.split("github.com/")[-1].strip("/")
        return v

class ReportResponse(BaseModel):
    username: str
    avatar_url: str
    score: int
    grade: str
    summary: str
    
    # NEW: Specific deliverables from Problem Statement
    strengths: List[str]
    weaknesses: List[str]   # "Red Flags"
    suggestions: List[str]  # "Actionable Feedback"
    
    details: Dict[str, Any]
    
    class Config:
        from_attributes = True