#!/usr/bin/env bash
# Check a URL; send an SMS via curl-sms if it is down (at most one per hour).
# Usage: check-site.sh <url> <receiver>
# cron:  */5 * * * * /usr/local/bin/check-site.sh https://example.com/health +4915123456789
set -euo pipefail
: "${CURLSMS_API_KEY:?Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys}"
url="${1:?Usage: $0 <url> <receiver>}"
receiver="${2:?Usage: $0 <url> <receiver>}"

if curl -fsS --max-time 10 -o /dev/null "$url"; then
  exit 0
fi

# Same key within the hour = same SMS: the API returns the stored response instead of sending again.
key="down-$(printf '%s' "$url" | cksum | cut -d' ' -f1)-$(date -u +%Y%m%d%H)"
body="$url is down ($(date -u +%H:%MZ))"

curl -sS -X POST https://curl-sms.com/api/sms/send \
  -H "Authorization: Bearer $CURLSMS_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: $key" \
  -d "{\"receiver\":\"$receiver\",\"body\":\"$body\"}" >/dev/null
