def success_response(data=None, message="Operation successful"):
    return {
        "success": True,
        "message": message,
        "data": data
    }