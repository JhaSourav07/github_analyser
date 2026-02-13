from fastapi import APIRouter, HTTPException
from app.schemas.report import AuditRequest, ReportResponse
from app.services.github_client import GitHubClient
from app.services.scoring_engine import ScoringEngine

router = APIRouter()

@router.post("/audit", response_model=ReportResponse)
async def audit_user(request: AuditRequest):
    # 1. Initialize Services
    client = GitHubClient()
    engine = ScoringEngine()

    # 2. Fetch Data from GitHub
    data = await client.get_user_data(request.username)
    
    if not data:
        raise HTTPException(
            status_code=404, 
            detail=f"User '{request.username}' not found on GitHub."
        )

    # 3. Calculate Score
    result = engine.calculate_score(data['profile'], data['repos'])

    # 4. Return Response
    return ReportResponse(
        username=data['profile']['login'],
        score=result['score'],
        grade=result['grade'],
        summary=result['summary'],
        details=result['details']
    )