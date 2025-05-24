import os
import cv2
import pandas as pd
import numpy as np
from detection.processing.constants import METADATA_FILE, MASKS_PATH, LABELS_PATH, IMAGES_PATH, OUTPUT_PATH, CLASS_MAPPING, CLASS_COLORS

os.makedirs(LABELS_PATH, exist_ok=True)
os.makedirs(OUTPUT_PATH, exist_ok=True)

df = pd.read_csv(METADATA_FILE)

def get_bounding_boxes(mask):
    boxes = []
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    for cnt in contours:
        x, y, w, h = cv2.boundingRect(cnt)
        boxes.append((x, y, w, h))
    return boxes

for i, (_, row) in enumerate(df.iterrows()):
    if i >= 50:
        break  
    
    image_id = row["image"]
    mask_file = os.path.join(MASKS_PATH, f"{image_id}.png")
    image_file = os.path.join(IMAGES_PATH, f"{image_id}.jpg")  
    
    if not os.path.exists(mask_file) or not os.path.exists(image_file):
        continue
    
    mask = cv2.imread(mask_file, cv2.IMREAD_GRAYSCALE)
    image = cv2.imread(image_file)
    h, w = mask.shape
    bounding_boxes = get_bounding_boxes(mask)
    
    class_id = np.argmax(row[1:].values)  
    yolo_class = CLASS_MAPPING[list(CLASS_MAPPING.keys())[class_id]]
    
    label_file = os.path.join(LABELS_PATH, f"{image_id}.txt")
    with open(label_file, "w") as f:
        for x, y, bw, bh in bounding_boxes:
            x_center = (x + bw / 2) / w
            y_center = (y + bh / 2) / h
            norm_bw = bw / w
            norm_bh = bh / h
            f.write(f"{yolo_class} {x_center} {y_center} {norm_bw} {norm_bh}\n")
            
            x2 = x + bw
            y2 = y + bh
            cv2.rectangle(image, (x, y), (x2, y2), CLASS_COLORS[yolo_class], 2)
            cv2.putText(image, list(CLASS_MAPPING.keys())[class_id], (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, CLASS_COLORS[yolo_class], 2)
    
    output_file = os.path.join(OUTPUT_PATH, f"{image_id}.jpg")
    cv2.imwrite(output_file, image)
