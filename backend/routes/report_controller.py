from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from fastapi.responses import StreamingResponse
from datetime import datetime
from bson import ObjectId
from internal.database.database import fs_bucket, report_collection
from internal.tokens.dependencies import get_current_user
from internal.utils.response import success_response
from io import BytesIO
from fastapi import Form

router = APIRouter(prefix="/api/reports", tags=["Reports"])

@router.post("/upload")
async def upload_report(
    image: UploadFile = File(...),
    pdf: UploadFile = File(...),
    label: str = Form(...),
    confidence: float = Form(...),
    risk_level: str = Form(...),
    advice: str = Form(...),
    current_user: dict = Depends(get_current_user)
):
    image_bytes = await image.read()
    pdf_bytes = await pdf.read()

    image_stream = BytesIO(image_bytes)
    pdf_stream = BytesIO(pdf_bytes)

    image_file_id = await fs_bucket.upload_from_stream(image.filename, image_stream)
    pdf_file_id = await fs_bucket.upload_from_stream(pdf.filename, pdf_stream)

    report_data = {
        "user_id": current_user["user_id"],
        "image_file_id": image_file_id,
        "pdf_file_id": pdf_file_id,
        "label": label,
        "confidence": confidence,
        "risk_level": risk_level,
        "advice": advice,
        "created_at": datetime.utcnow()
    }

    inserted = await report_collection.insert_one(report_data)
    return success_response(data={"report_id": str(inserted.inserted_id)})



@router.get("/me")
async def get_my_reports(current_user: dict = Depends(get_current_user)):
    cursor = report_collection.find({"user_id": current_user["user_id"]}).sort("created_at", -1)
    reports = []
    async for report in cursor:
        reports.append({
            "id": str(report["_id"]),
            "label": report["label"],
            "confidence": report["confidence"],
            "risk_level": report["risk_level"],
            "advice": report["advice"],
            "created_at": report["created_at"],
        })
    return success_response(data=reports)


@router.get("/pdf/{report_id}")
async def download_pdf(report_id: str, current_user: dict = Depends(get_current_user)):
    report = await report_collection.find_one({"_id": ObjectId(report_id)})
    if not report or report["user_id"] != current_user["user_id"]:
        raise HTTPException(status_code=404, detail="PDF not found or unauthorized")

    stream = await fs_bucket.open_download_stream(report["pdf_file_id"])
    contents = await stream.read()
    return StreamingResponse(BytesIO(contents), media_type="application/pdf")


@router.get("/image/{report_id}")
async def get_image(report_id: str, current_user: dict = Depends(get_current_user)):
    report = await report_collection.find_one({"_id": ObjectId(report_id)})
    if not report or report["user_id"] != current_user["user_id"]:
        raise HTTPException(status_code=404, detail="Image not found or unauthorized")

    stream = await fs_bucket.open_download_stream(report["image_file_id"])
    contents = await stream.read()
    return StreamingResponse(BytesIO(contents), media_type="image/jpeg")
