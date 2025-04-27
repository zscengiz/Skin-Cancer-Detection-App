from fastapi import FastAPI
from backend.routes.auth_route import router as auth_router

app = FastAPI()

app.include_router(auth_router, prefix="/api/auth", tags=["Authentication"])

@app.get("/")
def read_root():
    return {"message": "Welcome to Skin Cancer Detection App!"}
