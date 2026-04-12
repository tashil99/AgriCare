# AgriCare - A Tomato Disease Detection App with AI-Based Remedy Recommendation

## Description
AgriCare is an AI-based system that detects tomato leaf diseases using a YOLO deep learning model.  
It integrates a FastAPI backend with a Flutter mobile application to provide real-time predictions and treatment recommendations.

---

## Tech Stack
- Python (FastAPI, YOLOv8)
- Flutter (Mobile App)
- PyTorch
- Supabase

---

## How to Run the Project

### 1. Clone the Repository
```bash
git clone https://github.com/tashil99/AgriCare.git
```

### 2. Run the Backend (FastAPI)
Open the **Agri-care-ai-model** folder in PyCharm (or any IDE), then run:

```bash
python -m uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```

This will start the API server on port **8000**.

### 3. Run the Mobile Application (Flutter)
Open the **agri_care_app** folder in VS Code, then in the terminal:

```bash
cd agri_care_app
flutter clean
flutter pub get
flutter run
```

---

##  Important Notes
- Ensure that the **mobile device and backend server are connected to the same network**.
- For proper real-time detection and camera functionality, the application should be run on a **physical mobile device** rather than an emulator.

---

## API Endpoint

**POST /predict**

- Input: Image file (`file`)
- Output: Disease prediction with confidence score and recommendation

---

## Author
Tashil Boyro
