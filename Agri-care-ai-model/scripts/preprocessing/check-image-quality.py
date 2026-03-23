import os
import cv2
import numpy as np
from typing import Dict, List, Tuple


def check_and_clean_quality(
    image_dir: str,
    label_dir: str = None,
    min_size: Tuple[int, int] = (256, 256),
    max_aspect_ratio: float = 5.0,
    low_variance_thresh: float = 3.0,
    valid_ext: Tuple[str, ...] = (".jpg", ".jpeg", ".png"),
):

    issues: Dict[str, List[str]] = {
        "unreadable": [],
        "zero_size": [],
        "too_small": [],
        "extreme_aspect": [],
        "low_variance": [],
    }

    image_info = {}

    min_w, min_h = min_size
    total_files = 0

    print(f"\nScanning images in: {image_dir}\n")

    for root, _, files in os.walk(image_dir):
        for filename in files:

            if not filename.lower().endswith(valid_ext):
                continue

            path = os.path.join(root, filename)
            total_files += 1

            img = cv2.imread(path)

            if img is None:
                issues["unreadable"].append(path)
                continue

            h, w = img.shape[:2]

            image_info[path] = (w, h)

            if w == 0 or h == 0:
                issues["zero_size"].append(path)
                continue

            if w < min_w or h < min_h:
                issues["too_small"].append(path)

            ar = max(w / h, h / w)
            if ar > max_aspect_ratio:
                issues["extreme_aspect"].append(path)

            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            var = float(np.var(gray))

            if var < low_variance_thresh:
                issues["low_variance"].append(path)

    print(f"Total images checked: {total_files}\n")

    if not any(issues.values()):
        print("All images meet the quality standards.")
        return

    print("Image quality issues found:\n")

    for key, files in issues.items():
        if files:
            title = key.replace("_", " ").title()
            print(f"{title}: {len(files)}")

    print("\nAvailable issue types:")
    print("unreadable, zero_size, too_small, extreme_aspect, low_variance")

    choice = input("\nEnter issue types to delete (comma separated) or 'all': ").strip().lower()

    if choice == "all":
        issue_types_to_remove = list(issues.keys())
    else:
        issue_types_to_remove = [c.strip() for c in choice.split(",") if c.strip() in issues]

    files_to_delete = []

    for issue_type in issue_types_to_remove:
        for img_path in issues[issue_type]:
            files_to_delete.append((img_path, issue_type))

    if not files_to_delete:
        print("\nNo files found for the selected issue types.")
        return

    print(f"\n{len(files_to_delete)} files will be deleted\n")

    for i, (img_path, issue_type) in enumerate(files_to_delete, 1):

        w, h = image_info.get(img_path, (0, 0))

        if label_dir:
            label_path = os.path.join(
                label_dir,
                os.path.splitext(os.path.basename(img_path))[0] + ".txt"
            )
        else:
            label_path = img_path.replace("/images/", "/labels/").rsplit(".", 1)[0] + ".txt"

        print(f"{i}. Issue: {issue_type}")
        print(f"Image: {img_path} ({w}x{h})")
        print(f"Label: {label_path if os.path.exists(label_path) else label_path + ' (not found)'}\n")

    confirm = input(f"\nDelete these {len(files_to_delete)} images and labels? (y/n): ").lower()

    if confirm != "y":
        print("\nNo files were deleted.")
        return

    deleted_images = 0
    deleted_labels = 0

    print("\nDeleting files...\n")

    for img_path, _ in files_to_delete:

        if label_dir:
            label_path = os.path.join(
                label_dir,
                os.path.splitext(os.path.basename(img_path))[0] + ".txt"
            )
        else:
            label_path = img_path.replace("/images/", "/labels/").rsplit(".", 1)[0] + ".txt"

        if os.path.exists(img_path):
            os.remove(img_path)
            deleted_images += 1
            print(f"Deleted image: {img_path}")

        if os.path.exists(label_path):
            os.remove(label_path)
            deleted_labels += 1
            print(f"Deleted label: {label_path}")

    print("\n**** SUMMARY ****")
    print(f"Total images deleted: {deleted_images}")
    print(f"Total labels deleted: {deleted_labels}")


check_and_clean_quality(
    image_dir="C:/Middlesex/AgriCare/Agri-care-ai-model/dataset/train/images",
    label_dir="C:/Middlesex/AgriCare/Agri-care-ai-model/dataset/train/labels",
    min_size=(256, 256),
    max_aspect_ratio=10.0,
    low_variance_thresh=4.0,
)