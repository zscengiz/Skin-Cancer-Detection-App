from fastapi import APIRouter, UploadFile, File
from ultralytics import YOLO
import shutil
from pathlib import Path
import uuid
import os

router = APIRouter()

# Geçici klasörü oluştur
os.makedirs("temp", exist_ok=True)

# Eğitimli YOLO modelini yükle
model = YOLO("models/best.pt")

# Sınıf etiketlerinin detaylı açıklamaları
CLASS_DETAILS = {
    'MEL': {
        'full_label': 'Melanoma',
        'risk_level': 'High risk',
        'advice': 'Consult a dermatologist immediately. Melanoma can be aggressive and requires urgent attention.'
    },
    'NV': {
        'full_label': 'Melanocytic Nevus',
        'risk_level': 'Low risk',
        'advice': 'No intervention required. Monitor periodically for changes.'
    },
    'BCC': {
        'full_label': 'Basal Cell Carcinoma',
        'risk_level': 'Moderate risk',
        'advice': 'Consult a dermatologist for evaluation. Early treatment is usually effective.'
    },
    'AKIEC': {
        'full_label': 'Actinic Keratoses / Intraepithelial Carcinoma',
        'risk_level': 'High risk',
        'advice': 'Requires medical assessment and possible biopsy to determine cancer risk.'
    },
    'BKL': {
        'full_label': 'Benign Keratosis',
        'risk_level': 'Low risk',
        'advice': 'Generally harmless. Cosmetic removal can be considered.'
    },
    'DF': {
        'full_label': 'Dermatofibroma',
        'risk_level': 'Low risk',
        'advice': 'Harmless fibrous lesion. No treatment necessary unless symptomatic.'
    },
    'VASC': {
        'full_label': 'Vascular Lesion',
        'risk_level': 'Low to moderate risk',
        'advice': 'Consult a dermatologist for cosmetic or vascular concerns.'
    }
}

@router.post("/detect")
async def detect_lesion(file: UploadFile = File(...)):
    """
    Uploaded image üzerinden cilt lezyonlarını tespit eder.
    YOLOv8 modelinden çıkan kutular ve sınıf bilgileri ile detaylı analiz döner.
    """
    # Geçici dosya olarak kaydet
    temp_path = Path(f"temp/{uuid.uuid4()}.jpg")
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Tahmin yap
    results = model(temp_path, imgsz=640)
    boxes = results[0].boxes
    class_names = model.names

    predictions = []

    # Sonuçları işle
    for box in boxes:
        cls_id = int(box.cls[0].item())
        label = class_names[cls_id]
        confidence = round(box.conf[0].item(), 2)
        details = CLASS_DETAILS.get(label, {})

        predictions.append({
            "class": label,
            "confidence": confidence,
            "full_label": details.get("full_label", label),
            "risk_level": details.get("risk_level", "Unknown"),
            "advice": details.get("advice", "No advice available.")
        })

    return {"predictions": predictions}
