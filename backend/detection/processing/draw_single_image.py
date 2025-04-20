import os
import cv2

LABEL_FOLDER = "/Users/zcengiz/Grad-Project/Skin-Cancer-Detection-App/data/labels"
IMAGE_FOLDER = "/Users/zcengiz/Grad-Project/Skin-Cancer-Detection-App/data/images"

def draw_bboxes(image_path, label_path):
    img = cv2.imread(image_path)
    with open(label_path, 'r') as f:
        for line in f:
            label_data = line.strip().split()
            class_id = int(label_data[0])
            xmin = int(float(label_data[1]) * img.shape[1])
            ymin = int(float(label_data[2]) * img.shape[0])
            xmax = int(float(label_data[3]) * img.shape[1])
            ymax = int(float(label_data[4]) * img.shape[0])
            cv2.rectangle(img, (xmin, ymin), (xmax, ymax), (0, 255, 0), 2)
            cv2.putText(img, str(class_id), (xmin, ymin-10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
    cv2.imshow('Image with Bounding Boxes', img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

count = 0
for image_name in os.listdir(IMAGE_FOLDER):
    if image_name.endswith('.jpg') and count < 1:
        label_name = image_name.replace('.jpg', '.txt')
        image_path = os.path.join(IMAGE_FOLDER, image_name)
        label_path = os.path.join(LABEL_FOLDER, label_name)
        if os.path.exists(label_path):
            draw_bboxes(image_path, label_path)
            count += 1
