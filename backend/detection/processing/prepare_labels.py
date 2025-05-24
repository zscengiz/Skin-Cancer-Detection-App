import os
from detection.processing.constants import LABELS_PATH

if not os.path.exists(LABELS_PATH):
    os.makedirs(LABELS_PATH)
    print(f"Directory created: {LABELS_PATH}")
else:
    print(f"Directory already exists: {LABELS_PATH}")
