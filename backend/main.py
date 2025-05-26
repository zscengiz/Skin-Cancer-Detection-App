from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from routes.detection import router as detection_router
from routes import report_controller
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi import FastAPI, Request
import traceback

from internal.exception.handler import (
    http_exception_handler,
    validation_exception_handler,
    generic_exception_handler,
    base_exception_handler,
)
from internal.exception.base_exception import BaseException
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from routes.auth_controller import router as auth_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    print("Validation Error:")
    print("Route:", request.url)
    print("Body:", await request.body())
    print("Errors:", exc.errors())
    return JSONResponse(
        status_code=400,
        content={"detail": exc.errors()}
    )

app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)
app.add_exception_handler(BaseException, base_exception_handler)
app.include_router(auth_router)
app.include_router(detection_router)
app.include_router(report_controller.router)


@app.get("/")
def read_root():
    return {"message": "Welcome to Skin Cancer Detection App!"}

app.mount("/", StaticFiles(directory="static", html=True), name="static")

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    print("Validation Error:")
    print("Route:", request.url)
    print("Body:", await request.body())
    print("Errors:", exc.errors())