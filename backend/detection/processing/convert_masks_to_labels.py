import os
import cv2
import pandas as pd
import numpy as np
from detection.processing.constants import METADATA_FILE, MASKS_PATH, LABELS_PATH, CLASS_MAPPING

os.makedirs(LABELS_PATH, exist_ok=True)

df = pd.read_csv(METADATA_FILE)

def get_bounding_boxes(mask):
    boxes = []
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    for cnt in contours:
        x, y, w, h = cv2.boundingRect(cnt)
        boxes.append((x, y, w, h))
    return boxes

for _, row in df.iterrows():
    image_id = row["image"]
    mask_file = os.path.join(MASKS_PATH, f"{image_id}.png")
    
    if not os.path.exists(mask_file):
        continue
    
    mask = cv2.imread(mask_file, cv2.IMREAD_GRAYSCALE)
    h, w = mask.shape
    bounding_boxes = get_bounding_boxes(mask)
    
    class_id = np.argmax(row[1:].values)  
    yolo_class = CLASS_MAPPING[list(CLASS_MAPPING.keys())[class_id]]
    
    label_file = os.path.join(LABELS_PATH, f"{image_id}.txt")
    with open(label_file, "w") as f:
        for x, y, bw, bh in bounding_boxes:
            x_center = (x + bw / 2) / w
            y_center = (y + bh / 2) / h
            bw = bw / w
            bh = bh / h
            f.write(f"{yolo_class} {x_center} {y_center} {bw} {bh}\n")
