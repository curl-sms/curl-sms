#!/usr/bin/env bash
# Check parts, encoding, price and whether the SMS would be allowed, without sending.
# Usage: CURLSMS_API_KEY=cs_test_… ./estimate.sh
set -euo pipefail
: "${CURLSMS_API_KEY:?Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys}"

curl -sS -X POST https://curl-sms.com/api/sms/estimate \
  -H "Authorization: Bearer $CURLSMS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"receiver":"+4915123456789","body":"Emoji use Unicode: 70 characters per part 👋"}'
echo
