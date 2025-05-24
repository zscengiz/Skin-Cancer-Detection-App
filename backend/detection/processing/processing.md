# Skin Cancer Detection - Data Processing Pipeline

This document explains the order and usage of Python scripts under `backend/detection/processing/`. These scripts process segmentation masks into YOLO-format bounding boxes and visualize them on the original images.

Data: https://www.kaggle.com/datasets/surajghuwalewala/ham1000-segmentation-and-classification

Data Source: https://arxiv.org/abs/1803.10417

1. Create the labels directory (if it doesn't exist)
python backend/detection/processing/prepare_labels.py

2. Generate YOLO-format bounding box .txt files from mask images
python backend/detection/processing/convert_masks_to_labels.py

3. Visualize bounding boxes on top of original images
python backend/detection/processing/visualize_predictions.py

4. Manually view a single image and its labels (for debugging)
python backend/detection/processing/draw_single_image.py

