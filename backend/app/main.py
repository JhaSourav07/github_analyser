from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.endpoints import audit

# Initialize App
app = FastAPI(
    title="GitHub Portfolio Analyzer",
    description="Backend API for Hackathon Project",
    version="1.0.0"
)

# --- CORS SETUP ---
# Allows Flutter (running on different port) to access this API
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- INCLUDE ROUTES ---
app.include_router(audit.router, prefix="/api/v1", tags=["audit"])

@app.get("/")
def health_check():
    return {"status": "ok", "message": "Backend is running!"}

# Instructions:
# Run from 'backend/' folder:
# uvicorn app.main:app --reload