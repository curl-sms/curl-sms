"""Send an SMS with the Python standard library only (no dependencies).

Usage:
    export CURLSMS_API_KEY=cs_test_…
    python send_sms.py "+4915123456789" "Hello from Python"

Prefer a client library? `pip install curl-sms`, see
https://github.com/curl-sms/curl-sms-python
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
import uuid

API = "https://curl-sms.com/api/sms/send"


def send_sms(receiver: str, body: str, idempotency_key: str | None = None) -> dict:
    key = os.environ.get("CURLSMS_API_KEY")
    if not key:
        raise SystemExit("Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys")
    request = urllib.request.Request(
        API,
        method="POST",
        data=json.dumps({"receiver": receiver, "body": body}).encode(),
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "Accept-Language": "en",
            # Same key + same body within 24 h never sends twice: safe to retry.
            "Idempotency-Key": idempotency_key or str(uuid.uuid4()),
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            return json.load(response)
    except urllib.error.HTTPError as exc:
        error = json.load(exc).get("error", {})
        raise RuntimeError(f"{exc.code} {error.get('code')}: {error.get('message')}") from None


if __name__ == "__main__":
    to = sys.argv[1] if len(sys.argv) > 1 else "+4915123456789"
    text = sys.argv[2] if len(sys.argv) > 2 else "Hello from Python"
    sms = send_sms(to, text)
    print(sms["id"], sms["status"], f"{sms['segments']} part(s)", f"EUR {sms['price']}")
