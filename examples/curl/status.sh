#!/usr/bin/env bash
# Query the status of an SMS by its id (from the send response).
# Usage: CURLSMS_API_KEY=cs_test_… ./status.sh 01JDQ8M3V6R1T5ZK2X9N4C7B0A
set -euo pipefail
: "${CURLSMS_API_KEY:?Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys}"
id="${1:?Usage: $0 <sms-id>}"

curl -sS "https://curl-sms.com/api/sms/$id" \
  -H "Authorization: Bearer $CURLSMS_API_KEY"
echo
