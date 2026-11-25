// Send an SMS with Node.js 18+ built-in fetch (no dependencies).
//
// Usage:
//   export CURLSMS_API_KEY=cs_test_…
//   node send-sms.mjs "+4915123456789" "Hello from Node.js"
//
// Prefer a typed client? `npm install curl-sms`, see https://github.com/curl-sms/curl-sms-node
import { randomUUID } from 'node:crypto';

export async function sendSms(receiver, body, idempotencyKey = randomUUID()) {
  const key = process.env.CURLSMS_API_KEY;
  if (!key) throw new Error('Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys');

  const res = await fetch('https://curl-sms.com/api/sms/send', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
      'Accept-Language': 'en',
      // Same key + same body within 24 h never sends twice: safe to retry.
      'Idempotency-Key': idempotencyKey,
    },
    body: JSON.stringify({ receiver, body }),
    signal: AbortSignal.timeout(15_000),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(`${res.status} ${data.error.code}: ${data.error.message}`);
  return data;
}

const [receiver = '+4915123456789', text = 'Hello from Node.js'] = process.argv.slice(2);
const sms = await sendSms(receiver, text);
console.log(sms.id, sms.status, `${sms.segments} part(s)`, `EUR ${sms.price}`);
