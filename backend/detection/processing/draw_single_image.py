import os
import cv2
from backend.detection.processing.constants import LABELS_PATH, IMAGES_PATH

def draw_bboxes(image_path, label_path):
    img = cv2.imread(image_path)
    
    with open(label_path, 'r') as f:
        for line in f:
            label_data = line.strip().split()
            class_id = int(label_data[0])
            x_center = float(label_data[1]) * img.shape[1]
            y_center = float(label_data[2]) * img.shape[0]
            bw = float(label_data[3]) * img.shape[1]
            bh = float(label_data[4]) * img.shape[0]
            x = int(x_center - bw / 2)
            y = int(y_center - bh / 2)
            x2 = int(x + bw)
            y2 = int(y + bh)
            
            cv2.rectangle(img, (x, y), (x2, y2), (0, 255, 0), 2)
            label_text = str(class_id)
            cv2.putText(img, label_text, (x, y-10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)

    cv2.imshow('Image with Bounding Boxes and Labels', img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

count = 0
for image_name in os.listdir(IMAGES_PATH):
    if image_name.endswith('.jpg') and count < 1:  
        label_name = image_name.replace('.jpg', '.txt')  
        image_path = os.path.join(IMAGES_PATH, image_name)
        label_path = os.path.join(LABELS_PATH, label_name)
        
        if os.path.exists(label_path):
            draw_bboxes(image_path, label_path)
            count += 1
