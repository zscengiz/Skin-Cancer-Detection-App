from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Skin Cancer Detection App is running!"}
 