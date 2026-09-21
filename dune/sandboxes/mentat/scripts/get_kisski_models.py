import requests
import json
import os

# Configuration
API_URL = "https://chat-ai.academiccloud.de/v1/models"
KEYS_FILE = os.path.expanduser("../.env")


def get_api_key(provider_prefix="KISSKI_API_KEY="):
    """Extracts the API key from the ../.env"""
    try:
        if not os.path.exists(KEYS_FILE):
            raise FileNotFoundError(f"Key file not found at {KEYS_FILE}")

        with open(KEYS_FILE, "r") as f:
            for line in f:
                if line.startswith(provider_prefix):
                    # Split by '=' and take the second part, stripping whitespace
                    return line.split("=", 1)[1].strip()

        raise ValueError(
            f"Provider '{provider_prefix}' not found in {KEYS_FILE}"
        )
    except Exception as e:
        print(f"Error reading key: {e}")
        exit(1)


def generate_enhanced_config():
    api_key = get_api_key()

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Accept": "application/json",
    }

    try:
        response = requests.get(API_URL, headers=headers)
        response.raise_for_status()
        data = response.json()

        models_config = {}

        for model in data.get("data", []):
            m_id = model.get("id")
            m_name = model.get("name")
            inputs = model.get("input", [])
            outputs = model.get("output", [])

            entry = {"name": m_name}

            # Mapping Logic
            if "image" in inputs:
                entry["visual"] = True

            if "thought" in outputs:
                entry["reasoning"] = True

            if "video" in inputs:
                entry["video"] = True

            models_config[m_id] = entry

        # Output formatted JSON
        with open("models.json", "w", encoding="utf-8") as ff:
            json.dump(models_config, ff, indent=2)

    except Exception as e:
        print(f"Error fetching models: {e}")


if __name__ == "__main__":
    generate_enhanced_config()
