import os
from PIL import Image

def check_and_clean_small_images(image_dir, label_dir, min_width=256, min_height=256):

    small_images = []
    valid_images = []   # ✅ NEW

    total_files_checked = 0

    for file in os.listdir(image_dir):
        if file.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp')):
            total_files_checked += 1
            image_path = os.path.join(image_dir, file)

            try:
                with Image.open(image_path) as img:
                    width, height = img.size

                    if width < min_width or height < min_height:
                        small_images.append((width, height, file))
                    else:
                        valid_images.append((width, height, file))  # ✅ NEW

            except Exception as e:
                print(f"Error reading {file}: {e}")

    # ✅ SUMMARY
    print(f"\nTotal image files checked: {total_files_checked}")
    print(f"Images smaller than {min_width}x{min_height}: {len(small_images)}")
    print(f"Images >= {min_width}x{min_height}: {len(valid_images)}")  # ✅ NEW

    if not small_images:
        print("\nNo small images found.")
        return

    print("\nSmall images detected:")
    for width, height, filename in small_images[:20]:
        print(f" - {filename}: {width}x{height}")

    if len(small_images) > 20:
        print(f"...and {len(small_images) - 20} more.")

    choice = input(f"\nDelete these {len(small_images)} small images AND their labels? (y/n): ").strip().lower()

    if choice != 'y':
        print("\nNo files were deleted.")
        return

    deleted_images = 0
    deleted_labels = 0

    print("\nDeleting files...\n")

    for width, height, filename in small_images:

        img_path = os.path.join(image_dir, filename)
        label_path = os.path.join(label_dir, os.path.splitext(filename)[0] + ".txt")

        if os.path.exists(img_path):
            os.remove(img_path)
            deleted_images += 1
            print(f"Deleted image: {img_path}")

        if os.path.exists(label_path):
            os.remove(label_path)
            deleted_labels += 1
            print(f"Deleted label: {label_path}")

    print("\n**** FINAL SUMMARY ****")
    print(f"Images deleted: {deleted_images}")
    print(f"Labels deleted: {deleted_labels}")
    print(f"Remaining valid images: {len(valid_images)}")  # ✅ NEW


check_and_clean_small_images(
    image_dir="C:/Middlesex/AgriCare/Agri-care-ai-model/dataset/train/images",
    label_dir="C:/Middlesex/AgriCare/Agri-care-ai-model/dataset/train/labels"
)