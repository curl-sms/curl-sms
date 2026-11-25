#!/usr/bin/env bash
# Send the same text to several receivers at a later time.
# The Idempotency-Key makes a retry after a timeout safe: nothing is sent twice.
# Usage: CURLSMS_API_KEY=cs_test_… ./send-many-scheduled.sh
set -euo pipefail
: "${CURLSMS_API_KEY:?Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys}"

# Tomorrow 08:00 UTC, RFC 3339 (GNU date; on macOS use: date -u -v+1d +%Y-%m-%dT08:00:00Z)
send_at=$(date -u -d tomorrow +%Y-%m-%dT08:00:00Z)

curl -sS -X POST https://curl-sms.com/api/sms/send \
  -H "Authorization: Bearer $CURLSMS_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: reminder-$(date -u +%Y%m%d)" \
  -d "{\"receivers\":[\"+4915123456789\",\"+4917612345678\"],
       \"body\":\"Maintenance starts in one hour.\",
       \"send_at\":\"$send_at\"}"
echo
