from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO
from PIL import Image
import io
import numpy as np

# --------------------
# Gemini SDK
# --------------------
from google import genai

# --------------------
# FastAPI app
# --------------------
app = FastAPI(title="YOLO Crop Disease Detection with Gemini Recommendations")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------------------
# Load YOLO model
# --------------------
MODEL_PATH = "C:/Middlesex/AgriCare/Agri-care-ai-model/trained-models/tomato_model_6/weights/best.pt"

model = YOLO(MODEL_PATH)

# --------------------
# Gemini API Key
# --------------------
API_KEY = "AIzaSyAs3d_buwwvstb4KkCw92as6e7fJw-ZESs"

# --------------------
# Caches (prevents repeated Gemini calls)
# --------------------
recommendation_cache = {}
symptoms_cache = {}
cause_cache = {}

# --------------------
# Bullet formatting helper
# --------------------
def format_bullets(text: str) -> str:
    lines = text.split("\n")
    formatted = []

    for line in lines:
        line = line.strip()
        if not line:
            continue

        if line.startswith(("•", "-", "*")):
            line = "● " + line[1:].strip()

        if not line.startswith("●"):
            line = "● " + line

        formatted.append(line)

    return "\n".join(formatted)

# --------------------
# Gemini client
# --------------------
client = genai.Client(api_key=API_KEY)

# --------------------
# Get Symptoms
# --------------------
def get_symptoms(disease_name: str, crop_name: str) -> str:

    key = f"{crop_name}__{disease_name}"

    if key in symptoms_cache:
        return symptoms_cache[key]

    prompt = f"""
Crop: {crop_name}
Disease: {disease_name}

List the symptoms.

Rules:
- Use this bullet symbol exactly: ●
- Maximum 3 bullet points
"""

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt
        )

        symptoms = format_bullets(response.text.strip())

    except Exception as e:
        symptoms = f"Symptoms unavailable: {str(e)}"

    symptoms_cache[key] = symptoms
    return symptoms

# --------------------
# Get Cause
# --------------------
def get_cause(disease_name: str, crop_name: str) -> str:

    key = f"{crop_name}__{disease_name}"

    if key in cause_cache:
        return cause_cache[key]

    prompt = f"""
Crop: {crop_name}
Disease: {disease_name}

Explain the main cause of this disease in one short sentence.
"""

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt
        )

        cause = response.text.strip()

    except Exception as e:
        cause = f"Cause unavailable: {str(e)}"

    cause_cache[key] = cause
    return cause

# --------------------
# Get Treatment Recommendation
# --------------------
def get_recommendation(disease_name: str, crop_name: str) -> str:

    key = f"{crop_name}__{disease_name}"

    if key in recommendation_cache:
        return recommendation_cache[key]

    prompt = f"""
Crop: {crop_name}
Disease: {disease_name}

Provide treatment recommendations.

Rules:
- Use this bullet symbol exactly: ●
- Maximum 4 bullet points
"""

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt
        )

        recommendation = format_bullets(response.text.strip())

    except Exception as e:
        recommendation = f"Recommendation unavailable: {str(e)}"

    recommendation_cache[key] = recommendation
    return recommendation

# --------------------
# Prediction Endpoint
# --------------------
@app.post("/predict")
async def predict(file: UploadFile = File(...)):

    # Read uploaded image
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB")
    image_np = np.array(image)

    # Run YOLO detection
    results = model.predict(
        source=image_np,
        imgsz=700,
        conf=0.35
    )

    detections = []

    for box in results[0].boxes:

        cls_id = int(box.cls[0].item())
        conf = float(box.conf[0].item())
        class_name = str(model.names[cls_id])

        # Split crop and disease
        if "__" in class_name:
            crop_name, disease_name = class_name.split("__")
        else:
            crop_name, disease_name = "Unknown", class_name

        # Healthy leaf
        if "healthy" in class_name.lower():

            symptoms = "● Plant is healthy"
            cause = "No disease present."
            recommendation = "● No treatment needed"

        else:

            symptoms = get_symptoms(disease_name, crop_name)
            cause = get_cause(disease_name, crop_name)
            recommendation = get_recommendation(disease_name, crop_name)

        detections.append({
            "class": class_name,
            "confidence": conf,
            "symptoms": symptoms,
            "cause": cause,
            "recommendation": recommendation
        })

    return {"detections": detections}