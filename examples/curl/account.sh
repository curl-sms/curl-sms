#!/usr/bin/env bash
# Show plan, included SMS left, balance and limits.
# Usage: CURLSMS_API_KEY=cs_test_… ./account.sh
set -euo pipefail
: "${CURLSMS_API_KEY:?Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys}"

curl -sS https://curl-sms.com/api/account \
  -H "Authorization: Bearer $CURLSMS_API_KEY"
echo
