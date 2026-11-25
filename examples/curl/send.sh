#!/usr/bin/env bash
# Send one SMS with curl.
# Usage: CURLSMS_API_KEY=cs_test_… ./send.sh
set -euo pipefail
: "${CURLSMS_API_KEY:?Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys}"

curl -sS -X POST https://curl-sms.com/api/sms/send \
  -H "Authorization: Bearer $CURLSMS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"receiver":"+4915123456789","body":"Hello from curl-sms"}'
echo
