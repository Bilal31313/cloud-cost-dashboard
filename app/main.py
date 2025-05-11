from fastapi import FastAPI
from sqlmodel import SQLModel
from routers import costs
from db.session import engine

app = FastAPI()
app.include_router(costs.router)

@app.on_event("startup")
def on_startup():
    SQLModel.metadata.create_all(engine)
