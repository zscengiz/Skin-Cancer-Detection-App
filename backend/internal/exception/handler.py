from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from internal.exception.error_codes import ErrorCodes
from internal.exception.base_exception import BaseException
from datetime import datetime

async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content=create_api_error(request, exc.detail, ErrorCodes.HTTP_EXCEPTION)
    )

async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = []
    for err in exc.errors():
        errors.append({
            "loc": err.get("loc"),
            "msg": err.get("msg"),
            "type": err.get("type")
        })

    return JSONResponse(
        status_code=422,
        content=create_api_error(request, "Validation Error", ErrorCodes.VALIDATION_ERROR, details=errors)
    )

async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content=create_api_error(request, "Internal Server Error", ErrorCodes.INTERNAL_SERVER_ERROR)
    )

async def base_exception_handler(request: Request, exc: BaseException):
    return JSONResponse(
        status_code=exc.status_code,
        content=create_api_error(request, exc.message, exc.error_code)
    )

def create_api_error(request: Request, message: str, error_code: str, details=None):
    error = {
        "path": str(request.url),
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "hostname": request.client.host if request.client else "unknown",
        "message": message,
        "error_code": error_code
    }
    if details:
        error["details"] = details

    return {
        "success": False,
        "error": error
    }
