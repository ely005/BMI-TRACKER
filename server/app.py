"""
Local BMI Tracker API — http://localhost:51266/api
REST API with in-memory store for local development.
"""
import datetime
import hashlib
import json
import os
import random
import string
import uuid

from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# ---- In-memory store (replace with SQLite/Postgres as needed) ----

USERS: dict[str, dict] = {}
TOKENS: dict[str, str] = {}       # token -> user_id
BMI_RECORDS: dict[str, dict] = {}  # record_id -> record dict


# ---- Helpers ----


def _gen_token() -> str:
    return "tok_" + "".join(
        random.choices(string.ascii_lowercase + string.digits, k=32)
    )


def _is_auth() -> str | None:
    auth = request.headers.get("Authorization", "")
    if auth.startswith("Bearer "):
        token = auth[len("Bearer ") :]
        return TOKENS.get(token)
    return None


def _bmi(h: float, w: float) -> float:
    return round(w / (h / 100) ** 2, 2)


def _category(b: float) -> str:
    if b < 18.5:
        return "Underweight"
    if b < 25:
        return "Normal"
    if b < 30:
        return "Overweight"
    return "Obese"


def _user(user_id: str):
    return USERS.get(user_id)


def _record(user_id: str):
    """Return all BMI records for a given user."""
    return [r for r in BMI_RECORDS.values() if r["user_id"] == user_id]


def _record_or_404(record_id: str):
    rec = BMI_RECORDS.get(record_id)
    if rec is None:
        return None, 404
    return rec, 200


def _json(data, code=200):
    return jsonify(data), code


# ---- Auth Endpoints ----


@app.route("/api/auth/signup", methods=["POST"])
def signup():
    data = request.get_json(force=True)
    email = data.get("email", "")
    password = data.get("password", "")
    name = data.get("name", "")

    if not email or not password or not name:
        return _json({"error": "name, email, and password are required"}, 400)

    if email in [u["email"] for u in USERS.values()]:
        return _json({"error": "Email already registered"}, 409)

    user_id = str(uuid.uuid4())
    user = {
        "id": user_id,
        "email": email,
        "name": name,
        "password": password,  # demo only — hash in production
    }
    USERS[email] = user

    token = _gen_token()
    TOKENS[token] = user_id

    return _json(
        {
            "id": user_id,
            "email": email,
            "name": name,
            "token": token,
        },
        201,
    )


@app.route("/api/auth/login", methods=["POST"])
def login():
    data = request.get_json(force=True)
    email = data.get("email", "")
    password = data.get("password", "")

    user = USERS.get(email)
    if user is None or user["password"] != password:
        return _json({"error": "Invalid email or password"}, 401)

    token = _gen_token()
    TOKENS[token] = user["id"]

    return _json(
        {
            "id": user["id"],
            "email": user["email"],
            "name": user["name"],
            "token": token,
        },
        200,
    )


@app.route("/api/auth/logout", methods=["POST"])
def logout():
    uid = _is_auth()
    to_delete = [tok for tok, uid2 in TOKENS.items() if uid2 == uid]
    for tok in to_delete:
        del TOKENS[tok]
    return _json({"message": "Logged out"}, 200)


@app.route("/api/auth/me", methods=["GET"])
def me():
    uid = _is_auth()
    if uid is None:
        return _json({"error": "Unauthorized"}, 401)
    u = _user(uid)
    if u is None:
        return _json({"error": "Unauthorized"}, 401)
    return _json({"id": u["id"], "email": u["email"], "name": u["name"]}, 200)


# ---- BMI Records Endpoints ----


@app.route("/api/bmi-records", methods=["GET"])
def get_records():
    uid = _is_auth()
    if uid is None:
        return _json({"error": "Unauthorized"}, 401)
    records = _record(uid)
    records.sort(key=lambda r: r["created_at"], reverse=True)
    return _json(records)


@app.route("/api/bmi-records", methods=["POST"])
def create_record():
    uid = _is_auth()
    if uid is None:
        return _json({"error": "Unauthorized"}, 401)

    data = request.get_json(force=True)
    height_cm = float(data.get("height_cm", 0))
    weight_kg = float(data.get("weight_kg", 0))

    bmi_val = _bmi(height_cm, weight_kg)
    cat = data.get("category") or _category(bmi_val)

    now = datetime.datetime.now().isoformat()
    record_id = str(uuid.uuid4())
    record = {
        "id": record_id,
        "user_id": uid,
        "height_cm": height_cm,
        "weight_kg": weight_kg,
        "bmi_value": bmi_val,
        "category": cat,
        "notes": data.get("notes"),
        "created_at": now,
        "updated_at": now,
    }
    BMI_RECORDS[record_id] = record
    return _json(record, 201)


@app.route("/api/bmi-records/<record_id>", methods=["GET"])
def get_record_detail(record_id: str):
    uid = _is_auth()
    if uid is None:
        return _json({"error": "Unauthorized"}, 401)
    rec, code = _record_or_404(record_id)
    if rec is None:
        return _json({"error": "Not found"}, 404)
    if rec["user_id"] != uid:
        return _json({"error": "Forbidden"}, 403)
    return _json(rec, code)


@app.route("/api/bmi-records/<record_id>", methods=["PATCH", "PUT"])
def update_record(record_id: str):
    uid = _is_auth()
    if uid is None:
        return _json({"error": "Unauthorized"}, 401)
    rec, code = _record_or_404(record_id)
    if rec is None:
        return _json({"error": "Not found"}, 404)
    if rec["user_id"] != uid:
        return _json({"error": "Forbidden"}, 403)

    data = request.get_json(force=True)

    if "height_cm" in data and "weight_kg" in data:
        rec["height_cm"] = float(data["height_cm"])
        rec["weight_kg"] = float(data["weight_kg"])
        if "bmi_value" not in data and "category" not in data:
            rec["bmi_value"] = _bmi(rec["height_cm"], rec["weight_kg"])
            rec["category"] = _category(rec["bmi_value"])

    if "bmi_value" in data:
        rec["bmi_value"] = float(data["bmi_value"])
    if "category" in data:
        rec["category"] = data["category"]
    if "notes" in data:
        rec["notes"] = data["notes"]

    rec["updated_at"] = datetime.datetime.now().isoformat()
    return _json(rec, 200)


@app.route("/api/bmi-records/<record_id>", methods=["DELETE"])
def delete_record(record_id: str):
    uid = _is_auth()
    if uid is None:
        return _json({"error": "Unauthorized"}, 401)
    rec, code = _record_or_404(record_id)
    if rec is None:
        return _json({"error": "Not found"}, 404)
    if rec["user_id"] != uid:
        return _json({"error": "Forbidden"}, 403)
    del BMI_RECORDS[record_id]
    return _json({"message": "Deleted"}, 204)


# ---- Run ----

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=51266, debug=True)
