"""Receive and verify curl-sms webhooks with Flask.

Usage:
    pip install flask
    export CURLSMS_WEBHOOK_SECRET=whsec_…
    flask --app python_flask run --port 8000

Add https://<your-host>/hooks/curl-sms under https://curl-sms.com/app/webhooks.
Docs: https://curl-sms.com/docs/webhooks
"""

from __future__ import annotations

import hashlib
import hmac
import os
import time

from flask import Flask, abort, request

app = Flask(__name__)
SECRET = os.environ.get("CURLSMS_WEBHOOK_SECRET", "")
seen: set[str] = set()  # use your database in production


def verify(secret: str, header: str, body: bytes, tolerance: int = 300) -> bool:
    parts = dict(p.split("=", 1) for p in header.split(",") if "=" in p)
    t, sig = parts.get("t", ""), parts.get("v1", "")
    if not t.isdigit() or not sig or abs(time.time() - int(t)) > tolerance:
        return False
    mac = hmac.new(secret.encode(), t.encode() + b"." + body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(mac, sig)


@app.post("/hooks/curl-sms")
def curl_sms_webhook():
    # Verify against the raw body, never re-serialized JSON.
    if not verify(SECRET, request.headers.get("X-CurlSMS-Signature", ""), request.get_data()):
        abort(400)

    event = request.get_json()
    if event["id"] in seen:  # delivery is at-least-once
        return "", 204
    seen.add(event["id"])

    if event["type"] == "sms.status_changed":
        data = event["data"]
        app.logger.info(
            "SMS %s is now %s %s", data["id"], data["status"], data.get("error_code", "")
        )
    return "", 204
