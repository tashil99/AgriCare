import os
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO
from PIL import Image
import io
import numpy as np
from google import genai
from dotenv import load_dotenv



# FastAPI app
app = FastAPI(title="YOLO Crop Disease Detection with Gemini Recommendations")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load YOLO model
MODEL_PATH = "C:/Middlesex/AgriCare/Agri-care-ai-model/trained-models/tomato_model_6/weights/best.pt"

model = YOLO(MODEL_PATH)

load_dotenv("config.env")

API_KEY = os.getenv("GEMINI_API_KEY")

# Caches (prevents repeated Gemini calls)
recommendation_cache = {}
symptoms_cache = {}
cause_cache = {}

# Bullet formatting helper
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

# Gemini client
client = genai.Client(api_key=API_KEY)

# Get Symptoms
def get_symptoms(disease_name: str, crop_name: str) -> str:

    key = f"{crop_name}__{disease_name}"

    if key in symptoms_cache:
        return symptoms_cache[key]

    prompt = f"""
    You are an experienced agricultural advisor helping farmers.

    Crop: {crop_name}
    Disease: {disease_name}

    Task:
    List the main visible symptoms of this disease in a simple and practical way.

    Requirements:
    - Use simple, farmer-friendly language
    - Focus ONLY on visible signs on the plant (especially leaves, stems, or fruits)
    - Avoid scientific terms or complex explanations
    - Do NOT include causes or treatments

    Formatting Rules (STRICT):
    - Use this bullet symbol EXACTLY: ●
    - Maximum 2 bullet points
    - Each bullet must be short (1 simple sentence)
    - Each bullet should describe a clear visible symptom

    Example output:
    ● Leaves develop dark brown spots with yellow edges  
    ● White or grey mold may appear on the underside of leaves  

    Output ONLY the bullet points.
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

# Get Cause
def get_cause(disease_name: str, crop_name: str) -> str:

    key = f"{crop_name}__{disease_name}"

    if key in cause_cache:
        return cause_cache[key]

    prompt = f"""
    You are an experienced agricultural advisor helping farmers.

    Crop: {crop_name}
    Disease: {disease_name}

    Task:
    Explain the most likely cause(s) of this disease in a simple and practical way that farmers can easily understand.

    Requirements:
    - Use simple, non-technical language
    - Focus on real-world causes (e.g., fungus, pests, humidity, watering issues, temperature, soil problems)
    - Avoid scientific names or complex terminology
    - Avoid long explanations

    Formatting Rules (STRICT):
    - Use this bullet symbol EXACTLY: ●
    - Maximum 2 bullet points
    - Each bullet must be short (1 simple sentence)
    - Each bullet should clearly describe the cause in plain language

    Example output:
    ● Caused by a fungal infection that spreads in wet and humid conditions  
    ● Can develop due to overwatering and poor air circulation around the plant  

    Output ONLY the bullet points.
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

# Get Treatment Recommendation
def get_recommendation(disease_name: str, crop_name: str) -> str:

    key = f"{crop_name}__{disease_name}"

    if key in recommendation_cache:
        return recommendation_cache[key]

    prompt = f"""
    You are an expert agricultural specialist.

    Crop: {crop_name}
    Disease: {disease_name}

    Task:
    Provide precise and practical treatment recommendations for farmers.

    Requirements:
    - Focus ONLY on fertilizers, nutrients, or chemical treatments relevant to this disease
    - Include exact dosage instructions (e.g., grams per liter, ml per liter, or per hectare)
    - Ensure recommendations are realistic and commonly used in agriculture
    - Avoid general advice (no "improve care" or "monitor plants")
    - Avoid explanations — ONLY actionable treatment steps

    Formatting Rules (STRICT):
    - Use this bullet symbol EXACTLY: ●
    - Maximum 4 bullet points
    - Each bullet MUST:
      - Start with the treatment name (e.g., "Copper-based fungicide")
      - Include dosage
      - Be concise (1–2 lines only)
    - DO NOT use numbering, dashes, or other symbols
    - DO NOT include headings or extra text

    Example format:
    ● Copper-based fungicide: Apply 2–3 g per liter of water every 7–10 days  
    ● Potassium fertilizer: Apply 50 kg per hectare to improve plant resistance  

    Output ONLY the bullet points.
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

# Prediction Endpoint
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

            symptoms = "Plant is healthy"
            cause = "No disease present."
            recommendation = "No treatment needed"

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