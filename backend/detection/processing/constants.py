import os

BASE_PATH = "/Skin-Cancer-Detection-App"

DATA_PATH = os.path.join(BASE_PATH, "data")

LABELS_PATH = os.path.join(DATA_PATH, "labels")
MASKS_PATH = os.path.join(DATA_PATH, "masks")
IMAGES_PATH = os.path.join(DATA_PATH, "images")
OUTPUT_PATH = os.path.join(DATA_PATH, "visualized")

METADATA_FILE = os.path.join(DATA_PATH, "metadata.csv")

CLASS_MAPPING = {
    'MEL': 0,
    'NV': 1,
    'BCC': 2,
    'AKIEC': 3,
    'BKL': 4,
    'DF': 5,
    'VASC': 6
}

CLASS_COLORS = [
    (255, 0, 0),     
    (0, 255, 0),     
    (0, 0, 255),     
    (255, 255, 0),   
    (255, 0, 255),   
    (0, 255, 255),   
    (128, 128, 128)  
]
