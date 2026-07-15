from flask import Flask, request, jsonify
import json
import os
from datetime import datetime

app = Flask(__name__)

# For storing the outages
OUTAGES_FILE = "data/outages.json"

# To create a directory for the data if it doesn't exist already
os.makedirs("data", exist_ok=True)

# Also initialize the Json file if it doesn't already exist
if not os.path.exists(OUTAGES_FILE):
    with open(OUTAGES_FILE, "w") as f:
        json.dump([], f)

@app.route("/log-outage", methods=["POST"])
def log_outage():
    """POST endpont to log a loadshedding outage."""
    try:
        data = request.get_json() # Get the JSON data from request

        if not data or "date" not in data or "time" not in data or "stage" not in data:
            return jsonify({
                "error": "Missing required fields: date, time, stage"
            }), 400

        # Create the outage record with a timestamp
        outage_record = {
            "id": len(load_outages()) + 1,
            "date": data["date"],
            "time": data["time"],
            "stage": data["stage"],
            "logged_at": datetime.now().isoformat()
        }

        # load the existing outages
        outages = load_outages()

        # Add a new outage
        outages.append(outage_record)

        # Save
        save_outages(outages)

        return jsonify({
            "message": "Outage logged successfully",
            "outage": outage_record
        }), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/outages", methods=["GET"])
def get_outages():
    """Retrieve all logged outages."""
    try:
        outages = load_outages()
        return jsonify({
            "total": len(outages),
            "outages": outages
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

def load_outages():
    """Load the outages from Json file"""
    try:
        with open(OUTAGES_FILE, "r") as f:
            return json.load(f)
    except:
        return []

def save_outages(outages):
    """Save to JSON file"""
    with open(OUTAGES_FILE, "w") as f:
        json.dump(outages, f, indent=2)

if __name__ == "__main__":
    # Run the app in debug mode
   app.run(debug=True, host="localhost", port=5000)

