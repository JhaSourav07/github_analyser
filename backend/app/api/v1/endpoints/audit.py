from fastapi import APIRouter, HTTPException
from app.schemas.report import AuditRequest, ReportResponse
from app.services.github_client import GitHubClient
from app.services.scoring_engine import ScoringEngine

router = APIRouter()

@router.post("/audit", response_model=ReportResponse)
async def audit_user(request: AuditRequest):
    # 1. Extract Username (Handled by Pydantic Validator in Schema)
    username = request.profile_url_or_username
    print(f"Analyzing user: {username}...")
    
    # 2. Initialize Services
    client = GitHubClient()
    engine = ScoringEngine()

    # 3. Fetch Data
    data = await client.get_user_data(username)
    
    if not data:
        raise HTTPException(
            status_code=404, 
            detail=f"GitHub profile '{username}' not found. Please check the URL."
        )

    # 4. Calculate Score & Feedback
    report = engine.calculate_score(data['profile'], data['repos'])

    # 5. Return Response
    return ReportResponse(
        username=data['profile']['login'],
        avatar_url=data['profile']['avatar_url'],
        score=report['score'],
        grade=report['grade'],
        summary=report['summary'],
        strengths=report['strengths'],
        weaknesses=report['weaknesses'],
        suggestions=report['suggestions'],
        details=report['details']
    )