"""Send an SMS and poll its status until it is final.

Usage:
    export CURLSMS_API_KEY=cs_test_…
    python wait_for_delivery.py

With a test key the status is simulated: queued -> sent -> delivered within ~20 s.
For production, prefer webhooks over polling: https://curl-sms.com/docs/webhooks
"""

from __future__ import annotations

import json
import os
import time
import urllib.request

BASE = "https://curl-sms.com"
FINAL = {"delivered", "failed", "expired", "canceled"}


def call(method: str, path: str, payload: dict | None = None) -> dict:
    request = urllib.request.Request(
        BASE + path,
        method=method,
        data=json.dumps(payload).encode() if payload is not None else None,
        headers={
            "Authorization": f"Bearer {os.environ['CURLSMS_API_KEY']}",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        return json.load(response)


sms = call("POST", "/api/sms/send", {"receiver": "+4915123456789", "body": "Status demo"})
print("sent request:", sms["id"], sms["status"])

deadline = time.monotonic() + 60
while sms["status"] not in FINAL and time.monotonic() < deadline:
    time.sleep(3)
    sms = call("GET", f"/api/sms/{sms['id']}")
    print("status:", sms["status"])

# "sent" is the reliable success state; "delivered" needs a network delivery report.
print("final:", sms["status"], sms["error_code"] or "")
