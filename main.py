from fastapi import FastAPI
from backend.internal.exception.handler import (
    http_exception_handler,
    validation_exception_handler,
    generic_exception_handler,
    base_exception_handler
)
from backend.internal.exception.base_exception import BaseException
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from backend.routes.auth_controller import router as auth_router

app = FastAPI()

app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)
app.add_exception_handler(BaseException, base_exception_handler)
app.include_router(auth_router, prefix="/api/auth", tags=["Authentication"])

@app.get("/")
def read_root():
    return {"message": "Welcome to Skin Cancer Detection App!"}