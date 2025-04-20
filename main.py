from fastapi import FastAPI
from backend.routes.auth_controller import router as auth_router
from backend.routes import auth_route
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"], 
)
app.include_router(auth_router)
app.include_router(auth_route.router)
app.mount("/", StaticFiles(directory="backend/static", html=True), name="static")

@app.get("/")
def root():
    return {"message": "Skin Cancer Detection API is alive!"}
