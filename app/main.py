from fastapi import FastAPI
from sqlmodel import SQLModel
from app.routers import costs, recommendations
from app.db.session import engine

app = FastAPI(
    title="Cloud Cost Dashboard",
    version="1.0.0",
    description="A DevOps-grade FastAPI backend for AWS cost visibility, optimization, and alerts."
)

# Include API routers
app.include_router(costs.router)
app.include_router(recommendations.router)
# Auto-create DB tables on startup
@app.on_event("startup")
def on_startup():
    SQLModel.metadata.create_all(engine)

@app.get("/")
def read_root():
    return {"message": "🚀 Cloud Cost Dashboard deployed via GitHub Actions!"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
