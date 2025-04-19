from fastapi import FastAPI
from backend.routes.auth_controller import router as auth_router
from backend.routes import auth_route

app = FastAPI()
app.include_router(auth_router)
app.include_router(auth_route.router)

@app.get("/")
def root():
    return {"message": "Skin Cancer Detection API is alive!"}
