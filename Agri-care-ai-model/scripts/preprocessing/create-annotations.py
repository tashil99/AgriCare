import os
import shutil

def annotate_single_class(class_folder_path, output_split_path, class_id, copy_images=True):

    images_dir = os.path.join(output_split_path, "images")
    labels_dir = os.path.join(output_split_path, "labels")

    os.makedirs(images_dir, exist_ok=True)
    os.makedirs(labels_dir, exist_ok=True)

    print(f" Processing: {class_folder_path}")

    for img_name in os.listdir(class_folder_path):

        if not img_name.lower().endswith((".jpg", ".jpeg", ".png")):
            continue

        src_img = os.path.join(class_folder_path, img_name)
        dst_img = os.path.join(images_dir, img_name)

        # Copy or move
        if copy_images:
            shutil.copy(src_img, dst_img)
        else:
            shutil.move(src_img, dst_img)

        # Create label
        label_name = os.path.splitext(img_name)[0] + ".txt"
        label_path = os.path.join(labels_dir, label_name)

        with open(label_path, "w") as f:
            f.write(f"{class_id} 0.5 0.5 1 1")

    print("Done!")

annotate_single_class(
    class_folder_path="C:/Middlesex/AgriCare/Agri-care-ai-model/PlantDoc/test/Tomato mold leaf",
    output_split_path="C:/Middlesex/AgriCare/Agri-care-ai-model/dataset/valid/",
    class_id=4
)